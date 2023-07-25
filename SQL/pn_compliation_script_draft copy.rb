require 'restforce'
require 'awesome_print'
require 'pg'
require 'csv'

#connnect to SalesForce API
# client = Restforce.new :username => 'andy@crowdflower.com',
# :password => '1awesomepassword',
# :security_token => 'fI3It3FCdoFuEYOixIin9gck9',
# :client_id => '3MVG9yZ.WNe6byQADrJ.3pNJkp1YwOg43Fdw4JQr5dfRbJqpZGto6arY5uSxst8zS2dvewgiil7eiS5eF86ds',
# :client_secret => '7380858972881717415'

# # Query Salesforce: Join Projects and Account Tables
# results = client.query("
# 	SELECT Projects__c.Name, Projects__c.Account__r.Name
# 	FROM Projects__c")

# #Create a Hash to store Pns and Company Names
# myhash = {}
# results.each do |result|
# 	pn = result.attrs["Name"]
# 	name = result.to_h["Account__r"].attrs["Name"]
# 	myhash[pn] = name
# end

# # create test hash with first 20 items in SF result
# test_hash = {}
# i = 0
# myhash.each do |k,v|
# 	i += 1
# 	test_hash[k] = v
# 	break if i == 20
# end 
pn_key = ["PN237","PN575","PN425","PN930","PN378","PN602","PN67","PN68","PN586","PN43","PN187","PN379","PN189","PN380","PN42","PN1384","PN1385","PN381","PN190","PN1098"]

pn_value = ["Fisher Investments","Infogroup","Answers.com","NJOY Electronic Cigarettes","Bartle Bogle Hogarty","Groupon","Microsoft","Microsoft","Microsoft","InsideView, Inc.","eBay","DocuSign","eBay","Lonely Planet","InsideView, Inc.","Washington University School of Medicine","Washington University School of Medicine","CNET/CBS Interactive Inc.","eBay","RainforestQA"]

test_hash = {}
for i in 0..19
	test_hash[pn_key[i]] = pn_value[i]
end

#Connect to Redshift
redshift = PG.connect( 
	dbname: 'matt_crowdflower', 
	host: 'cf-redshift.etleap.com',
	user: "matt_crowdflower",
	password: 'wznvhKJVAC135299756',
	port: 5439,
	)

csv_headers =["salesforce_pn", "salesforce_account", "builder_organizations_pn",
	"builder_jobs_pn", "organization_id", "team_name", "team_id", "akon_user_id", 
	"builder_user_id", "email", "job_id", "last_conversion"]

    #Create CSV for builder_organizations query results
	CSV.open("test_write_builder_organizations_query_results.csv", "w", write_headers:true, headers:csv_headers) do |build_org|
		#Create CSV for builder_jobs query results
		CSV.open("test_write_builder_jobs_query_results.csv", "w", write_headers:true, headers:csv_headers) do |build_jobs|
			#Iterate through SF Hash to populate redshift query	
			test_hash.each do |pn, name|
				rs_query_build_org = redshift.query("
					SELECT builder_organizations.project_number as builder_organizations_pn, builder_jobs.project_number as builder_jobs_pn, 
						builder_organizations.id as organization_id, akon_teams.name as team_name, akon_teams.id as team_id, 
						akon_team_memberships.user_id as akon_user_id, 
						builder_users.id as builder_user_id, builder_users.email as email, builder_jobs.id as job_id, max(builder_conversions.started_at) as last_conversion
					FROM builder_organizations
					JOIN akon_teams on akon_teams.organization_id = builder_organizations.id
					JOIN akon_team_memberships on akon_team_memberships.team_id = akon_teams.id
					JOIN builder_users on builder_users.akon_id = akon_team_memberships.user_id
					JOIN builder_jobs on builder_jobs.user_id = builder_users.id
					JOIN builder_conversions on builder_conversions.job_id = builder_jobs.id
					WHERE builder_organizations.project_number = '#{pn}'
						AND builder_conversions.started_at >= '2013-11-01'
					GROUP BY builder_organizations.project_number,builder_jobs.project_number, builder_organizations.id,akon_teams.name, akon_teams.id,
						akon_teams.id,builder_users.id, akon_team_memberships.user_id,builder_users.email, builder_jobs.id
					LIMIT 10
				")
				# if rs_query results are not empty for PN, fill csv with info
				if rs_query_build_org.ntuples > 0
					rs_query_build_org.each do |tuple|
						for_output = [pn, name]

						tuple.values.each do |col|
							for_output << col
						end
						build_org << for_output
					end
				else
					# Note where PNS are not present in builder_organizations
					for_output = [pn, name]
					for_output << "SalesForce PN not found in builder_organizations or outdated"
					build_org << for_output

					# Run Query on missing PNs in builder_jobs 
					rs_query_build_jobs = redshift.query("
						SELECT builder_jobs.project_number as builder_jobs_pn,akon_teams.organization_id,akon_teams.name as team_name,
							akon_team_memberships.team_id as team_id,akon_users.id as akon_user_id,	builder_jobs.user_id as builder_user_id,
							akon_users.email, 	builder_jobs.id as job_id, max(builder_conversions.started_at) as last_conversion
						FROM builder_jobs
						JOIN builder_users on builder_users.id = builder_jobs.user_id
						JOIN akon_users on akon_users.id = builder_users.akon_id
						JOIN builder_conversions on builder_jobs.id = builder_conversions.job_id
						JOIN akon_team_memberships on akon_team_memberships.user_id = akon_users.id
						JOIN akon_teams on akon_teams.id = akon_team_memberships.team_id
						WHERE builder_jobs.project_number = '#{pn}'
							AND builder_conversions.started_at >= '2013-11-01'
						GROUP BY builder_jobs.project_number, builder_jobs.id,
							builder_jobs.user_id, akon_users.id, akon_users.email,
							akon_team_memberships.team_id, akon_teams.organization_id, akon_teams.name
						LIMIT 10
						")
						# if build_jobs query is not empty, fill csv
						if rs_query_build_jobs.ntuples > 0
							rs_query_build_jobs.each do |tuple|
								for_output = [pn, name, "not_found"]
								tuple.values.each do |col|
									for_output << col
								end
								build_jobs << for_output
							end
						else
							# Note when PNs are not present in builder_jobs
							for_output = [pn, name, "not_found"]
							for_output << "SalesForce PN not found in builder_jobs"
							build_jobs << for_output
						end

				end
			end
		end
	end



