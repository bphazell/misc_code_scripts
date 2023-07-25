require 'pg'
require 'awesome_print'
require 'httparty'
require 'csv'

team_id = 'ac0b8c8c-7d58-44e8-b2d7-875e46071fc3'
HEADERS = ['job_id', 'response']

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
		CSV.open("remove_ip_results.csv", "w", write_headers:true, headers:HEADERS) do |csv|
			query_results.each do |tuple|
				ap "job_id: #{tuple['job_id']}"
				response =  HTTParty.put("https://api.crowdflower.com/v1/jobs/#{tuple['job_id']}.json?#{param}=&key=sXhKBtZPvLiDjWbGcEtN")
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
remove_ip(query_results)

