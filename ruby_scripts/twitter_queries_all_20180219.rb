require 'mail'
require 'chronic'
require 'sequel'
require 'json'
require 'pg'
require 'date'
require 'csv'
require 'awesome_print'

now = Date.today
# last_week = (now - 7)
now_date = now.strftime("%Y-%m-%d")
puts now_date

row_usage = ["Team ID", "Team Name", "Rows Run Last Week"]
judgments = ["User ID", "Email", "Abuse - this week", "Content - this week", "Cortex - this week", "Spam - this week", "Total Judgments"]
agreement = ["User ID", "Email", "Abuse Agmnt", "Content Discovery Agmnt", "Cortex Agmnt", "Spam Agmnt"]
cortex_jobs = ["User ID", "Email", "Job IDs", "Judgments", "Total Judgments"]

p now_date

RECIPIENTS = 	['jenniferh@twitter.com', 'hcomp@twitter.com', 'dino@twitter.com', 'glenn.volk@crowdflower.com', 'kirsten.gokay@crowdflower.com']

# RECIPIENTS = ['kirsten.gokay@crowdflower.com']

#configure options for mail gem
mail_options = {
	:address => "smtp.gmail.com",
	:port => 587,
	:domain => "gmail.com",
	:user_name => "cfcsdreports@gmail.com",
	:password => "123dolores",
	:authentication => 'plain',
	:enable_starttls_auto => true
}

Mail.defaults do
	delivery_method :smtp, mail_options
end

def connect_to_redshift
	redshift = PG.connect(
		dbname: 'matt_crowdflower',
		host: 'cf-redshift.etleap.com',
		user: "matt_crowdflower",
		password: 'wznvhKJVAC135299756',
		port: 5439,
		)
end



def row_usage_query(redshift)
	row_usage_results = redshift.query("
		select t.name, t.id,
		sum(case when a.created_at between '2018-02-12' and '2018-02-18' then number_units end) as last_week
		from public.akon_unit_adjustments a
		join public.akon_teams t on t.id = a.team_id
		where a.team_id in (
		'ac0b8c8c-7d58-44e8-b2d7-875e46071fc3',
		'3acd7acc-f595-4902-84a9-7584f35e25ec',
		'30a242db-54d2-43fd-b112-96e638bc1031',
		'e2b56b17-aa70-491e-a0ec-8ae93a5e4cb9',
		'14cd109e-b139-4919-8e1d-d790a318753d',
		'27fd9c2e-02b9-492d-9afe-84522773f182',
		'5e1a604e-372e-4761-86f5-cf61b6670de6'
		)
		and change_type in ('order', 'cancellation')
		group by t.name, t.id"
	)
end

def judgments_query(redshift)
	judgments_results = redshift.query("
		SELECT b.user_id, a.email,
		COUNT(DISTINCT(CASE WHEN (j.team_id = 'ac0b8c8c-7d58-44e8-b2d7-875e46071fc3' and builder_judgments.created_at between '2018-02-12' and '2018-02-18') THEN builder_judgments.id END)) AS abuse_thisweek,
		COUNT(DISTINCT(CASE WHEN (j.team_id = '30a242db-54d2-43fd-b112-96e638bc1031' and builder_judgments.created_at between '2018-02-12' and '2018-02-18') THEN builder_judgments.id END)) AS content_thisweek,
		COUNT(DISTINCT(CASE WHEN (j.team_id = 'e2b56b17-aa70-491e-a0ec-8ae93a5e4cb9' and builder_judgments.created_at between '2018-02-12' and '2018-02-18') THEN builder_judgments.id END)) AS cortex_thisweek,
		COUNT(DISTINCT(CASE WHEN (j.team_id = '5e1a604e-372e-4761-86f5-cf61b6670de6' and builder_judgments.created_at between '2018-02-12' and '2018-02-18') THEN builder_judgments.id END)) AS spam_thisweek,
		  COUNT(DISTINCT(builder_judgments.id)) AS total
		FROM builder_judgments
		JOIN builder_jobs j on j.id = builder_judgments.job_id
		JOIN builder_workers b on b.id = builder_judgments.worker_id
		join public.akon_users a on a.id = b.user_id
		WHERE builder_judgments.created_at >= '2016-01-01'
		and j.team_id in ('ac0b8c8c-7d58-44e8-b2d7-875e46071fc3',
		'30a242db-54d2-43fd-b112-96e638bc1031',
		'e2b56b17-aa70-491e-a0ec-8ae93a5e4cb9',
		'5e1a604e-372e-4761-86f5-cf61b6670de6')
		GROUP BY b.user_id, a.email
		ORDER BY total DESC")
end

def agreement_query(redshift)
	agreement_results = redshift.query("select 
		u.user_id, a.email,
		avg(case when j.team_id = 'ac0b8c8c-7d58-44e8-b2d7-875e46071fc3' then w.agreement end) as abuse_agmnt,
		avg(case when j.team_id = '30a242db-54d2-43fd-b112-96e638bc1031' then w.agreement end) as content_discovery_agmnt,
		avg(case when j.team_id = 'e2b56b17-aa70-491e-a0ec-8ae93a5e4cb9' then w.agreement end) as cortex_agmnt,
		avg(case when j.team_id = '5e1a604e-372e-4761-86f5-cf61b6670de6' then w.agreement end) as spam_agmnt
		from public.builder_worksets w
		join public.builder_workers u on u.id = w.worker_id
		join public.akon_users a on a.id = u.user_id
		join public.builder_jobs j on j.id = w.job_id
		join public.builder_judgments ju on ju.workset_id = w.id
		where ju.created_at between '2018-02-12' and '2018-02-18'
		and j.team_id in ('ac0b8c8c-7d58-44e8-b2d7-875e46071fc3',
		'30a242db-54d2-43fd-b112-96e638bc1031',
		'e2b56b17-aa70-491e-a0ec-8ae93a5e4cb9',
		'5e1a604e-372e-4761-86f5-cf61b6670de6')
		group by u.user_id, a.email
		order by a.email")
end

def cortex_jobs_query(redshift)
	cortex_jobs_results = redshift.query(
		"with jobs as (SELECT b.user_id, a.email, j.id, count(distinct(ju.id)) as judgments
		FROM builder_judgments ju
		JOIN builder_jobs j on j.id = ju.job_id
		JOIN builder_workers b on b.id = ju.worker_id
		join public.akon_users a on a.id = b.user_id
		WHERE ju.created_at between '2018-02-12' and '2018-02-18'
		and j.team_id = 'e2b56b17-aa70-491e-a0ec-8ae93a5e4cb9'
		GROUP BY b.user_id, a.email, j.id
		ORDER BY email)

		SELECT
		jobs.user_id, jobs.email,
		listagg(jobs.id, ', ') AS job_ids,
		listagg(jobs.judgments, ', ') as judgments,
		sum(jobs.judgments) as total_judgments
		FROM jobs
		GROUP BY jobs.user_id, jobs.email
		order by email")
end


def create_file1(row_usage_results, redshift, now_date, row_usage)
	CSV.open("Twitter_RowsRun_ByTeam_#{now_date}.csv",'w', headers: row_usage, write_headers: true) do |csv|
		row_usage_results.each_with_index do |row_usage_result|
			row_data = build_row1(row_usage_result, redshift)
			return "" if row_data == false
			csv << row_data
		end
	end
end

def create_file2(judgments_results, redshift, now_date, judgments)
	CSV.open("Twitter_Judgments_PerUser_#{now_date}.csv",'w', headers: judgments, write_headers: true) do |csv|
		judgments_results.each_with_index do |judgments_result|
			row_data = build_row2(judgments_result, redshift)
			return "" if row_data == false
			csv << row_data
		end
	end
end

def create_file3(agreement_results, redshift, now_date, agreement)
	CSV.open("Twitter_Agreement_PerUser_#{now_date}.csv",'w', headers: agreement, write_headers: true) do |csv|
		agreement_results.each_with_index do |agreement_result|
			row_data = build_row3(agreement_result, redshift)
			return "" if row_data == false
			csv << row_data
		end
	end
end

def create_file4(cortex_jobs_results, redshift, now_date, cortex_jobs)
	CSV.open("Twitter_CortexJudgments_PerUser_#{now_date}.csv",'w', headers: cortex_jobs, write_headers: true) do |csv|
		cortex_jobs_results.each_with_index do |cortex_jobs_result|
			row_data = build_row4(cortex_jobs_result, redshift)
			return "" if row_data == false
			csv << row_data
		end
	end
end

def build_row1(row_usage_result, redshift)
	team_id = row_usage_result["id"]
	team_name = row_usage_result["name"]
	rows_run = row_usage_result["last_week"]
	row_data = [
		team_id,
		team_name,
		rows_run
	]
end

def build_row2(judgments_result, redshift)
	user_id = judgments_result["user_id"]
	email = judgments_result["email"]
	abuse_thisweek = judgments_result["abuse_thisweek"]
	content_thisweek = judgments_result["content_thisweek"]
	cortex_thisweek = judgments_result["cortex_thisweek"]
	spam_thisweek = judgments_result["spam_thisweek"]
	total = judgments_result["total"]
	row_data = [
		user_id,
		email,
		abuse_thisweek,
		content_thisweek,
		cortex_thisweek,
		spam_thisweek,
		total
	]
end

def build_row3(agreement_result, redshift)
	user_id = agreement_result["user_id"]
	email = agreement_result["email"]
	abuse = agreement_result["abuse_agmnt"]
	content = agreement_result["content_discovery_agmnt"]
	cortex = agreement_result["cortex_agmnt"]
	spam = agreement_result["spam_agmnt"]
	row_data = [
		user_id,
		email,
		abuse,
		content,
		cortex,
		spam
	]
end

def build_row4(cortex_jobs_result, redshift)
	user_id = cortex_jobs_result["user_id"]
	email = cortex_jobs_result["email"]
	job_ids = cortex_jobs_result["job_ids"]
	judgments = cortex_jobs_result["judgments"]
	total_judgments = cortex_jobs_result["total_judgments"]
	row_data = [
		user_id,
		email,
		job_ids,
		judgments,
		total_judgments
	]
end

def send_email(now_date)
	mail = Mail.deliver do
		from 'cfcsdreports@gmail.com'
		to RECIPIENTS
		subject "CrowdFlower Twitter Usage Data #{now_date}"
		add_file "Twitter_RowsRun_ByTeam_#{now_date}.csv"
		add_file "Twitter_Judgments_PerUser_#{now_date}.csv"
		add_file "Twitter_Agreement_PerUser_#{now_date}.csv"
		add_file "Twitter_CortexJudgments_PerUser_#{now_date}.csv"
		body 'Hello,'
		body 'The attached documents contain an overview of rows run by team, judgments per user, and agreement per user last week. Let us know if you have any questions.'
		body 'Please note, the numbers for row usage correspond to row debits - negative numbers here mean rows ordered.'
	end
end

puts "Connecting to Redshift..."
redshift = connect_to_redshift
puts "Querying Redshift..."
row_usage_results = row_usage_query(redshift)
judgments_results = judgments_query(redshift)
agreement_results = agreement_query(redshift)
cortex_jobs_results = cortex_jobs_query(redshift)
puts "Creating CSV file..."
create_file1(row_usage_results, redshift, now_date, row_usage)
puts "First CSV file created!"
create_file2(judgments_results, redshift, now_date, judgments)
puts "Second CSV file created!"
create_file3(agreement_results, redshift, now_date, agreement)
puts "Third CSV created!"
create_file4(cortex_jobs_results, redshift, now_date, cortex_jobs)
puts "Fourth CSV created!"
puts "Sending email..."
send_email(now_date)
puts "E-Mail sent!"