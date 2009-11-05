def write_file(file)
  File.open(file, "w") { |f| yield f }
end

def write_csv(file)
  FasterCSV.open(file, "w") { |csv| yield csv }
end

def open_csv(file, options = {})
  options = { :col_sep => ",", :headers => true, :header_converters => :symbol }.merge(options)
  FasterCSV.open(file, options) { |csv| yield csv }
end  

def each_row(file, options = {})
  open_csv(file, options) do |csv|
    csv.each do |row|
      yield row
    end
  end
end
