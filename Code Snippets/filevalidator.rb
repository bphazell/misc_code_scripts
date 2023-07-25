require 'csv'

class FileValidator
  @file
  @headers

  def initialize
    @file = nil
    @headers = nil
  end

  def file=(file)
    @file = file
    raise "A csv file does not exist at the following location: #{file}" if !self.file_exists?
  end

  def file
    @file
  end
  
  # probably also want a method that tests if it is a valid csv
  def file_exists?
    FileTest.exist?(@file)
  end

  def duplicate_headers
    self.headers
    return @headers.length != @headers.uniq.length
  end

  def headers
    if @headers.nil?
      CSV.open(@file,'r',:headers=>true) do |csv|
        @headers = csv.first.headers
        csv.rewind
      end
    end
    @headers
  end
end