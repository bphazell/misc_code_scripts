# Post-processing script for Bloomberg URL Job 3 output
# Input: 1) agg csv
# Output: 1) csv of units that get sent to packaging
#         2) csv of units that continue to next job

# load gems
require 'csv'

# save name of input csv
input_csv = ARGV[0]

suffix1 = "postprocessed"
suffix2 = "to_packaging"
job_number = input_csv.gsub(/\D/,"") # takes the numbers out of input_file

# save name of output csvs
output1_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix1}.csv"
output2_csv = "#{input_csv.gsub(/(\.csv)/,"")}_#{suffix2}.csv"

# read in csv as CSV object
p "Reading in csv...this may take a while..."
reader = CSV.readlines(input_csv, :headers => true)

# save input headers
input_headers = reader.first.headers

headers_to_remove = ["_golden", "_canary", "_unit_state", "_trusted_judgments"]
headers_to_write = [] # headers for mapping to new csv
headers_first_row = [] 

# set up header row to include everything except for gold and confidence columns, and those in "headers_to_remove"
input_headers.each do |head|
    if !(headers_to_remove.include?(head) or head.end_with?("_gold") or head.end_with?("gold_reason"))
      headers_to_write << head  # these headers are used to access rows in the input_csv
      if head.to_s == "_unit_id"
        head = "#{job_number}_unit_id"
      elsif head.to_s == "_last_judgment_at"
        head = "#{job_number}_last_judgment_at"
      end
      headers_first_row << head # these headers are used just to write to the first row
    end
end

headers_first_row = headers_first_row + ["address_line_1_cf", "address_line_2_cf", "city_cf", "state_cf", "zip_cf"]

rows_written = 0
to_package = 0
rows_read = 0

# open output file
CSV.open(output1_csv, 'w', headers: headers_first_row, write_headers: true) do |new_csv|
  CSV.open(output2_csv, 'w', headers: headers_first_row, write_headers: true) do |end_csv|
    reader.each do |row|

      rows_read += 1
      # print out where we are so you don't think you broke the computer
      if rows_read % 1000 == 0 then p "Rows read: #{rows_read}" end

      # create blank fields
      address_line_1_cf = ""
      address_line_2_cf = ""
      city_cf = ""
      state_cf = ""
      zip_cf = ""
      # check if address found and if company is US
      if row["address_found"].to_s == "yes" and row["intl_headquaters"].to_s == "false"  # intl_headquaters is how it is spelled in cml
        row["address_line_1_verified"].to_s == "false" ? address_line_1_cf = row["addressline1"] : address_line_1_cf = row["address_line_1_corrected"]
        row["address_line_2_verified"].to_s == "false" ? address_line_2_cf = row["addressline2"] : address_line_2_cf = row["address_line_2_corrected"]
        row["city_verified"].to_s == "false" ? city_cf = row["city"] : city_cf = row["city_corrected"]
        row["state_verified"].to_s == "false" ? state_cf = row["state"] : state_cf = row["state_corrected"]
        row["zip_verified"].to_s == "false" ? zip_cf = row["zip"] : zip_cf = row["zip_corrected"]
        rows_written += 1
        new_csv << headers_to_write.map { |h| row[h]} + [address_line_1_cf, address_line_2_cf, city_cf, state_cf, zip_cf]
      # check if address not found and if company is non-US
      elsif row["address_found"].to_s == "no" or row["intl_headquaters"].to_s == "true"
        to_package += 1
        end_csv << headers_to_write.map { |h| row[h]} + [address_line_1_cf, address_line_2_cf, city_cf, state_cf, zip_cf]
      end
    end
  end
end

p "Rows read: #{rows_read}"
p "Rows written: #{rows_written}"
p "Units sent to packaging: #{to_package}"