
require "csv"

file = ARGV[0] 

file = File.read(file)

array = file.split("\n\n")

output = []


CSV.open("yay_we_did_it_on_our_first_try.csv", "w", write_headers: false) do |csv|
	array.each.with_index(1) do |v,i|
		output << v

		if i % 3 == 0
			csv << output
			output = []

		end


end

end 

