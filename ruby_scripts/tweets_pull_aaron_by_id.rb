require 'rubygems'
require 'csv'
require 'twitter'
require 'awesome_print'

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

#search_term = "@KennethLFisher"

FILE = "test_csv.csv"
CSV = CSV.readlines(file, :headers => true)

CSV.each do |row|
  ap row 
end



# client = Twitter::REST::Client.new do |config|
#   config.consumer_key = "nbKN7mOazkTvhUKoobxvlw"
#   config.consumer_secret = "aOZDbQ8xBXXNidst4NjLs9cHieNIi6G3An3PeKAYCa8"
#   config.access_token = "369127661-B1tLFbx9PsllymQ9EvQJwPUwpUY8DUR0OvYfmUeA"
#   config.access_token_secret = "FlTGS1M5d5Hkggdhv2hpOyIKwjXTjFFsNRWafEIRRc"
# end

# search_term = "591902695440527362"
# tweets = client.status(search_term) 
     
#      ap tweets["text"]


# CSV.open("Fisher_Tweets1.csv", "wb") do |csv|
#   csv << arr.first.keys # adds the attributes name on the first line538014035418296321
#   arr.each do |ha|
#     csv << ha.values
#   end 
# end
