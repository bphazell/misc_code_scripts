# load gems
require 'csv'

suffix = "addhttp"
column_to_check = "INPUT_COLUMN"
column_to_write = "OUTPUT_COLUMN"

# the input file
input_csv = ARGV[0]

if input_csv == nil or input_csv.length < 1
  raise "Usage: ruby #{__FILE__} csv1.csv"
end

# the output file name is the input file, but append new name to end
# gsub removes .csv and appends _addhttp.csv
output_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix}.csv"

# read in the input csv
reader = CSV.readlines(input_csv, :headers => true)

# save the headers
headers = reader.first.headers

output_headers = headers + [column_to_write]

rows_written = 0

# open output file to write to
CSV.open(output_csv, "w", :headers => output_headers, :write_headers => true) do |newCSV|
	# for each row of the input_csv
	reader.each do |row|
		my_column_to_write = ""
		if row["INPUT_COLUMN"].to_s != ""
			if row["INPUT_COLUMN"].include?("http")
				# save it to this header
				my_column_to_write = row["INPUT_COLUMN"]
			else # otherwise, add it to the website, and save
				my_column_to_write = "http://" + row["INPUT_COLUMN"].to_s.strip
			end	
			# write the headers to the new csv for each column
			# map does the same thing to each column in a row
			rows_written += 1
			newCSV << headers.map{ |h| row[h] } + [my_column_to_write]
		else
			p "no website"
			my_column_to_write = row["url"]
			rows_written += 1
			newCSV << headers.map{ |h| row[h] } + [my_column_to_write]
		end
	end
end

p "Rows written: " + rows_written.to_s