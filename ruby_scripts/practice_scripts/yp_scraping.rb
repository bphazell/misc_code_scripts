require 'csv'
require 'json'
require 'HTTParty'
require 'awesome_print'

GOOGLE_API_KEY = "AIzaSyB4kGVL1WZu0ZKHApIkaSOgumXAWiAOaz0"
FOURSQUARE_CLIENT_ID = "35ZF0XI3SXMGXDGQOFKLSPCPJXAREUS2NN55A4WN0QNXEID1"
FOURSQUARE_CLIENT_SECRET= "5Q5XJ0GCAC0SPYZC0RJXYD5G042SFYA142HTX41YYQMH40SP"

#handles file input
file= ARGV.first
csv = CSV.readlines(file, :headers => true)
headers = csv.first.headers

t = Time.now
date = t.strftime("%m_%d_%I%M%p")
good_output_file = "YP_scrape_results_#{date}.csv"

#checking if location data is present in JSON
def check_present (variable, place)
  if place != nil
    variable = place
  else
    variable = nil
  end
  return variable
end

def safe_parse(api, parse=true, attempt = 1)
  api_url = HTTParty.get(api)
  JSON.parse(api_url.body) if parse
rescue => e
  if attempt > 10
    puts "\n\nDebug error: #{e}\n\n"
    true_failure = true
    raise e
  else
    puts "\nRetrying #{api} because: \n\n#{e.message}\n"
    sleep 2
    safe_parse(api, parse, attempt + 1)
  end
end

#reverse geocode lookup
def reverse_geocode(lat, long)
  reverse_geocoding="http://api.geonames.org/findNearbyPostalCodesJSON?lat=#{lat}&lng=#{long}&username=imajenn&maxRows=1"
  reverse_geocoding_results=HTTParty.get(reverse_geocoding)
  reverse_geocoding_results=JSON.parse(reverse_geocoding_results.body)
  if reverse_geocoding_results["status"] != nil  || reverse_geocoding_results["postalCodes"].length == 0
    reverse_geocoding="http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&lat=#{lat}&lon=#{long}"
	  reverse_geocoding_results=HTTParty.get(reverse_geocoding)
	  reverse_geocoding_results=JSON.parse(reverse_geocoding_results.body)
	  zip = reverse_geocoding_results["address"]["postcode"]
  elsif reverse_geocoding_results["postalCodes"].length > 0 
	  zip = reverse_geocoding_results["postalCodes"][0]["postalCode"]
  else
	  zip = nil
  end
  return zip
end


#grabs data and outputs it to CSV
CSV.open(good_output_file, 'w', :headers=>headers + ["error", "listing_name", "address","city", "state", "zipcode", "latitude", "longitude","phone", "source", "results_number"], :write_headers=>true) do |scrape|
  csv.each do |row|
    #initialize
    if row["Geo"] == nil || row["Query"] == nil then next end
    id, query, location,error = nil, nil, nil
    query, id, location = row["Query"], row["ID"], row["Geo"]
  
    # URL encoding
    fixed_query = query.split(" ").join("+")
    fixed_query = fixed_query.gsub("&","%26")
    yahoo_query= (query.split(" ").join("%20")).gsub("&","%26")
    fixed_location = location.split(" ").join("+")
    encoded_location = location.split(" ").join("%20")
    puts "=== Currently on Row: " + id
    google_query = fixed_query + "+" + fixed_location
    
    #GOOGLE
    google_results=safe_parse("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{google_query}&sensor=false&key=#{GOOGLE_API_KEY}")
    google_placeid=[]
    if google_results["results"] != nil
  	  google_results["results"].each_with_index do |place,i|
  	    if i<=4
  		    google_placeid.push(place["place_id"])
  	    end
  	  end
    end
    
    google_details_results_array=[]
    google_placeid.each do |id|
      google_details_url="https://maps.googleapis.com/maps/api/place/details/json?placeid=#{id}&key=#{GOOGLE_API_KEY}"
      google_details_results = HTTParty.get(google_details_url)
      google_details_results_parsed = JSON.parse(google_details_results.body)
      google_details_results_array.push(google_details_results_parsed)
    end
    
    google_details_results_array.each_with_index do |place,index|
      street_number,street_name,subpremise,business_city,business_state,zip=nil,nil,nil,nil,nil,nil
      place["result"]["address_components"].each_with_index do |component, index|
  	    next if place["result"]["address_components"][0]["types"][0] == "country" && place["result"]["address_components"][0]["long_name"] != "United States"
  	    addresstype = place["result"]["address_components"][index]["types"][0]
  	    addressname= place["result"]["address_components"][index]["long_name"]
      
  	    if addresstype == "street_number"
  		  street_number = addressname
  	    end
      
  	    if addresstype == "route"
  		  street_name = addressname
  	    end
      
  	    if addresstype == "subpremise"
  		  subpremise = addressname
  	    end
      
  	    if addresstype == "locality"
  		  business_city = addressname
  	    end
      
  	    if addresstype == "administrative_area_level_1"
  		  business_state = addressname
  	    end
      
  	    if addresstype == "postal_code"
  		  zip = addressname
  	    end
	    end

      business_phone = check_present(business_phone, place["result"]["formatted_phone_number"])
      business_name = place["result"]["name"]
      business_address = street_number.to_s+" "+street_name.to_s+" "+subpremise.to_s
      lat= place["result"]["geometry"]["location"]["lat"]
      long= place["result"]["geometry"]["location"]["lng"]
      if index <= 4
        scrape << [id, query, location, error, business_name, business_address, business_city, business_state, zip, lat, long,business_phone, "Google", index]
        puts "Google Places Details: currently doing:   #{query}  #{location}"
      end
    end
    
    #YAHOO
    yahoo_results = safe_parse("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20local.search%20where%20query%3D%22#{yahoo_query}%22%20and%20location%3D%22#{encoded_location}%22%20limit%205&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
    
    if yahoo_results["query"]["results"] != nil
      if yahoo_results["query"]["count"] == 1 
  	    yahoo_results.each_with_index do |place, index|
  		    business_name = yahoo_results["query"]["results"]["Result"]["Title"]
  		    business_address = yahoo_results["query"]["results"]["Result"]["Address"].to_s
  		    business_state = yahoo_results["query"]["results"]["Result"]["State"].to_s
  		    business_city = yahoo_results["query"]["results"]["Result"]["City"].to_s
  		    business_phone = yahoo_results["query"]["results"]["Result"]["Phone"].to_s
  		    lat = yahoo_results["query"]["results"]["Result"]["Latitude"].to_s
  		    long = yahoo_results["query"]["results"]["Result"]["Longitude"].to_s
  		    zip = reverse_geocode(lat, long)
  		    scrape << [id, query, location, error, business_name, business_address, business_city, business_state, zip, lat, long, business_phone, "Yahoo", index]
  	    end

	    puts "Yahoo Local currently doing:  #{query}  #{location} ---- in count 1 loop"
	    else
        yahoo_results["query"]["results"]["Result"].each_with_index do |place, index|
          business_name = place["Title"]
          business_address = place["Address"].to_s
          business_state= place["State"].to_s
          business_city= place["City"].to_s
          business_phone = place["Phone"].to_s
          lat = place["Latitude"].to_s
          long = place["Longitude"].to_s
          zip = reverse_geocode(lat, long)
          scrape << [id, query, location, error, business_name, business_address, business_city, business_state, zip, lat, long, business_phone, "Yahoo", index]
          puts "Yahoo Local currently doing:  #{query}  #{location}"
        end
      end
    end
    
    #FOURSQUARE
    foursquare_results = safe_parse("https://api.foursquare.com/v2/venues/explore?client_id=#{FOURSQUARE_CLIENT_ID}&client_secret=#{FOURSQUARE_CLIENT_SECRET}&v=20130815&query=#{fixed_query}&near=#{encoded_location}&limit=5")
    
    if foursquare_results["meta"]["code"] != 200
      next
    
    elsif foursquare_results["response"]["groups"][0]["items"].empty?
     next
    
    else
      foursquare_results["response"]["groups"][0]["items"].each_with_index do |place, index|
        next if place["venue"]["location"]["country"] != nil && place["venue"]["location"]["country"] != "United States"
        business_name = place["venue"]["name"]
        business_address=check_present(business_address, place["venue"]["location"]["address"])
        business_city=check_present(business_city, place["venue"]["location"]["city"]) 
        business_state=check_present(business_state, place["venue"]["location"]["state"])	
        business_phone=check_present(business_phone, place["venue"]["contact"]["formattedPhone"])
        lat=check_present(lat,place["venue"]["location"]["lat"])
        long=check_present(long, place["venue"]["location"]["lng"])
        zip=check_present(zip, place["venue"]["location"]["postalCode"])
        if zip == nil
	       zip = reverse_geocode(lat, long)
        end
        scrape << [id, query, location, error, business_name, business_address, business_city, business_state, zip, lat , long, business_phone, "Foursquare", index]
        puts "Foursquare currently doing:  #{query} #{location}"
      end
    end
  end
end