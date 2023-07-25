# load gem
require 'csv'

# save name of csv file
input_csv = ARGV[0]

# read in csv as CSV object
reader = CSV.readlines(input_csv, :headers => true)

# save input headers
input_headers = reader.first.headers

# make an array for output headers (change as needed)
output_headers = input_headers + ["new_header1_cf", "new_header2_cf", "new_header3_cf"]

# open output file to write to
CSV.open("output.csv", 'w', :headers => output_headers, :write_headers => true) do |new_csv|
	# go through each row of the input_csv
	reader.each do |row|

        p row
        
        ### Everything after this can be modified to fit your actual post-processing
        ### needs.

    	if row["found_phone_yn"].to_s == "yes" and row["phone_numbers"].to_s != ""
    		phone_numbers_cf = row["phone_numbers"]
    	else
    		phone_numbers_cf = ""
    	end

    	new_header1_cf = phone_numbers_cf.split("\n")[0].to_s
    	new_header2_cf = phone_numbers_cf.split("\n")[1].to_s
    	new_header3_cf = phone_numbers_cf.split("\n")[2].to_s
    	
    	###### Change everything above

		# write to new csv (change headers as needed)
		new_csv << input_headers.map { |h| row[h] } + [new_header1_cf, new_header2_cf, new_header3_cf]
		
    end
end