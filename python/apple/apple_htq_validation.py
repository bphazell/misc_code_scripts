import csv
import sys
import os
import re
import string
import uuid
import time
import random
import pycurl
import zipfile
import random
import StringIO
import numpy
import argparse, fileinput, json, ast, subprocess, os
from pprint import pprint
from io import BytesIO

DEBUG=False
API_KEY="7f5Sgkce3UBDgrxvYBsb"
REPORT_TYPE="full"
FORCE_REGENERATE=False
JOB_ID=None
HIDDEN_TQ_FILE=None
CHECK_FIELDS=None
HIDDEN_TQ_UNITS={}
HIDDEN_ANSWER_COL_SUFFIX = None
HIDDEN_ROW_COL = None

#Normalize column names to CrowdFlower standards 
#(A) Replace space with "_"
#(B) Make everything lowercase
def normalize_columns(columns):
	ret_cols=[]
	for col in columns:
		col=string.replace(col," ","_")
		ret_cols.append(col.lower())
	return ret_cols

def spinning_cursor():
    while True:
        for cursor in '|/-\\':
            yield cursor

spinner = spinning_cursor()

def readHiddenTQs():
    #Read all the hidden Test Questions

    #open file

    #{unit id: { field : [list of answers]}}

    print "\nLoading hiddent test question units from file {}".format(HIDDEN_TQ_FILE)

    num_units=0

    with open(HIDDEN_TQ_FILE) as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            answers={}
            for field in CHECK_FIELDS:
                answer[field]=row[field]

            HIDDEN_TQ_UNITS[row["_unit_id"]]=answers
            num_units = num_units + 1
            
    print "Finished loading {} hidden test question units".format(num_units)



def main(): 

    buffer = BytesIO()
    c = pycurl.Curl()
    c.setopt(c.WRITEDATA, buffer)

    #Force report generation
    #TODO can potentially be skipped
    if FORCE_REGENERATE == True:
        url = "https://api.crowdflower.com/v1/jobs/{}/regenerate?type={}&key={}".format(JOB_ID,REPORT_TYPE,API_KEY)
        print "\nForce generating report {}".format(FORCE_REGENERATE)
        print url
        c.setopt(c.URL, url)
        c.setopt(c.POST, 1)
        c.perform()
        responseCode = c.getinfo(c.RESPONSE_CODE)
        print('Status: %d' % responseCode)

    #Prep and Ready Check wait for 302
    url = "https://api.crowdflower.com/v1/jobs/{}.csv?type={}&key={}".format(JOB_ID,REPORT_TYPE,API_KEY)
    print "\nChecking report readiness"
    print url
    c.setopt(c.URL, url)

    responseCode = None

    
    while responseCode <> 302:
        c.perform()
        responseCode = c.getinfo(c.RESPONSE_CODE)
        #print('Status: %d' % responseCode)
        if responseCode <> 302:
            #print "Waiting (Status Code:"+ str(responseCode) + ")"+ "." * random.randint(1,10) 
            sys.stdout.write("Waiting for report generation to complete (Status: "+ str(responseCode) + ")   " + spinner.next()+"\n")
            sys.stdout.flush()
            sys.stdout.write("\033[F")
            time.sleep(0.5)

    print "\nReport ready for download"

    filename = "f"+ str(JOB_ID) + "_" + str(uuid.uuid4()) +".zip"
    print "\nDownloading File: {}".format(filename)
    with open(filename, 'wb') as f:
        c = pycurl.Curl()
        url = "https://api.crowdflower.com/v1/jobs/{}.csv?type={}&key={}".format(JOB_ID,REPORT_TYPE,API_KEY)
        c.setopt(c.URL, url)
        c.setopt(c.WRITEDATA, f)
        c.setopt(c.FOLLOWLOCATION, True)
        c.perform()
        c.close()

    #
    zipfilehandle = open(filename, 'rb')
    zfile = zipfile.ZipFile(zipfilehandle)
    data = StringIO.StringIO(zfile.read("f"+str(JOB_ID)+".csv")) #don't forget this line!
    reader = csv.DictReader(data)

    worker_scoring_map={}
    worker_profile={}

    for row in reader:
        
        #Check if contributor is already in contributor map
        worker_id = row["_worker_id"]
        unit_id = row["_unit_id"]
        tainted = row["_tainted"]

        if worker_id not in worker_profile:
            worker_profile[worker_id]={"channel":set(),"trust":set(),"country":set(),"region":set(),"city":set(),"ip":set()}
        
        worker_profile[worker_id]["channel"].add(row["_channel"])
        worker_profile[worker_id]["trust"].add(row["_trust"])
        worker_profile[worker_id]["country"].add(row["_country"])
        worker_profile[worker_id]["region"].add(row["_region"])
        worker_profile[worker_id]["city"].add(row["_city"])
        worker_profile[worker_id]["ip"].add(row["_ip"])

        if SKIP_TAINTED and tainted.upper()=="TRUE":
            if DEBUG:
                print "Skipping tainted row for worker {} and unit {}".format(worker_id,unit_id)
            continue

        #print "Processing unit id:" + unit_id

        #Check if the unit is a hidden test question
        if HIDDEN_TQ_FILE and unit_id in HIDDEN_TQ_UNITS:
            
            if DEBUG:
                print "[External HTQ File] Found Hidden Test Question in unit id {}".format(unit_id)            
            #Obtain HTQ unit
            htq_unit = HIDDEN_TQ_UNITS["unit_id"]
           
            worker_findings=[]
            htq_unit_status = "correct"
            for htq,answers in htq_unit.iteritems():
                #Accomodate multiple answers e.g. URLs, Phone #, etc.
                all_answers = answers.strip().split("\n")

                findings = {"htq": htq, "expected": all_answers, "actual": row[htq]}

                #Check if answer for the HTQ is in any of the answers 
                if row[htq] in all_answers:
                    #Got this HTQ correct
                    findings["status"] = "correct"
                else:
                    #Got this HTQ correct
                    findings["status"] = "incorrect"
                    #Atleast one answer was incorrect
                    htq_unit_status = "incorrect"
                
                worker_findings.append(findings)

            if worker_id not in worker_scoring_map:
                worker_scoring_map[worker_id]={"failedHTQ": [], "failedTQ": [], "passedHTQ": [], "passedTQ": []}

            if htq_unit_status == "incorrect":
                worker_scoring_map[worker_id]["failedHTQ"].append({unit_id:worker_findings})
            elif htq_unit_status == "correct":
                worker_scoring_map[worker_id]["passedHTQ"].append({unit_id:worker_findings})
        
        elif row["_golden"].upper()=="TRUE":
            if DEBUG:
                print "Found GOLD Test Question in unit id {}".format(unit_id)
            worker_findings=[]
            gtq_unit_status = "correct"
            for gtq in CHECK_FIELDS:
                #Accomodate multiple answers e.g. URLs, Phone #, etc.
                gold_answers = row[gtq+"_gold"].strip().split("\n")

                findings = {"gtq": gtq, "expected": gold_answers, "actual": row[gtq]}

                #Check if answer for the HTQ is in any of the answers 
                if row[gtq] in gold_answers:
                    #Got this HTQ correct
                    findings["status"] = "correct"
                else:
                    #Got this HTQ correct
                    findings["status"] = "incorrect"
                    #Atleast one answer was incorrect
                    gtq_unit_status = "incorrect"
                
                worker_findings.append(findings)

            if worker_id not in worker_scoring_map:
                worker_scoring_map[worker_id]={"failedHTQ": [], "failedGTQ": [], "passedHTQ": [], "passedGTQ": []}

            if gtq_unit_status == "incorrect":
                worker_scoring_map[worker_id]["failedGTQ"].append({unit_id:worker_findings})
            elif gtq_unit_status == "correct":
                worker_scoring_map[worker_id]["passedGTQ"].append({unit_id:worker_findings})
        elif HIDDEN_ROW_COL in row and row[HIDDEN_ROW_COL].upper()==HIDDEN_ROW_COL_VALUE.upper(): #Special case of no hidden tq file , only using _hidden fields
            if DEBUG:
                print "Found HIDDEN Test Question in unit id {}".format(unit_id)
            worker_findings=[]
            htq_unit_status = "correct"
            for htq in CHECK_FIELDS:
                #Accomodate multiple answers e.g. URLs, Phone #, etc.
                htq_gold_answers = row[htq+HIDDEN_ANSWER_COL_SUFFIX].strip().split("\n")

                findings = {"htq": htq, "expected": htq_gold_answers, "actual": row[htq]}

                #Check if answer for the HTQ is in any of the answers 
                if row[htq] in htq_gold_answers:
                    #Got this HTQ correct
                    findings["status"] = "correct"
                else:
                    #Got this HTQ correct
                    findings["status"] = "incorrect"
                    #Atleast one answer was incorrect
                    htq_unit_status = "incorrect"
                
                worker_findings.append(findings)

            if worker_id not in worker_scoring_map:
                worker_scoring_map[worker_id]={"failedHTQ": [], "failedGTQ": [], "passedHTQ": [], "passedGTQ": []}

            if htq_unit_status == "incorrect":
                worker_scoring_map[worker_id]["failedHTQ"].append({unit_id:worker_findings})
            elif htq_unit_status == "correct":
                worker_scoring_map[worker_id]["passedHTQ"].append({unit_id:worker_findings})

    if len(worker_scoring_map.keys())==0:
        print "\n**Abort!! Found no applicable rows for analysis**"

    for worker_id in worker_scoring_map.keys():
        print "Worker Id: {}".format(worker_id)
        print "Worker Profile:\b"
        pprint (worker_profile[worker_id])
        fHTQ = len(worker_scoring_map[worker_id]["failedHTQ"])
        pHTQ = len(worker_scoring_map[worker_id]["passedHTQ"])
        fGTQ = len(worker_scoring_map[worker_id]["failedGTQ"])
        pGTQ = len(worker_scoring_map[worker_id]["passedGTQ"])

        if fHTQ + pHTQ == 0:
            accuracyHTQ = float('nan')
        else:
            accuracyHTQ = 100 * (numpy.float(pHTQ)/(pHTQ+fHTQ))
        
        if fGTQ + pGTQ == 0:
            accuracyGTQ = float('nan')
        else: 
            accuracyGTQ = 100 * (numpy.float(pGTQ)/(pGTQ+fGTQ))

        if fGTQ + pGTQ + fHTQ + pGTQ == 0:
            accuracyOverall = float('nan')
        else: 
            accuracyOverall = 100 * (numpy.float(pGTQ+pHTQ)/(pGTQ+fGTQ+pHTQ+fHTQ))      

        print "Failed HTQ: {}".format(fHTQ)
        print "Passed HTQ: {}".format(pHTQ)
        print "Failed GTQ: {}".format(fGTQ)
        print "Passed GTQ: {}".format(pGTQ)
        print "Accuracy HTQ: {} % Accuracy GTQ: {} % Accuracy Overall: {} %".format(round(accuracyHTQ,2),round(accuracyGTQ,2),round(accuracyOverall,2))
        print "\n"
    
    #pprint (worker_scoring_map)
    
    logfilename = "f"+ str(JOB_ID) + "_" + str(uuid.uuid4()) +".log"
    print "\nWriting Detailed Log File for analysis: {}".format(logfilename)

    with open(logfilename, 'w') as flog:
        pprint(worker_scoring_map,flog)
   
if __name__ == '__main__':

    if "DEBUG" in os.environ and os.environ["DEBUG"].upper() == "TRUE":
       DEBUG=True
    
    parser = argparse.ArgumentParser(description='Validates the full report against the set of hidden test questions')
    parser.add_argument('--jobId', help='CF Job ID', required=True,type=int)
    parser.add_argument('--hiddenTQFile', help='File containing hidden test questions',required=False,type=str)
    parser.add_argument('--checkFields', help='Comma Seperated List of Fields to Validate', required=True,type=str)
    parser.add_argument('--forceRegenerate', help='Force Regenerate the Report', required=False,nargs='?',const=True,default=False,type=bool)
    parser.add_argument('--skipTainted', help='Skip Tainted Rows',required=False,default=True,type=bool)
    parser.add_argument('--hiddenRowCol', help='Column Indentifying Hidden Test Question Rows', default="_hidden",type=str)
    parser.add_argument('--hiddenRowColValue', help='Column Value Indentifying Hidden Test Question Rows', default="TRUE",type=str)
    parser.add_argument('--hiddenAnswerColSuffix', help='Column Indentifying Hidden Test Questions Answers', default="_gold",type=str)
    parser.add_argument('--apiKey',help='API Key for the CF Rest API',default=API_KEY,type=str)

    args = parser.parse_args()
    
    globals()['JOB_ID']= args.jobId
    globals()['API_KEY']= args.apiKey
    globals()['FORCE_REGENERATE']= args.forceRegenerate
    globals()['SKIP_TAINTED']=args.skipTainted
    globals()['HIDDEN_TQ_FILE']= args.hiddenTQFile
    globals()["HIDDEN_ROW_COL"] = args.hiddenRowCol
    globals()["HIDDEN_ROW_COL_VALUE"] = args.hiddenRowColValue
    globals()["HIDDEN_ANSWER_COL_SUFFIX"] = args.hiddenAnswerColSuffix
    globals()['CHECK_FIELDS']=args.checkFields.split(",")
    

    if HIDDEN_TQ_FILE:
        readHiddenTQs()

    main()




