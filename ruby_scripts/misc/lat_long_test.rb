
require 'csv'
require 'HTTParty'

def api_test (lat,long)
reverse_geocoding = "http://api.geonames.org/findNearbyPostalCodesJSON?lat=#{lat}&lng=#{long}&username=imajenn&maxRows=1"
reverse_geocoding_results = HTTParty.get(reverse_geocoding)
reverse_geocoding_results=JSON.parse(reverse_geocoding_results.body)
puts reverse_geocoding_results

end

api_test(39.834557,-94.861265)