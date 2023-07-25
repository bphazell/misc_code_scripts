
os.chdir("Dropbox (CrowdFlower)/code/python/giphy_ml_tests")

import requests
import zipfile
from os import listdir
import re
import pandas as pd

def remove_headers(df):
    head = df.columns
    bad_headers = ["confidence", "gold", "unit", "judgment"]
    columns_remove = []
    
    for i in range(0,len(bad_headers)):
        col = head[head.str.contains(bad_headers[i])].values.tolist()
        columns_remove = columns_remove + col 

    new_df = df.drop(columns_remove, axis=1)
    return new_df 


giphy_jobs = [ 1024325,973446,983875,951902,959636,1197626,1199631 ]

for job_id in range(0,len(giphy_jobs)) :
    url = ("https://api.crowdflower.com/v1/jobs/"+str(giphy_jobs[job_id])+".csv?type=aggregated&key=jn-dHQVeDHjsarVExWgW")
    r = requests.get(url, allow_redirects=True)
    if r.status_code == 200 :
        print('200')


r = requests.get("https://api.crowdflower.com/v1/jobs/1199631.csv?type=aggregated&key=jn-dHQVeDHjsarVExWgW",allow_redirects=True)
open('crowdflower.zip', 'wb').write(r.content)
zip_ref = zipfile.ZipFile("crowdflower.zip",'r')
zip_ref.extractall()
zip_ref.close()

def find_filenames(suffix):
	filenames = listdir(os.getcwd())
	return [ filename for filename in filenames if filename.endswith( suffix ) ]

files = find_filenames(".csv")

df_all = pd.read_csv(files[0])
df_all = df_all[~(df_all["_golden"])]

for file in range(1,len(files)):
    df = pd.read_csv(files[file])
    df = df[~(df["_golden"])]
    df_all = df_all.append(df)
    
df = df_all[0:10]

df.to_csv("testing_csv.csv", index=False)

ml_call = "http://52.207.138.145/giphy/?url="

# r = requests.get("http://52.207.138.145/giphy/?url=https://media.giphy.com/media/otO0SUurcyvYI/giphy.gif", allow_redirects=True)

output_df = df
output_df = remove_headers(output_df)

output_df["gif_status"] = ""
output_df["gif_ml_label"] = ""
output_df["gif_ml_label_conf"] = ""

# DeprecationWarningisable Chain error ????
pd.options.mode.chained_assignment = None 

for index, row in output_df.iterrows():
    if (output_df["gif_status"][index] == "queued") | (output_df["gif_status"][index] == "")  :
        print row['image_url']
        giph_name = re.sub("https://media.giphy.com/media/|/giphy.gif","", row['image_url'])
        giph_url = row['image_url']
        r = requests.get(ml_call+giph_url, allow_redirects=True)
        print r.status_code
        result = json.loads(r.content)
        # wait response
        
        if result.has_key("label"):
            print("ready")
            label = result["label"]
            output_df["gif_status"][index] = "complete"
            top_frame = result["top_frames"][label]
            output_df["gif_ml_label"][index] = label
            output_df["gif_ml_label_conf"][index] = result["max_confidences"][label]
            with open(giph_name+"_"+label+".png", "wb") as fh:
                fh.write(top_frame.decode('base64'))
        else :
            print("queued")
            output_df["gif_status"][index] = result["status"]
    else :
        print "skip " + output_df["id"][index]

        
    






