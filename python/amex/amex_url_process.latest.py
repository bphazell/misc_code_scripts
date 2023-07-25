import csv
import sys
import os
import re
import string
import uuid
from collections import OrderedDict
import traceback
from pprint import pprint
import json


DEBUG=False

#Normalize column names to CrowdFlower standards 
#(A) Replace space with "_"
#(B) Make everything lowercase
def normalize_columns(columns):
    ret_cols=[]
    for col in columns:
        col=string.replace(col," ","_")
        ret_cols.append(col.lower())
    return ret_cols

def main(): 
    urls_skipped=0
    urls_added=0
    rows_read=0
    rows_written=0
    rows_written_error=0

    ###############################
    #Configure column headers here
    ###############################
    #Customer source columns
    #src_columns=["Promotion Name","SIT_MZP_ID","SIT_COMPANY_NAME","SIT_ADDR_LINE_1","SIT_CITY_NAME","SIT_STATE_CD","SIT_ZIP5_CODE","SIT_ZIP4_CODE","SIT_COUNTRY_CODE","STP_MASTERID","STP_ARBRITRATED_SALES_CONFDNC_CD_NEW","STP_ARBITRATED_SALES_NEW","STP_ARBITRATED_SALES_SOURCE_NEW","SIT_ABI_FLAG","SIT_DMI_FLAG","SIT_EQUIFAX_FLAG","SIT_AXC_FL"]
    src_columns=["promotion_name","sit_abi_flag","sit_addr_line_1","sit_axc_fl","sit_city_name","sit_company_name","sit_country_code","sit_dmi_flag","sit_equifax_flag","sit_mzp_id","sit_state_cd","sit_zip4_code","sit_zip5_code","stp_arbitrated_sales_new","stp_arbitrated_sales_source_new","stp_arbritrated_sales_confdnc_cd_new","stp_masterid"]
    
    #url columns which you want to duplicate over in new file
    url_columns=["official_url_worker_input","directory_url_worker_input","glassdoor_url_worker_input","linkedin_url_worker_input","owler_url_worker_input"]

    #url columns to add to the new output file
    addl_columns=["url_type","url","uuid","status","reason"]

    #unique id column identifier
    id_field="unique_id"
    uuid_field="sit_mzp_id"

    

    src_columns=normalize_columns(src_columns)
    url_columns=normalize_columns(url_columns)
    addl_columns=normalize_columns(addl_columns)

    #output headers are src columns and addl columns
    headers=[]
    headers.extend(src_columns)
    headers.extend(addl_columns)

    input_file = sys.argv[1]

    if not os.path.isfile(input_file):
       print("File path {} does not exist. Exiting...".format(input_file))
       sys.exit()
    
    found_columns=set()

    output_file = input_file.split(".")[0]+".output_ungrouped.csv"
    
    
    #[url_type,url] - {uuid: [other uuids]}
    grouped_urls={}
    grouped_urls_reject={}
    
    with open(input_file,"rU") as csv_input:
        reader = csv.DictReader(csv_input)
        

        with open(output_file,"w") as csv_output:
            writer = csv.writer(csv_output) 

            writer.writerow(headers)

            for row in reader:
                rows_read = rows_read + 1

                #print "Processing id field:" + row[id_field]
                try:
                    output_cols=[]

                    #process each row from source and write source data
                    for c in src_columns:
                        output_cols.append(row[c])

                    #now process the url columns and keep a map for the writing to output
                    urls_map=OrderedDict()
                    urls_reject_map=OrderedDict()
                    
                    #Check for missing sit_mzp_id
                    if row["sit_mzp_id"].strip() == "":
                        print "Warning: sit_mzp_id is missing for business {} - Possible test question please remove from input/output".format(row["sit_company_name"])
                        ##You could just uncomment the line below with "continue" and it will automatically skip##
                        #continue
                    
                    #Check for test question
                    if "_gold" in row:
                        print "Warning: Test Question (GOLD) row in source data for business name {} please remove from input/output ".format(row["sit_company_name"])
                        ##You could just uncomment the line below with "continue" and it will automatically skip##
                        #continue
                    
                    for c in url_columns:
                        #write out the url and address row only if the url is found
                            if c in row:
                                found_columns.add(c)
                                if row[c].strip() != "":
                                    urls_added = urls_added + 1
                                    urls_map[c] = row[c]
                                    
                                else:
                                    urls_skipped= urls_skipped + 1
                                    urls_reject_map[c] = row[c]
                            else:
                                #print "Aborting process - missing url column!!! {}".format{c}
                                if DEBUG:
                                    print "Column '" + c + "' not found in source data" 

                    #generate duplicate output row per for output rows       
                    for url_type in urls_map.keys():
                        
                        if url_type in row:
                            temp_row=[]
                            temp_row.extend(output_cols)

                            #url type is now a column value
                            temp_row.append(url_type)

                            #actual url is the final column
                            temp_row.append(urls_map[url_type])

                                #Add a uuid for the URL concatenate the sit_mzp_id to the uuid4
                            uid =    row["sit_mzp_id"] + "-" + str(uuid.uuid4())
                            temp_row.append(uid)

                            writer.writerow(temp_row)
                            
                            if url_type + "##" + urls_map[url_type] not in grouped_urls:
                                grouped_urls[url_type + "##" + urls_map[url_type]] = []
                            
                            
                            grouped_urls[ url_type + "##"+ urls_map[url_type]].append(uid)
                            rows_written = rows_written + 1
                    
                    #generate duplicate output row per for empty rows 
                    for url_type in urls_reject_map.keys():
                        
                        if url_type in row:
                            temp_row=[]
                            temp_row.extend(output_cols)

                            #url type is now a column value
                            temp_row.append(url_type)

                            #actual url is the final column
                            temp_row.append(urls_reject_map[url_type])

                                #Add a uuid for the URL concatenate the sit_mzp_id to the uuid4
                            uid =    row["sit_mzp_id"] + "-" + str(uuid.uuid4())
                            
                            temp_row.append(str(uid))
                            temp_row.append("reject")
                            utype = url_type
                            temp_row.append("No URL found for " + utype.replace("_worker_input",""))
                            
                            if url_type + "##" + urls_reject_map[url_type] not in grouped_urls_reject:
                                grouped_urls_reject[url_type + "##" + urls_reject_map[url_type]] = []
                            
                            
                            grouped_urls_reject[ url_type + "##" + urls_reject_map[url_type]].append(uid)

                            writer.writerow(temp_row)

                            rows_written_error = rows_written_error + 1
                    
                except Exception as e:
                    print "Except Exception as e:"
                    print "Abandoning - Exception occurred processing column - " + c
                    print (e)
                    traceback.print_exc()
                    exit()

        #print "\nLast row:" + str(row)

    
    topn=5
    if DEBUG:
        for pair in sorted(grouped_urls.items(), key=lambda s: len(s[1]),reverse=True):
            if topn ==0:
                break
            else:
                topn -=1

            print "URL Group: {} of {} items and UUIDS:{}".format(pair[0],len(pair[1]),json.dumps(pair[1]))
    
    #print "Grouped URLS Reject:"
    #pprint(grouped_urls_reject)
    print "\nFinished processing " + input_file + " to output file " +  output_file
    print "\n*Statistics*"
    print "Rows Read: {:,}".format(rows_read)
    print "URLs Added: {:,}".format(urls_added)
    print "URLs Skipped: {:,}".format(urls_skipped)
    print "Rows Written: {:,}".format(rows_written) 
    print "Rows Written Errors: {:,}".format(rows_written_error)
    print "\n*Validations* "
    print "URLs added + URLs Skipped = "+str(len(found_columns))+ " * Rows Read ? {}".format((urls_added+urls_skipped) == (len(found_columns) * rows_read))
    print "Rows Written = URLs added ? {}".format(rows_written==urls_added)
    
    print "Finished Phase I"
    
    print "\nRunning Phase II"
    
    output_file_grouped= input_file.split(".")[0]+".output_grouped.csv"
    
    #Note: You can optimize this additionally by removing the additional linked in query strings which have ??originalSubdomain=co or even trailing slashes to URLs which cause different urls
    
    #Take the file generated in the previous phase and trim it
    rows_read_phaseII=0
    rows_written_phaseII=0
    with open(output_file,"rU") as csv_input_phaseI:
        reader_phaseI = csv.DictReader(csv_input_phaseI)
        #header_phaseI = next(reader_phaseI)
        
        #print "Headers {}".format(header_phaseI)
        
        with open(output_file_grouped,"w") as csv_output_phaseII:
            writer_phaseII = csv.DictWriter(csv_output_phaseII,headers+ ["other_uuids","count_other_uuids"])
           
            writer_phaseII.writeheader()
            for rown in reader_phaseI:
                
                rows_read_phaseII+=1

                if rown["url_type"] + "##" + rown["url"] in grouped_urls and rown["reason"] == None:
                    otheruids=grouped_urls[rown["url_type"] + "##" + rown["url"]]
                    #print "Other uids: {}".format(otheruids)
                    joined = " / ".join(otheruids)
                    #print "Joined: "+ joined 
                    #temp_row.append(row)
                    #temp_row.append(joined)
                    rown.update({"other_uuids":joined,"count_other_uuids":len(otheruids)})
                    #pprint(rown)
                    writer_phaseII.writerow(rown)
                    rows_written_phaseII+=1
                    
                    #Remove item from the grouped_urls so that you dont write it again
                    del grouped_urls[rown["url_type"] + "##" + rown["url"]]
            
    print "\nFinished processing " + output_file + " to output file " +  output_file_grouped
    print "\n*Statistics*"
    print "Rows Read (Including Rejects): {:,}".format(rows_read_phaseII)
    print "Rows Written with Grouping (Excluding Rejects): {:,}".format(rows_written_phaseII) 

if __name__ == '__main__':  
   main()



