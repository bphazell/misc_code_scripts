require 'open-uri'
require 'net/http'
require 'csv'

def remote_file_exists?(url)
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
end

input_csv = ARGV[0]

column = "YOUR_COLUMN_NAME"

reader = CSV.readlines(input_csv, headers: true)

# save input headers
input_headers = reader.first.headers

# make an array for output headers (change as needed)
output_headers = input_headers + ["valid?"]

# open output file to write to
CSV.open("output.csv", 'w', headers: output_headers, write_headers: true) do |new_csv|
	# go through each row of the input_csv
	reader.each do |row|
		if remote_file_exists?(row[column])
			valid = true
		else
			valid = false
		end
		new_csv << input_headers.map { |h| row[h] } + [valid]
	end
end