#contributor IDs (comma separated)
nums = []

#Message and API key
nums.each do |num|
  `curl -H "Content-Length: 0" -X PUT 'https://api.crowdflower.com/v1/jobs/351692/workers/#{num}/ban.json?key=a057502ca2ca91b2fe55e99c17affe817eb76182'`
end