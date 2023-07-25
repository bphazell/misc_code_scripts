import requests 
import pandas
import os 
from os import listdir
from watson_developer_cloud import VisualRecognitionV3
import json
import csv

visual_recognition = VisualRecognitionV3(
	version='2018-03-19',
	url='https://gateway.watsonplatform.net/visual-recognition/api',
	iam_api_key='cRmu8P-G1nlhxx10Fdr-DNdpKbLFnFboyaqIHBdyapfq'
	)

# with open('notbeauty_GS01055876.jpg', 'rb') as images_file:
#     classes = visual_recognition.classify(
#         images_file,
#         threshold='0.0',
#         classifier_ids='TABeautyvx1_1048214863')
#     print(json.dumps(classes, indent=2))


# print(classes['images'][0]["image"])
# print(classes['images'][0]["classifiers"][0]["classes"][0]["score"])



def find_filenames(suffix, folder):
    filenames = listdir(os.getcwd()+folder)
    return [ filename for filename in filenames if filename.endswith( suffix ) ]

### UPDATE DIRECTORY ###
files = find_filenames(".jpg", "/not_beauty_test")

### REMOVE WHEN PRODUCITON ###
files = files[1:100]

### UPDATE DIRECTORY ###
os.chdir("not_beauty_test")
### UPDATE FILE NAME  ###
with open('not_beauty_test.csv', 'wb') as csvfile:
    filewriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    filewriter.writerow(['image_name', 'gold_classification', 'model_classificatoni', 'model_confidence'])
    for i in range(0,len(files)) :
        # if (i < 2):
            try: 
                image = (files[i])
                with open(image, 'rb') as images_file:
                    classes = visual_recognition.classify(
                        images_file,
                        threshold='0.0',
                        classifier_ids='TABeautyvx1_1048214863')
                    print(json.dumps(classes, indent=2))
                    image_name = classes['images'][0]["image"]
                    ml_class = classes['images'][0]["classifiers"][0]["classes"][0]["class"]
                    ml_score = classes['images'][0]["classifiers"][0]["classes"][0]["score"]
                    ### UPDATE LABEL ###
                    filewriter.writerow([image_name, 'Not Beauty', ml_class, ml_score])
            except Exception as e:
                print("error: " + str(i))
                print(e)
                continue 



