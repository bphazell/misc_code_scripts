
require 'awesome_print'
require 'csv'
require 'mail'
require 'sequel'
require 'json'
require 'pg'

# RECIPIENTS = 	['bhazell@crowdflower.com',
# 				 'julia.guthrie@crowdflower.com',
# 				  'blake.street@crowdflower.com']

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
		select amount
	from public.builder_credit_balances 
	where team_id = '35703a4e-a35d-446f-bc17-fdf921b7a1fb'"
	)
end

def threshBody(funds, thresh)
	"The funds in your account passed the #{thresh.gsub('under_','')} threshold"
end

def send_email(funds, thresh)
	text = threshBody(funds, thresh)
	mail = Mail.deliver do
		from 'cfcsdreports@gmail.com'
		to RECIPIENTS
		subject "Lyst funds at #{funds}"
		body text
	end
end


def threshFunc(funds, row, thresh)
	if funds < thresh
		ap "less than #{thresh}"
		emailLogic(row, funds, "under_#{thresh}")
		row["under_#{thresh}"] = 1
	elsif funds > thresh
		ap "more than #{thresh}"
		row["under_#{thresh}"] = 0
	end

end

def fundLogic(funds, row, data)
	begin
		threshFunc(funds, row, 15000)
		threshFunc(funds, row, 10000)
		threshFunc(funds, row, 5000)
	rescue
		print 'broke'
		data
	end
end

def emailLogic(row, funds, thresh)
	if row[thresh] == '0'
		ap "send #{thresh} email"
		send_email(funds, thresh)
	end
end

def send_email_nl(funds)
	mail = Mail.deliver do
		from 'cfcsdreports@gmail.com'
		to RECIPIENTS
		subject "Lyst funds at #{funds}"
		body "FYI"
	end
end

def parseResults(query_result)
	output = ""
	query_result.each do |tupple|
		output << tupple["amount"]
	end
	return output  
end

# funds = 14000
puts "Connecting to Redshift..."
redshift = connect_to_redshift
puts "Querying Redshift..."
query1_results = query1(redshift)
funds = parseResults(query1_results)
funds = (funds.to_f * 0.01).round(2)
ap funds 
send_email_nl(funds)

CSV.foreach("lyst_email_tracker.csv", :headers => true) do |row|
	CSV.open("lyst_email_tracker.csv", 'w', :write_headers => true, :headers => ["under_15000","under_10000", "under_5000"]) do |out|
		data = row
		fundLogic(funds, row, data)
		ap row
		out << row
	end
end

