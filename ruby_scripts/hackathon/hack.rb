
require 'csv'
require 'crowdflower'
require 'ap'
require 'oj'

API_KEY = "sXhKBtZPvLiDjWbGcEtN"
DOMAIN_BASE = "https://api.crowdflower.com"
CrowdFlower::Job.connect! API_KEY, DOMAIN_BASE

class JobUpdate
  def initialize(csv)
    @csv = csv
    @job_two = copy_job
    @cat_tag = convert_to_array("Tag- Category")
    @tool_tag = convert_to_array("Tag- Widget")
    @cml = get_cml

  end

  def copy_job
    job_one = CrowdFlower::Job.new(@csv["original_id"])    
    job_two = job_one.copy(all_units:true)
  end

  def convert_to_array(col)
    if @csv[col] != nil
      @csv[col].include?(",") ? cat_tag = @csv[col].split(",") : cat_tag = @csv[col].split("\n")
    end
  end

  def update_new_tags
    @cat_tag.each do |tag|
      cat_tag_case(tag)
    end
    if @tool_tag != nil
      @tool_tag.each do |tag|
        tool_tag_case(tag)
      end
    end
    cml_tag_case
  end

  def tool_tag_case(tag)
    if tag == "jquery_popover"
      puts "add jquery_popover"
      @job_two.add_tags("jquery_popover")
    end
    if tag == "advanced_liquid"
      puts "add advanced_liquid tag"
      @job_two.add_tags("advanced_liquid")
    end
    if tag == "twitter_widget"
      puts "add twitter_widget tag"
      @job_two.add_tags("twitter_widget")
    end
    if tag == "facebook_widget"
      puts "add facebook_widget tag"
      @job_two.add_tags("facebook_widget")
    end
    if tag == "hours_widget"
      puts "add hours_widget tag"
      @job_two.add_tags("hours_widget")
    end
    if tag == "address_widget"
      puts "add address_widget tag"
      @job_two.add_tags("address_widget")
    end
    if tag == "taxonomy_widget"
      puts "add taxonomy_widget tag"
      @job_two.add_tags("taxonomy_widget")
    end
    if tag == "jquery_tabs"
      puts "add jquery_tabs tag"
      @job_two.add_tags("jquery_tabs")
    end
    if tag == "instagram_widget"
      puts "add instagram_widget tag"
      @job_two.add_tags("instagram_widget")
    end
  end

  def cat_tag_case(tag)
    if tag == "search_rel"
      puts "add search rel tag"
      @job_two.add_tags("search_rel")
    end
    if tag == "sentiment_analysis"
      puts "add sentiment_analysis tag"
      @job_two.add_tags("sentiment_analysis")
    end
    if tag == "url_find"
      puts "add url_find tag"
      @job_two.add_tags("url_find")
    end
    if tag == "data_collection"
      puts "add data_collection tag"
      @job_two.add_tags("data_collection")
    end
    if tag == "data_correction"
      puts "add data_correction tag"
      @job_two.add_tags("data_correction")
    end
    if tag == "categorization"
      puts "add categorization tag"
      @job_two.add_tags("categorization")
    end
    if tag == "dedupe"
      puts "add dedupe tag"
      @job_two.add_tags("dedupe")
    end
    if tag == "transcription"
      puts "add transcription tag"
      @job_two.add_tags("transcription")
    end
  end

  def get_cml
    cml = @job_two.get["cml"]
  end

  def cml_tag_case
    if @cml.include?("<cml:radios")
      puts "add radios tag"
      @job_two.add_tags("cml_radios")
    end
    if @cml.include?("<cml:select")
      puts "add cml_select tag"
      @job_two.add_tags("cml_select")
    end
    if @cml.include?("<cml:checkboxes")
      puts "add cml_checkboxes tag"
      @job_two.add_tags("cml_checkboxes")
    end
    if @cml.include?("<cml:text")
      puts "add cml_text tag"
      @job_two.add_tags("cml_text")
    end
    if @cml.include?("<cml:textarea")
      puts "add cml_textarea tag"
      @job_two.add_tags("cml_textarea")
    end
    if @cml.include?('class="btn')
      puts "add bootstrap_button tag"
      @job_two.add_tags("bootstrap_button")
    end
    if @cml.include?("<img")
      puts "add image tag"
      @job_two.add_tags("image")
    end
  end

  def move_to_project
    project_curl
  end


  def project_curl
    puts "moving job to project folder \n"
  `curl 'https://make.crowdflower.com/jobs' -X PUT -H 'Cookie: optimizelyEndUserId=oeu1374108277234r0.9156798699405044; __mauuid=7f8e3f8d-c9c1-4ca3-aae3-6797f5801d9e; hsfirstvisit=https%3A%2F%2Fcrowdflower.com%2Fblog%2F%3Fp%3D8945||1389216287356; _mkto_trk=id:890-IJH-613&token:_mch-crowdflower.com-1375891859232-44393; mp_64ad2f3568e7a95ebcbd535a4f424a18_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Ftasks.crowdflower.com%2Fchannels%2Fcf_internal%2Fjobs%2F209625%2Feditor_preview%22%7D; mp_34db428377e01b5101a5659c6ebdfa7e_mixpanel=%7B%22distinct_id%22%3A%20%22141c8b7d7f582-098e6a992-68132675-13c680-141c8b7d7f65bb%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; olfsk=olfsk4495328636839986; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _sio=d1e7c14e-c5aa-4899-be89-09f325f019f0----23183; ajs_anonymous_id=%2223183%22; __zlcprivacy=1; user_segment=Prospect; mp_82b9518491269bbd6342e0a6fb9f259e_mixpanel=%7B%22distinct_id%22%3A%20140457%2C%22user_id%22%3A%2021599315%2C%22groups%22%3A%20%5B%0A%20%20%20%20%22All%22%2C%0A%20%20%20%20%22Odd%22%0A%5D%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22site_id%22%3A%20140457%2C%22tour_version%22%3A%205%2C%22junkAccount%22%3A%20false%2C%22site_host%22%3A%20%22communitysupport.crowdflower.com%22%7D; mp_00f02d597c642b7efab39759dac628ea_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fcoolstuff.crowdflower.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22coolstuff.crowdflower.com%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D; optimizelySegments=%7B%22172094809%22%3A%22gc%22%2C%22172190267%22%3A%22false%22%2C%22172225027%22%3A%22direct%22%2C%22298794671%22%3A%22referral%22%2C%22298874097%22%3A%22false%22%2C%22298896012%22%3A%22gc%22%2C%22338723638%22%3A%22referral%22%2C%22338796251%22%3A%22false%22%2C%22339416244%22%3A%22gc%22%7D; optimizelyBuckets=%7B%22172111659%22%3A%22172095664%22%7D; _ok=7808-547-10-4236; _sid=cPpyBB1eX8bApADP9ZscbCtsJKsFpqcT; _builder_user_id=BAhpAo9a--c989c892adad250ea2e98555fe9f79b204dfed4e; _worker_ui_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWYwNmIyODBlNmEyZWZlYWE1MzJiYzFmNmYxZGRhZjI4BjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMTl4WC9FR1ZTNGIxZ0lsZTN3RnBpbHJBbkljckREalFSWUhoNGh6Z1Q1Rkk9BjsARg%3D%3D--6a13e30ffac28a1fd8ea6bb3b942c38fbb5cc4ae; _okac=885c15e23c4a290a52ffea8bc4902c80; _okla=1; __utma=105072849.1211284818.1374012347.1424723145.1424973163.1784; __utmc=105072849; __utmz=105072849.1424973163.1784.971.utmcsr=make.crowdflower.com|utmccn=(referral)|utmcmd=referral|utmcct=/jobs/204975/preview; __utmv=105072849.worker_ui; _gat=1; _okbk=cd4%3Dtrue%2Cvi5%3D0%2Cvi4%3D1424972327772%2Cvi3%3Dactive%2Cvi2%3Dfalse%2Cvi1%3Dfalse%2Ccd8%3Dchat%2Ccd6%3D0%2Ccd5%3Daway%2Ccd3%3Dfalse%2Ccd2%3D0%2Ccd1%3D0%2C; _make_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWU4NTdhZDdjNzEyNmYyZWYzZDRmMjdiNTUwMTAxNzBiBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMS8rcncrV3pCaWhzOXF5aCs3dkkxc3J1N1pXSFpqODh1QXQ0ZHZpTTl0QnM9BjsARg%3D%3D--15f93a14329a3492140d5bc7268326c85f4c4c6d; ajs_group_id=null; ajs_user_id=23183; _ga=GA1.2.1211284818.1374012347; mp_e0fd08bd7e74d0bf03862bb8de3a5168_mixpanel=%7B%22distinct_id%22%3A%2023183%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22plan%22%3A%20%22admin%22%2C%22company%22%3A%20%22crowdflower%22%2C%22balance%22%3A%2015%2C%22first_name%22%3A%20%22Brian%22%2C%22last_name%22%3A%20null%2C%22lastName%22%3A%20null%2C%22team_admin%22%3A%20true%2C%22subscription_unit_limit%22%3A%20%22%22%2C%22subscription_units_used%22%3A%20172871%2C%22subscription_expires_at%22%3A%20%22%22%2C%22subscription_type%22%3A%20%22trial%22%2C%22title%22%3A%20null%2C%22phone_number%22%3A%20null%2C%22phone%22%3A%20null%2C%22id%22%3A%2023183%2C%22%24created%22%3A%20%222013-07-16T22%3A05%3A00.000Z%22%2C%22%24email%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24first_name%22%3A%20%22Brian%22%2C%22%24name%22%3A%20%22Brian%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Fmake.crowdflower.com%2Fjobs%2F692066%2Fpreview%22%2C%22%24ignore%22%3A%20%22true%22%7D; __hstc=14529640.bb743abbae725dd601645001094acd40.1389216287361.1424982920601.1424986212279.1256; __hssrc=1; __hssc=14529640.17.1424986212279; hubspotutk=bb743abbae725dd601645001094acd40; __zlcmid=S5eFXu3FyFdOgw; olfsk=olfsk4495328636839986; wcsid=EAqt4AetFl0CnMGO6N49s5O0GXK505ew; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _ga=GA1.3.1211284818.1374012347; _oklv=1424986421700%2CEAqt4AetFl0CnMGO6N49s5O0GXK505ew' -H 'Origin: https://make.crowdflower.com' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'X-CSRF-Token: /+rw+WzBihs9qyh+7vI1sru7ZWHZj88uAt4dviM9tBs=' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Referer: https://make.crowdflower.com/jobs' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data 'jobs%5B0%5D%5Bid%5D=#{@job_two.id}&jobs%5B0%5D%5Bproject_id%5D=1648' --compressed`
  end

  def curl_tags
    puts "grabbing original tags \n"
     `curl -X GET https://api.crowdflower.com/v1/jobs/#{@job_two.id}/tags?key=sXhKBtZPvLiDjWbGcEtN`
  end

  def get_tags
    tags = Oj.load(curl_tags)
    tags.each_with_object([]) do |tag, output|
      output << tag["name"]
    end
  end

  def remove_org_tags
    org_tags = get_tags
    org_tags.each do |tag|
    @job_two.remove_tags(tag)
    end
  end

end
  i = 0
CSV.foreach("Hackday Use Case LIst - Sheet1 (1).csv", headers:true) do |csv|
  i += 1
  puts i
  update = JobUpdate.new(csv)
  update.remove_org_tags
  update.cml_tag_case
  update.update_new_tags
  update.move_to_project
end






