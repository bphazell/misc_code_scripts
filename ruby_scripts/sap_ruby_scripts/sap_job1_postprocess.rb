
require 'csv'

input_file = ARGV[0]

#remove csv from source file
output_name = "#{input_file.gsub(/(\.csv)/,"")}"

suffix1 = "postprocessed"
suffix2 = "to_packaging"

job_number = input_file.gsub(/\D/,"")

#create names for csv files
output_csv1 = "#{output_name}_#{suffix1}.csv"
output_csv2 = "#{output_name}_#{suffix2}.csv"

reader = CSV.readlines(input_file, :headers=> true)

input_headers = reader.first.headers

headers_to_remove = ["_golden", "_canary", "_unit_state", "_trusted_judgments","_unit_id","_last_judgment_at"]
headers_first_row = []

#input_headers = input_headers + ["url_cf"]

input_headers.each do |head|
	if !(headers_to_remove.include?(head) or head.end_with?("gold") or head.end_with?("_gold_reason") or head.include?(":confidence"))
		headers_first_row << head
	end
end



 headers_mod = headers_first_row + ["url_cf"]

rows_for_next_job = 0
rows_for_packaging = 0
rows_read = 0


 CSV.open(output_csv1, 'w', :headers=>headers_mod, :write_headers=>true ) do |next_job|
 	CSV.open(output_csv2, 'w', :headers=>headers_mod, :write_headers=>true ) do |pack|
 		reader.each do |row|
 			for_output = []
 			rows_read +=1
 			
 			# Next Job: URL Verified
 			if row["url_verified"] == "yes_verified"
 				headers_first_row.each do |name|
 					for_output << row[name]
 				end
 				fix_url = row["url_address"]
 				fix_url = fix_url.downcase!.gsub("http://","").prepend("http://")
 				for_output << fix_url
 				next_job << for_output
 				rows_for_next_job +=1

 			# Next Job: URL Unverified Found
			elsif row["url_verified"] == "no" and row["url_unverified_found"] == "yes_corrected"
				headers_first_row.each do |name|
					for_output << row[name]
				end
				fix_url = row["url_unverified_text_worker_input"]
				fix_url = fix_url.gsub("http://", "").prepend("http://")
				for_output << fix_url
				next_job << for_output
				rows_for_next_job +=1
			# Pack: URL Unverified Not Found
			elsif row["url_verified"] == "no" and row["url_unverified_found"] == "no"
				headers_first_row.each do |name|
					for_output << row[name]
				end 
				pack << for_output
				rows_for_packaging +=1
			# Next Job: URL Found
			elsif row["url_found"] == "yes_corrected"
				headers_first_row.each do|name|
					for_output << row[name]
				end
				fix_url = row["url_found_text_worker_input"]
				fix_url = fix_url.gsub("http://","").prepend("http://")
				for_output << fix_url
				next_job << for_output
				rows_for_next_job +=1
			# Pack: URL Not Found
			elsif row["url_found"] == "no"
				headers_first_row.each do|name|
					for_output << row[name]
				end
				pack << for_output
				rows_for_packaging += 1



 			end

 		end


 	end
 end

p "Rows Read #{rows_read}"
p "Rows For Packaging #{rows_for_packaging}"
p "Rows For Next Job #{rows_for_next_job}"

 			