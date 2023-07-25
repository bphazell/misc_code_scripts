require 'awesome_print'
require 'mail'
require 'pg'
require 'csv'
require 'crowdflower'

# Determines if you want to pause jobs: 'yes' or 'no'
PAUSE_JOB = false

CSV_HEADERS = 
[
  "job_id",
  "job_state",
  "tq_count",
  "after_gold",
  "job_owner",
  "created_at"
]

API_KEY = "sXhKBtZPvLiDjWbGcEtN"
DOMAIN_BASE = "https://api.crowdflower.com"
CrowdFlower::Job.connect! API_KEY, DOMAIN_BASE

# Connect to Redshift
redshift = PG.connect( 
  dbname: 'matt_crowdflower', 
  host: 'cf-redshift.etleap.com',
  user: "matt_crowdflower",
  password: 'wznvhKJVAC135299756',
  port: 5439) 

# Establish Mail sender
options = 
{ :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'crowdflower.com',
  :user_name            => 'help@crowdflower.com',
  :password             => 'LiQSbYco',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

class AdverseQuiz
  def initialize(redshift, csv)
    @redshift = redshift
    @csv = csv
    @results = query
  end

  def query
    @redshift.query(
    "with tq_count as (select builder_units.job_id, count(builder_units.id) as tq_count
      from builder_units
      where builder_units.state = 6
      group by builder_units.job_id)

      select builder_jobs.id,
             (CASE 
               WHEN builder_jobs.state = 1 THEN 'unordered'
               WHEN builder_jobs.state = 2 THEN 'running'
               WHEN builder_jobs.state = 3 THEN 'paused'
             END) as job_state,
             tq_count.tq_count,
             after_gold,
             builder_users.email,
             builder_jobs.created_at
      from builder_jobs
      join tq_count on builder_jobs.id = tq_count.job_id
      join builder_users on builder_users.id = builder_jobs.user_id
      where tq_count.tq_count <= builder_jobs.after_gold
      and builder_jobs.front_load = 'false'
      and builder_jobs.created_at > '2015-01-01 00:00:00'
      and builder_jobs.state not in (4, 5) 
      and builder_users.email not like '%@crowdflower.com'
      and builder_jobs.deleted_at IS NULL
      order by builder_jobs.created_at" )
  end

  def take_job_action(tuple)
      job = CrowdFlower::Job.new(tuple["id"])
      if tuple["job_state"] == 'running'
        puts job.pause
      else
        puts "Job #{tuple["id"]} is not Running"
      end
  end

  def write_csv
    @results.each do |tuple|
      # If pause_job == true, pause all running jobs
      PAUSE_JOB ? take_job_action(tuple) : (puts "Job #{tuple["id"]}: No job action taken")
      write_tuple_to_csv(tuple)
    end
  end

  def write_tuple_to_csv(tuple)
    for_csv = [
      tuple["id"], 
      tuple["job_state"], 
      tuple["tq_count"], 
      tuple["after_gold"], 
      tuple["email"], 
      tuple["created_at"]
      ]
    @csv << for_csv
  end
end

# Delivers Email
def deliver_mail
   Mail.deliver do
    from    'help@crowdflower.com'
    to      'bhazell@crowdflower.com'
    subject "Jobs With TQ < after_gold "
    body    "The jobs attached are impossible for contributors to become trusted"
    add_file :filename => 'jobs_with_tqs_under_after_gold.csv', :content => File.read('jobs_with_tqs_under_after_gold.csv')
  end
end

CSV.open("jobs_with_tqs_under_after_gold.csv", "w", headers: CSV_HEADERS, write_headers: true) do |csv|
  object = AdverseQuiz.new(redshift, csv)
  query_results = object.write_csv
end

# Will not send email if query results are empty
file_empty = File.zero?("jobs_with_tqs_under_after_gold.csv")
if file_empty != true
  deliver_mail
else
  puts "No Results"
end



