require 'fastercsv'

class EasyIO
  DefaultOptions = { :col_sep => ",", :headers => true, :header_converters => :symbol }
  DefaultSource = ENV["RAILS_ENV"] == "production" ? :s3 : :file_system
  
  def self.default_s3_bucket(bucket)
    @default_bucket = bucket
  end
  
  def self.write_file(file)
    File.open(file, "w") { |f| yield f }
  end

  def self.write_csv(file)
    FasterCSV.open(file, "w") { |csv| yield csv }
  end

  def self.open_csv(file, options = {})
    FasterCSV.open(file, default_options(options)) { |csv| yield csv }
  end  
  
  def self.file_source(options = {})
    options.delete(:source) || DefaultSource
  end
  
  def self.each_row(file, options = {})
    if file_source(options) == :s3
      require 'aws/s3'
      require 'open-uri'
      url = AWS::S3::S3Object.url_for(file, get_s3_bucket(options))
      open(url) do |f|
        f.each_line do |line|
          FasterCSV.parse(line, default_options(options)) do |row|
            yield row
          end
        end
      end
    else
      open_csv(file, options) do |csv|
        csv.each do |row|
          yield row
        end
      end
    end
  end
    
  def self.get_s3_bucket(options = {})
    options.delete(:bucket) || @default_bucket
  end
  
  def self.default_options(options)
    DefaultOptions.merge(options)
  end
end