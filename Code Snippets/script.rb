require 'csv'
require 'json'

AUTH_KEY = 'YOUR_AUTH_KEY'
in_csv = ARGV[0]
out_csv = in_csv.gsub(".csv","_TITLED.csv")
job = ""
count = 1
headers = ["job_id","pn","date","title"] #Or whatever headers you have or want


CSV.open(out_csv,'w',:headers=>headers,:write_headers=>true) do |row|
	CSV.foreach(in_csv, :headers=>true) do |row2|
		job = row2["job_id"]
		x = `curl https://api.crowdflower.com/v1/jobs/#{job}.json?key=#{AUTH_KEY}`

		job_title = JSON.parse(x)["title"]
		puts job_title
		row << [job,row2["pn"],row2["date"],job_title]
		puts "this is the #{count} job you've done"
		count += 1
	end
end