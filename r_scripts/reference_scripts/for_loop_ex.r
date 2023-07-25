setwd("~/Desktop/")

# Always use stringsAsFactors = False. Just do it...#

agg = read.csv("agg_for_no_gold_bburljob1b.csv", stringsAsFactors = FALSE)

# Brackts pick out "which" rows you want to take out of the csv based off whats its equal to. 
# Make sure you put a ' , ' before the last bracket, this tells r you are looking for the rows not the columns. (x,y)

verno = agg[agg$url_verified == "no",]
vernono = verno[verno$url_unverified_found =="yes_corrected",]


# to add a column just use $ with the name you want to call the column. Set it equal to the somethign to fill the rows. 
vernono$biz_url <- ""




#grepl searches for string, but does not replace: form (string to look for, df string in located in)
#

vertrue = vernono[(grepl(".com",vernono$company_web_address) == TRUE),] 
verorg = vernono[(grepl(".org",vernono$company_web_address) == TRUE),]

complete = rbind(vertrue,verorg)

# i is the dummy variable that signifies the row that is being processed. (so it will constantly change)
#(i in 1:nrow) means to run the funciton til the end of the the rows or document. 
#you can replace it with a number if you only want it to go to a certain point, ie. 24, 50, etc. 
#for if statements the parenthesis tell you what to look for. The brackets separate the actions you want to take
#based of the results of the if statement. 
#make sure you input [i] as this is the dummy variable that runs down the csv. 

for(i in 1:nrow(complete)){
  if (i < nrow(complete)){
    complete$biz_url[i] <- complete$company_web_address[i+1]
  }
  else {
    complete$biz_url[i] <- "www.ebay.com"
  }
}
    
# A more concise way do a for loop with an if statement.#
for(i in 1:nrow(vernono)){
  vernono$biz_url[i] = ifelse(i < nrow(vernono), vernono$company_web_address[i+1], "www.ebay.com")
}

#how to find and replace#
# syntax for gsub = (what to be replaced, what to replace it with, the df with column that needs to be checked)

#vernono$biz_url = gsub("www.", "http://", vernono$biz_url)

#"$" means 'end of line' in regex#

#vernono$biz_url = gsub("$", "/", vernono$biz_url)


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

complete$x_gold_pool = "work"

colnames(complete)[1] = "X_id"




#replace exxes
name = names(complete)
new_names = gsub("X_","_", name)
colnames(complete) = new_names

complete$"_id" = 1


#always use row.names.=FALSE, no need for an extra column

write.csv(complete,"bburljob1_auto_gold.csv",row.names=FALSE)
    
    
