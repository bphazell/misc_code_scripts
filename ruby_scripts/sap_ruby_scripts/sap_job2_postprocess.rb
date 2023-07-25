
require 'csv'

input_file = ARGV[0]
output_name = "#{input_file.gsub(/(\.csv)/,"")}"

output_csv1 = "#{output_name}_postprocessed.csv"
output_csv2 = "#{output_name}_for_pack.csv"


reader = CSV.readlines(input_file, :headers=>true)

original_headers = reader.headers


headers_to_remove = ["_golden", "_canary", "_unit_state", "_trusted_judgments","_unit_id","_last_judgment_at"]


output_headers = []

original_headers.each do |head|
	if !(headers_to_remove.include?(head) or head.end_with?("_gold") or head.end_with?("_gold_reason") or head.include?(":confidence"))
		output_headers << head 

	end
end


sub_out_col = "contact_url_text_add_worker_input"
sub_in_col = "contact_url_cf"

# output_headers.reject!{ |x| x == sub_out_col }
# output_headers << sub_in_col



# output_headers.each_with_index do |x, i|
# 	if x != sub_out_col
# 		output_headers[i] = x
# 		else
# 			output_headers[i] = sub_in_col
			
# 	end
# end

# puts output_headers

# new_headers = []
# counter = 0
# output_headers.each do |x| 
# 	counter += 1
# 	if x != sub_out_col
# 		new_headers[counter] = x
# 	else
# 	new_headers[counter] = "contact_url_cf"	
# 	end
# end
# puts new_headers

new_headers = []

output_headers.each do |name|
	if name != sub_out_col
		new_headers << name
	end
end
mod_headers = new_headers
new_headers = new_headers + ["contact_url_cf"]




rows_read = 0
rows_to_pack = 0
rows_to_next_job = 0

CSV.open(output_csv1, "w", headers:new_headers, :write_headers=>true) do |next_job|
	CSV.open(output_csv2, "w", headers:new_headers, :write_headers=>true) do |pack|
		reader.each do |row|
			rows_read +=1
			if (row["url_cf_verified2"] == "yes_verified") && (row["contact_found"] == "yes") && (row["contact_url_text_add_worker_input"] != "")
				rows_to_next_job +=1

				for_output = []
				mod_headers.each do |name| 
					for_output << row[name]			
			end
			url_fix = row["contact_url_text_add_worker_input"]
			url_fix = url_fix.gsub("http://", "").prepend("http://")
			for_output << url_fix	
			next_job << for_output
				
			end

			if row["url_cf_verified2"] == "no" 
				rows_to_pack += 1
				for_output = []
				mod_headers.each do |name|
				for_output << row[name]
			end
			pack << for_output
			end

			if row["url_cf_verified2"] == "yes_verified" and row["contact_found"] == "no"
				rows_to_pack += 1
				for_output = []
				mod_headers.each do |name|
					for_output << row[name]

				end

				pack << for_output
			end

end
end
end


puts "rows read #{rows_read}"
puts "rows to next job #{rows_to_next_job}"
puts "rows to packaging #{rows_to_pack}"

