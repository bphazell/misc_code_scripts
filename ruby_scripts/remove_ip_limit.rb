require 'pg'
require 'awesome_print'
require 'httparty'

team_id = '677cc342-c327-4297-ae2c-78257db210ba'

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
						builder_jobs.max_judgments_per_ip
		FROM akon_teams
		JOIN builder_jobs on builder_jobs.team_id = akon_teams.id
		WHERE akon_teams.id IN ('#{team_id}')
		AND builder_jobs.max_judgments_per_ip IS NOT NULL"
		)

	end

def remove_ip(query_results)
	param = URI.encode("job[max_judgments_per_ip]")
	if query_results.ntuples > 0
		query_results.each do |tuple|
			ap "job_id: #{tuple['job_id']}"
			response =  HTTParty.put("https://api.crowdflower.com/v1/jobs/#{tuple['job_id']}.json?#{param}=&key=sXhKBtZPvLiDjWbGcEtN")
			ap response.code
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
remove_ip(query_results)

