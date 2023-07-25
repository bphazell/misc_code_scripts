
import requests 
import pandas
import zipfile

os.chdir("Dropbox (CrowdFlower)/code/python")

org_job = 963218
API_KEY = "jn-dHQVeDHjsarVExWgW"
 

# Problem Set 5:
# Input:
# Job 963218 agg report
# Source data: https://tinyurl.com/y7pkwdpt

# To do:
# Using the API:
# Download the aggregated report from job 963218
# Convert 50 test questions
# Copy job 963218
# Upload source data to new job
# Upload TQs and convert
# Launch internally

# Download the aggregated report from job 963218
request_url = "https://api.figure-eight.com/v1/jobs/{}.csv?type=aggregated".format(org_job)
payload = {'key' : API_KEY}
r = requests.get(request_url, params=payload, allow_redirects=True)
open('figureeight.zip', 'wb').write(r.content)
zip_ref = zipfile.ZipFile("figureeight.zip",'r')
zip_ref.extractall()
zip_ref.close()

agg = pd.read_csv("a963218.csv")

# Convert 50 test questions
g = agg.loc[(agg["category"] == "g") & (agg["category:confidence"] > 0.90)][1:16]
pg = agg.loc[(agg["category"] == "pg") & (agg["category:confidence"] > 0.6)][1:16]
pg_13 = agg.loc[(agg["category"] == "pg-13") & (agg["category:confidence"] > 0.5)][1:16]
r = agg.loc[(agg["category"] == "r") & (agg["category:confidence"] > 0.6)][1:16]

for_gold = g.append([pg,pg_13,r])

for_gold["category_gold"] = for_gold["category"]
for_gold["category_gold_reason"] = "tq reason"
for_gold["_golden"] = "TRUE"

for_gold.to_csv("giphy_gold.csv", index=False)

# copy job 
request_url = "https://api.figure-eight.com/v1/jobs/{}/copy.json".format(org_job)
copy = requests.get(request_url, params=payload)
copy = json.loads(copy.content)
new_job = copy["id"]

# Upload TQs and convert

## upload TQ 
request_url = "https://api.figure-eight.com/v1/jobs/{}/upload.json".format(new_job)
headers = {'content-type': 'text/csv'}
# payload with force=true
payload2 = { 'key': API_KEY,
            'force': "true"}

file_path = "giphy_gold.csv"
csv_file = open(file_path, 'rb')

requests.put(request_url, data=csv_file, params=payload2, headers=headers)

# Convert TQ
request_url = "https://api.figure-eight.com/v1/jobs/{}/gold.json".format(new_job)
payload = { 'key': API_KEY}
r = requests.put(request_url, params=payload)

# Upload source data to new job

new_source = agg[["id", "image_url"]][1:101]
new_source.to_csv("new_giphy_source.csv", index=False)
file_path = "new_giphy_source.csv"
csv_file = open(file_path, 'rb')

request_url = "https://api.figure-eight.com/v1/jobs/{}/upload.json".format(new_job)
requests.put(request_url, data=csv_file, params=payload2, headers=header)

# Launch internally

request_url = "https://api.figure-eight.com/v1/jobs/{}/orders.json".format(new_job)
payload = { 'key': API_KEY,
            'debit[units_count]' : 105,
            'channels[0]' : "cf_internal"}

r = requests.post(request_url, params=payload)
r.status_code

# curl -X POST -d "channels[0]=cf_internal&debit[units_count]={100}" https://api.figure-eight.com/v1/jobs/{job_id}/orders.json?key={api_key}


