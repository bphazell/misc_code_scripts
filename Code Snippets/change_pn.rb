require 'json'
require 'csv'
require 'rubygems'

input_csv = ARGV[0]

key = "af574018a6b7360b924c210c41d1f263e264cf83"
counter = 1

#This attempts to make API calls a bit more robust
def safe_parse(curl_command,parse=true, attempt = 1)
  response = `#{curl_command}`
  JSON.parse(response) if parse
rescue => e
  if attempt > 3
    puts "\n\nDebug error: #{e}\n\n"
    true_failure = true
    raise e
  else
    puts "\nRetrying #{curl_command} because: \n\n#{e.message}\n"
    sleep 2
    safe_parse(curl_command, parse, attempt + 1)
  end
end

CSV.foreach(input_csv, :headers => true) do |row|

  puts "\n\nNow attempting iteration: #{counter}"
  job_id = row["job_id"]
  new_pn = row["pn"]

  inst_response = safe_parse("curl 'https://api.crowdflower.com/v1/jobs/#{job_id}.json?key=#{key}'")
  instruction_test = inst_response["instructions"]
  if instruction_test == ""
    puts "******\n*****\nJob ID: #{job_id} has no instructions.  Now chaning that.\n*****\n*****"
    ints_response_test = safe_parse("curl -X PUT --data-urlencode 'job[instructions]=inserting instructions...' 'https://api.crowdflower.com/v1/jobs/#{job_id}.json?key=#{key}'")
  else
  end


  puts "Now attempting Job ID: #{job_id}"
  response_raw = safe_parse("curl -X PUT --data-urlencode 'job[project_number]=#{new_pn.to_s}' 'https://api.crowdflower.com/v1/jobs/#{job_id}.json?key=#{key}'")
  verify_pn = response_raw["project_number"] 
  verify_job_id = response_raw["id"]
  puts "Successfully changed to PN: #{verify_pn} for Job ID: #{verify_job_id}"
  if verify_pn != new_pn
    puts "UH OH! Something went wrong\n\n"
    break
  else
    puts "This was definitely successful.  YOURE AWESOME!\n\n"
  end
  counter += 1
end
