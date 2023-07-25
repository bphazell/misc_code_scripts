require 'csv'
require 'crowdflower'



input = ARGV[0]


job_id = 610581
amount = 1
message = "Hi,

CrowdFlower is contacting you because you recently completed a survey task and expressed an interest in tasking with us more!

Given that you indicated you like to talk on the phone and are capable of doing this during weekly US business hours, we have a task that we think you will enjoy. 

This task involves calling various publicly listed businesses to verify basic business product and contact information. These phone calls will follow a script and be very quick and straight forward. You will use the regular CrowdFlower task interface to read the questions you need to ask businesses and then enter their answers. Phone calls should not be longer than 5 minutes each and the pay for this job will include compensation for use of your personal phone line. 

If you are interested in this kind of task please email us 2-3 sentences at ashley.ortega@crowdflower.com telling us why you would be good at this task. Also provide us with a phone number we can reach you at and a good time to reach you Thursday (09/11/2014) or Friday (09/12/2014) from 8am to 5pm PST.


Thank you for your interest in working with CrowdFlower more!

Best,

Ashley Ortega
"






AUTH_KEY = "tizo6rmJ3u_x-XvsP7J1"
DOMAIN_BASE = "https://api.crowdflower.com"

CrowdFlower::Job.connect! AUTH_KEY, DOMAIN_BASE

job_resource = CrowdFlower::Job.new(job_id)
worker_resource = CrowdFlower::Worker.new(job_resource)

CSV.foreach(input, :headers => true) do |row|
	worker = row["_worker_id"]
	puts worker
	response = worker_resource.bonus(worker, amount, message)
	puts response
end











