require 'fastercsv'

module EasyIO
  def write_file(file)
    File.open(file, "w") { |f| yield f }
  end

  def write_csv(file)
    FasterCSV.open(file, "w") { |csv| yield csv }
  end

  def open_csv(file, options = {})
    FasterCSV.new(file, default_options(options)) { |csv| yield csv }
  end  
  
  def each_row(file, options = {})
    if options.delete(:source) == :s3
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
    else
      open_csv(file, options) do |csv|
        csv.each do |row|
          yield row
        end
      end
    end
  end
  
  def default_options(options)
    { :col_sep => ",", :headers => true, :header_converters => :symbol }.merge(options)
  end
end