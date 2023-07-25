
setwd("~/Dropbox/ebay_product_type/Cell Phones & Musical Instruments/source/cell phones/04_07/")

au = read.csv("AU_Phones_2014_04_08_With_Suggestions.csv")
us = read.csv("US_Cell Phones & Accessories_2014_04_08_With_Suggestions.csv")

au$country = "au"

au$group_member = ""

pt = au$PT
sug = au$SUGGESTIONS

new = paste(pt, sug, sep = ";")
new = gsub(";$", "", new)
au$group_member = new
au$unique_id = ""



us$country = "us"

us$group_member = ""

pt2 = us$PT
sug2 = us$SUGGESTIONS

new = paste(pt2, sug2, sep = ";")
new = gsub(";$", "", new)
us$group_member = new
us$unique_id = ""

comb = rbind(us, au)




for(i in 1:nrow(comb)){
  comb$unique_id[i] = i
  print(i)
}

comb2 = comb[sample(nrow(comb)),]

write.csv(comb2, "us_au_Phones_04_07_14k_units_for_job.csv", na="", row.names=F)








