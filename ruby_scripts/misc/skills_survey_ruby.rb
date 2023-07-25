

require 'crowdflower'
require 'json'

AUTH_KEY = "sXhKBtZPvLiDjWbGcEtN"
DOMAIN_BASE = "https://api.crowdflower.com"
job_owner = "bhazell@crowdflower.com"
pn = "PN000"
title = "This is a test survey2"
payment = 1
judgements = 1000
cml_skills = '<cml:select label="Please select the year you were born." validates="required" name="born" gold="true">
    <cml:option label="2013"></cml:option>
    <cml:option label="2012"></cml:option>
    <cml:option label="2011"></cml:option>
    <cml:option label="2010"></cml:option>
    <cml:option label="2009"></cml:option>
    <cml:option label="2008"></cml:option>
    <cml:option label="2007"></cml:option>
    <cml:option label="2006"></cml:option>
    <cml:option label="2005"></cml:option>
    <cml:option label="2004"></cml:option>
    <cml:option label="2003"></cml:option>
    <cml:option label="2002"></cml:option>
    <cml:option label="2001"></cml:option>
    <cml:option label="2000"></cml:option>
    <cml:option label="1999"></cml:option>
    <cml:option label="1998"></cml:option>
  </cml:select>'
cml_survey = '<!-- this is a test for survey -->'


 

def update_settings(job_owner, pn, title, cml_skills, cml_survey, payment, judgements)
CrowdFlower::Job.connect! AUTH_KEY, DOMAIN_BASE

#prescreen = div class = nowfluid
#survey 


template_job = "surveytemplate"
#system("curl http://api.crowdflower.com/v1/jobs/{template_job}/copy.json?key={auth_key}&gold=true")
#job = CrowdFlower::Job.new(template_job)
#job = job.copy

response = `curl -X POST 'https://crowdflower.com/jobs/#{template_job}/copy?all_units=true&key=#{AUTH_KEY}'`
parse_response = JSON.parse(response)
job_id = parse_response["id"]
puts "Job id is: #{job_id}"

job = CrowdFlower::Job.new(job_id)


new_cml = "{% if prescreen == 'yes' %} \n" + cml_skills + "\n{% else %}\n " + cml_survey + "\n{% endif %}"

`curl -X PUT --data-urlencode 'job[owner_email]=#{job_owner}' 'https://make.crowdflower.com/jobs/#{job_id}/settings/general.json?key=#{AUTH_KEY}'`


job.update({title: title})
job.update({project_number: pn})
job.update({problem: new_cml})
job.update({payment_cents: payment})
job.update({judgments_per_unit: judgements})

end


blah =update_settings(job_owner, pn, title, cml_skills, cml_survey, payment, judgements)


	

