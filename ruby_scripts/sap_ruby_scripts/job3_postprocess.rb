
require 'csv'

input_file = ARGV[0]

input_name = "#{input_file.gsub(/(\.csv)/,"")}"

puts input_name

output_csv1 = "#{input_name}_for_next_job.csv"
output_csv2 = "#{input_name}_for_packaging.csv"

reader = CSV.readlines(input_file, :headers=>true)
input_headers = reader.headers

BAD_HEADERS = ["_golden", "_canary", "_unit_state", "_trusted_judgments","_unit_id","_last_judgment_at", "_gold", "_gold_reason",":confidence"]

def good_headers(header)
	BAD_HEADERS.each do |bad_header|
	return true if bad_header.include?(header)
end
return false

end

input_headers.reject!{|x| good_headers(x)}

rows_read = 0
rows_to_pack = 0
rows_to_next_job = 0 


CSV.open(output_csv1, "w", headers:input_headers, :write_headers=>true) do |next_job|
	CSV.open(output_csv2, "w", headers:input_headers, :write_headers=>true) do |pack|
		CSV.foreach(input_file, headers:true) do |row|
			for_output = []
			rows_read +=1
				input_headers.each do |head|
					for_output << row[head]
				end
			if (row["andress_found_yn"] == "yes") && (row["andress_match_yn"] == "yes") && (row["pasted_address"] != nil)
				next_job << for_output
				rows_to_next_job +=1
			else
				pack << for_output
				rows_to_pack +=1
			end

		end
	end
end

puts "Rows Read #{rows_read}"
puts "Rows To Packaging #{rows_to_pack}"
puts "Rows For Next Job #{rows_to_next_job}"