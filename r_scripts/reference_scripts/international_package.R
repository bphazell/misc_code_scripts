setwd("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/intl_package/")

a1 = read.csv("a350933_bburljob1a_to_packaging_5061_units copy.csv", stringsAsFactors = FALSE)
b1 = read.csv("a350937_bburljob1b__to_packaging_6108_units copy.csv",stringsAsFactors = FALSE)
c1 = read.csv("a350949_bburljob1c_to_packaging_6456_units copy.csv",stringsAsFactors = FALSE)
d1 = read.csv("a350956_bburljob1d_to_packaging_6047 copy.csv",stringsAsFactors = FALSE)

colnames(a1)[c(1,2)] = c("X_unit_id", "X_last_judgement_at")
colnames(b1)[c(1,2)] = c("X_unit_id", "X_last_judgement_at")
colnames(c1)[c(1,2)] = c("X_unit_id", "X_last_judgement_at")
colnames(d1)[c(1,2)] = c("X_unit_id", "X_last_judgement_at")

a2 = read.csv("output_bbcontactjob2a_to_packaging_32001_units copy.csv",stringsAsFactors = FALSE)
b2 = read.csv("output_bbcontactjob2b_a363498_to_packaging_33665_units copy.csv",stringsAsFactors = FALSE)
c2 = read.csv("output_bbcontactjob2c_a362213_to_packaging_39675_units copy.csv",stringsAsFactors = FALSE)
d2 = read.csv("output_bbcontactjob2d_a361490_to_packaging_32837_units copy.csv",stringsAsFactors = FALSE)

colnames(a2)[c(1,2,3,4)] = c("X_unit_id", "X_last_judgement_at", "X_unit_id2", "X_last_judgment_at2")
colnames(b2)[c(1,2,3,4)] = c("X_unit_id", "X_last_judgement_at", "X_unit_id2", "X_last_judgment_at2")
colnames(c2)[c(1,2,3,4)] = c("X_unit_id", "X_last_judgement_at", "X_unit_id2", "X_last_judgment_at2")
colnames(d2)[c(1,2,3,4)] = c("X_unit_id", "X_last_judgement_at", "X_unit_id2", "X_last_judgment_at2")

nomatch = !(colnames(b2) %in% colnames(c2))

alljob1 = rbind(a1,b1,c1,d1)
alljob2 = rbind(a2,b2,c2,d2)

all = rbind.fill(alljob1,alljob2)

#replace exxes
name = names(all)
new_names = gsub("X_","_", name)
colnames(all) = new_names


all = all[!(is.na(all$id_bb_company)),]
intl = all[tolower(all$country) != "united states",]
us = all[tolower(all$country) == "united states",]

count = unique(all$id_bb_company)


write.csv(all,"all_packaging_units.csv",row.names=FALSE,na="")

write.csv(intl,"international_units_only.csv",row.names=FALSE,na="")
write.csv(us,"us_units_only.csv",row.names=FALSE,na="")




