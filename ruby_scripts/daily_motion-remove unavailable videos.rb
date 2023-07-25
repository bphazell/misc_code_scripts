require 'csv'
require 'json'

JOB_ID = ARGV[0]
API_KEY = "sXhKBtZPvLiDjWbGcEtN" #REPLACE THIS WITH YOUR API KEY
REMOVED = "This video has been removed"
DELETED = "This video is no longer available because it has been deleted"
PRIVATE = "We're sorry, but we cannot display this content because it has been labelled private by its author"
REDIRECT = "You will be redirected to the homepage"
HEADERS = ["Row ID", "URL"]
now = Time.now
page = 0
output = "disabled_rows_#{now}.csv"

def get_page(url)
	page = `curl #{url}`
end

def check_availability(page) #Returns true for unavailable videos
	page.include?(REMOVED) || page.include?(DELETED) || page.include?(PRIVATE) || page.include?(REDIRECT)
end

def get_rows(page)
	rows = `curl -X GET "https://api.crowdflower.com/v1/jobs/#{JOB_ID}/units.json?key=#{API_KEY}&page=#{page}"`
	rows = JSON.parse(rows)
end

def disable_row(unit_id)
	response = `curl -X PUT --data-urlencode "unit[state]=canceled" https://api.crowdflower.com/v1/jobs/#{JOB_ID}/units/#{unit_id}.json?key=#{API_KEY}`
end

CSV.open(output, "wb", headers: HEADERS, write_headers: true) do |out|
	while true == true
		page += 1
		rows = get_rows(page)
		break if rows.empty?
		rows.each do |one|
			row_id = one[0]
			url = one[1]["url"]
			page = get_page(url)
			if check_availability(page)
				p "attempting to disable row"
				disable_row(row_id)
				out << [row_id, url]
			end
		end
	end
end