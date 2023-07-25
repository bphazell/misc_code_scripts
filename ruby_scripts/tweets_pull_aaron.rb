require 'rubygems'
require 'csv'
require 'twitter'

# @sherylsandberg since:2015-03-00 -RT
# to:sherlysandberg
# Sherly sandberg
# @johndoerr
# to:johndoerr
# John Doerr
# @marissamayer
#to:@marissamayer
# Marissa Mayer
# 500 of each
search_term = "machine learning"

lang = "en"
quantity = 500



client = Twitter::REST::Client.new do |config|
  config.consumer_key = "nbKN7mOazkTvhUKoobxvlw"
  config.consumer_secret = "aOZDbQ8xBXXNidst4NjLs9cHieNIi6G3An3PeKAYCa8"
  config.access_token = "369127661-B1tLFbx9PsllymQ9EvQJwPUwpUY8DUR0OvYfmUeA"
  config.access_token_secret = "FlTGS1M5d5Hkggdhv2hpOyIKwjXTjFFsNRWafEIRRc"
end

arr = Array.new

tweets = client.search(search_term, :lang => lang, :count => quantity ).take(quantity).collect do |tweet|
       hash = { :text => tweet.text, :tweet_id => tweet.id, :name => tweet.user.screen_name, :retweet_count => tweet.retweet_count, :tweet_location => tweet.user.location, :tweet_created => tweet.created_at, :user_timezone => tweet.user.time_zone, :tweet_coord => tweet.geo.coordinates}
  	arr << hash
end

CSV.open("machine_learning4.csv", "wb") do |csv|
  csv << arr.first.keys # adds the attributes name on the first line538014035418296321
  arr.each do |ha|
    csv << ha.values
  end 
end
