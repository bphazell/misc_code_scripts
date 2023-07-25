require 'desk_api'
require 'awesome_print'
require 'pg'
require 'csv'

#Script to automate test question process for community
#Written by Brian Hazell in Feb 2015
#Tested on Ruby 2.1.2

#id of the filter to find tickets in desk
FILTER_ID = 2270499

#connect to redshift
DB = PG::Connection.open(
  dbname: 'matt_crowdflower',
  user: 'matt_crowdflower',
  password: 'wznvhKJVAC135299756',
  host: 'cf-redshift.etleap.com',
  port: 5439
)

time = Time.now
time = time.strftime("%m_%d_%I:%M_%p")

#connect to desk_api
DeskApi.configure do |config|
  config.username = "community@crowdflower.com"
  config.password = "s3ntigold"
  config.endpoint = "https://crowdflower.desk.com"
end

FORGVIE_MESSAGE = "Hi {{customer.first_name}}, The Support Team reviewed the Test Questions you missed on this Job and determined that one or more of them was unfair or broken in some way. We’ve adjusted your Accuracy on this Job accordingly. We appreciate your efforts to report potentially unfair Test Questions to us and would like to thank you for your patience during the review process"

NOT_FORGIVE_MESSAGE = "Hi {{customer.first_name}}, Thanks for writing in. The Support Team reviewed the Test Questions you missed on this Job and determined that they do not qualify to be reviewed by an Admin. To keep up with our large support volume and help keep our support resolution times low, we require that Test Questions be missed by over 40% of Contributors that encounter them before they are reviewed by an Admin. Unfortunately, the Test Questions you missed in this Job did not meet this criteria, so we have not adjusted your accuracy for the Test Questions. Thank you for your understanding."

DESK_TICKETS_CLOSED_HEADERS = 
[
  "desk_id", 
  "status", 
  "message"
]

FORGIVE_RESULTS_HEADERS =
[
  "successful", 
  "job_id", 
  "unit_id", 
  "contributor_id", 
  "time_submitted", 
  "status"
]

######################################
### DONE WITH VARIABLE DECLARATION ###
######################################

class DeskObject
  def initialize(desk_csv)
    @desk_csv = desk_csv
    @desk_info = find_desk_ticket_objects
    @job_ids_for_sql = job_ids_for_sql
    @contributor_ids_for_sql = contributor_ids_for_sql
    @rs_forgive_info =  create_redshift_hash
  end

  def find_desk_ticket_objects
    desk_info = []
    # remove i in production
    i = 0
    DeskApi.cases(filter_id: FILTER_ID).all do |ticket, page|
      if ticket.to_hash['custom_fields']['contributor_id'] != nil
        desk_info << {
          desk_ticket: ticket,
          contributor_ids: "'#{ticket.to_hash['custom_fields']['contributor_id'].to_s}'",
          job_ids: "'#{ticket.to_hash['custom_fields']['job_id'].to_s}'",
          tq_issue_id: ticket.to_hash['custom_fields']['job_id'] + ticket.to_hash['custom_fields']['contributor_id']
        }
      end
      i += 1
      break if i == 25
    end
    desk_info
  end

  def job_ids_for_sql
    job_ids = []
    @desk_info.each do |ticket|
      job_ids << ticket[:job_ids]
    end
    job_ids.join(', ')
  end

  def contributor_ids_for_sql
    contributor_ids = []
    @desk_info.each do |ticket|
      contributor_ids << ticket[:contributor_ids]
    end
    contributor_ids.join(', ')
  end

  def value_counter
    #create new hash 'counter_hash' whose key is the tq_id and value is the number of occurances
    @rs_forgive_info.each_with_object(Hash.new { |hash, key| hash[key] = 0}) do |input_hash, counter_hash|
      counter_hash[input_hash[:tq_issue_id]] +=1
    end 
  end

  def group_multiples_together(multiple_values_hash)
    #create new array containing duplicate tq_ids
    multiple_values_hash.each_with_object([]) do |(key, value), final_array|
      #fills array with buckets where hashes in array have the same tq as in input array
      final_array << @rs_forgive_info.select { |el| el[:tq_issue_id] == key }
    end
  end

  def match_desk_tickets_to_redshift_results(bucket)
    matching_desk_tickets = @desk_info.find_all { |desk_t| desk_t[:tq_issue_id] == bucket[0][:tq_issue_id] }
  end

  def ticket_resolution(rs_bucketed_array)
    #iterate through array of buckets (array of dupes)
    rs_bucketed_array.each do |bucket|
      # matching_desk_tickets is all desk tickets equal to the query results
      matching_desk_tickets = match_desk_tickets_to_redshift_results(bucket)
      # number_of_forgives is all query results (in bucket) with forgive = true
      number_of_forgives = bucket.find_all { |hash| hash[:forgive] == "t" }.length
      if matching_desk_tickets.length > 0 && number_of_forgives > 0
        puts "--------------- forgive message -----------------------"
        matching_desk_tickets.each do |ticket|
          response = close_ticket(FORGVIE_MESSAGE, ticket[:desk_ticket], "forgive") 
        end
      elsif matching_desk_tickets.length > 0
        puts "------------don't forgive message -------------------"
        matching_desk_tickets.each do |ticket|
          response = close_ticket(NOT_FORGIVE_MESSAGE, ticket[:desk_ticket], "not_forgiven")
        end
      end 
    end
  end

 def close_ticket(message, ticket_object, type)
  begin
    sleep(1)
    reply = ticket_object.replies.create({
      body: message,
      direction: "out"
      })
    status = ticket_object.update({
      status: "resolved"
      })
    puts("Ticket #{ticket_object.to_hash["id"]} was resolved: #{type}")
    @desk_csv << [ ticket_object.to_hash["id"], "resolved", type ]
  rescue DeskApi::Error::Conflict => e
    puts("Skipping ticket #{ticket_object.to_hash["id"]} because it is locked by another user")
    @desk_csv << [ ticket_object.to_hash["id"], "skipped locked by other user" ]
  rescue DeskApi::Error::TooManyRequests => e
    puts("Hit rate limit. Sleeping for a minute")
    sleep(60)
    retry
    end
  end

  def create_redshift_hash
    forgive_info=[]
    redshift_results = query_redshift
    redshift_results.each do |tuple|
      create_hash(tuple, forgive_info)
    end
    forgive_info
  end

  private

  def create_hash(tuple, array)
    array << { 
      job_id: tuple["job_id"], 
      contributor_id: tuple["contributor_id"],
      unit_id: tuple["unit_id"],
      forgive: tuple["forgive"],
      tq_issue_id: tuple["tq_issue_id"]
    }
  end

  def query_redshift
    DB.query(
    "SELECT goldfinger_gold_instances.job_id as job_id,
              goldfinger_gold_judgments.worker_id as contributor_id,
              goldfinger_gold_instances.unit_id as unit_id,
              (goldfinger_gold_instances.job_id) + (goldfinger_gold_judgments.worker_id) as tq_issue_id,
              goldfinger_gold_instance_counts.total_count,
              goldfinger_gold_instance_counts.total_missed,
              ((goldfinger_gold_instance_counts.total_missed * 100) / (goldfinger_gold_instance_counts.total_count)) as percent_missed, 
              (builder_jobs.state <> 2 AND ((goldfinger_gold_instance_counts.total_missed * 100) / goldfinger_gold_instance_counts.total_count) > 60)
              OR  (builder_jobs.state = 2 AND ((goldfinger_gold_instance_counts.total_missed * 100) / (goldfinger_gold_instance_counts.total_count)) > 70)  as forgive
      FROM    goldfinger_gold_instances
      JOIN    goldfinger_gold_instance_counts ON gold_instance_id = goldfinger_gold_instances.id
      JOIN    goldfinger_gold_judgments ON goldfinger_gold_judgments.unit_id = goldfinger_gold_instances.unit_id
      JOIN    builder_jobs ON builder_jobs.id = goldfinger_gold_instances.job_id
      JOIN    builder_worksets ON (builder_worksets.worker_id = goldfinger_gold_judgments.worker_id AND builder_worksets.job_id = builder_jobs.id)
      WHERE   goldfinger_gold_judgments.job_id IN (#{@job_ids_for_sql})
        AND   goldfinger_gold_judgments.worker_id IN (#{@contributor_ids_for_sql})
        AND   missed_fields <> '[]'
      GROUP BY goldfinger_gold_instances.job_id, 
              goldfinger_gold_instances.unit_id, 
              goldfinger_gold_instance_counts.job_id, 
              goldfinger_gold_instances.id, 
              goldfinger_gold_instance_counts.gold_instance_id, 
              goldfinger_gold_instance_counts.total_count, 
              goldfinger_gold_instance_counts.total_missed,
              goldfinger_gold_instance_counts.total_contested,
              goldfinger_gold_judgments.worker_id,
              builder_jobs.state
      ORDER BY unit_id DESC
      LIMIT   50"
     )
  end
end

class ForgiveData
  def initialize(rs_forgive_info, forgive_csv)
    @rs_forgive_info = rs_forgive_info
    @forgive_csv = forgive_csv
  end

  def iterate_through_forgive_info
    @rs_forgive_info.each do |tuple|
      if tuple[:forgive] == "t"
        forgive_contributors(tuple)
      else
        do_not_forgive_contributors(tuple)
      end    
    end
  end

  def forgive_curl(job_id, unit_id, worker_id)
   `curl -s 'https://crowdflower.com/jobs/#{job_id}/workers/#{worker_id}' -H 'Cookie: optimizelyEndUserId=oeu1374108277234r0.9156798699405044; __mauuid=7f8e3f8d-c9c1-4ca3-aae3-6797f5801d9e; olfsk=olfsk4495328636839986; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; hsfirstvisit=https%3A%2F%2Fcrowdflower.com%2Fblog%2F%3Fp%3D8945||1389216287356; _mkto_trk=id:890-IJH-613&token:_mch-crowdflower.com-1375891859232-44393; __atuvc=2%7C3%2C0%7C4%2C1%7C5%2C0%7C6%2C2%7C7; mp_64ad2f3568e7a95ebcbd535a4f424a18_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Ftasks.crowdflower.com%2Fchannels%2Fcf_internal%2Fjobs%2F209625%2Feditor_preview%22%7D; mp_34db428377e01b5101a5659c6ebdfa7e_mixpanel=%7B%22distinct_id%22%3A%20%22141c8b7d7f582-098e6a992-68132675-13c680-141c8b7d7f65bb%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; mp_82b9518491269bbd6342e0a6fb9f259e_mixpanel=%7B%22distinct_id%22%3A%20159910%2C%22user_id%22%3A%200%2C%22groups%22%3A%20%5B%0A%20%20%20%20%22Even%22%0A%5D%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; _sio=b8a62de4-b9f0-4e1c-abdf-b9c7a6850413----23183; _ok=7808-547-10-4236; _session_id=BAh7CEkiHmF1dGhlbnRpY2F0aW9uX3N0cmF0ZWdpZXMGOgZFRjBJIg5yZXR1%250Acm5fdG8GOwBGWwZJIhEvam9icy80MTE2NTkGOwBGSSIJdXNlcgY7AEZJIg9V%250Ac2VyIzIzMTgzBjsARg%253D%253D--4f525259e8a35bc5e7e4fd0cfafbf5f255ac8740; _builder_user_id=BAhpAo9a--c989c892adad250ea2e98555fe9f79b204dfed4e; _sid=yVDGs9advgsfj_JATxMKqicbRBfMsmvK; optimizelySegments=%7B%22172094809%22%3A%22gc%22%2C%22172190267%22%3A%22false%22%2C%22172225027%22%3A%22direct%22%2C%22338723638%22%3A%22referral%22%2C%22338796251%22%3A%22false%22%2C%22339416244%22%3A%22gc%22%7D; optimizelyBuckets=%7B%22172111659%22%3A%22172095664%22%7D; _ch_elite=BAh7BkkiCHVpZAY6BkVUSSIKMzAxMDkGOwBU--f4c086bebfa8971274525ec1372853611bc3dbce; ajs_anonymous_id=%2223183%22; user_segment=Prospect; _worker_ui_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWFmNjM5ZTI3YzIzMDdlZmY3ZmUxZTc3ODNiODA5NmZiBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMThCSDhRWmZtUjVYV2lpU1JjcDZhYmlEdU9QZFRNVnlmU0NEVHJrR3NmUDg9BjsARg%3D%3D--e7a109b36567c0b962b15467c50b4a8f770936ab; mp_00f02d597c642b7efab39759dac628ea_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fcoolstuff.crowdflower.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22coolstuff.crowdflower.com%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D; __utma=105072849.1211284818.1374012347.1414689738.1414696952.1598; __utmc=105072849; __utmz=105072849.1414696952.1598.788.utmcsr=make.crowdflower.com|utmccn=(referral)|utmcmd=referral|utmcct=/jobs/634593/preview; __utmv=105072849.worker_ui; _okac=f5b04657275be2cc57e5cb4cc59a8581; _okla=1; _make_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJTgwZWI4YTZhMzgwNjgzNzEyNTU1YmQ1OWQ3YjI0ZWRlBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMWIweVRYOFNBR2xVUGUxa0pSYnZ6QUlkcFFuRDZhdXY5aTVHS0hEYW01a009BjsARg%3D%3D--bfc4b8fb94f02619af3d7db22911d7e218879ae5; _okbk=cd4%3Dtrue%2Ccd5%3Davailable%2Cvi5%3D0%2Cvi4%3D1414685530544%2Cvi3%3Dactive%2Cvi2%3Dfalse%2Cvi1%3Dfalse%2Ccd8%3Dchat%2Ccd6%3D0%2Ccd3%3Dfalse%2Ccd2%3D0%2Ccd1%3D0%2C; _gat=1; ajs_group_id=null; ajs_user_id=23183; mp_e0fd08bd7e74d0bf03862bb8de3a5168_mixpanel=%7B%22distinct_id%22%3A%2023183%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22plan%22%3A%20%22admin%22%2C%22company%22%3A%20null%2C%22balance%22%3A%2015477.8%2C%22first_name%22%3A%20%22Brian%22%2C%22last_name%22%3A%20null%2C%22lastName%22%3A%20null%2C%22team_admin%22%3A%20false%2C%22subscription_unit_limit%22%3A%20%22%22%2C%22subscription_units_used%22%3A%20%22%22%2C%22subscription_expires_at%22%3A%20%22%22%2C%22subscription_type%22%3A%20%22%22%2C%22title%22%3A%20null%2C%22phone_number%22%3A%20null%2C%22phone%22%3A%20null%2C%22id%22%3A%2023183%2C%22%24created%22%3A%20%222013-07-16T15%3A05%3A16.000Z%22%2C%22%24email%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24first_name%22%3A%20%22Brian%22%2C%22%24name%22%3A%20%22Brian%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Fmake.crowdflower.com%2Fjobs%2F628946%22%7D; __hstc=14529640.bb743abbae725dd601645001094acd40.1389216287361.1414685527797.1414688901863.958; __hssrc=1; __hssc=14529640.175.1414688901863; hubspotutk=bb743abbae725dd601645001094acd40; olfsk=olfsk4495328636839986; wcsid=Asbm7WoAB6cmoOlc6N49s889DWrK1oFp; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _ga=GA1.2.1211284818.1374012347; _oklv=1414700841614%2CAsbm7WoAB6cmoOlc6N49s889DWrK1oFp' -H 'Origin: https://crowdflower.com' -H 'Accept-Encoding: gzip,deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36' -H 'Content-type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: text/javascript, text/html, application/xml, text/xml, */*' -H 'Referer: https://crowdflower.com/jobs/633623/contributors/27157168' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data '_method=put&forgive=#{unit_id}' --compressed`
  end

  def do_not_forgive_contributors(tuple)
    puts ""
    puts 
    puts "*********************************************"
    puts "Job ID: #{tuple[:job_id]}"
    puts "Unit ID: #{tuple[:unit_id]}"
    puts "contributor_id: #{tuple[:contributor_id]}"
    puts "forgive: #{tuple[:forgive]}"
    puts ""
    puts "Do Not Forgive"
    puts "*********************************************"
    time = Time.now
    time = time.strftime("%m_%d_%I:%M_%p")
    @forgive_csv << ["true", tuple[:job_id], tuple[:unit_id], tuple[:contributor_id], time, "Not Forgiven"]
  end

  def forgive_contributors(tuple)
    begin
      response = forgive_curl(tuple[:job_id], tuple[:unit_id], tuple[:contributor_id])
        puts ""
        puts "*********************************************"
        puts "Job ID: #{tuple[:job_id]}"
        puts "Unit ID: #{tuple[:unit_id]}"
        puts "contributor_id: #{tuple[:contributor_id]}"
        puts "forgive: #{tuple[:forgive]}"
        puts ""
        puts response
        puts "*********************************************"
        time = Time.now
        time = time.strftime("%m_%d_%I:%M_%p")
        if response == "Judgment was successfully forgiven."
          @forgive_csv << ["true", tuple[:job_id], tuple[:unit_id], tuple[:contributor_id], time, "Forgiven"]
        else 
          @forgive_csv << ["false", tuple[:job_id], tuple[:unit_id], tuple[:contributor_id], time, "Error"]
        end
    rescue
         @forgive_csv << ["false", tuple[:job_id], tuple[:unit_id], tuple[:contributor_id], time, "Error"]      
      end
    sleep 5
    end
end

#########################
### ACTUAL PROCESSING ###
#########################

CSV.open("Desk_Tickets_Closed_#{time}.csv", "w", headers: DESK_TICKETS_CLOSED_HEADERS, write_headers: true) do |desk_csv|
  CSV.open("Results_of_Forgiving_Contributors_#{time}.csv","w", headers: FORGIVE_RESULTS_HEADERS, write_headers: true) do |forgive_csv|
  desk = DeskObject.new(desk_csv)
  #close desk tickets
  multiple_values_hash = desk.value_counter
  rs_bucketed_array = desk.group_multiples_together(multiple_values_hash)
  resolve_test = desk.ticket_resolution(rs_bucketed_array)
  #forgive contributors
  rs_forgive_info = desk.instance_variable_get(:@rs_forgive_info)
  forgive_object = ForgiveData.new(rs_forgive_info, forgive_csv)
  forgive_object.iterate_through_forgive_info
  end
end













