require 'csv'
require 'awesome_print'

API_KEY = "API KEY"
input_csv = ARGV[0]

def change_row(job_id, row_id)
	ap "updating row #{row_id} in job #{job_id}"
	%x(curl -X PUT --data-urlencode 'unit[state]=canceled' https://api.crowdflower.com/v1/jobs/#{job_id}/units/#{row_id}.json?key=#{API_KEY})
end

CSV.foreach(input_csv, headers:true) do |row|
	 response = change_row(row["job_id"], row["row_id"])
	 ap response
end