require 'json'
require 'csv'

lrnr_auth_user = "doublepass" 
lrnr_auth_pwd = "blahs4blahs5ake"
resource = "http://lrnr.crowdflower.com/text/spelling.json" 

input_csv = ARGV[0]
suffix = "spellchecked"
output_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix}.csv"

# read in csv as CSV object
p "Reading in csv...this may take a while..."
reader = CSV.readlines(input_csv, :headers => true)

# save input headers
input_headers = reader.first.headers
output_headers = input_headers + ["fail"]

rows_written = 0
rows_read = 0

# open output csv
CSV.open(output_csv, 'w', headers: output_headers, write_headers: true) do |new_csv|
	reader.each do |row|

		rows_read += 1
		if rows_read % 5 == 0 then p "Rows read: #{rows_read}" end

		content = row["child"].gsub(/'/,"U+0027") # json encode apostrophes

		# -u: Specify the user name, password and optional login options to use for server authentication
		# --data-urlencode: (HTTP) This posts data, similar to the other --data options with the exception that this performs URL-encoding
		# -X: (HTTP) Specifies a custom request method to use when communicating with the HTTP server
		response = `curl -X GET -u '#{lrnr_auth_user}':'#{lrnr_auth_pwd}' --data-urlencode 'text=#{content}' '#{resource}'`

		result = JSON.parse(response)

		fail = result["case_insensitive_spelling_error_rate"] > 0

		new_csv << input_headers.map { |h| row[h]} + [fail]
		rows_written += 1

	end
end

p "Rows read: #{rows_read}"
p "Rows written: #{rows_written}"