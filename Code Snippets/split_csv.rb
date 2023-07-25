# Split CSV based on Attribute

# load gem
require 'csv'

# save name of input csv
input_CSV = ARGV[0]

# save name of column to do splitting on
finder = ARGV[1]

# save csv as CSV object
read_csv = CSV.readlines(input_CSV, headers:true)

# save headers
input_headers = read_csv.first.headers

# save output headers
output_headers = input_headers

# create a hash of the output headers with their index
headhash = Hash[output_headers.map.with_index.to_a]

# column saves the indices for each instance of finder's value
column = headhash[finder]

# add headers to each csv that is being created based on 
read_csv.each do |row|
	# name each output csv
	output_csv = "#{row[column]}_after_split.csv"
	
	# write headers to each output csv
	CSV.open(output_csv, 'w', write_headers: true) do |x|
		x << output_headers
	end
end

# add data to each csv
read_csv.each do |row|
	# pick which output csv you're writing to
	output_csv = "#{row[column]}_after_split.csv"
	
	# write the data to the output csv
	CSV.open(output_csv, 'a+') do |x|
		x << row
	end
end