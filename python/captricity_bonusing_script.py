import psycopg2
import code
import requests
import numpy as np
import datetime as dt   
import pandas as pd 
import smtplib
import mimetypes
from email.mime.multipart import MIMEMultipart
from email import encoders
from email.message import Message
from email.mime.base import MIMEBase
from email.mime.text import MIMEText

redshift = psycopg2.connect(dbname = 'matt_crowdflower', host = 'cf-redshift.etleap.com',
	port = 5439, user = 'matt_crowdflower', password = 'wznvhKJVAC135299756')
API_KEY = "8P4A-zpGr9AuBDkSGLCp"
headers = {"content-type": "text/csv"}
payload = {"key": API_KEY}


cur = redshift.cursor()
# this is the query we actually want to run (with current_date), but
# the job hasn't collected judgments since 9/6 so for testing purposes
# you can use the one further down...

cur.execute("with counts as (select s.akon_id, count(s.assignment_id) as assignments, s.job_id from public.stats_external_assignment_status s where s.job_id = 1206524 and s.status = 'approved' and s.created_at between (current_date - 1) and current_date group by s.akon_id, s.job_id order by s.akon_id), jobs as (select w.user_id as akon_id, worker_id as contributor_id from builder_worksets join builder_workers w on w.id = builder_worksets.worker_id join stats_external_assignment_status s on s.job_id = builder_worksets.job_id join builder_jobs on builder_jobs.id = builder_worksets.job_id where s.job_id = 1206524 group by 1,2) select distinct(j.contributor_id) as contributor_id, c.assignments from counts c join akon_users a on a.id = c.akon_id join builder_workers w on w.user_id = a.id join jobs j on j.akon_id = c.akon_id order by j.contributor_id")

# ...this one:
# cur.execute("with counts as (select s.akon_id, count(s.assignment_id) as assignments, s.job_id from public.stats_external_assignment_status s where s.job_id = 1206524 and s.status = 'approved' and s.created_at between '2017-09-05' and '2017-09-06' group by s.akon_id, s.job_id order by s.akon_id), jobs as (select w.user_id as akon_id, worker_id as contributor_id from builder_worksets join builder_workers w on w.id = builder_worksets.worker_id join stats_external_assignment_status s on s.job_id = builder_worksets.job_id join builder_jobs on builder_jobs.id = builder_worksets.job_id where s.job_id = 1206524 group by 1,2) select distinct(j.contributor_id) as contributor_id, c.assignments from counts c join akon_users a on a.id = c.akon_id join builder_workers w on w.user_id = a.id join jobs j on j.akon_id = c.akon_id order by j.contributor_id")
 
# sql_results = [(1L, 4L), (2L, 9L), (3L, 34L)] ## <<< this is dummy data you can test with

sql_results = cur.fetchall()
sql_results = np.asarray(sql_results)

output_array = []

for contributor in sql_results:
	i = contributor
	num = contributor[1]
	worker = contributor[0]
	bonus = num * 4
	message = "Good work on job 1206524! %s of your assignments were accepted." % num
	bonus_request = requests.post("https://api.crowdflower.com/v1/jobs/1206524/workers/{}/bonus.json?key={}&amount={}&reason={}".format(worker, API_KEY, bonus, message))
	cid = str(worker)
	bonus_amt_to_log = str(bonus)
	date = pd.to_datetime('today')
	success_v_fail = str(bonus_request)
	output_array.append([cid,bonus_amt_to_log,success_v_fail,date])

print output_array

# use this snippet below to break into the script for a makeshift console
# code.interact(local=dict(globals(), **locals()))
# break

# cur.close()
# redshift.close()
headers = ["contributor","bonus_amount","response","bonus_date"]
df = pd.DataFrame(output_array)
try:
	with open('captricity_bonus_results_test.csv') as file:
		df.to_csv('captricity_bonus_results_test.csv', mode='a', header=False, index=False)
except IOError:
	df.to_csv('captricity_bonus_results_test.csv', header=headers, index=False)

emailfrom = "cfcsdreports@gmail.com"
emailto = ["kirsten.gokay@figure-eight.com", "bhazell@figure-eight.com"] 
fileToSend = "captricity_bonus_results_test.csv"
username = "cfcsdreports@gmail.com"
password = "123dolores"

if not output_array:
	msg = MIMEMultipart()
	msg["From"] = emailfrom
	msg["To"] = ", ".join(emailto)
	date_none = pd.to_datetime('today')
	date_none = date_none.date()
	msg["Subject"] = "Captricity bonuses for %s" % date_none
	body_none = "There were no results from the query."
	body_none = MIMEText(body_none)
	msg.attach(body_none)
else:
	msg = MIMEMultipart()
	msg["From"] = emailfrom
	msg["To"] = ", ".join(emailto)
	date = date.date()
	msg["Subject"] = "Captricity bonuses for %s" % date
	body_success = "Attached are the results of today's bonuses."
	body_success = MIMEText(body_success)
	msg.attach(body_success)

	ctype, encoding = mimetypes.guess_type(fileToSend)
	if ctype is None or encoding is not None:
	    ctype = "application/octet-stream"

	maintype, subtype = ctype.split("/", 1)


	fp = open(fileToSend, "rb")
	attachment = MIMEBase(maintype, subtype)
	attachment.set_payload(fp.read())
	fp.close()
	encoders.encode_base64(attachment)
	attachment.add_header("Content-Disposition", "attachment", filename=fileToSend)
	msg.attach(attachment)

server = smtplib.SMTP("smtp.gmail.com:587")
server.starttls()
server.login(username,password)
server.sendmail(emailfrom, emailto, msg.as_string())
server.quit()    
