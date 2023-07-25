# READ ME
#
# This script lets you copy a job and redirect the new copy to a different user
# You can choose to copy the job without units, with gold units, or with all units
# 
# To use this script:
# 1. Specify the path to your CSV 
# 2. Make sure your CSV's first three columns match these headers:
  # job_id      --> The # of the job you are copying
  # user_email  --> The email of the new job_owner
  # copy_type   --> Choose all, gold or leave blank for none
#
# If you have any issues/ questions/ requests email enterprise.engineering@crowdflower.com :)

require 'csv'
require 'json'

AUTH_KEY = "af574018a6b7360b924c210c41d1f263e264cf83"
HEADERS = ["job_id", "user_email", "copy_type"]

# This copies a job based on the copy_type specified
def copy(job_id, auth_key, copy_type)
  copy_param = ""
  if copy_type == "all"
  # Note: if copy_type is gold but the job doesn't have gold units, the script will just copy all units  
    copy_param = "&all_units=true"
  elsif copy_type == "gold"
    copy_param = "&gold=true"
  end
  
  job_copy_response = `curl -X POST 'https://api.crowdflower.com/v1/jobs/#{job_id}/copy.json?key=#{AUTH_KEY}#{copy_param}'`

  # This parses the response so that we can use the copied job's id when transferring it to a new job_owner
  JSON.parse(job_copy_response)
end

# This updates the newly copied job's owner
def update_owner(job_id, user_email, auth_key)
  `curl -X PUT --data-urlencode 'job[owner_email]=#{user_email}' 'https://make.crowdflower.com/jobs/#{job_id}/settings/general.json?key=#{AUTH_KEY}'`
end

# This returns the headers of a given CSV file
def get_headers(csv_file)
  CSV.open(csv_file, 'r', headers: true) do |csv|
    csv.first.headers
  end
end

csv_file = ARGV[0]
  # Checks that a file was included
  if csv_file.nil?
    raise "Looks like you haven't included the path to your CSV file. Just type ruby update_owner.rb path/your_csv.csv"  
  # Checks that the correct headers are included in the CSV
  elsif get_headers(csv_file) & HEADERS != HEADERS
    raise "Required headers are: '#{HEADERS}' but the CSV's headers are: '#{get_headers(csv_file).inspect}'"
    p get_headers(csv_file).first(3)
    p HEADERS.first(3)
  else
    p "Loaded CSV, now checking the rows"
  end

CSV.foreach(csv_file, headers: true) do |row|
  job_id = row["job_id"]
  user_email = row["user_email"]
  copy_type = row["copy_type"]
  p "Copying '#{job_id}' with '#{copy_type}' units"
 
  # Checks that a job_id and user_email are included
  if job_id.nil? || user_email.nil?
      raise "The CSV has empty row(s), or invalid value(s) for job_id and/or user_email. Double check the data and run again."
  else
    parsed_job_copy_response = copy(job_id, AUTH_KEY, copy_type)
    new_job_id = parsed_job_copy_response["id"]
    p "Now updating '#{new_job_id}' owner to '#{user_email}'"
    update_owner(new_job_id, user_email, AUTH_KEY)
  end
end