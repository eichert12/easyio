require 'fastercsv'

class EasyIO
  DefaultOptions = { :col_sep => ",", :headers => true, :header_converters => :symbol }
  DefaultSource = ENV["RAILS_ENV"] == "production" ? :s3 : :file_system
  
  def self.write_file(file)
    File.open(file, "w") { |f| yield f }
  end

  def self.write_csv(file)
    FasterCSV.open(file, "w") { |csv| yield csv }
  end

  def self.open_csv(file, options = {})
    FasterCSV.new(file, default_options(options)) { |csv| yield csv }
  end  
  
  def self.file_source(options = {})
    options.delete(:source) || DefaultSource
  end
  
  def self.each_row(file, options = {})
    if file_source(options) == :s3
      load_from_s3(file, options, &block)
    else
      open_csv(file, options) do |csv|
        csv.each do |row|
          yield row
        end
      end
    end
  end
  
  def self.load_from_s3(file, options = {})
    require 'aws/s3'
    require 'open-uri'
    url = AWS::S3::S3Object.url_for(file, options.delete(:bucket))
    open(url) do |f|
      f.each_line do |line|
        FasterCSV.parse(line, default_options(options)) do |row|
          yield row
        end
      end
    end
  end
  
  def self.default_options(options)
    DefaultOptions.merge(options)
  end
end