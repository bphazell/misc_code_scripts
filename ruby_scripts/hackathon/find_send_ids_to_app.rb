require 'csv'
require 'crowdflower'
require 'ap'
require 'oj'
require 'faraday'

API_KEY = "sXhKBtZPvLiDjWbGcEtN"
DOMAIN_BASE = "https://api.crowdflower.com"
CrowdFlower::Job.connect! API_KEY, DOMAIN_BASE

 conn = Faraday.new(:url => 'https://warm-gorge-7527.herokuapp.com/') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

 page1 = File.read "/Users/bhazell/Desktop/ruby_scripts/hackathon/CrowdFlower.html"
 page2 = File.read "/Users/bhazell/Desktop/ruby_scripts/hackathon/CrowdFlower2.html"

 class PostHeroku
  def initialize(page1, page2, conn)
    @ids = create_id_array(page1, page2)
    @info_hash = create_info_hash
    @conn = conn
  end

  def create_id_array(page1, page2)
    page1_a = page1.scan(/job-select-(......)/).uniq.flatten
    page2_a = page2.scan(/job-select-(......)/).uniq.flatten
    job_ids = page1_a + page2_a
  end

  def test
    hash = create_info_hash
    ap hash
  end

  def create_info_hash
    @ids.each_with_object({}) do |id, hash|
      puts "creating hash #{id}"
      job = CrowdFlower::Job.new(id)
      hash[id] =
        {
          title:job.get["title"],
          cml:job.get["cml"],
          css:job.get["css"],
          js:job.get["js"]
        }
    end
  end

  def upload_to_heroku
    @info_hash.each do |k, v|
      puts "uploading #{k}"
      response = @conn.post '/jobs', 
      {job:
            { :name => v[:title], 
              :cf_id => k,
              :cml => v[:cml],
              :css => v[:css],
              :javascript => v[:js]
            } 
      }
      puts response.body
    end
  end
 end

object = PostHeroku.new(page1,page2,conn).upload_to_heroku


