require 'mail'
require 'chronic'
require 'sequel'
require 'json'
require 'pg'
require 'date'
require 'csv'
require 'awesome_print'

now = Date.today
last_week = (now - 7)
lastwk_date = last_week.strftime("%Y-%m-%d")
puts lastwk_date

HEADERS = ["Job ID", "Job Title", "Job State", "Number of Rows Finalized", "Job Cost", "Order Amount"]

p lastwk_date

# RECIPIENTS = 	['misti@crowdreason.com',
#  				'brandon@crowdreason.com',
#  				'carl@crowdreason.com',
#  				'andy@crowdflower.com',
#  				'glenn.volk@crowdflower.com',
#  				'jennifer.lee@crowdflower.com']
RECIPIENTS = 	['bhazell@crowdflower.com']

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



def query1(redshift)
	query_results = redshift.query("
		SELECT builder_jobs.id AS job_id,
		builder_jobs.title AS job_title,
		builder_jobs.state AS job_state,
		payments.paid_amt AS job_cost,
		unit_info.row_count AS rows_finalized,
		order_info.order_amount AS order_amount
FROM builder_jobs
JOIN (SELECT ROUND((SUM(builder_conversions.amount)*1.2)::FLOAT,2) as paid_amt, builder_conversions.job_id
      FROM builder_conversions
      WHERE builder_conversions.created_at BETWEEN (CURRENT_DATE - INTERVAL '7 DAYS') AND CURRENT_DATE
      GROUP BY builder_conversions.job_id) as payments ON builder_jobs.id = payments.job_id
JOIN (SELECT count(distinct(builder_units.id)) AS row_count, builder_units.job_id
			FROM builder_units
			WHERE builder_units.state NOT IN (1,6,7,8)
			AND builder_units.updated_at BETWEEN (CURRENT_DATE - INTERVAL '7 DAYS') AND CURRENT_DATE
			GROUP BY builder_units.job_id) AS unit_info ON builder_jobs.id = unit_info.job_id
JOIN (SELECT SUM(builder_orders.amount_in_cents) AS order_amount, builder_orders.job_id
		FROM builder_orders
		WHERE builder_orders.created_at BETWEEN (CURRENT_DATE - INTERVAL '7 DAYS') AND CURRENT_DATE
		GROUP BY builder_orders.job_id) AS order_info ON builder_jobs.id = order_info.job_id
WHERE builder_jobs.team_id = '8888b0ab-1855-459f-8521-a7a3cc8f3622'
ORDER BY builder_jobs.id ASC"
	)
end


def create_file(query1_results, redshift, lastwk_date)
	CSV.open("CrowdReason_JobReport_week_of_#{lastwk_date}.csv",'w', headers: HEADERS, write_headers: true) do |csv|
		query1_results.each_with_index do |query1_result|
			row_data = build_row(query1_result, redshift)
			return "" if row_data == false
			csv << row_data
		end
	end
end

def build_row(query1_result, redshift)
	job_title = query1_result["job_title"]
	job_id = query1_result["job_id"]
	job_state = interpret_state(query1_result)
	rows_finalized = query1_result["rows_finalized"]
	job_cost = query1_result["job_cost"]
	order_amount = query1_result["order_amount"]
	payment = interpret_order_amount(job_cost, order_amount)
	row_data = [
		job_id,
		job_title,
		job_state,
		rows_finalized,
		payment,
		order_amount
	]
end

def interpret_order_amount(job_cost, order_amount)
	order_amount = order_amount.to_s
	if order_amount == "0"
		"Internal"
	else
		job_cost
	end
end

def interpret_state(query1_result)
	state_num = query1_result["job_state"].to_s
	if state_num == "1"
		state = "Unordered"
	elsif state_num == "2"
		state = 'Running'
	elsif state_num == "3"
		state = 'Paused'
	elsif state_num == "4"
		state = 'Canceled'
	elsif state_num == "5"
		state = 'Finished'
	else
		state = state_num
	end
end

def send_email(lastwk_date)
	mail = Mail.deliver do
		from 'cfcsdreports@gmail.com'
		to RECIPIENTS
		subject "CrowdReason Job Report Week #{lastwk_date}"
		add_file "CrowdReason_JobReport_Week_of_#{lastwk_date}.csv"
		body 'Hello,'
		body 'The attached document contains a job overview of the past week. Let us know if you have any questions.'
	end
end

puts "Connecting to Redshift..."
redshift = connect_to_redshift
puts "Querying Redshift..."
query1_results = query1(redshift)
puts "Creating CSV file..."
create_file(query1_results, redshift, lastwk_date)
puts "CSV file created!"
puts "Sending email..."
send_email(lastwk_date)
puts "E-Mail sent!"