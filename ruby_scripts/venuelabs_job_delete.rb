# Delete Venuelabs units

require 'crowdflower'
require 'pg'
require 'awesome_print'

redshift = PG.connect( 
  dbname: 'matt_crowdflower', 
  host: 'cf-redshift.etleap.com',
  user: "matt_crowdflower",
  password: 'wznvhKJVAC135299756',
  port: 5439)

API_KEY = "sXhKBtZPvLiDjWbGcEtN"
DOMAIN_BASE = "https://api.crowdflower.com"

CrowdFlower::Job.connect! API_KEY, DOMAIN_BASE

  query_results = redshift.query("
  	With counts as (select builder_jobs.id, COUNT(builder_units.id) as unit_count
	from builder_jobs
	join builder_units on builder_jobs.id = builder_units.job_id
	group by builder_jobs.id) 

	select builder_jobs.id, counts.unit_count
	from builder_jobs 
	join builder_users on builder_users.id = builder_jobs.user_id
	join counts on builder_jobs.id = counts.id
	where builder_users.email = 'petem@venuelabs.com'
	and builder_jobs.created_at >= '2015-06-01'
	and builder_jobs.id != 745693
	and counts.unit_count <= 136
")


  query_results.each do |tuple|
	ap "deleting #{tuple['id']}"
	job = CrowdFlower::Job.new(tuple["id"])
	job.delete
  end