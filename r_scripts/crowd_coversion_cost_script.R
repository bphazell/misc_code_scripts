setwd("~/Desktop/")
options(stringsAsFactors=F)
mode = read.csv("mode-report-convrsion_no_markup.csv")
m_list = read.csv("Account Records Master 2015 - Accounts.csv")


new_mode = mode[0,]

for( i in 1:nrow(m_list)){
   meet = mode[tolower(mode$org_name) %in% tolower(m_list$Client.Name[i]),]
   if (nrow(meet) > 0){ 
   markup = m_list$Crowd.Markup[i]
   meet$markup = markup
   if (markup != "" && is.na(markup) != T) {
   markup = 1 + (markup/100)
   } else {
     markup = 1
   }
   license_fee = m_list$Monthly.Liscence.Fee[i]
   license_fee = gsub("\\$|,", "", license_fee)
   license_fee = as.numeric(license_fee)
   meet$license_fee = license_fee
   
      for( j in 1:nrow(meet)){
      org_cost = meet$cost_without_markup[j]
      adj_cost = org_cost * markup
      meet$cost_w_markup[j] = adj_cost 
      meet$total_spend[j] = adj_cost + license_fee
      }
       new_mode = rbind.fill(new_mode, meet)
         } else {
           print(i)
           print(m_list$Client.Name[i])
          }  
  }

write.csv(new_mode, "client_total_cost_per_month.csv",row.names=F, na="")



