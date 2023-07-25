
# require packages
require 'csv'
require 'crowdflower'

#set variables for functions (caps = constant)

JOB_ID = 123456
MESSAGE = "This is a test bonusing script"
output_headers= ["job_id", "worker_id", "amount", "bonus_boolean", "response"]

#establish connection wiht crowdflower API
CrowdFlower::Job.connect! AUTH_KEY , DOMAIN_BASE


def bonus_contributor(job_id, contributor_id, amount, messge)
	#create job as a variable
	job_object = CrowdFlower::Job.new(job_id)
	#create worker as variable
	worker_object = CrowdFlower::Worker.new(job_object)
	#bonus contributor and record response
	response=worker_object.bonus(contributor_id, amount, message)
	return response
end

#creates output file for csv
CSV.open(OUTPUT_FILE, "ab", :headers => output_headers, :write_headers => true ) do |out|
	#creates input file for csv
	CSV.foreach(INPUT_File, :headers=> true) do |row|
		#find every data cell that aligns with the header 'contributor_id'
		contributor_id = row["gen_job_contributor_id"]
		job_id = JOB_ID
		amount = AMOUNT
		message = MESSAGE
		#find every data cell that aligns with the header 'passed'
		bonus_boolean = row["passed"]
		if bonus_boolean == "yes"
			response = "testing bonus script"
			#test_function(job_id, contributor_id, amount, message)
			#response = bonus_contributor(job_id, contributor_id, amount, message)
			out << [job_id, contributor_id, amount, bonus_boolean, response]
		else
			out << [[job_id, contributor_id, amount, bonus_boolean, "Didnt even try to bonus."]]
		end
	end
end


