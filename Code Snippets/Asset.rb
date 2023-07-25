# load gem
require 'csv'

# save name of csv file
input_csv = ARGV[0]
suffix = "MY_SUFFIX"
output_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix}.csv"

# read in csv as CSV object
reader = CSV.readlines(input_csv, :headers => true)

# save input headers
input_headers = reader.first.headers

# make an array for output headers (change as needed)
output_headers = input_headers + ["NEW_COLUMN"]

# open output file to write to
CSV.open(output_csv, 'w', :headers => output_headers, :write_headers => true) do |new_csv|
	# go through each row of the input_csv
	reader.each do |row|

        NEW_COLUMN_VAR = row["COLUMN_1"].to_s + ", " + row["COLUMN_2"].to_s + ", " + row["COLUMN_3"].to_s
        NEW_COLUMN_VAR = "#{location.gsub(/, , /, ", ")}"

        # write to new csv
        new_csv << input_headers.map { |h| row[h] } + [NEW_COLUMN_VAR]

    end
end