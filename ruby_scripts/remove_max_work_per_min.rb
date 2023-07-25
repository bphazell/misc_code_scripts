require 'pg'
require 'awesome_print'
require 'httparty'
require 'csv'

team_id = '13c3065b-ff67-4d9d-a4ab-bbc3c778b94d'
HEADERS = ['job_id', 'updated?']

def connect_to_redshift
	redshift = PG.connect(
		dbname: 'matt_crowdflower',
		host: 'cf-redshift.etleap.com',
		user: "matt_crowdflower",
		password: 'wznvhKJVAC135299756',
		port: 5439,
		)
end

def query1(redshift, team_id)
	query_results = redshift.query("
		SELECT akon_teams.id as team_id, 
						akon_teams.name, 
						builder_jobs.id as job_id, 
						builder_jobs.max_assignments_per_minute
		FROM akon_teams
		JOIN builder_jobs on builder_jobs.team_id = akon_teams.id
		WHERE akon_teams.id IN ('#{team_id}')
		AND builder_jobs.max_assignments_per_minute IS NOT NULL"
		)

	end

def remove_max_per_min(query_results)
	param = URI.encode("job[max_assignments_per_minute]")
	if query_results.ntuples > 0
		CSV.open("remove_max_work_per_minute_results.csv", "w", write_headers:true, headers:HEADERS) do |csv|
			query_results.each do |tuple|
				ap "job_id: #{tuple['job_id']}"
				response =  HTTParty.put("https://api.crowdflower.com/v1/jobs/#{tuple['job_id']}.json?#{param}=8&key=sXhKBtZPvLiDjWbGcEtN")
				ap response.code
				csv << [tuple['job_id'], response.success?]
			end
	end
	else
		puts "Query Did Not Return Any Results"
	end
end

puts "Connecting to Redshift..."
redshift = connect_to_redshift
puts "Querying Redshift..."
query_results = query1(redshift, team_id)
puts "Removing Instances of Max Work Per IP..."
remove_max_per_min(query_results)

