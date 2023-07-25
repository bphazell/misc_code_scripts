
require 'awesome_print'
require 'csv'
require 'mail'

# RECIPIENTS = 	['bhazell@crowdflower.com',
# 				 'julia.guthrie@crowdflower.com',
# 				  'blake.street@crowdflower.com']

RECIPIENTS = 	['bhazell@crowdflower.com']
				  
COOKIE = "optimizelyEndUserId=oeu1468342190728r0.5197446759497777; ajs_anonymous_id=%222bf06741-ec11-4fa9-8b2b-1a6ec8533370%22; colodin_id=2027182383-177040907-3539579678-crowdflower.com; _vwo_uuid=A6F1F71E2456EE327BC67BB70DE3FCFB; mp_00f02d597c642b7efab39759dac628ea_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpu%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D; __utma=105072849.2005251143.1468342193.1487014676.1487029508.57; __utmz=105072849.1485798514.52.40.utmcsr=make.crowdflower.com|utmccn=(referral)|utmcmd=referral|utmcct=/jobs/980050/dashboard; __utmv=105072849.Taxonomyzer; optimizelySegments=%7B%22298794671%22%3A%22direct%22%2C%22298874097%22%3A%22false%22%2C%22298896012%22%3A%22gc%22%7D; optimizelyBuckets=%7B%7D; _sid=qpxD5GqA5_yoGMnxWsmdco6zgk4vdZUL; 991804-mapper=true; 992140-mapper=true; _hp2_id.2757902115=%7B%22userId%22%3Anull%2C%22pageviewId%22%3A%221047290498979981%22%2C%22sessionId%22%3A%220353831115001409%22%2C%22identity%22%3A%22f88b37ce1417edd018f6e92d65edd9da6f3747ef%22%2C%22trackerVersion%22%3A%223.0%22%7D; 986931-mapper=true; colodin_thank_you_page_referrer=https%3A%2F%2Fwww.google.com%2Furl%3Fq%3Dhttps%253A%252F%252Fwww.crowdflower.com%252Fcontact%252F%26sa%3DD%26sntz%3D1%26usg%3DAFQjCNGy_UH70Ws3jKrN4P0Grgv7lAcgfQ; colodin_thank_you_page_url=https%3A%2F%2Fwww.crowdflower.com%2Fcontact%2F; _vwo_uuid_v2=A6F1F71E2456EE327BC67BB70DE3FCFB|ec3582e64e3bc1a8e5ee99cc739291dc; trwv.uid=crowdflower2-1469044937069-07cddf11%3A37; 993902-mapper=true; __zlcmid=bbfhGEF5bnC9JW; _make_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWE5NmI4OTk1YmU3ZjdjMjRmYjhlYWFmMDJlNTRhZDM5BjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMWtEeU5vdEN3UHRBR0k5bmtRYUQybUowTCtnRzgxbVpxSWFlQzl3ekVqa289BjsARg%3D%3D--0eaa192645eb681b83d594e9b06d6a4af61fdd22; _gat=1; last_seen=102; ajs_group_id=null; ajs_user_id=23183; _ga=GA1.2.2005251143.1468342193; mp_e0fd08bd7e74d0bf03862bb8de3a5168_mixpanel=%7B%22distinct_id%22%3A%2023183%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fwww.crowdflower.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22www.crowdflower.com%22%2C%22%24search_engine%22%3A%20%22yahoo%22%2C%22mp_lib%22%3A%20%22Segment%3A%20web%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22plan%22%3A%20%22admin%22%2C%22company%22%3A%20%22crowdflower%22%2C%22balance%22%3A%2015%2C%22team_admin%22%3A%20true%2C%22phone%22%3A%20null%2C%22subscription_unit_limit%22%3A%2099999999%2C%22subscription_units_used%22%3A%206061%2C%22subscription_expires_at%22%3A%20%222018-12-31T00%3A00%3A00.000Z%22%2C%22subscription_type%22%3A%20%22active%22%2C%22title%22%3A%20null%2C%22id%22%3A%2023183%2C%22%24created%22%3A%20%222013-07-16T22%3A05%3A00.000Z%22%2C%22%24email%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24first_name%22%3A%20%22Brian%22%2C%22%24last_name%22%3A%20%22%22%2C%22%24name%22%3A%20%22Brian%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Fmake.crowdflower.com%2Fjobs%2F963716%2Ftest_questions%2F1102360826%2Fedit%22%7D; mp_mixpanel__c=0; _mkto_trk=id:416-ZBE-142&token:_mch-crowdflower.com-1468342192717-82211"

#configure options for mail gem
mail_options = {
	:address => "smtp.gmail.com",
	:port => 587,
	:domain => "gmail.com",
	:user_name => "cfcsdreports@gmail.com",
	:password => "123dolores",
	:authentication => 'plain',
	:enable_starttls_auto => true
}

Mail.defaults do
	delivery_method :smtp, mail_options
end

def threshBody(funds, thresh)
	"The funds in your account passed the #{thresh.gsub('under_','')} threshold"
end

def send_email(funds, thresh)
	text = threshBody(funds, thresh)
	mail = Mail.deliver do
		from 'cfcsdreports@gmail.com'
		to RECIPIENTS
		subject "Lyst funds at #{funds}"
		body text
	end
end


def curlTeam
	response = %x(curl -L 'https://make.crowdflower.com/admin/teams/35703a4e-a35d-446f-bc17-fdf921b7a1fb' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: https://make.crowdflower.com/admin/teams?q=lyst' -H 'Cookie: #{COOKIE}' -H 'Connection: keep-alive' --compressed)
end

def parseResponse
	puts "in parse response"
	response = curlTeam
	info = response.to_s
	info = info.gsub("\n", "").scan(/(?<=Enterprise)(.*)(?=Jobs in Progress)/).to_s
	info = info.scan(/<td>([^<>]*)<div>/)[0][0].gsub(/\s+/, "").gsub(/\D/,'').to_f
	info = info * 0.01
end


def threshFunc(funds, row, thresh)
	if funds < thresh
		ap "less than #{thresh}"
		emailLogic(row, funds, "under_#{thresh}")
		row["under_#{thresh}"] = 1
	elsif funds > thresh
		ap "more than #{thresh}"
		row["under_#{thresh}"] = 0
	end

end

def fundLogic(funds, row, data)
	begin
		threshFunc(funds, row, 15000)
		threshFunc(funds, row, 10000)
		threshFunc(funds, row, 5000)
	rescue
		print 'broke'
		data
	end
end

def emailLogic(row, funds, thresh)
	if row[thresh] == '0'
		ap "send #{thresh} email"
		send_email(funds, thresh)
	end
end

def send_email_nl(funds)
	mail = Mail.deliver do
		from 'cfcsdreports@gmail.com'
		to RECIPIENTS
		subject "Lyst funds at #{funds}"
		body "FYI"
	end
end

# funds = 14000
ap "start parse"
funds = parseResponse 
ap funds 
send_email_nl(funds)

CSV.foreach("lyst_email_tracker.csv", :headers => true) do |row|
	CSV.open("lyst_email_tracker.csv", 'w', :write_headers => true, :headers => ["under_15000","under_10000", "under_5000"]) do |out|
		data = row
		fundLogic(funds, row, data)
		ap row
		out << row
	end
end

