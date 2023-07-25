import requests
import urllib

def generate_bearer_token() :
	url_api = "https://api.tealiumiq.com/v2/auth"
	headers = {'content-type' : 'application/x-www-form-urlencoded'}
	payload = {'username' : 'brian.hazell@tealium.com', 'key' : 'H7G4^UMe#i|9iG~HQ,cjSMo|KEMlT(*h,,9Q^e9[*6KK4#^x}KRdXQ%,n$nLSPj!'}
	payload = urllib.urlencode(payload)
	r = requests.post(url_api, data=payload, headers=headers)
	token = r.json()['token']
	return token 


bearer = generate_bearer_token()
print "Bearer Token = {}".format(bearer)