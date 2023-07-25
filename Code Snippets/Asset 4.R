# This script assumes you are combining several csvs, where each csv has unique columns to combine into one.
# The source csv is used as a starting point, and new info is added to it from other csvs.
# The matching is done via a unique id so disparate info in each csv may be recombined.

### load libraries
library(stringr)

### set working directory
setwd('~/Dropbox/TripAdvisor/PN660/Packaging/18October2013')

### job information
filename = "YOUR_FILENAME"

### read in all csvs
source_file = read.csv('SOURCE.csv', stringsAsFactors=F)
JOB1_file = read.csv('JOB1.csv', stringsAsFactors=F)
JOB2_file = read.csv('JOB2.csv', stringsAsFactors=F)
JOB3_file = read.csv('JOB3.csv', stringsAsFactors=F)

### JOB1 units
UNIQUE_id = JOB1_file$property_id

english_yn = JOB1_file$english_yn
verified_official_url = JOB1_file$verified_official_url
numrooms_cf = JOB1_file$numrooms_cf

JOB1_DATA = data.frame(property_id, english_yn, verified_official_url, numrooms_cf)

### JOB2 units
UNIQUE_id = JOB2_file$property_id

language = JOB2_file$language
verified_official_url = JOB2_file$verified_official_url
numrooms_cf = JOB2_file$numrooms_cf
numrooms_url = JOB2_file$numrooms_url

JOB2_DATA = data.frame(property_id, language, verified_official_url, numrooms_cf, numrooms_url)

### JOB3 units
UNIQUE_id = JOB3_file$property_id

language = JOB3_file$language
verified_official_url = JOB3_file$verified_official_url
numrooms_cf = JOB3_file$numrooms_cf
numrooms_url = JOB3_file$numrooms_url

JOB3_DATA = data.frame(property_id, language, verified_official_url, numrooms_cf, numrooms_url)

### make list of data.frames
data_list = list(JOB1_DATA, JOB2_DATA, JOB3_DATA)

# merge for loop
print("looping through merges")

for (i in 1:length(data_list)) {
  output <- merge(source_file, data_list[[i]], by = "UNIQUE_id", all=TRUE)
  source_file = output
}

nunits = nrow(output)

### Write new file
write.csv(output, file=sprintf("%s_%sunits.csv", filename, nunits), na="", row.names=F)
