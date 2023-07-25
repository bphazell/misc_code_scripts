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

## UPDATE DIRECTORY ###
# files = find_filenames(".jpg", "/fitness_cv")

### REMOVE WHEN PRODUCITON ###

# files = files[1]

### UPDATE DIRECTORY ###
def model_test(file_name, gold_class):
    files = find_filenames(".jpg", "/"+file_name)
    ### REMOVE FOR PRODUCITON 
    files = files[1:100]
    os.chdir(file_name)
    ### UPDATE FILE NAME  ###
    with open(file_name+"_test_output_v2.csv", 'wb') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        filewriter.writerow(['image_name', 'gold_classification', 'model_classificaton', 'model_confidence', 'raw_output'])
        for i in range(0,len(files)) :
            try: 
                image = (files[i])
                with open(image, 'rb') as images_file:
                    classes = visual_recognition.classify(
                        images_file,
                        threshold='0.0',
                        classifier_ids='TAMultiClassV1_530564482')
                    # print(json.dumps(classes, indent=2))
                    image_name = classes['images'][0]["image"]
                    ml_classes = classes['images'][0]["classifiers"][0]["classes"]
                    class_hash = {}
                    for item in ml_classes:
                        class_hash[item["class"]] = item["score"]
                        if (1-item["score"]) > item["score"]:
                            output_class = "not_"+item["class"]
                    print(str(i)+ " " + image_name)   
                    ### replace function to remove not for class 
                    relevant_score = class_hash[(gold_class).replace("not_", "").title()]
                    if (1-relevant_score) > relevant_score:
                        if "not_" not in gold_class: 
                            relevant_ml_class = "not_" + gold_class
                        else:
                            relevant_ml_class = gold_class
                    else:
                        ### replace function to remove not for class 
                        relevant_ml_class = gold_class.replace("not_", "")
                ### UPDATE LABEL ###
                filewriter.writerow([image_name, gold_class, relevant_ml_class, relevant_score, str(class_hash).replace(",", "|") ])
            except Exception as e:
                print("error: " + str(i))
                print(e)
                # print("error: " + str(files[i]))
                continue 


model_test("fitness_cv", "fitness")

