
setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/output/")
options(stringsAsFactors=F)

agg = read.csv("eng_cat_output_a441352 .csv")

agg$category_cf = ""
agg$package = ""

agg$

for (i in 1:nrow(agg)){
  if(agg$unit_okay[i] == "all_wrong"){
    agg$category_cf[i] = agg$corrected_category[i]
  }
  if(agg$unit_okay[i] == "all_correct"){
    agg$category_cf[i] = agg$category[i]
    agg$package[i] = "done"
  }
  if(agg$unit_okay[i] == "subcategory_needs_correction"){
    agg$category_cf[i] = agg$category[i]
  }
  if(agg$unit_okay[i] == "category_correct"){
    agg$category_cf[i] = agg$category[i]
  }
  if(agg$unit_okay[i] == "category_incorrect"){
    agg$category_cf[i] = agg$corrected_category[i]
  }
  if(agg$unit_okay[i] == ""){
    agg$category_cf[i] = agg$corrected_category[i]
  }
  else {
    print("logic_break")
  }
  print(i) 
}

broken = agg[grep("^__", agg$channel_name),]

agg_no_broken = agg[!(agg$X_unit_id %in% broken$X_unit_id),]

complete = agg_no_broken[agg_no_broken$package == "done",]

package = rbind(broken,complete)

output = agg[!(agg$X_unit_id %in% package$X_unit_id),]

setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/")

write.csv(package, "en_cat_package_broken_link_all_correct_3419_units.csv", row.names=F,na="")
write.csv(output, "en_cat_output_for_subcat_3317_units.csv", row.names=F,na="")
write.csv

test_output = read.csv("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/en_cat_output_for_subcat_3317_units.csv")

test_output$category_cf[74] == "Arts and Performance" 



setwd("~/Desktop/")
write.csv(agg, "eng_cat_output_logic_test.csv", row.names=F, na="")



