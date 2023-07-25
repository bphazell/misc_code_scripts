########### this part copies the job and changes settings ####################

############# this is the part that pings job id and gets json #############
require 'json'
require 'crowdflower'
require 'nokogiri'

new_id = ARGV[0].to_s # job that wiil be made into a golddigging job

auth_key = "5b7d73e5e7eb06556f12b45f87b013fc419f45f2"
domain_base = "https://api.crowdflower.com/"

CrowdFlower::Job.connect! auth_key, domain_base

# grab job
new_job_resource = CrowdFlower::Job.new(new_id)

#units per assignment = 1
new_job_resource.update({:units_per_assignment => 1,
                        :pages_per_assignment => 1,
                        :variable_judgments_mode => "none" ,
                        :judgments_per_unit => "1" ,
                        :options => {:front_load => false ,
                        :after_gold => "1" ,
                        :reject_at => "10" ,
                        :flag_on_rate_limit => false,
                        :flag_on_min_assignment_duration => false,
                        :send_emails_on_rate_limit => false,
                        :req_ttl_in_seconds => 120*60 },
                        :included_countries => nil,
                        :excluded_countries => nil,
                        :desired_requirements => {}.to_json,
                        :minimum_requirements => {:priority => 1, :skill_scores => {:goldbusters => 1}, :min_score => 1}.to_json,
                        :flag_on_rate_limit => false,
                        :max_judgments_per_worker => 30,
                        :max_judgments_per_ip => 30,
                        :flag_on_rate_limit => nil,
                        :auto_order => false,
                        :minimum_account_age_seconds => "0",
                        :payment_cents => 20,
                        :gold_per_assignment => "0"})


# order on all channels
#curl -d 'key={api_key}&channels[0]=amt&channels[0]=sama&debit[units_count]=20' https://api.crowdflo$
# allegedly, we do not need thsi anymore since gpa can be set to 0 even where golds are present
#`curl -H "Content-Type: application/json" -X PUT 'https://api.crowdflower.com/v1/jobs/#{new_id}/gold.json?key=#{auth_key}' -d '{"reset": true}'`
#golds per assignment = 0






