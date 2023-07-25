require 'csv'
require 'crowdflower'

JOB_ID = 123456
MESSAGE = "This is a test bonusing script."
AMOUNT = 100
AUTH_KEY = "af574018a6b7360b924c210c41d1f263e264cf83"
DOMAIN_BASE = "https://api.crowdflower.com"
INPUT_FILE = "test.csv"
OUTPUT_FILE = "brians_test_bonus_results.csv"
output_headers = ["job_id", "worker_id", "amount", "bonus_boolean", "response"]

CrowdFlower::Job.connect! AUTH_KEY, DOMAIN_BASE

def bonus_contributor(job_id, contributor_id, amount, message)
	job_object = CrowdFlower::Job.new(job_id)
	worker_object = CrowdFlower::Worker.new(job_object)
	response = worker_object.bonus(contributor_id, amount, message)
	return response
end

def test_function(job_id, contributor_id, amount, message)
	puts "Job ID: #{job_id}"
	puts "Contributor_id: #{contributor_id}"
	puts "Would have paid this amount: #{amount}"
	puts "#{message}"
	puts "DID IT BITCH"
end

CSV.open(OUTPUT_FILE, "ab", :headers => output_headers, :write_headers => true) do |out|
	CSV.foreach(INPUT_FILE, :headers => true) do |row|
		contributor_id = row["gen_job_contributor_id"]
		job_id = JOB_ID
		amount = AMOUNT
		message = MESSAGE
		bonus_boolean = row["passed"]
		if bonus_boolean == "Yes"
			response = "This isn't really a bonus script.  It's for Brian to mess around with."
			test_function(job_id, contributor_id, amount, message)
			#response = bonus_contributor(job_id, contributor_id, amount, message)
			out << [job_id, contributor_id, amount, bonus_boolean, response]
		else
			out << [job_id, contributor_id, amount, bonus_boolean, "Didnt even try to bonus."]
		end
	end
end
