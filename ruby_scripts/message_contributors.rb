
require "awesome_print"
require 'csv'

API_KEY = 'MDyi9b331-G29XDxf3xn'
CONTRIBUTOR_CSV = ARGV[0]


def message_contributors(worker_id, job_id, message_to_worker)
	 `curl -X POST --data-urlencode "message=#{message_to_worker}" https://api.crowdflower.com/v1/jobs/#{job_id}/workers/#{worker_id}/notify.json?key=#{API_KEY}`
end


CSV.foreach(CONTRIBUTOR_CSV, headers: true) do |row|
	worker_id = row["worker_id"]
	job_id = row["job_id"]
	message_to_worker = row["message"]
	message = message_contributors(worker_id, job_id, message_to_worker)
	ap message
	sleep 2
end


