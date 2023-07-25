require 'restforce'
require 'awesome_print'
require 'csv'
require 'pg'
require 'date'


# The jobs you want to view the had a conversion after a specified data. Ex: 2013-11-01
active_jobs_range = "2014-10-31"

time = Time.now.strftime("%Y-%m-%d")

# Connect to SalesForce API
client = Restforce.new :username => 'andy@crowdflower.com',
:password => '1awesomepassword',
:security_token => 'fI3It3FCdoFuEYOixIin9gck9',
:client_id => '3MVG9yZ.WNe6byQADrJ.3pNJkp1YwOg43Fdw4JQr5dfRbJqpZGto6arY5uSxst8zS2dvewgiil7eiS5eF86ds',
:client_secret => '7380858972881717415'


results = client.query("
	SELECT Work_Order__c.Earned_Date__c, Work_Order__c.Work_Order_Fee_Type__c, Work_Order__c.Project__r.Name, 
		Work_Order__c.Project__r.Account__r.Name, Work_Order__c.Project__r.Target_Completion_Date__c
	FROM Work_Order__c
	WHERE Work_Order__c.Project__r.Target_Completion_Date__c > #{time}
	LIMIT 75
	")

# Create a hash to store SF results
my_hash = {}

results.each do |item|
	e_date = item.attrs["Earned_Date__c"]
	fee_type = item.attrs["Work_Order_Fee_Type__c"]
	pn = item["Project__r"].attrs["Name"]
	name = item["Project__r"]["Account__r"].attrs["Name"]
	c_date = item["Project__r"].attrs["Target_Completion_Date__c"]
	my_hash[pn] = [name, e_date, fee_type, c_date]
end

# Connect to Redshift
redshift = PG.connect( 
	dbname: 'matt_crowdflower', 
	host: 'cf-redshift.etleap.com',
	user: "matt_crowdflower",
	password: 'wznvhKJVAC135299756',
	port: 5439,
	)

csv_headers =["salesforce_pn", "salesforce_account", "sf_earned_date", "sf_fee_type", "contract_exp_date", "builder_organizations_pn",
	"builder_jobs_pn", "organization_id", "team_name", "team_id", "akon_user_id", 
	"builder_user_id", "email", "job_id", "last_conversion", "job_cost"]

#Create CSV for builder_organizations query results
	CSV.open("builder_organizations_query_results.csv", "w", write_headers:true, headers:csv_headers) do |build_org|
		#Create CSV for builder_jobs query results
		CSV.open("missing_pns_from_builder_organizations_query_results.csv", "w", write_headers:true, headers:csv_headers) do |build_jobs|
			#Iterate through SF Hash to populate redshift query	
			my_hash.each do |pn, array|
				rs_query_build_org = redshift.query("
					SELECT builder_organizations.project_number as builder_organizations_pn, builder_jobs.project_number as builder_jobs_pn, 
						builder_organizations.id as organization_id, akon_teams.name as team_name, akon_teams.id as team_id, 
						akon_team_memberships.user_id as akon_user_id, 
						builder_users.id as builder_user_id, builder_users.email as email, builder_jobs.id as job_id, max(builder_conversions.started_at) as last_conversion, ROUND(SUM(builder_conversions.amount),3) as job_cost
					FROM builder_organizations
					JOIN akon_teams on akon_teams.organization_id = builder_organizations.id
					JOIN akon_team_memberships on akon_team_memberships.team_id = akon_teams.id
					JOIN builder_users on builder_users.akon_id = akon_team_memberships.user_id
					JOIN builder_jobs on builder_jobs.user_id = builder_users.id
					JOIN builder_conversions on builder_conversions.job_id = builder_jobs.id
					WHERE builder_organizations.project_number = '#{pn}'
						AND builder_conversions.started_at >= '#{active_jobs_range}'
					GROUP BY builder_organizations.project_number,builder_jobs.project_number, builder_organizations.id,akon_teams.name, akon_teams.id,
						akon_teams.id,builder_users.id, akon_team_memberships.user_id,builder_users.email, builder_jobs.id, builder_conversions.amount
					ORDER BY builder_users.id ASC	
				")
				# if rs_query results are not empty for PN, fill csv with info
				if rs_query_build_org.ntuples > 0
					rs_query_build_org.each do |tuple|
						for_output = []
						for_output << pn

						array.each do |info|
							for_output << info
						end
						
						tuple.values.each do |col|
							for_output << col
						end

						build_org << for_output
					end

				else
					# Take note where PNS are not present in builder_organizations
					    for_output = []
						for_output << pn

						array.each do |info|
							for_output << info
						end

						for_output << "SalesForce PN not found in builder_organizations"
						build_org << for_output

						# Run Query on missing PNs in builder_jobs 
						rs_query_build_jobs = redshift.query("
						SELECT builder_jobs.project_number as builder_jobs_pn,akon_teams.organization_id,akon_teams.name as team_name,
							akon_team_memberships.team_id as team_id,akon_users.id as akon_user_id,	builder_jobs.user_id as builder_user_id,
							akon_users.email, 	builder_jobs.id as job_id, max(builder_conversions.started_at) as last_conversion,
							ROUND(SUM(builder_conversions.amount),3) as job_cost
						FROM builder_jobs
						JOIN builder_users on builder_users.id = builder_jobs.user_id
						JOIN akon_users on akon_users.id = builder_users.akon_id
						JOIN builder_conversions on builder_jobs.id = builder_conversions.job_id
						JOIN akon_team_memberships on akon_team_memberships.user_id = akon_users.id
						JOIN akon_teams on akon_teams.id = akon_team_memberships.team_id
						WHERE builder_jobs.project_number = '#{pn}'
							AND builder_conversions.started_at >= '#{active_jobs_range}'
						GROUP BY builder_jobs.project_number, builder_jobs.id,
							builder_jobs.user_id, akon_users.id, akon_users.email,
							akon_team_memberships.team_id, akon_teams.organization_id, akon_teams.name
						")
							# if build_jobs query is not empty, fill csv
							if rs_query_build_jobs.ntuples > 0
								rs_query_build_jobs.each do |tuple|
									for_output = []
									for_output << pn

									array.each do |info|
										for_output << info
									end
									for_output << "not_found"

									tuple.values.each do |col|
										for_output << col
									end

									build_jobs << for_output

								end
							else
								# Take note when PNs are not present in builder_jobs
								for_output = []
									for_output << pn

									array.each do |info|
										for_output << info
									end

									for_output << "SalesForce PN not found in builder_jobs"
									build_jobs << for_output
							end
				end
					
						
			end	
		end
	end

input = "builder_organizations_query_results.csv"

csv_headers =["salesforce_pn", "salesforce_account", "sf_earned_date", "sf_fee_type", "contract_exp_date", "builder_organizations_pn",
	"builder_jobs_pn", "organization_id", "team_name", "team_id", "akon_user_id", 
	"builder_user_id", "email", "job_id", "last_conversion", "job_cost"]

CSV.open("jobs_with_mismathed_pns.csv", "w", write_headers: true, headers:csv_headers) do |out|
	CSV.foreach(input, headers:true) do |row|
		builder_orgs = row["builder_organizations_pn"]
		builder_jobs = row["builder_jobs_pn"]
		if builder_orgs != builder_jobs
			out << row

		end
	end	
end

