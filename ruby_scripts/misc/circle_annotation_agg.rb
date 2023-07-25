# This script aggregates the RedLaser "Place Centroid" job.
# We need custom aggregation on Lat/Long/Radius coordinates.
# Written by Emma Sept 2012, modified Oct 2012

# 1) get the average lat/long/rad per unit
# 2) calculate outlier cutoff (3 SDs)
# 3) remove outliers and re-calculate mean
# 4) count how many responses were physically far from mean
puts "starting to load gems"
require 'rubygems'
puts "done rubygems"
# require 'fastercsv'
require 'csv'
puts "done csv"
require 'ap'
puts "done ap"
require 'descriptive_statistics'
puts "done descriptive"
require 'standard_deviation'
puts "done standard_deviation"
require 'simple-statistics'
puts "done loading gems"

############ VARIABLES TO CHANGE/CHECK #################
# What is this job?
jobtype = "centroid"
firstjobname = "findlatlong_175134_unit_id" # these need to be manually changed each batch of data
firstjobtime = "findlatlong_175134_created_at" # these need to be manually changed each batch of data
# suffix for output file
suffix = "officepierparty_2379units_latlongrad_agg" # these need to be manually changed each batch of data
########################################################

# the input file is the first argument (the csv name, e.g., "a123127.csv")
input_csv = ARGV[0]

if input_csv == nil or input_csv.length < 1
  raise "Usage: ruby #{__FILE__} csv1.csv"
end

job_number = input_csv.gsub(/\D/,"") # takes the numbers out of input_file

# the output file name is the input file, but append new name to end
# gsub removes .csv and appends suffix
output_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix}.csv"

# read in the input csv
reader = CSV.readlines(input_csv, :headers => true)
# save the headers
input_headers = reader.first.headers

headers_to_remove = ["_golden", "_id", "_missed", "_started_at", "_tainted", "_channel", "_trust", "_worker_id", "_country", "_region", "_city", "_ip", "building_loc", "lat_lon_zoom", "latitude", "longitude", "radius", "visual_confirmation"]
# old headers will have "_1" appended to them.
headers_to_rename = ["mean_lat", "mean_lon", "mean_viscon", "num_outliers", "num_resp", "num_far", "prop_far", "newmean_lat","newmean_lon"]
headers_to_write = [] # headers for mapping to new csv
headers_first_row = [] # headers to write to first row

# set up header row to include everything except for gold and confidence columns, and those in "headers_to_remove"
input_headers.each do |head|
  	if !(headers_to_remove.include?(head) or head.end_with?("_gold"))
  		headers_to_write << head  # these headers are used to access rows in the input_csv
  		# add suffix to differentiate headers from job 1 and job 2
  		if headers_to_rename.include?(head)
  			head = "#{head}_1"
  		end
	  	if head.to_s == "_unit_id"
	  		head = "#{jobtype}_#{job_number}_unit_id"
	  	elsif head.to_s == "_created_at"
	  		head = "#{jobtype}_#{job_number}_created_at"
	  	end
	  	headers_first_row << head # these headers are used just to write to the first row
  	end
end

# new headers to write
headers_first_row = headers_first_row + ["mean_lat_2", "mean_lon_2", "mean_rad_2", "newmean_lat_2", "newmean_lon_2", "newmean_rad_2", "num_resp_2", "num_outliers_2", "num_far_2", "prop_far_2", "mean_viscon_2"]

headers_to_write = headers_to_write + ["mean_lat_2", "mean_lon_2", "mean_rad_2", "newmean_lat_2", "newmean_lon_2", "newmean_rad_2", "num_resp_2", "num_outliers_2", "num_far_2", "prop_far_2", "mean_viscon_2"]

ap headers_first_row
ap headers_to_write

viscon_bin = [] # empty array
uniq_ids = [] # empty array
unit_ids = {} # empty hash
outlier_count = 0
zero_count = 0

# PLAY AROUND WITH THESE NUMBERS TILL WE GET GOOD AGGREGATED RESULTS
phys_thresh = 0.0005
outlier_thresh = 2

ap "Reading in csv"

# reader = CSV.readlines(input_csv, :headers => true)

# create an array of unique unit ids
reader.each_with_index do |row, row_n|
	uniq_ids << row["_unit_id"].to_s
end

uniq_ids = uniq_ids.uniq
num_uniq_ids = uniq_ids.length
ap "Num unique IDs: " + num_uniq_ids.to_s

CSV.open(output_csv,"w", :headers => headers_first_row, :write_headers => true) do |newcsv|

	for i in 0..(num_uniq_ids-1)

		if i % 250 == 0 then p "UNIQUE IDs READ: #{i}" end

		ap "ID " + uniq_ids[i].to_s

		lat_arr = [] # empty array
		lon_arr = [] # empty array
		rad_arr = [] # empty array
		viscon_arr = [] # empty array

		# THESE VARIABLES NEED TO MATCH THE INPUT FILE HEADERS
		# COMMENT OR UNCOMMENT AS NEEDED
		# timestamp, street, city, lat, lon, name, phone, zipcode, state = nil

		# EMMAISGONE SCRIPT 3
		timestamp = nil
		street1 = nil
		#street1 = nil
		street2 = nil
		city = nil
		lat = nil
		lon = nil
		name = nil
		store_name = nil
		store_id = nil
		#store_id = nil
		phone = nil
		# main_phone = nil
		# alt_phone = nil
		zipcode = nil
		# postal_code = nil
		state = nil
		# country_code = nil
		# homepage = nil
		# intersection = nil

		firstjob, firstjobtimestamp, mean_viscon_1, mean_lat_1, mean_lon_1, newmean_lat_1, newmean_lon_1, num_far_1, num_outliers_1, num_resp_1, prop_far_1 = nil

		reader.each_with_index do |row, row_n|
			if row["_unit_id"] == uniq_ids[i]
				if row["latitude"].to_f != 0.0  # removes blanks
					lat_arr << row["latitude"].to_f				
				end
				if row["longitude"].to_f != 0.0  # removes blanks
					lon_arr << row["longitude"].to_f
				end
				if row["radius"].to_f != 0.0  # removes blanks
					rad_arr << row["radius"].to_f
				end
				# convert visual confirmation to 1s and 0s
				if row["visual_confirmation"].to_s == "yes_visual"
					viscon_arr << 1
				else
					viscon_arr << 0
				end

				# timestamp = row["_created_at"]
				# street = row["street"].to_s
				# city = row["city"].to_s
				# lat = row["lat"].to_s
				# lon = row["lon"].to_s
				# name = row["name"].to_s
				# phone = row["phone"].to_s
				# zipcode = row["zipcode"].to_s
				# state = row["state"].to_s

				# THESE VARIABLES NEED TO MATCH THE INPUT FILE HEADERS
				# COMMENT OR UNCOMMENT AS NEEDED
				# EMMAISGONE SCRIPT 3
				timestamp = row["_created_at"]
				street1 = row["street1"].to_s
				# addressline1 = row["addressline1"]
				street2 = row["street2"].to_s
				city = row["city"].to_s
				lat = row["lat"].to_s
				lon = row["lon"].to_s
				name = row["name"].to_s
				store_name = row["store_name"].to_s
				# store_code = row["store_code"]
				store_id = row["store_id"]
				phone = row["phone"].to_s
				# main_phone = row["main_phone"].to_s
				# alt_phone = row["alt_phone"].to_s
				zipcode = row["zipcode"].to_s
				# postal_code = row["postal_code"].to_s
				state = row["state"].to_s
				# country_code = row["country_code"]
				# homepage = row["homepage"]
				# intersection = row["intersection"]

				firstjob = row[firstjobname].to_s
				firstjobtimestamp = row[firstjobtime].to_s
				mean_viscon_1 = row["mean_viscon"].to_s
				mean_lat_1 = row["mean_lat"].to_s
				mean_lon_1 = row["mean_lon"].to_s
				newmean_lat_1 = row["newmean_lat"].to_s
				newmean_lon_1 = row["newmean_lon"].to_s
				num_far_1 = row["num_far"].to_s
				num_outliers_1 = row["num_outliers"].to_s
				num_resp_1 = row["num_resp"].to_s
				prop_far_1 = row["prop_far"].to_s
			end
		end

		# ap "Latitude Array: " + lat_arr.to_s
		# ap "Longitude Array: " + lon_arr.to_s
		# ap "Radius Array: " + rad_arr.to_s

		# Make sure there is at least one entry per unit
		if lat_arr.empty? 	# If there are none
			mean_lat_2 = ""
			mean_lon_2 = ""
			newmean_lat_2 = ""
			newmean_lon_2 = ""
			mean_viscon_2 = 0
			num_resp_2 = 0
			num_outliers_2 = 0 
			num_far_2 = 0
			prop_far_2 = 0
			zero_count += 1

		elsif lat_arr.length < 2		# If there is only 1
			mean_lat_2 = lat_arr[0]
			mean_lon_2 = lon_arr[0]
			newmean_lat_2 = lat_arr[0]
			newmean_lon_2 = lon_arr[0]
			mean_viscon_2 = viscon_arr.mean
			num_resp_2 = 1
			num_outliers_2 = 0 
			num_far_2 = 0
			prop_far_2 = 0

		else
			# Calculate mean latitude, longitude, and radius
			mean_lat_2 = lat_arr.mean
			mean_lon_2 = lon_arr.mean
			mean_rad_2 = rad_arr.mean
			mean_viscon_2 = viscon_arr.mean

			# ap "Mean Lat: " + mean_lat_2.to_s
			# ap "Mean Lon: " + mean_lon_2.to_s
			# ap "Mean Rad: " + mean_rad_2.to_s

			# Calculate standard deviation of latitude and longitude
			std_lat = lat_arr.stdevp
			std_lon = lon_arr.stdevp
			std_rad = rad_arr.stdevp

			# ap "STD Lat: " + std_lat.to_s
			# ap "STD Lon: " + std_lon.to_s
			# ap "STD Rad: " + std_rad.to_s

			# Calculate 2 SD outlier cutoffs
			poscut_lat = mean_lat_2 + (outlier_thresh * std_lat)
			negcut_lat = mean_lat_2 - (outlier_thresh * std_lat)
			poscut_lon = mean_lon_2 + (outlier_thresh * std_lon)
			negcut_lon = mean_lon_2 - (outlier_thresh * std_lon)

			# ap street
			# ap "Outlier Cutoffs"
			# ap poscut_lat
			# ap negcut_lat
			# ap poscut_lon
			# ap negcut_lon

			# Then, check if the coordinates are outliers. If not, add to new array
			newlat_arr = [] # empty array
			newlon_arr = [] # empty array
			newrad_arr = [] # empty array
			num_outliers_2 = 0
			num_resp_2 = 0

			for j in 0..(lat_arr.length-1)
				# make sure the cutoffs aren't equal to each other	
				if poscut_lat != negcut_lat and poscut_lon != negcut_lon 
					if lat_arr[j] <= poscut_lat and lat_arr[j] >= negcut_lat and lon_arr[j] <= poscut_lon and lon_arr[j] >= negcut_lon
						newlat_arr << lat_arr[j].to_f
						newlon_arr << lon_arr[j].to_f
						newrad_arr << rad_arr[j].to_f
						num_resp_2 += 1
					else
						outlier_count += 1
						num_outliers_2 += 1
					end
				else
					newlat_arr << lat_arr[j].to_f
					newlon_arr << lon_arr[j].to_f
					newrad_arr << rad_arr[j].to_f
					num_resp_2 += 1
				end
			end

			# ap "New Lat and Lon"
			# ap newlat_arr
			# ap newlon_arr
			# ap newrad_arr

			# Calculate new means, without outliers
			newmean_lat_2 = newlat_arr.mean
			newmean_lon_2 = newlon_arr.mean
			newmean_rad_2 = newrad_arr.mean

			# ap "New Averages"
			# ap newmean_lat_2
			# ap newmean_lon_2
			# ap newmean_rad_2

			# Check if non-outliers are all super far away from the mean
			# If they are, throw out the whole unit
			newlat_arr_close = [] # empty array
			newlon_arr_close = [] # empty array
			# newrad_arr_close = [] # empty array
			newlat_arr_far = [] # empty array
			newlon_arr_far = [] # empty array
			# newrad_arr_far = [] # empty array
			num_far_2 = 0
			prop_far_2 = 0
			for k in 0..(newlat_arr.length-1)
				if (newlat_arr[k] - newmean_lat_2).abs < phys_thresh and (newlon_arr[k] - newmean_lon_2).abs < phys_thresh
					newlat_arr_close << newlat_arr[k]
					newlon_arr_close << newlon_arr[k]
				else
					newlat_arr_far << newlat_arr[k]
					newlon_arr_far << newlon_arr[k]
				end
			end

			# Check how many are super far away
			if !newlat_arr_far.empty?
				num_far_2 = newlat_arr_far.length
				prop_far_2 = num_far_2.to_f/num_resp_2.to_f
			end
		end

		# THESE HEADERS NEED TO MATCH THE ORDER OF "headers_first_row"
		# EMMAISGONE SCRIPT 3
		# Create hash with new information for each unique unit ID
		unit_ids[i] = [uniq_ids[i], timestamp, city, firstjobtimestamp, firstjob, lat, lon, mean_lat_1, mean_lon_1, mean_viscon_1, name, newmean_lat_1, newmean_lon_1, num_far_1, num_outliers_1, num_resp_1, phone, prop_far_1, state, store_id, store_name, street1, street2, zipcode, mean_lat_2, mean_lon_2, mean_rad_2, newmean_lat_2, newmean_lon_2, newmean_rad_2, num_resp_2, num_outliers_2, num_far_2, prop_far_2, mean_viscon_2]

		# unit_ids[i] = [uniq_ids[i], timestamp, addressline1, addressline2, alt_phone, city, country_code, firstjobtimestamp, firstjob, homepage, intersection, lat, lon, main_phone, mean_lat_1, mean_lon_1, mean_viscon_1, name, newmean_lat_1, newmean_lon_1, num_far_1, num_outliers_1, num_resp_1, postal_code,prop_far_1, state, store_code, mean_lat_2, mean_lon_2, mean_rad_2, newmean_lat_2, newmean_lon_2, newmean_rad_2, num_resp_2, num_outliers_2, num_far_2, prop_far_2, mean_viscon_2]

		# unit_ids[i] = [uniq_ids[i], timestamp, city, lat, lon, name, store_code, main_phone, alt_phone, state, addressline1, addressline2, postal_code, country_code, homepage, intersection, mean_lat, mean_lon, newmean_lat, newmean_lon, num_resp, num_outliers, num_far, prop_far, mean_viscon]

		# ap "about to print to file"
		# Write one row per unit ID
		newcsv << unit_ids[i]

	end

end

ap "Number of outliers: " + outlier_count.to_s
ap "Number of units with no lat/lon: " + zero_count.to_s
