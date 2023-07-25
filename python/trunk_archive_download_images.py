import requests 
import pandas
from os import listdir
from watson_developer_cloud import VisualRecognitionV3

# visual_recognition = VisualRecognitionV3(
# 	version='{version}',
# 	url='https://gateway.watsonplatform.net/visual-recognition/api',
# 	iam_api_key='cRmu8P-G1nlhxx10Fdr-DNdpKbLFnFboyaqIHBdyapfq'
# 	)

os.chdir("Trunk Archive ML/")

df = pd.read_csv("beauty_job_a1282418.csv")
df = df[df["medium_res_tr2_watermarked_trunkarchive_path"].isnull() == False]

# split data into training / testing / CV sets for beauty and notbeauty 
df_train_excellent = df.loc[df["tag_relevance"] == "excellent"][1:501]
df_cv_excellent = df.loc[df["tag_relevance"] == "excellent"][1001:1250]
df_test_excellent = df.loc[df["tag_relevance"] == "excellent"][1251:1519]

df_train_wrong = df.loc[(df["tag_relevance"] == "completely_wrong") | (df["tag_relevance"] == "poor")][1:25]
df_cv_wrong = df.loc[(df["tag_relevance"] == "completely_wrong") | (df["tag_relevance"] == "poor")][201:301]
df_test_wrong1 = df.loc[(df["tag_relevance"] == "completely_wrong") | (df["tag_relevance"] == "poor")][26:100]
df_test_wrong2 = df.loc[(df["tag_relevance"] == "completely_wrong") | (df["tag_relevance"] == "poor")][301:326]

df_test_wrong = df_test_wrong1.append(df_test_wrong2)

# url = "http://trunk.orangesafebox.com/Doc/TRU/Media/TR2_WATERMARKED/2/9/7/6/TRU2244882.jpg?d63653703007"

# Download images into directory 
i = 0

# update dataframe 
for index, row in df_test_wrong.iterrows():
    # if( i < 3) : 
        try: 
            print('downloading #' + str(i) + ': ' + str(row['medium_res_tr2_watermarked_trunkarchive_path']))
            url = row['medium_res_tr2_watermarked_trunkarchive_path']
            # update file name
            image_name = "not_beautytest_" + str(row['_unit_id'])+".jpg"
            img = requests.get(row['medium_res_tr2_watermarked_trunkarchive_path'], allow_redirects=True)
            # Update path
            path = "not_beauty_test/"+image_name
            if (img.status_code != 403) :
                open(path, 'wb').write(img.content)
            else :
                print("error " + str(img.status_code) + " " + row['medium_res_tr2_watermarked_trunkarchive_path'])
            i +=1
        except Exception as e:
            print("error: " + str(i) + " "+ str(row['_unit_id']))
            print(e)
            # print(row)
            continue 
        
    
# df_cv_wrong.to_csv("df_cv_wrong.csv")
