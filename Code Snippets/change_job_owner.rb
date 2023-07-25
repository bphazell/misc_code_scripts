require 'csv'
require 'rubygems'

def update_owner(job_id, user_email, auth_key)
  `curl -X PUT --data-urlencode 'job[owner_email]=#{user_email}' 'https://make.crowdflower.com/jobs/#{job_id}/settings/general.json?key=#{auth_key}'`
end

#the csv should have column with header "id" and the job ids of the jobs you want to update
input_csv = "job_owner.csv"

#email address you want to change job owner to
owner = "job_owner@crowdflower.com"
#your api key (possibly has to be the old job owners api key)
key = "KEY"

CSV.foreach(input_csv, :headers => true) do |row|

  	job_id = row["id"]
  	p "Changing owner for Job ID: #{job_id}"
  	response_raw = update_owner(job_id, owner, key)

end