import csv
import sys
import os
import re
import string
import uuid
from collections import OrderedDict

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

    ###############################
    #Configure column headers here
    ###############################
    #Customer source columns
    #src_columns=["Promotion Name","SIT_MZP_ID","SIT_COMPANY_NAME","SIT_ADDR_LINE_1","SIT_CITY_NAME","SIT_STATE_CD","SIT_ZIP5_CODE","SIT_ZIP4_CODE","SIT_COUNTRY_CODE","STP_MASTERID","STP_ARBRITRATED_SALES_CONFDNC_CD_NEW","STP_ARBITRATED_SALES_NEW","STP_ARBITRATED_SALES_SOURCE_NEW","SIT_ABI_FLAG","SIT_DMI_FLAG","SIT_EQUIFAX_FLAG","SIT_AXC_FL"]
    src_columns=["promotion_name","sit_abi_flag","sit_addr_line_1","sit_axc_fl","sit_city_name","sit_company_name","sit_country_code","sit_dmi_flag","sit_equifax_flag","sit_mzp_id","sit_state_cd","sit_zip4_code","sit_zip5_code","stp_arbitrated_sales_new","stp_arbitrated_sales_source_new","stp_arbritrated_sales_confdnc_cd_new","stp_masterid"]
    
    #url columns which you want to duplicate over in new file
    url_columns=["official_url_worker_input","directory_url_worker_input","glassdoor_url_worker_input","linkedin_url_worker_input","owler_url_worker_input"]

    #url columns to add to the new output file
    addl_columns=["url_type","url","uuid"]

    #unique id column identifier
    id_field="unique_id"
    uuid_field="sit_mzp_id"

    

    src_columns=normalize_columns(src_columns)
    url_columns=normalize_columns(url_columns)
    addl_columns=normalize_columns(addl_columns)

    #output headers are src columns and addl columns
    headers=[]
    headers.extend(src_columns)
    #headers.extend()

    input_file = sys.argv[1]

    if not os.path.isfile(input_file):
       print("File path {} does not exist. Exiting...".format(input_file))
       sys.exit()


    with open(input_file,"rU") as csv_input:
        reader = csv.DictReader(csv_input)
        

        with open("output-"+ input_file,"w") as csv_output:
            with open("output-reject-" + input_file, "w") as csv_reject:
                writer = csv.writer(csv_output) 
                writer_reject = csv.writer(csv_reject)

                writer.writerow(headers + addl_columns)
                writer_reject.writerow(headers + ["reject_reason"])

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

                        message=""
                        for c in url_columns:
                            #write out the url and address row only if the url is found
                                if c in row:
                                    if row[c].strip() != "":
                                        urls_added = urls_added + 1
                                        urls_map[c] = row[c]
                                    else:
                                        urls_skipped= urls_skipped + 1
                                        message = message + "/" + c 
                                       
                                else:
                                    if DEBUG:
                                        print "Column '" + c + "' not found in source data" 

                        if message <> "":
                            writer_reject.writerow(output_cols + ["Empty URLs: " + message.replace("_worker_input","")])
                        #generate duplicate output row per url      
                        
                        for url_type in urls_map.keys():
                            
                            if url_type in row:
                                temp_row=[]
                                temp_row.extend(output_cols)

                                #url type is now a column value
                                temp_row.append(url_type)

                                #actual url is the final column
                                temp_row.append(urls_map[url_type])

                                    #Add a uuid for the URL concatenate the sit_mzp_id to the uuid4
                                temp_row.append(row["sit_mzp_id"] + "-" + str(uuid.uuid4()))

                                writer.writerow(temp_row)

                                rows_written = rows_written + 1

                    except Exception as e:
                        print "except Exception as e:"
                        print "Abandoning - Exception occurred processing column - " + c
                        print (e)
                        exit()

        #print "\nLast row:" + str(row)
    print "Finished processing " + input_file + " to output " + "output-"+ input_file
    print "\n*Statistics*"
    print "Rows Read: {:,}".format(rows_read)
    print "URLs Added: {:,}".format(urls_added)
    print "URLs Skipped: {:,}".format(urls_skipped)
    print "Rows Written: {:,}".format(rows_written) 
    print "\n*Validations* "
    print "URLs added + URLs Skipped ="+str(len(url_columns))+ " * Rows Read ? {}".format((urls_added+urls_skipped) == (len(url_columns) * rows_read))
    print "Rows Written = URLs added ? {}".format(rows_written==urls_added)

if __name__ == '__main__':  
   main()



