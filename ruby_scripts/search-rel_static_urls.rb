
require 'nokogiri'
require 'awesome_print'
require 'open-uri'
require 'csv'
require 'aws-sdk'
require 'net/http'

key = "AKIAIJQCFBW7Y3DKKN4Q"
secret = "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"
bucket = "cf-public-view"
folder_name = "static_web_pages2"
AWS_S3BASE = "https://cf-public-view.s3.amazonaws.com/"

# connect to aws
creds = Aws::Credentials.new(key, secret)
s3 = Aws::S3::Client.new(
  region: "us-east-1",
  credentials: creds,
)


input_csv_name = ARGV[0]

output_csv_name = "#{input_csv_name}_static.csv"
new_header = "static_url"

def get_headers(csv_name)
	CSV.foreach(csv_name, headers: false) do |row|
		return row
	end
end

def split_url(url)
	url = url.gsub("http://","")
	url1 = url.scan(/^[^;]*com/)[0]
	url2 = url.split(".com")[1]
	url_a = [url1, url2]
end

counter = 0
headers = get_headers(input_csv_name)
headers << new_header

CSV.open(output_csv_name, "w", write_headers: true, headers: headers) do |out|
	CSV.foreach(input_csv_name, headers: true) do |row|
		begin
			counter += 1
			url = row['product_link']
			if url.include?("walmart.com")
				doc = Nokogiri::HTML(open(url))
				file_name = "file_#{counter}.html"
			else
				url_a = split_url(url)
				doc = Net::HTTP.get("#{url_a[0]}", "#{url_a[1]}")
				file_name = "file_#{counter}.html"
			end
			key = "#{folder_name}/#{file_name}"
			response = s3.put_object(bucket: bucket, key: key, body: doc.to_s, acl: "public-read")
			url = AWS_S3BASE + key
			ap url
			row << url
		rescue
			next
		end
		out << row
	end
end



