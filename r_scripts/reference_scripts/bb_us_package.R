

options(stringsAsFactors=F)
job4apost = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1//Output of Job 4 - Find and Correct Phone Number/job4a/a371890_job4a_20413_units_postprocessed.csv")
job4bpost = read.csv("~/Dropbox/bloomberg_url/Units Between Jobs/50000 Unit Production 1/Output of Job 4 - Find and Correct Phone Number/job4b/a370246_job4b_16592_units_postprocessed.csv")


a = names(job4apost)
b = names(job4bpost)

int = b[!(b %in% a)]
int2 = a[!(a %in% b)]

testa = job4apost[!(names(job4apost) %in% int2)]
testb = job4bpost[!(names(job4bpost) %in% int)]



job4_all_post = rbind(testa,testb)

name = names(job4_all_post)
new_names = gsub("X_","_",name)
colnames(job4_all_post) = new_names

job4_all_post[is.na(job4_all_post)] = ""

setwd("~/Dropbox//bloomberg_url/Units Between Jobs/50000 Unit Production 1/BB_final_package_us_intl/")
write.csv(job4_all_post,"pack_all_job4_37005_units.csv",row.names = F)



sour = read.csv("~/Dropbox/bloomberg_url/Source/source_split/CF_200K_EntityList.csv")
sour_norun = read.csv("~/Dropbox/bloomberg_url/Source/source_split/Bloomberg_no_address_101units.csv")

sour_run = sour[!(sour$id_bb_company %in% sour_norun$id_bb_company),]

setwd("~/Dropbox/bloomberg_url/Source/source_split/")

write.csv(sour,"bburl_all_source_200291_units.csv",row.names=F)
write.csv(sour_run,"bburl_with_address_source_200190_units.csv",row.names=F)

setwd("~/Dropbox/bloomberg_url/For Bloomberg/final_packaging/")

us_final = read.csv("BB_final_output_us_only_46194_units_reordered.csv",stringsAsFactors = F)

need_zip = us_final[str_length(us_final$zip_cf) == 4,]
zip_good = us_final[str_length(us_final$zip_cf) == 5,]
no_zip = us_final[str_length(us_final$zip_cf) == 0,]
tri_tip = us_final[str_length(us_final$zip_cf) == 3,]
too_much_zip = us_final[str_length(us_final$zip_cf) > 5,]


need_zip2 <- paste(0,need_zip$zip_cf,sep="")

test = cbind(need_zip,need_zip2)

test$zip_cf = NULL


names(test) 
names(test)[32] = "zip_cf"

zip_ba_dee_doo_dah = rbind(zip_good,test,no_zip, too_much_zip,tri_tip)

extra = us_final[!(us_final$long_comp_name %in% zip_ba_dee_doo_dah$long_comp_name),]

uni = unique(zip_ba_dee_doo_dah$id_bb_company)

setwd("~/Dropbox/bloomberg_url/For Bloomberg/final_packaging/")

write.csv(zip_ba_dee_doo_dah,"BB_final_output_us_only_46194_units_reordered_complete_zip.csv",row.names=F)


us_final = randomRows(us_final,125)

us_final[is.na(us_final)]=""

write.csv(us_final,"BB_audit_us_only_125_units.csv",row.names=F)



