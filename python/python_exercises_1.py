
import pandas as pd
import csv
import numpy

os.chdir("code/python/python_exercies_amex/")

###### EXERCISE 1 ######

df = pd.read_csv("amex_url_source_for_python.csv")
# note "~" is = to "!"

# X Remove Test Questions From Report (not using job settings) 
Test_question = df[df["_golden"]]
df2 = df[~(df["_golden"])]
df3 = df[1:10]
# df3 = df2.head(5)

# X Calculate Recall for URL 
rows = float(len(df2))
url_yes = float(len(df2[df2["official_url_yn"] == "yes"]))
off_url_recall = url_yes/rows

# X Calculate Recall for Directory Sites 
dir_yes = float(len(df2[df2["directory_yn"] == "yes"]))
dir_url_recall = dir_yes / rows


# X Calculate Recall for both URL and Directory Sites (in same function) 
dir_off_url = float(len(df2[(df2["official_url_yn"] == "yes") | (df2["directory_yn"] == "yes")]))
dir_off_recall = dir_off_url / rows

# X Create 2 CSV’s: one where a URL OR directory site could be found and another where neither an official nor directory site could be found 

url_found = df2[(df2["official_url_yn"] == "yes") | (df2["directory_yn"] == "yes")]
no_url = df2[(df2["official_url_yn"] == "no") & (df2["directory_yn"] == "no")]

url_found.to_csv("python_exercises_urls_found.csv")
no_url.to_csv("python_exercises_urls_not_found.csv")

# identify dataframes intersection
# non_dupe = df2[df2["_unit_id"].isin(dupe["_unit_id"])]


# X Identify duplicate / non duplicate rows 
dupe = df2[df2.duplicated]
non_dupe = df2.drop_duplicates()


# X Remove extraneous columns from report (_gold, confidence, unit_id, etc.)
# note str.contains is from numpy 
### how to match by multiple strings in str.contains ??? ###

def remove_headers(df):
    head = df.columns
    bad_headers = ["confidence", "gold", "unit", "judgment"]
    columns_remove = []
    
    for i in range(0,len(bad_headers)):
        col = head[head.str.contains(bad_headers[i])].values.tolist()
        columns_remove = columns_remove + col 

    new_df = df.drop(columns_remove, axis=1)
    return new_df 

# X Create 2 CSV files: 1 with headers only, 1 without headers 

new_df.to_csv("file_without_headers.csv", header=False)
headers = new_df.columns.values

res = [headers]
my_df = pd.DataFrame(res)
my_df.to_csv('headers_only.csv', index=False, header=False)


    ###### Notes #####
    # aggregate   
    # iloc subsets by integer 
    # df3.iloc[4,2]
    
    #get directory headers 
    head = df3.columns
    dir_col = head[head.str.contains("directory")].values
    
    # selcect row values by mulitple conditionals 
    df3.loc[(df3["official_url_yn"] == "yes") | (df3["directory_yn"] == "yes"),]
    
    
    # select rows by conditoinal and headers via array 
    df2.loc[(df2["official_url_yn"] == "yes"), dir_col] = ""
    # or 
    #df3.loc[(df3["official_url_yn"] == "yes"), ["directory_yn", "directory_url"]]


###### EXERCISE 2 ######

# Source Files:
# Amex URL agg report (976438)
# Amex Address agg report (978134)

url_agg = pd.read_csv("python_2_a976438.csv")
add_agg = pd.read_csv("python_2_address.csv")

# remove test questions 
url_agg = url_agg[~(url_agg["_golden"])]
add_agg = add_agg[~(add_agg["_golden"])]

# remove gold columnes 
url_agg = remove_headers(url_agg)
add_agg = remove_headers(add_agg)

# Disable logic awareness and apply logic through script (i.e. when url_yn = no, url text box should be empty) 

# url logic aware

dir_cols = url_agg.columns[url_agg.columns.str.contains("directory")].values
url_agg.loc[url_agg["official_url_yn"] == "yes", dir_cols] = ""

# address logic aware 
str_col = add_agg.columns[add_agg.columns.str.contains("street")]
city_col = add_agg.columns[add_agg.columns.str.contains("city") & ~(add_agg.columns.str.contains("sit"))]
state_col = add_agg.columns[add_agg.columns.str.contains("state") & ~(add_agg.columns.str.contains("sit"))]
post_col = add_agg.columns[add_agg.columns.str.contains("postal") & ~(add_agg.columns.str.contains("sit"))]
phone_col = add_agg.columns[add_agg.columns.str.contains("phone")]
loc_col = add_agg.columns[add_agg.columns.str.contains("locations")]

add_agg.loc[~(add_agg["address_found"] == "yes"), np.append([str_col, city_col, state_col], [post_col, phone_col, loc_col])] = ""

# Subset the URL agg report to only match IDs in the Address agg report 

# remove duplicate unique identifiers
url_agg2 = url_agg.drop_duplicates(subset="sit_mzp_id")
add_agg2 = add_agg.drop_duplicates(subset="sit_mzp_id")

url_sub = url_agg[url_agg["sit_mzp_id"].isin(add_agg["sit_mzp_id"])]

# Remove extraneous column headers from both reports 

    # see remove_columns function 

# Merge the 'no URL' and Address agg reports into a single report   

url_no = url_agg2[(url_agg2["official_url_yn"] == "no") & (url_agg2["directory_yn"] == "no")]

# Same as rbind in R 
data_comb = url_no.append(add_agg2)

#### Notes ####
    #  Use merge, by default there is inner join:
    # pd.merge(df1, df2, left_index=True, right_index=True)


###### EXERCISE 3 ######

# SOURCE FILES

# LinkedIn Agg Report (976436)
# Revenue Agg Report (977063)

link = pd.read_csv("python_ex3_linkedin.csv")
rev = pd.read_csv("python_ex3_revenue.csv")

# Remove column headers using pattern matching (ex: all columns with “_gold”) 

link = link.drop(link.columns[link.columns.str.contains("_gold")], axis = 1)
link = remove_headers(link)
rev = remove_headers(rev)

# Recall of years in business 
link_recall = float(len(link[link["company_founded_yn"] == "yes"])) / float(len(link))

# Recall of Revenue (for both owler and Glass door) 
gd_recall = float(len(rev[(rev["gd_revenue_listed"].notnull() & ~(rev["gd_revenue_listed"] == "no"))]))
owl_recall = float(len(rev[rev["owler_revenue_listed"] == "yes"]))
rev_recall = (gd_recall + owl_recall) / float(len(rev))

# Recall of total employees (from all resources) 

col_match = link.columns[link.columns.isin(rev.columns)].tolist()

merged = pd.merge(link, rev, on=col_match)

emp_count= float(len(merged[(merged["company_size_yn"] == "yes") | (merged["gd_employees_listed"] == "yes") | (merged["owler_company_size"] == "yes")]))
emp_recall = emp_count / float(len(merged))

###########################
###### Problem Set 4 ######
###########################

# Input:
# Amex URL Agg report (976438)
# Amex Address Agg report (978134)
# LinkedIn Agg Report (976436)
# Revenue Agg Report (977063)
# Industry Cat Agg Report (978523, 978522)

url = pd.read_csv("python_ex4_url_a976438.csv")
add = pd.read_csv("python4_address_a978134.csv")
link = pd.read_csv("python_4_linkedin_a976436.csv")
rev = pd.read_csv("python_4_revenue_a977063 4.csv")
ind1 = pd.read_csv("python_4_industry1_a978523 2.csv")
ind2 = pd.read_csv("python4_industry2_a978522 2.csv")

ind = ind1.append(ind2)

# X Remove extraneous columns from each report

url = remove_headers(url)
add = remove_headers(add)
link = remove_headers(link)
rev = remove_headers(rev)
ind = remove_headers(ind)


# X Merge all reports into a single csv
url_add_col = url.columns[url.columns.isin(add.columns)].tolist()

merged_url_add = pd.merge(url, add, on=url_add_col, how="left")

merged_match_cols = merged_url_add.columns[merged_url_add.columns.isin(link.columns)].tolist()

merged2 = pd.merge(merged1, link, on=merged_match_cols)
merged3 = pd.merge(merged2, rev, on=merged_match_cols)
merged4 = pd.merge(merged3, ind, on=url_add_col, how="left")

# Convert 50 rows from agg report into a test question report for URL find job 

# identify columns with gold answers (remove worker_inputs)
url_ans_cols = url.columns[url.columns.str.contains("url|yn")].drop(url.columns[url.columns.str.contains("worker_input")]).tolist()

url_for_tq = pd.read_csv("python_ex4_url_a976438.csv")
# subset 25 rows for directory and official where confidence > .75
url_off_conf = url_for_tq.loc[url_for_tq["official_url:confidence"] > .75][0:25]
url_dir_conf = url_for_tq.loc[url_for_tq["directory_url:confidence"] > .75][0:25]
url_conf = url_off_conf.append(url_dir_conf)

for i in range(0, len(url_ans_cols)):
    url_conf[(url_ans_cols[i] + "_gold")] = url_conf[url_ans_cols[i]]
    # url_conf[(url_ans_cols[i] + "_gold_reason")] = ""
    
url_conf["_golden"] = "TRUE"

url_conf.to_csv("python_4_url_tqs.csv", index=False)

# Convert 50 rows from agg report into a test question report for Address find job

add_for_tq = pd.read_csv("python4_address_a978134.csv")

# subset by different answer types
add_conf_no_add = add_for_tq.loc[(add_for_tq["address_found"] == "no") & (add_for_tq["address_found:confidence"] > .75)][0:5]
add_conf_edit = add_for_tq.loc[(add_for_tq["address_street_correction"] == "edit") & (add_for_tq["address_street_correction:confidence"] > .75)][0:30]
add_conf_confirm = add_for_tq.loc[(add_for_tq["address_street_correction"] == "confirm") & (add_for_tq["address_street_correction:confidence"] > .75)][0:10]
add_conf_loc = add_for_tq.loc[(add_for_tq["mult_locations_yn"] == "yes") & (add_for_tq["mult_locations_yn:confidence"] > .75)][0:5]
# combine into single 50 row file 
add_conf = add_conf_no_add.append([add_conf_edit, add_conf_confirm, add_conf_loc])

add_conf = remove_headers(add_conf)

add_cols = add_conf.columns[add_conf.columns.str.contains("street|city|state|postal|phone|locations|address_found") & ~(add_conf.columns.str.contains("sit"))]

for i in range(0, len(add_cols)) :
    add_conf[add_cols[i] + "_gold"] = add_conf[add_cols[i]]
    # add_conf[add_cols[i] + "_gold_reason"] = ""

add_conf["_golden"] = "True"

add_conf.to_csv("python4_address_tqs.csv", index=False)

# url_tqs.rename(columns={'directory_url': 'directory_url_gold', 'official_url': 'official_url_gold', 'official_url_yn': 'official_url_yn_gold', 'directory_url': 'directory_url_gold', 'directory_yn': 'directory_yn_gold'}, inplace=True)

