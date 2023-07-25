import csv
import sys
import os
import re
import string
import uuid
from collections import OrderedDict
from pprint import pprint

DEBUG=True
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
    rows_read=0
    rows_written=0

	###############################
	#Configure column headers here
	###############################
    src_columns=["promotion_name","sit_abi_flag","sit_addr_line_1","sit_axc_fl","sit_city_name","sit_company_name","sit_country_code","sit_dmi_flag","sit_equifax_flag","sit_mzp_id","sit_state_cd","sit_zip4_code","sit_zip5_code","stp_arbitrated_sales_new","stp_arbitrated_sales_source_new","stp_arbritrated_sales_confdnc_cd_new","stp_masterid"]
    
    crowdflower_columns=["url","url_type","business_name","street","city","state","postal_code"]
    
    output_jobs={3:"Industry",4:"LinkedIn",5:"Glassdoor_Owler",6:"Phone"}
    
    output_columns={3:["Job 3:categorize_yn","Job 3:industry_sic3","Job 3:industry_sic4","Job 3:new_url","Job 3:new_url_worker_input","Job 3:new_url_yn","Job 3:SIC2_code","Job 3:SIC4_code"],
                    4:["Job 4:company_founded_yn","Job 4:company_hq_yn","Job 4:company_size","Job 4:company_size_yn","Job 4:linkedin_founded_yr","Job 4:linkedin_url","Job 4:linkedin_yn"],
                    5:["Job 5:company_hq_yn","Job 5:gd_company_size","Job 5:gd_employees_listed","Job 5:gd_lower_revenue","Job 5:gd_profile_yn","Job 5:gd_revenue_listed","Job 5:gd_upper_revenue","Job 5:gd_url","Job 5:gd_url_worker_input","Job 5:glassdoor_hq_yn","Job 5:official_company_size","Job 5:official_employees_listed","Job 5:official_revenue","Job 5:official_revenue_yn","Job 5:owler_company_size","Job 5:owler_employees_listed","Job 5:owler_hq_yn","Job 5:owler_url","Job 5:owler_profile_yn","Job 5:owler_revenue","Job 5:owler_revenue_listed"],
                    6:["Job 6:mult_locations_yn","Job 6:new_url","Job 6:new_url_worker_input","Job 6:new_url_yn","Job 6:num_locations","Job 6:phone","Job 6:phone_searched","Job 6:phone_yn"]}

    UUID = "uuid"
    
    path = sys.argv[1]
    
    if not os.path.isdir(path):
        print("File path {} does not exist. Exiting...".format(path))
        sys.exit()
        
    #files=["Job_3_full_SIC.csv","Job_3_Delta_SIC.csv","Job_4.csv","Job_4_Delta.csv","Job_5.csv","Job_5_Delta.csv","Job_4.csv","Job_6.csv","Job_6_Delta.csv"]
    file_column_map={"a1234207_SIC- Job 3 - Industry - Categorize Businesses - New Headers.csv":3,"a1234224 - Job 4 - Linked In - New Headers.csv":4,"a1234208 - Job 5 - Revenue - Company Information - New Headers.csv":5,"a1234209 - Job 6 - Phone #, Locations - New Headers.csv":6}
    
    src_done = False
    output = {}
    
    for fname in file_column_map.keys():
        print ("Opening: " + path + "/" + fname)
        with open(path + "/" +fname) as fh:
            reader = csv.DictReader(fh)
            #Process each row
            #if DEBUG:
                #print "Processing file {}...".format(fname)
                #print "Processing columns:"
                #pprint(src_columns + crowdflower_columns + output_columns[file_column_map[fname]])
            for row in reader:
                
                for fld in (src_columns + crowdflower_columns + output_columns[file_column_map[fname]]):
                    #if DEBUG:
                        #print "Row is: "
                        #pprint(row)
                        #print "Output is:"
                        #pprint(output)

                    if row[UUID] not in output:
                        output[row[UUID]]={UUID:row[UUID]}
                    try:
                        if fld in output[row[UUID]]:
                            #Don't overwrite with empty values
                            if output[row[UUID]][fld].strip() == "" and row[fld].strip() <> "":
                                output[row[UUID]][fld]=row[fld]
                        else:
                            output[row[UUID]][fld]=row[fld]
                    except Exception as e:
                        #output[row[UUID]][fld]=""
                        if DEBUG:
                            print "Field {} not found in file {}".format(fld,fname)
    
    #if DEBUG:
        #print "Output:"
        #pprint (output)

    #error_count=0
    error_uuid=set()
    with open("output-consolidated.csv","w") as csv_output:
        writer = csv.writer(csv_output)
        writer.writerow(["uuid"]+src_columns + crowdflower_columns + output_columns[3] + output_columns[4] + output_columns[5] + output_columns[6])
        
        for uuid in output.keys():
            row_output=[]
            #row_output.append(uuid)
            for fld in (["uuid"]+src_columns + crowdflower_columns + output_columns[3] + output_columns[4] + output_columns[5] + output_columns[6]):
                #if DEBUG:
                #    print "Row output is:"
                #    pprint(output[uuid])
                try:
                    row_output.append(output[uuid][fld])
                except KeyError as ke:
                    print "Unexpected: Unsure why this occurred field {} missing in output for row with UUID {}".format(fld,uuid)
                    error_uuid.add(uuid)
                    #pprint(output[uuid])
                    #print "Premature Exit!"
                    #exit()

            try:
                #print "Writing Row" + str(row_output)
                writer.writerow(row_output)
                rows_written = rows_written + 1
            except Exception as e:
                print ("Exception occurred writing row")
                exit()

	print "Finished processing files output-consolidated"
	print "\n*Statistics*"
	print "Rows Written: {:,}".format(rows_written) 
    print "Error Count: {:,}".format(len(error_uuid)) 
    print "UUID with errors"
    pprint(error_uuid)
if __name__ == '__main__':  
   main()
   if "DEBUG" in os.environ and os.environ["DEBUG"].upper() == "TRUE":
       DEBUG=True


