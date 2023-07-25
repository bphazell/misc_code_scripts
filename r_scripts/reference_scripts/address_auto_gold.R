setwd("~/Desktop/")

agg = read.csv("logic_aware_agg_for_brian.csv")

agg2 = agg[agg$address_line_1_verified =="false",]
agg2 = agg2[agg2$address_line_1_verified.confidence>=.9,]
agg2 = agg2[agg2$address_line_2_verified.confidence>=.9,]
agg2 = agg2[agg2$city_verified.confidence>=.9,]
agg2 = agg2[agg2$state_verified.confidence>=.9,]
agg2 = agg2[agg2$zip_verified.confidence>=.9,]

agg2



name = colnames(agg1)

agg1$address_line_1_corrected_gold = agg1$address_line_1_corrected
agg1$address_line_2_corrected_gold = agg1$address_line_2_corrected
agg1$city_corrected_gold = agg1$city_corrected
agg1$state_corrected_gold = agg1$state_corrected
agg1$zip_corrected_gold = agg1$zip_corrected
agg1$address_already_correct_gold = agg1$address_already_correct
agg1$address_found_gold = agg1$address_found


agg1$address_line_1_verified_gold = agg1$address_line_1_verified
agg1$address_line_2_verified_gold = agg1$address_line_2_verified
agg1$city_verified_gold = agg1$city_verified
agg1$state_verified_gold = agg1$state_verified
agg1$zip_verified_gold = agg1$zip_verified


agg1$address_line_1_corrected_gold_reason = "This is the correct address line for the provided company"

agg1$address_line_2_corrected_gold_reason= "This is the correct address line for the provided company"
agg1$city_corrected_gold_reason= "This is the correct city for the provided company"
agg1$state_corrected_gold_reason= "This is the correct state for the provided company"
agg1$zip_corrected_gold_reason= "This is the correct zip for the provided company"
agg1$address_already_correct_gold_reason= "The address on the website differs than the address provied."
agg1$address_found_gold_reason="We were able to find the international address for the provided company"

agg1$address_line_1_verified_gold_reason=""
agg1$address_line_2_verified_gold_reason=""
agg1$city_verified_gold_reason=""
agg1$state_verified_gold_reason=""
agg1$zip_verified_gold_reason=""
agg1$intl_headquaters_gold_reason=""

agg1$X_pct_missed = ""
agg1$X_judgments = ""
agg1$X_gold_case = ""
agg1$X_difficulty = ""
agg1$X_hidden = ""
agg1$X_contention = ""
agg1$X_pct_contested = ""
agg1$X_gold_pool = ""

agg1$X_gold_pool = "work"



agg1$url_cf_verified2=NULL    
agg1$url_cf_verified2confidence=NULL 
agg1$url_found=NULL 
agg1$url_found_text=NULL 
agg1$url_found_text_worker_input=NULL 
agg1$url_found_text_worker_inputconfidence=NULL 
agg1$url_found_textconfidence=NULL 
agg1$url_foundconfidence=NULL 
agg1$url_unverified_found=NULL 
agg1$url_unverified_foundconfidence=NULL 
agg1$url_unverified_text=NULL 
agg1$unverified_text_worker_input=NULL 
agg1$url_unverified_text_worker_inputconfidence=NULL 
agg1$url_unverified_textconfidence=NULL 
agg1$url_verified=NULL 
agg1$url_verifiedconfidence=NULL 

agg1$X_id= 1 

agg1$X_unit_id=NULL

#replace exxes

name = names(agg1)
new_names = gsub("X_","_", name)
colnames(agg1) = new_names



#verified gold

agg2$address_line_1_corrected_gold = agg2$address_line_1_corrected
agg2$address_line_2_corrected_gold = agg2$address_line_2_corrected
agg2$city_corrected_gold = agg2$city_corrected
agg2$state_corrected_gold = agg2$state_corrected
agg2$zip_corrected_gold = agg2$zip_corrected
agg2$address_already_correct_gold = agg2$address_already_correct
agg2$address_found_gold = agg2$address_found


agg2$address_line_1_verified_gold = agg2$address_line_1_verified
agg2$address_line_2_verified_gold = agg2$address_line_2_verified
agg2$city_verified_gold = agg2$city_verified
agg2$state_verified_gold = agg2$state_verified
agg2$zip_verified_gold = agg2$zip_verified


agg2$address_line_1_corrected_gold_reason = "This is the correct address line for the provided company"

agg2$address_line_2_corrected_gold_reason= "This is the correct address line for the provided company"
agg2$city_corrected_gold_reason= "This is the correct city for the provided company"
agg2$state_corrected_gold_reason= "This is the correct state for the provided company"
agg2$zip_corrected_gold_reason= "This is the correct zip for the provided company"
agg2$address_already_correct_gold_reason= "The address on the website differs than the address provied."
agg2$address_found_gold_reason="We were able to find the international address for the provided company"

agg2$address_line_1_verified_gold_reason="The address is correct as is."
agg2$address_line_2_verified_gold_reason="The address is correct as is."
agg2$city_verified_gold_reason="The address is correct as is."
agg2$state_verified_gold_reason="The address is correct as is."
agg2$zip_verified_gold_reason="The address is correct as is."
agg2$intl_headquaters_gold_reason="The address is correct as is."

agg2$X_pct_missed = ""
agg2$X_judgments = ""
agg2$X_gold_case = ""
agg2$X_difficulty = ""
agg2$X_hidden = ""
agg2$X_contention = ""
agg2$X_pct_contested = ""
agg2$X_gold_pool = ""

agg2$X_gold_pool = "work"



agg2$url_cf_verified2=NULL    
agg2$url_cf_verified2confidence=NULL 
agg2$url_found=NULL 
agg2$url_found_text=NULL 
agg2$url_found_text_worker_input=NULL 
agg2$url_found_text_worker_inputconfidence=NULL 
agg2$url_found_textconfidence=NULL 
agg2$url_foundconfidence=NULL 
agg2$url_unverified_found=NULL 
agg2$url_unverified_foundconfidence=NULL 
agg2$url_unverified_text=NULL 
agg2$unverified_text_worker_input=NULL 
agg2$url_unverified_text_worker_inputconfidence=NULL 
agg2$url_unverified_textconfidence=NULL 
agg2$url_verified=NULL 
agg2$url_verifiedconfidence=NULL 

agg2$X_id= 1 

agg2$X_unit_id=NULL

#replace exxes

name = names(agg2)
new_names = gsub("X_","_", name)
colnames(agg2) = new_names


randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

agg2=randomRows(agg2,50)

#replace "na's"


agg2[is.na(agg2)] = ""

agg1[is.na(agg1)] = ""

#always use row.names.=FALSE, no need for an extra column

write.csv(agg1,"bbaddressjob3_auto_gold.csv",row.names=FALSE)
write.csv(agg2,"bbaddressjob3_auto_gold.csv_verified",row.names=FALSE)



