
require 'csv'

#input a csv file containing the job_id and unit_id that all contributors should be forgiven for
input_file = ARGV[0]

#Returns an array containing ids of all workers that submitted a judgment on the unit id
def get_worker_ids(job_id, unit_id)
response =  `curl 'https://crowdflower.com/jobs/#{job_id}/units/#{unit_id}' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: https://crowdflower.com/jobs/#{job_id}/golds/#{unit_id}/edit' -H 'Cookie: optimizelyEndUserId=oeu1374108277234r0.9156798699405044; __mauuid=7f8e3f8d-c9c1-4ca3-aae3-6797f5801d9e; olfsk=olfsk4495328636839986; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; hsfirstvisit=https%3A%2F%2Fcrowdflower.com%2Fblog%2F%3Fp%3D8945||1389216287356; _mkto_trk=id:890-IJH-613&token:_mch-crowdflower.com-1375891859232-44393; __atuvc=2%7C3%2C0%7C4%2C1%7C5%2C0%7C6%2C2%7C7; mp_64ad2f3568e7a95ebcbd535a4f424a18_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Ftasks.crowdflower.com%2Fchannels%2Fcf_internal%2Fjobs%2F209625%2Feditor_preview%22%7D; mp_34db428377e01b5101a5659c6ebdfa7e_mixpanel=%7B%22distinct_id%22%3A%20%22141c8b7d7f582-098e6a992-68132675-13c680-141c8b7d7f65bb%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; mp_82b9518491269bbd6342e0a6fb9f259e_mixpanel=%7B%22distinct_id%22%3A%20159910%2C%22user_id%22%3A%200%2C%22groups%22%3A%20%5B%0A%20%20%20%20%22Even%22%0A%5D%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; _sio=b8a62de4-b9f0-4e1c-abdf-b9c7a6850413----23183; optimizelySegments=%7B%22172094809%22%3A%22gc%22%2C%22172190267%22%3A%22false%22%2C%22172225027%22%3A%22direct%22%2C%22338723638%22%3A%22referral%22%2C%22338796251%22%3A%22false%22%2C%22339416244%22%3A%22gc%22%7D; optimizelyBuckets=%7B%22172111659%22%3A%22172095664%22%7D; ajs_anonymous_id=%2223183%22; user_segment=Prospect; mp_00f02d597c642b7efab39759dac628ea_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fcoolstuff.crowdflower.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22coolstuff.crowdflower.com%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D; _ok=7808-547-10-4236; _okbk=cd5%3Davailable%2Ccd4%3Dtrue%2Cvi5%3D0%2Cvi4%3D1415051722042%2Cvi3%3Dactive%2Cvi2%3Dfalse%2Cvi1%3Dfalse%2Ccd8%3Dchat%2Ccd6%3D0%2Ccd3%3Dfalse%2Ccd2%3D0%2Ccd1%3D0%2C; _sid=3b9TYxyeX85izjkeZDs7e7GUVuQ3xfnK; _make_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJTZiNjFiYjUzYTI0ODI5NjBkNWFmNDU0ZjU3YTkyMGFhBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMUc5U3JueWZaR2ErdzVRMFhmdDA2USsybFA5NkZQSzB0dEtvRnljNzdzMG89BjsARg%3D%3D--1d8622c7848a0af6d9a5c2002d570767811c9c2c; _session_id=BAh7CEkiHmF1dGhlbnRpY2F0aW9uX3N0cmF0ZWdpZXMGOgZFRjBJIg5yZXR1%250Acm5fdG8GOwBGWwZJIhEvam9icy82MzM2MjMGOwBGSSIJdXNlcgY7AEZJIg9V%250Ac2VyIzIzMTgzBjsARg%253D%253D--87985e9230acedd5654ee30aff3bd8bb848b0f68; _builder_user_id=BAhpAo9a--c989c892adad250ea2e98555fe9f79b204dfed4e; _worker_ui_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJTU4NzY1ZGZhY2IwM2U0ZDJlZDgyNDU3NzU5ZTA3YTdhBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMXVoRkY1NUxjSDVyRXhXeis2ak5nVFI4bnFPVUprYnAyRmdsK0pmQ2xKRnc9BjsARg%3D%3D--256c0eb3557b58a7b24fdc5f8e047e4fcde70728; __utma=105072849.1211284818.1374012347.1414794305.1415053728.1603; __utmb=105072849.4.10.1415053728; __utmc=105072849; __utmz=105072849.1415053728.1603.793.utmcsr=make.crowdflower.com|utmccn=(referral)|utmcmd=referral|utmcct=/jobs/637479/preview; __utmv=105072849.worker_ui; _gat=1; ajs_group_id=null; ajs_user_id=23183; mp_e0fd08bd7e74d0bf03862bb8de3a5168_mixpanel=%7B%22distinct_id%22%3A%2023183%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22plan%22%3A%20%22admin%22%2C%22company%22%3A%20null%2C%22balance%22%3A%2015514.8%2C%22first_name%22%3A%20%22Brian%22%2C%22last_name%22%3A%20null%2C%22lastName%22%3A%20null%2C%22team_admin%22%3A%20false%2C%22subscription_unit_limit%22%3A%20%22%22%2C%22subscription_units_used%22%3A%20%22%22%2C%22subscription_expires_at%22%3A%20%22%22%2C%22subscription_type%22%3A%20%22%22%2C%22title%22%3A%20null%2C%22phone_number%22%3A%20null%2C%22phone%22%3A%20null%2C%22id%22%3A%2023183%2C%22%24created%22%3A%20%222013-07-16T15%3A05%3A16.000Z%22%2C%22%24email%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24first_name%22%3A%20%22Brian%22%2C%22%24name%22%3A%20%22Brian%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Fmake.crowdflower.com%2Fjobs%2F628946%22%7D; __hstc=14529640.bb743abbae725dd601645001094acd40.1389216287361.1415046576433.1415051721451.971; __hssrc=1; __hssc=14529640.54.1415051721451; hubspotutk=bb743abbae725dd601645001094acd40; olfsk=olfsk4495328636839986; wcsid=MlIbyYuQXs87mSHq6N49s5IeEX5j1o1K; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _ga=GA1.2.1211284818.1374012347; _okac=f5b04657275be2cc57e5cb4cc59a8581; _okla=1; _oklv=1415054851144%2CMlIbyYuQXs87mSHq6N49s5IeEX5j1o1K' -H 'Connection: keep-alive' --compressed`
info = response.to_s
 info = info[/var workerInfoGraph(.*)\]\}\}/]
 id = info.scan(/"id":"(.*?)","/).to_a
 id.flatten!
end


#Returns an array of hashes the forgive contributor curl command
def collect_worker_ids(unit_data_judgments, job_id, unit_id)
  unit_data_judgments.each_with_object([]) do |judgment_data, array|
    array <<
     {
       job_id: job_id,
       unit_id:unit_id,
       worker_id: judgment_data
     }    
     
  end
end

#Forgive contributors curl command
def forgive_curl(job_id, unit_id, worker_id)
  puts "job_id: #{job_id} unit_id: #{unit_id} worker_id: #{worker_id}"
 `curl -s 'https://crowdflower.com/jobs/#{job_id}/workers/#{worker_id}' -H 'Cookie: optimizelyEndUserId=oeu1374108277234r0.9156798699405044; __mauuid=7f8e3f8d-c9c1-4ca3-aae3-6797f5801d9e; olfsk=olfsk4495328636839986; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; hsfirstvisit=https%3A%2F%2Fcrowdflower.com%2Fblog%2F%3Fp%3D8945||1389216287356; _mkto_trk=id:890-IJH-613&token:_mch-crowdflower.com-1375891859232-44393; __atuvc=2%7C3%2C0%7C4%2C1%7C5%2C0%7C6%2C2%7C7; mp_64ad2f3568e7a95ebcbd535a4f424a18_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Ftasks.crowdflower.com%2Fchannels%2Fcf_internal%2Fjobs%2F209625%2Feditor_preview%22%7D; mp_34db428377e01b5101a5659c6ebdfa7e_mixpanel=%7B%22distinct_id%22%3A%20%22141c8b7d7f582-098e6a992-68132675-13c680-141c8b7d7f65bb%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; mp_82b9518491269bbd6342e0a6fb9f259e_mixpanel=%7B%22distinct_id%22%3A%20159910%2C%22user_id%22%3A%200%2C%22groups%22%3A%20%5B%0A%20%20%20%20%22Even%22%0A%5D%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; _sio=b8a62de4-b9f0-4e1c-abdf-b9c7a6850413----23183; _ok=7808-547-10-4236; _session_id=BAh7CEkiHmF1dGhlbnRpY2F0aW9uX3N0cmF0ZWdpZXMGOgZFRjBJIg5yZXR1%250Acm5fdG8GOwBGWwZJIhEvam9icy80MTE2NTkGOwBGSSIJdXNlcgY7AEZJIg9V%250Ac2VyIzIzMTgzBjsARg%253D%253D--4f525259e8a35bc5e7e4fd0cfafbf5f255ac8740; _builder_user_id=BAhpAo9a--c989c892adad250ea2e98555fe9f79b204dfed4e; _sid=yVDGs9advgsfj_JATxMKqicbRBfMsmvK; optimizelySegments=%7B%22172094809%22%3A%22gc%22%2C%22172190267%22%3A%22false%22%2C%22172225027%22%3A%22direct%22%2C%22338723638%22%3A%22referral%22%2C%22338796251%22%3A%22false%22%2C%22339416244%22%3A%22gc%22%7D; optimizelyBuckets=%7B%22172111659%22%3A%22172095664%22%7D; _ch_elite=BAh7BkkiCHVpZAY6BkVUSSIKMzAxMDkGOwBU--f4c086bebfa8971274525ec1372853611bc3dbce; ajs_anonymous_id=%2223183%22; user_segment=Prospect; _worker_ui_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWFmNjM5ZTI3YzIzMDdlZmY3ZmUxZTc3ODNiODA5NmZiBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMThCSDhRWmZtUjVYV2lpU1JjcDZhYmlEdU9QZFRNVnlmU0NEVHJrR3NmUDg9BjsARg%3D%3D--e7a109b36567c0b962b15467c50b4a8f770936ab; mp_00f02d597c642b7efab39759dac628ea_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fcoolstuff.crowdflower.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22coolstuff.crowdflower.com%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D; __utma=105072849.1211284818.1374012347.1414689738.1414696952.1598; __utmc=105072849; __utmz=105072849.1414696952.1598.788.utmcsr=make.crowdflower.com|utmccn=(referral)|utmcmd=referral|utmcct=/jobs/634593/preview; __utmv=105072849.worker_ui; _okac=f5b04657275be2cc57e5cb4cc59a8581; _okla=1; _make_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJTgwZWI4YTZhMzgwNjgzNzEyNTU1YmQ1OWQ3YjI0ZWRlBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMWIweVRYOFNBR2xVUGUxa0pSYnZ6QUlkcFFuRDZhdXY5aTVHS0hEYW01a009BjsARg%3D%3D--bfc4b8fb94f02619af3d7db22911d7e218879ae5; _okbk=cd4%3Dtrue%2Ccd5%3Davailable%2Cvi5%3D0%2Cvi4%3D1414685530544%2Cvi3%3Dactive%2Cvi2%3Dfalse%2Cvi1%3Dfalse%2Ccd8%3Dchat%2Ccd6%3D0%2Ccd3%3Dfalse%2Ccd2%3D0%2Ccd1%3D0%2C; _gat=1; ajs_group_id=null; ajs_user_id=23183; mp_e0fd08bd7e74d0bf03862bb8de3a5168_mixpanel=%7B%22distinct_id%22%3A%2023183%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22plan%22%3A%20%22admin%22%2C%22company%22%3A%20null%2C%22balance%22%3A%2015477.8%2C%22first_name%22%3A%20%22Brian%22%2C%22last_name%22%3A%20null%2C%22lastName%22%3A%20null%2C%22team_admin%22%3A%20false%2C%22subscription_unit_limit%22%3A%20%22%22%2C%22subscription_units_used%22%3A%20%22%22%2C%22subscription_expires_at%22%3A%20%22%22%2C%22subscription_type%22%3A%20%22%22%2C%22title%22%3A%20null%2C%22phone_number%22%3A%20null%2C%22phone%22%3A%20null%2C%22id%22%3A%2023183%2C%22%24created%22%3A%20%222013-07-16T15%3A05%3A16.000Z%22%2C%22%24email%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24first_name%22%3A%20%22Brian%22%2C%22%24name%22%3A%20%22Brian%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Fmake.crowdflower.com%2Fjobs%2F628946%22%7D; __hstc=14529640.bb743abbae725dd601645001094acd40.1389216287361.1414685527797.1414688901863.958; __hssrc=1; __hssc=14529640.175.1414688901863; hubspotutk=bb743abbae725dd601645001094acd40; olfsk=olfsk4495328636839986; wcsid=Asbm7WoAB6cmoOlc6N49s889DWrK1oFp; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _ga=GA1.2.1211284818.1374012347; _oklv=1414700841614%2CAsbm7WoAB6cmoOlc6N49s889DWrK1oFp' -H 'Origin: https://crowdflower.com' -H 'Accept-Encoding: gzip,deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36' -H 'Content-type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: text/javascript, text/html, application/xml, text/xml, */*' -H 'Referer: https://crowdflower.com/jobs/633623/contributors/27157168' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data '_method=put&forgive=#{unit_id}' --compressed`
end


#iterates through the forive array and runs the forgive_curl for every worker_id 
def forgive_contributors(forgive_array,out)
  forgive_array.each do |forgive_data_hash|
    job_id = forgive_data_hash[:job_id]
    unit_id = forgive_data_hash[:unit_id]
    worker_id = forgive_data_hash[:worker_id]
    begin
      response = forgive_curl(job_id, unit_id, worker_id)
      puts ""
      puts "*********************************************"
      puts "Job ID: #{job_id}"
      puts "Unit ID: #{unit_id}"
      puts "Worker ID: #{worker_id}"
      puts "*********************************************"
      puts response
      time = Time.now
      time = time.strftime("%m_%d_%I:%M_%p")
      #Writes response into a csv for tracking purposes
      if response == "Judgment was successfully forgiven."
        out << ["true", {job_id: job_id, unit_id: unit_id, worker_id:worker_id}, time]

      else 
        out << ["false", {job_id: job_id, unit_id: unit_id, worker_id: worker_id}, time]
    
      end
    rescue
      out << ["false", {job_id: job_id, unit_id: unit_id, worker_id:worker_id}, time]
      next
    end
    #sleep 5
  end
end

def forgive_contributors_by_contributor_id(job_id, unit_id, contributor_id,out)
   
    begin
      response = forgive_curl(job_id, unit_id, contributor_id)
      puts response
      puts ""
      puts "*********************************************"
      puts "Job ID: #{job_id}"
      puts "Unit ID: #{unit_id}"
      puts "contributor_id: #{contributor_id}"
      puts "*********************************************"
      time = Time.now
      time = time.strftime("%m_%d_%I:%M_%p")
      #Writes response into a csv for tracking purposes
      if response == "Judgment was successfully forgiven."
        out << ["true", {job_id: job_id, unit_id: unit_id, contributor_id:contributor_id}, time]
      else 
        out << ["false", {job_id: job_id, unit_id: unit_id, contributor_id: contributor_id}, time]
      end
    rescue
       out << ["false", {job_id: job_id, unit_id: unit_id, contributor_id:contributor_id}, time]
      
     end
     #sleep 5
      
end



CSV.open("results_of_forgiving_contributors.csv","a", headers: ["successful", "forgive_data","time_submitted"], write_headers: true) do |out|
  CSV.foreach(input_file,headers:true) do |row|
    job_id = row["job_id"]
    unit_id = row["unit_id"]
    contributor_id = row["contributor_id"]

    #puts "job_id:#{job_id} unit_id:#{unit_id} contributor_id:#{contributor_id}"
    if contributor_id == nil
    #Do forgive actions
    puts "no worker_id"
    unit_data_judgments = get_worker_ids(job_id,unit_id)
    forgive_array = collect_worker_ids(unit_data_judgments,job_id,unit_id)
    forgivie_contributors_results = forgive_contributors(forgive_array, out)
  else
    puts "has worker_id"
    forgivie_contributors_results = forgive_contributors_by_contributor_id(job_id, unit_id, contributor_id, out)
  end
  end
end




