setwd("~/Desktop/")
options(stringsAsFactors=F)

gold = read.csv('en_subcat_gold_for_test.csv')

cat = gold$category_cf
subcat = gold$new_subcategory_gold

new_df = cbind(cat, subcat)

gold$youtube_recat_gold = paste(gold$category_cf,gold$new_subcategory_gold, sep = " &gt; ")

for(i in 1:nrow(gold)){
  if(length(grep( "\n",gold$youtube_recat_gold[i])) > 0){
    cat = gold$category_cf[i]
    gold$youtube_recat_gold[i] = gsub("\n", paste0("\n",cat," &gt; "),gold$youtube_recat_gold[i])   
  }
  print(i)
}

name = names(gold)
new_names= gsub("X_","_", name)
colnames(gold) = new_names

write.csv(gold, "en_recat_gold_for_combine", row.names=F, na="")



en = read.csv("en_recat_gold_for_combine")
intl = read.csv("intl_recat_gold_for_combine")

intl$language_decoded = NULL

extra = intl[!(names(intl) %in% names(en))]
  
recat_total = rbind(en,intl)

recat_total$X_id = 1

name = names(recat_total)
new_names= gsub("X_","_", name)
colnames(recat_total) = new_names

setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/Gold/")

write.csv(recat_total, "recat_gold_intl_en_151_units.csv",row.names=F,na="")
