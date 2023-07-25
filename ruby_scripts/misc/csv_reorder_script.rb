# Re-order columns in csv

# load gems
require 'csv'
require 'facets'

# define variables
suffix = "reordered"

# the input file is the first argument (the csv name, e.g., "a123127.csv")
input_csv = ARGV[0]

if input_csv == nil or input_csv.length < 1
  raise "Usage: ruby #{__FILE__} csv1.csv"
end

# the output file name is the input file, but append new name to end
output_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix}.csv"

# read in the input csv and save headers
read_csv = CSV.readlines(input_csv, headers: true)
input_headers = read_csv.first.headers
header_numbers = []

# prompt user
prompt = "Enter here >> "
puts "------------------------------"

puts "These are your current headers"
input_headers.each_with_index do |h,i|
	puts "[#{i+1}] #{h}"
	header_numbers.push i+1
end
puts "------------------------------"

puts "Type in the order you want, separating header numbers with commas: "
print prompt
#7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,24,27,30,31,1,5,6
header_order = STDIN.gets.chomp!
puts "This is the order you entered: "

# normalize user input
header_order = header_order.gsub(' ', '').split(',')

# convert strings to numbers
header_order = header_order.collect{ |s| s.to_i }
p header_order

# Make sure the input entered by the user makes sense
output_headers = []

if header_order.include? 0
	raise "Order contained strings. Aborting script."

# check whether any of the columns are missing or there are extra columns
elsif header_order.frequency != header_numbers.frequency
	p "The order you entered doesn't match the frequency of items in the original list. Are you sure you want to continue? (y/n)"
	print prompt
	confirmation = STDIN.gets.chomp!
	if confirmation == "n"
		raise "Your wish is my command. Aborting script."
	else
		p "Okay, I warned you!"
	end
end

# everything checks out
# reorder the headers
# we use header_order as the index to select items in input_headers
# we have to subtract 1 from h because ruby begins indexing at 0
output_headers = header_order.map { |h| input_headers[h-1] }
p output_headers


CSV.open(output_csv, 'w', headers: output_headers, write_headers: true) do |new_csv|
	read_csv.each do |row|
		new_csv << output_headers.map{ |h| row[h] }
	end
end

puts "------------------------------"
puts "#{output_csv} successfully written! Now go make sure it came out correctly."