

options(stringsAsFactors=F)
job1apack = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1a/a350933_bburljob1a_to_packaging_5061_units.csv")
job1bpack = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1b//a350937_bburljob1b__to_packaging_6108_units.csv")
job1cpack = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1c//a350949_bburljob1c_to_packaging_6456_units.csv")
job1dpack = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1d//a350956_bburljob1d_to_packaging_6047.csv")

colnames(job1apack)[c(1,2)] = c("X_unit_id","X_last_judgement_at")
colnames(job1bpack)[c(1,2)] = c("X_unit_id","X_last_judgement_at")
colnames(job1cpack)[c(1,2)] = c("X_unit_id","X_last_judgement_at")
colnames(job1dpack)[c(1,2)] = c("X_unit_id","X_last_judgement_at")

job1all = rbind(job1apack,job1bpack,job1cpack,job1dpack)

name = names(job1all)
new_names = gsub("X_","_",name)
colnames(job1all) = new_names

job1all[is.na(job1all)] = ""

setwd("~/Dropbox//bloomberg_url/Units Between Jobs/50000 Unit Production 1/BB_final_package_us_intl/")
write.csv(job1all,"pack_all_job1_23672_units.csv",row.names = F)

job1apost = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1a/a350933_bburljob1a_postprocessed_43487_units.csv")
job1bpost = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1b/a350937_bburljob1b_postprocessed_48440_units.csv")
job1cpost = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1c//a350949_bburljob1c_postprocessed_42092_units.csv")
job1dpost = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 1 - Find and Verify URL/bburljob1d//a350956_bburljob1d_postprocessed_42499_units.csv")


colnames(job1apost)[c(1,2)] = c("X_unit_id","X_last_judgement_at")
colnames(job1bpost)[c(1,2)] = c("X_unit_id","X_last_judgement_at")
colnames(job1cpost)[c(1,2)] = c("X_unit_id","X_last_judgement_at")
colnames(job1dpost)[c(1,2)] = c("X_unit_id","X_last_judgement_at")

job1all_post = rbind(job1apost,job1bpost,job1cpost,job1dpost)

name = names(job1all_post)
new_names = gsub("X_","_",name)
colnames(job1all_post) = new_names

job1all_post[is.na(job1all_post)] = ""

setwd("~/Dropbox//bloomberg_url/Units Between Jobs/50000 Unit Production 1/BB_final_package_us_intl/")
write.csv(job1all_post,"post_all_job1_176518_units.csv",row.names = F)








