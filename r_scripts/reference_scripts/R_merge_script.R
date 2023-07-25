setwd("~/Desktop")

goldreport = read.csv('job_223684_gold_report reorder.csv')
goldreport2 = read.csv("job_222551_gold_report_reorder_.csv")

complete_gold = rbind(goldreport, goldreport2)
complete_gold[is.na(complete_gold)] = ""
complete_gold[complete_gold == 0] = ""

write.csv(complete_gold, "bio_bus_complete_gold.csv")