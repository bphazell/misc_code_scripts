require 'csv'
require 'mechanize'

agent = Mechanize.new

input_csv = ARGV[0]
output_csv = input_csv.gsub(".csv","_CHECKED.csv")
column = "YOUR_COL	UMN_NAME"

reader = CSV.readlines(input_csv, headers: true)

# save input headers
input_headers = reader.first.headers

# make an array for output headers (change as needed)
output_headers = input_headers + ["valid?"]

# open output file to write to
CSV.open(output_csv, 'w', headers: output_headers, write_headers: true) do |new_csv|
# go through each row of the input_csv
  reader.each do |row|
    valid = true
    url = row[column]
    begin
      puts "Checking URL: #{url}"
      page = agent.get(url)
    rescue => e
      valid = false
      p "this don't work: #{url}"
    end
    new_csv << input_headers.map { |h| row[h] } + [valid]
  end
end