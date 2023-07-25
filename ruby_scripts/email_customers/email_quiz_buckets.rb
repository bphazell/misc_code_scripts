
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
    @query_3_results = create_account_hash(list3_query)
    # @query_4_results = create_account_hash(list4_query)
    @csv = csv
  end

  # Organizes all job ids into an array within a hash
  def create_jobs_hash(result)
    result.each_with_object(Hash.new{ |hash, key| hash[key] = [] }) do |tuple, output|
     output[tuple["email"]] << tuple["job_id"]    
   end
  end

  def test
    puts "query 1 #{@query_1_results}"
    ap @query_1_results
    puts "*******"
    puts "query 2 #{@query_2_results}"
    ap @query_2_results
    puts "*******"
    new_hash = @query_1_results.merge(@query_2_results)
    ap new_hash

    # @query_1_results.each do |k, v|
    #   ap k
    # end
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

  # Identify which query results hash to use
  def identify_hash(copy_num)
    if copy_num == 1
      hash = @query_1_results
    elsif copy_num == 2
      hash = @query_2_results
    elsif copy_num == 3
      hash = @query_3_results
    elsif copy_num == 4
      hash = @query_4_results
    end  
  end
 
 # Identify which copy to Use
  def fill_and_send_email(copy_num)
    email = "bhazell@crowdflower.com"
    hash = identify_hash(copy_num)
    hash.each do |k, v|
    ap "email #{k}"
    for_csv = [k, v[:jobs].join(", "), v[:first_name], v[:last_name]]
    if copy_num == 1
      for_csv.push(1)
      body = copy1(v)
    elsif copy_num == 2
      for_csv.push(2)
      body = copy2(v)
    elsif copy_num == 3
      for_csv.push(3)
      body = copy3(v)
    elsif copy_num == 4
      for_csv.push(4)
      body = copy4(v)
    end
    @csv << for_csv
     ap body
     deliver_mail(body, email)
    end
  end

  def copy1(v)
    if v[:jobs].length > 1
      "COPY 1 Hey #{v[:first_name]}, \n\n Your jobs #{v[:jobs].join(", ")} will be affected."
    else
      "COPY 1 Hey #{v[:first_name]}, \n\n Your job #{v[:jobs].join(", ")} will be affected."
    end
  end

  def copy2(v)
    if v[:jobs].length > 1
      "COPY 2 Hey #{v[:first_name]}, \n\n Your jobs #{v[:jobs].join(", ")} will be affected."
    else
      "COPY 2 Hey #{v[:first_name]}, \n\n Your job #{v[:jobs].join(", ")} will be affected."
    end
  end

  def copy3(v)
    if v[:jobs].length > 1
      "COPY 3 Hey #{v[:first_name]}, \n\n Your jobs #{v[:jobs].join(", ")} will be affected."
    else
      "COPY 3 Hey #{v[:first_name]}, \n\n Your job #{v[:jobs].join(", ")} will be affected."
    end
  end

  def copy4(v)
    if v[:jobs].length > 1
      "COPY 4 Hey #{v[:first_name]}, \n\n Your jobs #{v[:jobs].join(", ")} will be affected."
    else
      "COPY 4 Hey #{v[:first_name]}, \n\n Your job #{v[:jobs].join(", ")} will be affected."
    end
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

  # We will automatically set test questions per page
  def list3_query
    puts "running query 3"
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
            AND jobs.gold_per_assignment > 1
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
      )LIMIT 1"
      )
  end
  
  # Only see tq once, workers won't be able to continue
  # def list4_query
  #   puts "running query 4"
  #   @redshift.query("
  #     with matching_jobs as (
  #     select builder_jobs.id as id, 
  #     count(goldfinger_gold_instances.*) as active_golds_count
  #     from builder_jobs
  #     join pn_list on pn_list.pn = builder_jobs.project_number
  #     join goldfinger_gold_instances
  #     on goldfinger_gold_instances.job_id = builder_jobs.id
  #     where builder_jobs.state = 2
  #     and goldfinger_gold_instances.state = 'active'
  #     group by builder_jobs.id
  #   ), matching_jobs_recent_judgments as (
  #     select matching_jobs.id, active_golds_count from matching_jobs
  #     join goldfinger_gold_judgments 
  #     on goldfinger_gold_judgments.job_id = matching_jobs.id
  #     where goldfinger_gold_judgments.created_at > (getdate() - '7 days'::interval)
  #     group by matching_jobs.id, matching_jobs.active_golds_count
  #     having count(*) > 0
  #   ), matching_job_worker_seen_counts as (
  #     select matching_jobs_recent_judgments.id,
  #            goldfinger_gold_judgments.worker_id,
  #            active_golds_count,
  #            count(goldfinger_gold_judgments.*) as seen_count
  #     from matching_jobs_recent_judgments
  #     join goldfinger_gold_judgments
  #     on goldfinger_gold_judgments.job_id = matching_jobs_recent_judgments.id
  #     join goldfinger_gold_instances
  #     on goldfinger_gold_instances.id = goldfinger_gold_judgments.gold_instance_id
  #     where goldfinger_gold_instances.state = 'active'
  #     group by matching_jobs_recent_judgments.id, goldfinger_gold_judgments.worker_id, active_golds_count
  #     having count(*) > 0
  #   ), risk_of_overexposed_report as (
  #     select matching_job_worker_seen_counts.id as job_id,
  #            count(case when active_golds_count*0.8 > seen_count then 1 else null end) as no_risk,
  #            count(case when active_golds_count*0.8 < seen_count then 1 else null end) as risk
  #     from matching_job_worker_seen_counts
  #     group by matching_job_worker_seen_counts.id
  #     order by risk desc
  #   )
  #   select job_id,
  #     risk + no_risk as total_workers_on_job,
  #     round(((risk::float)/(risk+no_risk) * 100),1) as percent_risked_workers,
  #     builder_users.email as email,
  #     builder_users.first_name,
  #     builder_users.last_name
  #     from risk_of_overexposed_report
  #     join builder_jobs
  #     on builder_jobs.id = job_id
  #     join builder_users
  #     on builder_users.id = builder_jobs.user_id
  #     order by percent_risked_workers desc
  #     LIMIT 1;
  #     "
  #     )
  # end
end

CSV.open("quiz_buckets_outbound_emails.csv", "w", headers: CSV_HEADERS, write_headers:true) do |csv|
  queries = MailObject.new(redshift, csv)
  queries.test
  # puts "email 1"
  # email1 = queries.fill_and_send_email(1)
  # puts "email 2"
  # email2 = queries.fill_and_send_email(2)
  # puts "email 3"
  # email3 = queries.fill_and_send_email(3)
  # puts "email 4"
  # email4 = queries.fill_and_send_email(4)
end








