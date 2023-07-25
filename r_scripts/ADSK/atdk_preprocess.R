
setwd("~/Downloads/")

#Change name in quotes to name of source
sour = read.delim("CF_IND_20140319.FRADSK", header=TRUE, sep="|")



#Run This funciton
adsk_preprocess = function(adsk_source){
adsk_source$RowDelimiter=NULL
colnames(adsk_source) = c("x_uuid", "name", "x_url", "addressline", "addressline_2", "addressline_3", "city", "x_state_prov", "country", "zipcode", "email_domains")
output=adsk_source
setwd("~/Desktop/")
write.csv(adsk_source, "atdk_output_for_upload.csv", row.names = F, na = "")

}

adsk_preprocess(sour)
