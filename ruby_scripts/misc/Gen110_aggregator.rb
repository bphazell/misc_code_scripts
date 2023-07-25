# This script aggregates the Gen110 job.
# We need custom aggregation on Lat/Long/Radius coordinates.

# 1) get the average lat/long/rad per unit
# 2) calculate outlier cutoff (3 SDs)
# 3) remove outliers and re-calculate mean
# 4) count how many responses were physically far from mean

require 'csv'
require 'ap'
require 'descriptive_statistics'
require 'standard_deviation'
require 'simple-statistics'

############ VARIABLES TO CHANGE/CHECK #################
# What is this job?
jobtype = "gen110"
# suffix for output file
suffix = "gen110_200units_latlongrad_agg" # these need to be manually changed each batch of data
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

headers_to_remove = ["_golden", "_canary", "_id", "_missed", "_started_at", "_tainted", "_channel", "_trust", "_worker_id", "_country", "_region", "_city", "_ip", "latitude", "longitude", "radius"]
headers_to_write = [] # headers for mapping to new csv
headers_first_row = [] # headers to write to first row

# set up header row to include everything except for gold and confidence columns, and those in "headers_to_remove"
input_headers.each do |head|
	if !(headers_to_remove.include?(head) or head.end_with?("_gold"))
		headers_to_write << head  # these headers are used to access rows in the input_csv
  	if head.to_s == "_unit_id"
  		head = "#{jobtype}_#{job_number}_unit_id"
  	elsif head.to_s == "_created_at"
  		head = "#{jobtype}_#{job_number}_created_at"
  	end
  	headers_first_row << head # these headers are used just to write to the first row
	end
end

# new headers to write
headers_first_row = headers_first_row + ["mean_lat", "mean_lon", "mean_rad", "newmean_lat", "newmean_lon", "newmean_rad", "num_resp", "num_outliers", "num_far", "prop_far"]

headers_to_write = headers_to_write + ["timestamp", "address_located_yn", "mean_lat", "mean_lon", "mean_rad", "newmean_lat", "newmean_lon", "newmean_rad", "num_resp", "num_outliers", "num_far", "prop_far"]

ap "headers_first_row: #{headers_first_row}"
ap "headers_to_write: #{headers_to_write}"

uniq_ids = [] # empty array
unit_ids = {} # empty hash
outlier_count = 0
zero_count = 0

# PLAY AROUND WITH THESE NUMBERS TILL WE GET GOOD AGGREGATED RESULTS
phys_thresh = 0.0005
outlier_thresh = 2

ap "Reading in csv"

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

		ap "ID: #{uniq_ids[i]}"

		lat_arr = [] # empty array
		lon_arr = [] # empty array
		rad_arr = [] # empty array

		# THESE VARIABLES NEED TO MATCH THE INPUT FILE HEADERS
		timestamp = nil
		address_located_yn = nil
		address = nil
		appid = nil
		batchid = nil
		batchn = nil
		bgfips = nil
		city = nil
		state = nil
		zip = nil

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

				# THESE VARIABLES NEED TO MATCH THE INPUT FILE HEADERS
				timestamp = row["_created_at"]
				address_located_yn = row["address_located_yn"].to_s
				address = row["address"].to_s
				appid = row["appid"].to_s
				batchid = row["batchid"].to_s
				batchn = row["batchn"].to_s
				bgfips = row["bgfips"].to_s
				city = row["city"].to_s
				state = row["state"].to_s
				zip = row["zip"].to_s
			end
		end

		ap "Latitude Array: " + lat_arr.to_s
		ap "Longitude Array: " + lon_arr.to_s
		ap "Radius Array: " + rad_arr.to_s

		# Make sure there is at least one entry per unit
		if lat_arr.empty? 	# If there are none
			mean_lat = ""
			mean_lon = ""
			newmean_lat = ""
			newmean_lon = ""
			num_resp = 0
			num_outliers = 0
			num_far = 0
			prop_far = 0
			zero_count += 1

		elsif lat_arr.length < 2		# If there is only 1
			mean_lat = lat_arr[0]
			mean_lon = lon_arr[0]
			newmean_lat = lat_arr[0]
			newmean_lon = lon_arr[0]
			num_resp = 1
			num_outliers = 0
			num_far = 0
			prop_far = 0

		else
			# Calculate mean latitude, longitude, and radius
			mean_lat = lat_arr.mean
			mean_lon = lon_arr.mean
			mean_rad = rad_arr.mean

			ap "Mean Lat: " + mean_lat.to_s
			ap "Mean Lon: " + mean_lon.to_s
			ap "Mean Rad: " + mean_rad.to_s

			# Calculate standard deviation of latitude and longitude
			std_lat = lat_arr.stdevp
			std_lon = lon_arr.stdevp
			std_rad = rad_arr.stdevp

			ap "STD Lat: " + std_lat.to_s
			ap "STD Lon: " + std_lon.to_s
			ap "STD Rad: " + std_rad.to_s

			# Calculate 2 SD outlier cutoffs
			poscut_lat = mean_lat + (outlier_thresh * std_lat)
			negcut_lat = mean_lat - (outlier_thresh * std_lat)
			poscut_lon = mean_lon + (outlier_thresh * std_lon)
			negcut_lon = mean_lon - (outlier_thresh * std_lon)

			ap address
			ap "Outlier Cutoffs"
			ap poscut_lat
			ap negcut_lat
			ap poscut_lon
			ap negcut_lon

			# Then, check if the coordinates are outliers. If not, add to new array
			newlat_arr = [] # empty array
			newlon_arr = [] # empty array
			newrad_arr = [] # empty array
			num_outliers = 0
			num_resp = 0

			for j in 0..(lat_arr.length-1)
				# make sure the cutoffs aren't equal to each other
				if poscut_lat != negcut_lat and poscut_lon != negcut_lon
					if lat_arr[j] <= poscut_lat and lat_arr[j] >= negcut_lat and lon_arr[j] <= poscut_lon and lon_arr[j] >= negcut_lon
						newlat_arr << lat_arr[j].to_f
						newlon_arr << lon_arr[j].to_f
						newrad_arr << rad_arr[j].to_f
						num_resp += 1
					else
						outlier_count += 1
						num_outliers += 1
					end
				else
					newlat_arr << lat_arr[j].to_f
					newlon_arr << lon_arr[j].to_f
					newrad_arr << rad_arr[j].to_f
					num_resp += 1
				end
			end

			ap "New Lat and Lon"
			ap newlat_arr
			ap newlon_arr
			ap newrad_arr

			# Calculate new means, without outliers
			newmean_lat = newlat_arr.mean
			newmean_lon = newlon_arr.mean
			newmean_rad = newrad_arr.mean

			ap "New Averages"
			ap newmean_lat
			ap newmean_lon
			ap newmean_rad

			# Check if non-outliers are all super far away from the mean
			# If they are, throw out the whole unit
			newlat_arr_close = [] # empty array
			newlon_arr_close = [] # empty array
			# newrad_arr_close = [] # empty array
			newlat_arr_far = [] # empty array
			newlon_arr_far = [] # empty array
			# newrad_arr_far = [] # empty array
			num_far = 0
			prop_far = 0
			for k in 0..(newlat_arr.length-1)
				if (newlat_arr[k] - newmean_lat).abs < phys_thresh and (newlon_arr[k] - newmean_lon).abs < phys_thresh
					newlat_arr_close << newlat_arr[k]
					newlon_arr_close << newlon_arr[k]
				else
					newlat_arr_far << newlat_arr[k]
					newlon_arr_far << newlon_arr[k]
				end
			end

			# Check how many are super far away
			if !newlat_arr_far.empty?
				num_far = newlat_arr_far.length
				prop_far = num_far.to_f/num_resp.to_f
			end
		end

		# THESE HEADERS NEED TO MATCH THE ORDER OF "headers_first_row"
		# Create hash with new information for each unique unit ID
		unit_ids[i] = [uniq_ids[i], timestamp, address_located_yn, address, appid, batchid, batchn, bgfips, city, state, zip, mean_lat, mean_lon, mean_rad, newmean_lat, newmean_lon, newmean_rad, num_resp, num_outliers, num_far, prop_far]

		ap "about to print to file"
		# Write one row per unit ID
		newcsv << unit_ids[i]

	end

end

ap "Number of outliers: " + outlier_count.to_s
ap "Number of units with no lat/lon: " + zero_count.to_s