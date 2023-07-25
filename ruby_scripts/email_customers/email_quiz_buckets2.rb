
require 'awesome_print'
require 'mail'
require 'pg'
require 'csv'

CSV_HEADERS = ["email", "affected_jobs", "first_name", "last_name", "bucket_num"]

redshift = PG.connect( 
  dbname: 'matt_crowdflower', 
  host: 'cf-redshift.etleap.com',
  user: "matt_crowdflower",
  password: 'wznvhKJVAC135299756',
  port: 5439) 

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


class MailObject
  def initialize(redshift, csv)
    @redshift = redshift
    @query_1_results = create_account_hash(list1_query)
    @query_2_results = create_account_hash(list2_query)
    @query_4_results = create_account_hash(list4_query)
    @combined = combine_all
    @csv = csv
  end

  # Organizes all job ids into an array within a hash
  def create_jobs_hash(result)
    result.each_with_object(Hash.new{ |hash, key| hash[key] = [] }) do |tuple, output|
     output[tuple["email"]] << tuple["job_id"]    
   end
  end

  def combine_jobs_array(querya, queryb)
    querya.each do |k, v|
      if queryb.keys.include?(k)
       querya[k][:jobs] = querya[k][:jobs] + queryb[k][:jobs]
       querya[k][:jobs] = querya[k][:jobs].uniq
      end
    end
  end

  def combine_all
    query_1_2 = combine_jobs_array(@query_1_results, @query_2_results)
    query_1_2_4 = combine_jobs_array(query_1_2, @query_4_results)


    query_2_4 = combine_jobs_array(@query_2_results, @query_4_results)
    query_2_4_1 = combine_jobs_array(query_2_4, @query_1_results)

    query_4_1 = combine_jobs_array(@query_4_results, @query_1_results)
    query_4_1_2 = combine_jobs_array(query_4_1, @query_2_results)

    combined_query = query_1_2_4.merge(query_2_4_1)
    combined_query = combined_query.merge(query_4_1_2)    
  end



  # Organized first and last names into a hash
  def create_names_hash(result)
    result.each_with_object({}) do |tuple, output|
     output[tuple["email"]] =
      {
        first_name: tuple["first_name"],
        last_name: tuple["last_name"] 
      }      
   end
  end

  # Combines the names and jobs hash into a new hash
  def create_account_hash(result) 
    jobs_hash = create_jobs_hash(result)
    names_hash = create_names_hash(result)
    jobs_hash.each_with_object({}) do |(k, v), output|
      output[k] = 
      {
        jobs: jobs_hash[k],
        first_name: names_hash[k][:first_name],
        last_name: names_hash[k][:last_name]
      }
    end
  end

  # Delivers Email
  def deliver_mail(copy, email)
     Mail.deliver do
      from    'help@crowdflower.com'
      to      email
      subject "This is a test email"
      body    copy
    end
  end


  def copy(v)
    "Dear #{v[:first_name]}

      We’re making some changes this coming Monday, April 20, regarding Test Questions in your jobs. In short, we’re going to be automatically handling some of the quality settings that you previously had to set manually.

      There are a few cases in which these changes might reduce throughput on currently-running jobs. We’ve analyzed your jobs and discovered that some of them might be affected.

      Don’t worry, though! The solution is easy: all you need to do is create more test questions in your job. If you’re not sure how many test questions to create, you can go to the “Test Questions” step of any job to see how many Test Questions we recommend creating. There’s a progress bar in the upper right you can use as a guide. For help creating test questions, feel free to reach out to help@crowdflower.com.

      We’ve determined that the following jobs may need more Test Questions:

      #{v[:jobs].join("\n")}
      
      Let us know if you need any help.
      "
  end

# Quiz length different than assignment length
  def list1_query
    puts "running query 1"
    @redshift.query(
        "SELECT *
          FROM (
            SELECT orders.job_id, orders.email,orders.first_name, orders.last_name, orders.cost, orders.units_count, orders.rows_per_assignment, orders.gold_per_assignment, COUNT(gold.id) AS gold_count, orders.completed_at
            FROM (
              SELECT orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, COUNT(units.id) AS units_count, orders.rows_per_assignment, orders.gold_per_assignment, orders.completed_at
              FROM (
                SELECT jobs.id AS job_id, users.email, users.first_name, users.last_name, SUM(conversions.amount) AS cost, jobs.units_per_assignment AS rows_per_assignment, jobs.gold_per_assignment, jobs.completed_at
                FROM builder_jobs AS jobs
                JOIN pn_list on pn_list.pn = jobs.project_number
                JOIN builder_users AS users ON users.id = jobs.user_id
                JOIN builder_conversions AS conversions ON jobs.id = conversions.job_id
                WHERE jobs.completed_at > '01-17-2015'
                GROUP BY jobs.id, users.email, users.first_name, users.last_name, jobs.units_per_assignment, jobs.gold_per_assignment, jobs.completed_at
              ) AS orders
              JOIN builder_units AS units ON orders.job_id = units.job_id
              GROUP BY orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, orders.rows_per_assignment, orders.gold_per_assignment, orders.completed_at
            ) AS orders
            JOIN (
              SELECT *
              FROM goldfinger_gold_instances
              WHERE state = 'active'
            ) AS gold ON orders.job_id = gold.job_id
            GROUP BY orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, orders.units_count, orders.rows_per_assignment, orders.gold_per_assignment, orders.completed_at
            ORDER BY orders.completed_at
          ) WHERE gold_count <= rows_per_assignment
            "
        )
  end

  # Once contributors pass quiz can only do additional five judgments
  def list2_query
    puts "running query 2"
    @redshift.query(
      "SELECT *
      FROM (
        SELECT orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, orders.units_count, orders.rows_per_assignment, orders.gold_per_assignment, COUNT(gold.id) AS gold_count, orders.completed_at
        FROM (
          SELECT orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, COUNT(units.id) AS units_count, orders.rows_per_assignment, orders.gold_per_assignment, orders.completed_at
          FROM (
            SELECT jobs.id AS job_id, users.email, users.first_name, users.last_name, SUM(conversions.amount) AS cost, jobs.units_per_assignment AS rows_per_assignment, jobs.gold_per_assignment, jobs.completed_at
            FROM builder_jobs AS jobs
            JOIN pn_list on pn_list.pn = jobs.project_number
            JOIN builder_users AS users ON users.id = jobs.user_id
            JOIN builder_conversions AS conversions ON jobs.id = conversions.job_id
            WHERE jobs.completed_at > '01-17-2015'
            GROUP BY jobs.id, users.email, users.first_name, users.last_name, jobs.units_per_assignment, jobs.gold_per_assignment, jobs.completed_at
          ) AS orders
          JOIN builder_units AS units ON orders.job_id = units.job_id
          GROUP BY orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, orders.rows_per_assignment, orders.gold_per_assignment, orders.completed_at
        ) AS orders
        JOIN (
          SELECT *
          FROM goldfinger_gold_instances
          WHERE state = 'active'
        ) AS gold ON orders.job_id = gold.job_id
        GROUP BY orders.job_id, orders.email, orders.first_name, orders.last_name, orders.cost, orders.units_count, orders.rows_per_assignment, orders.gold_per_assignment, orders.completed_at
        ORDER BY orders.completed_at
      ) WHERE gold_count < rows_per_assignment + 5
      AND gold_count > rows_per_assignment
      "
      )
  end
  
  # Only see tq once, workers won't be able to continue
  def list4_query
    puts "running query 4"
    @redshift.query("
      with matching_jobs as (
      select builder_jobs.id as id, 
      count(goldfinger_gold_instances.*) as active_golds_count
      from builder_jobs
      join pn_list on pn_list.pn = builder_jobs.project_number
      join goldfinger_gold_instances
      on goldfinger_gold_instances.job_id = builder_jobs.id
      where builder_jobs.state = 2
      and goldfinger_gold_instances.state = 'active'
      group by builder_jobs.id
    ), matching_jobs_recent_judgments as (
      select matching_jobs.id, active_golds_count from matching_jobs
      join goldfinger_gold_judgments 
      on goldfinger_gold_judgments.job_id = matching_jobs.id
      where goldfinger_gold_judgments.created_at > (getdate() - '7 days'::interval)
      group by matching_jobs.id, matching_jobs.active_golds_count
      having count(*) > 0
    ), matching_job_worker_seen_counts as (
      select matching_jobs_recent_judgments.id,
             goldfinger_gold_judgments.worker_id,
             active_golds_count,
             count(goldfinger_gold_judgments.*) as seen_count
      from matching_jobs_recent_judgments
      join goldfinger_gold_judgments
      on goldfinger_gold_judgments.job_id = matching_jobs_recent_judgments.id
      join goldfinger_gold_instances
      on goldfinger_gold_instances.id = goldfinger_gold_judgments.gold_instance_id
      where goldfinger_gold_instances.state = 'active'
      group by matching_jobs_recent_judgments.id, goldfinger_gold_judgments.worker_id, active_golds_count
      having count(*) > 0
    ), risk_of_overexposed_report as (
      select matching_job_worker_seen_counts.id as job_id,
             count(case when active_golds_count*0.8 > seen_count then 1 else null end) as no_risk,
             count(case when active_golds_count*0.8 < seen_count then 1 else null end) as risk
      from matching_job_worker_seen_counts
      group by matching_job_worker_seen_counts.id
      order by risk desc
    )
    select job_id,
      risk + no_risk as total_workers_on_job,
      round(((risk::float)/(risk+no_risk) * 100),1) as percent_risked_workers,
      builder_users.email as email,
      builder_users.first_name,
      builder_users.last_name
      from risk_of_overexposed_report
      join builder_jobs
      on builder_jobs.id = job_id
      join builder_users
      on builder_users.id = builder_jobs.user_id
      order by percent_risked_workers desc;
      "
      )
  end

  # Delivers Email
  def deliver_mail(copy, email)
     Mail.deliver do
      from    'help@crowdflower.com'
      to      email
      subject "Upcoming CrowdFlower Release May Affect Your Jobs"
      body    copy
    end
  end

  def fill_and_send_email(combined)
    #change email to k
    combined.each do |k, v|
    email = "#{k}"
    for_csv = [k, v[:jobs].join(", "), v[:first_name], v[:last_name]]
    body = copy(v)
    @csv << for_csv
     deliver_mail(body, email)
    end
  end
end



CSV.open("quiz_buckets_outbound_emails.csv", "w", headers: CSV_HEADERS, write_headers:true) do |csv|
  queries = MailObject.new(redshift, csv)
  combined = queries.combine_all
  queries.fill_and_send_email(combined)
end








