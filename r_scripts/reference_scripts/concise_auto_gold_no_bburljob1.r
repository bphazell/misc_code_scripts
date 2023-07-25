setwd("~/Desktop/")

#input agg report here
agg = read.csv("agg_for_no_gold_bburljob1b.csv", stringsAsFactors = FALSE)


verno = agg[agg$url_verified == "no",]
vernono = verno[verno$url_unverified_found =="yes_corrected",]

vernono$biz_url <- ""

vertrue = vernono[(grepl(".com",vernono$company_web_address) == TRUE),] 
verorg = vernono[(grepl(".org",vernono$company_web_address) == TRUE),]

complete = rbind(vertrue,verorg)

for(i in 1:nrow(complete)){
  if (i < nrow(complete)){
    complete$biz_url[i] <- complete$company_web_address[i+1]
  }
  else {
    complete$biz_url[i] <- "www.ebay.com"
  }
}
    


#to remove columns
complete$company_web_address = NULL

#to rename columns
names(complete)[37]="company_web_address"

#add column names with a no value. 
  
complete$url_verified_gold = "no"
complete$url_verified_gold_reason = "The name on the website does not match the provided company name"

complete$url_unverified_found_gold= "yes_corrected"
complete$url_unverified_found_gold_reason = "We were able to find the official website for the provided company"

#whatever column you are trying to copy into needs to be first

complete$url_unverified_text_gold = complete$url_unverified_text
complete$url_unverified_text_gold_reason = "This is the correct url for the provided company name."

#headers to simiulate a gold report

#headers to simiulate a gold report

complete$url_found_gold_reason = ""
complete$url_found_gold = ""
complete$url_found_text_gold = ""
complete$url_found_text_gold_reason= ""
complete$X_pct_missed = ""
complete$X_judgments = ""
complete$X_gold_case = ""
complete$X_difficulty = ""
complete$X_hidden = ""
complete$X_contention = ""
complete$X_pct_contested = ""
complete$X_gold_pool = ""

#rename column

#set gold pool to quiz or work

complete$X_gold_pool = "work"

colnames(complete)[1] = "X_id"

complete$"X_id" = 1


#replace exxes
name = names(complete)
new_names = gsub("X_","_", name)
colnames(complete) = new_names


#replace "na's"
complete[is.na(complete)] = ""

#always use row.names.=FALSE, no need for an extra column

write.csv(complete,"bburljob1_auto_gold.csv",row.names=FALSE)
    
    
