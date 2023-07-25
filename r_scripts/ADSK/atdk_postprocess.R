
setwd("~/Downloads/")
options(stringsAsFactors=F)

#update name to match what mews spits out
#example: read.csv("source file name")

#Start Need to Modify
output = read.csv("Dataset_61_2014-03-13 17-15-17 +0000 (2).csv")
#End: Need to Modify
  


adsk_post_process = function(output){
colnames(output) = c("x_ou_num", "name", "x_url", "st_address", "x_addr_line_2", "x_addr_line_3", "city",
                     "x_state_prov", "country","zipcode", "email_domains", "market", "confidence_index", "found_candidate",
                     "found_directory_candidate", "primarywebsite", "sic8", "industry_subsegment", "is_individual", "address_class")
setwd("~/Desktop/")
write.table(output,"update_name_to_match_source.TOADSK", sep = "|", na="", col.names=T, quote=F, row.names=F)

#create output summary
#count number of units
num_units = nrow(output)

#count enriched categories
industry_subsegment = output["industry_subsegment"]
not_empty = length(industry_subsegment[industry_subsegment != ""])

#num of people vs company
is_individual = output$is_individual
num_people=length(is_individual[is_individual == TRUE])
num_compnay = length(is_individual[is_individual == FALSE])

#create and write summary report

summary = as.character(c("total units =",num_units, "\n industry categories enriched = ", not_empty, "\n number of businesses that are individuals = ", num_people, "\n number of business that are compnanies = ", num_compnay))
write.table(summary, "ADSK_output_summary.txt", row.names=F, quote = F)
}

#call function
adsk_post_process(output)












