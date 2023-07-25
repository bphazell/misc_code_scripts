
require 'csv'
input_file = ARGV[0]

reader = CSV.readlines(input_file, :headers=> true)
input_headers = reader.headers

file_name = "#{input_file.gsub(/(\.csv)/,"")}"
output_csv1 = "#{file_name}_for_next_job.csv"
output_csv2 = "#{file_name}_for_packaging.csv"

BAD_HEADERS = ["_golden", "_canary", "_unit_state", "_trusted_judgments","_unit_id","_last_judgment_at", "_gold", "_gold_reason",":confidence"]

def good_headers?(headers)
	BAD_HEADERS.each do |bad_header|
		return true if headers.include?(bad_header)
	end
	return false
end

def swap_good_header(headers)
	headers.each_with_object([]) do |input_headers, output_headers|
		if input_headers == "contact_url_text_add_worker_input"
			output_headers << "contact_url_cf"
		else
			output_headers << input_headers
	end
end
end

input_headers.reject!{|x| good_headers?(x)}
output_headers = swap_good_header(input_headers)

rows_read = 0
rows_to_pack = 0
rows_to_next_job = 0 

CSV.open(output_csv1, "w", headers:output_headers, :write_headers=> true) do |next_job|
	CSV.open(output_csv2,"w", headers:output_headers, :write_headers=>true) do |pack|

		CSV.foreach(input_file, headers:true) do |row|
			rows_read += 1
			for_output = []
			input_headers.each do |head|
				for_output << row[head]
			end

			if (row["url_cf_verified2"] == "yes_verified") && (row["contact_found"] == "yes") && (row["contact_url_text_add_worker_input"] != nil)
				rows_to_next_job += 1
				next_job << for_output

			else
				rows_to_pack += 1
				pack << for_output
			end



		end
	end
end

puts "Rows Read #{rows_read}"
puts "Rows To Packaging #{rows_to_pack}"
puts "Rows For Next Job #{rows_to_next_job}"


