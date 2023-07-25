require 'awesome_print'
require 'csv'
require 'pg'
require 'date'
require 'mail'


redshift = PG.connect( 
dbname: 'matt_crowdflower', 
host: 'cf-redshift.etleap.com',
user: "matt_crowdflower",
password: 'wznvhKJVAC135299756',
port: 5439,
)

#Set up email settings
#you need enable 'allow less secure apps to access your account' in gmail settings 
options = { :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'crowdflower',
  :user_name            => 'bphazell',
  :password             => 'Jaydice16',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }
  Mail.defaults do
  delivery_method :smtp, options
end

def name_message(name)
  "hey #{name} there, I'm emailing you!!!"
end

#To identify "dormant" contributors

query_results = redshift.query("
   SELECT pn_list.pn, 
          builder_users.email, 
          builder_users.first_name, 
          builder_users.last_name, 
          unit_count_per_user.unit_count as unit_count_per_user, 
          builder_users.created_at
     From pn_list
      JOIN builder_users
      ON builder_users.project_number = pn_list.pn
      FULL JOIN
          (SELECT SUM(unit_counts_per_job.unit_count) AS unit_count, 
                  builder_jobs.user_id AS jobs_uid
          FROM builder_jobs 
          JOIN 
                (SELECT count(builder_units.id) AS unit_count, 
                        builder_units.job_id AS job_id
                FROM builder_units
                WHERE builder_units.state = 9
                GROUP BY builder_units.job_id) AS unit_counts_per_job
            ON builder_jobs.id = unit_counts_per_job.job_id
          GROUP BY jobs_uid) AS unit_count_per_user 
        ON builder_users.id = unit_count_per_user.jobs_uid
      WHERE (unit_count_per_user.unit_count < 100 
            OR builder_users.id NOT IN (
                                select builder_users.id
                                from pn_list
                                join builder_users on builder_users.project_number = pn_list.pn
                                JOIN builder_jobs on builder_jobs.user_id = builder_users.id)
                                )
       AND builder_users.created_at < '2015-06-01'
      ORDER BY pn_list.pn
  ")

query_results.each do |tuple|
  if tuple["first_name"] != ""
    mail = Mail.deliver do
      from    'bhazell@crowdflower.com'
      to      "bhazell@crowdflower.com"
      subject "This is a test email"
      body    name_message(tuple["first_name"])
    end
    name_message(tuple["first_name"])
  end
else
  mail = Mail.deliver do
      from    'bhazell@crowdflower.com'
      to      "bhazell@crowdflower.com"
      subject "This is a test email"
      body    name_message(tuple["first_name"])
    end
    name_message("")
end

### to idenftify first "successful" job

   SELECT builder_users.email,
          job_data.job_id,
          job_data.project_number,
          job_data.created_at,
          job_data.fin_unit,
          job_data.gold_unit,
          job_data.total_jud,
          job_data.total_trusted_jud,
          ROUND(((CAST(job_data.total_jud - job_data.total_trusted_jud as numeric)) / (CAST(job_data.total_jud as numeric))), 2) as untrusted_ratio
   From builder_users
   JOIN
      (select builder_jobs.id as job_id,
              builder_jobs.project_number,
              builder_jobs.created_at,
              builder_jobs.user_id,
              COUNT(DISTINCT(CASE WHEN unit_data.state = 9 THEN unit_data.unit_id END)) AS fin_unit,
              COUNT(DISTINCT(CASE WHEN unit_data.state = 6 THEN unit_data.unit_id END)) as gold_unit,
              SUM(CASE WHEN unit_data.state = 9 OR unit_data.state = 2 or unit_data.state = 3 THEN unit_data.judgments_count END) as total_jud,
              SUM(CASE WHEN unit_data.state = 9 OR unit_data.state = 2 or unit_data.state = 3 THEN unit_data.number_of_accurate_judgments END) as total_trusted_jud
      FROM builder_jobs
      JOIN
          (SELECT builder_units.id as unit_id,
                  builder_units.state,
                  builder_units.judgments_count, 
                  builder_units.number_of_accurate_judgments,  
                  builder_units.job_id
          from builder_units
          WHERE builder_units.state = 9
            OR builder_units.state = 6
            OR builder_units.state = 2
            OR builder_units.state = 3) as unit_data
       ON builder_jobs.id = unit_data.job_id
      GROUP BY builder_jobs.id, builder_jobs.project_number, builder_jobs.created_at, builder_jobs.user_id
      ORDER BY builder_jobs.id DESC) as job_data
  ON job_data.user_id = builder_users.id
  WHERE job_data.fin_unit > 25


      


      






    
          