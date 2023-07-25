setwd("~/Desktop/")

f980 = read.csv("f204980 .csv")
q_deliver = read.csv("Quid_DeliverablesAsOfJuly3 .csv", stringsAsFactors = FALSE)

names_f980 = names(f980)
names_q_deliver = names(q_deliver)

both = names_q_deliver[names_q_deliver %in% names_f980]
extras = names_q_deliver[!(names_q_deliver %in% names_f980)]

correct_columns_deliverables_f980 = f980[ ,both] 

#####

f096 = read.csv("f203096 .csv")

names_f096 = names(f096)

both2 = names_q_deliver[names_q_deliver %in% names_f096]
extras2 = names_q_deliver[!(names_q_deliver %in% names_f096)]

correct_columns_deliverables_f096 = f096[ ,both2] 

######

f315 = read.csv("f202315 .csv")

names_f315 = names(f315)

both3 = names_q_deliver[names_q_deliver %in% names_f315]
extras3 = names_q_deliver[!(names_q_deliver %in% names_f315)]

correct_columns_deliverables_f315 = f315[ ,both3] 

#######

f942 = read.csv("f201942 .csv")

names_f942 = names(f942)

both4 = names_q_deliver[names_q_deliver %in% names_f942]
extras4 = names_q_deliver[!(names_q_deliver %in% names_f942)]

correct_columns_deliverables_f942 = f942[ ,both4] 

########### compile all files

Compile_columns_deliverables = rbind(correct_columns_deliverables_f096,correct_columns_deliverables_f315, correct_columns_deliverables_f942, correct_columns_deliverables_f980)
#############

write.csv(Compile_columns_deliverables, "Quid_Compiled_Deliverables.csv")