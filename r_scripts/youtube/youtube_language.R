
setwd("~/Desktop/")
options(stringsAsFacotrs=F)

gold = read.csv("intl_cat_gold.csv")

gold$language_decoded = ""


setwd("~/Desktop/")
options(stringsAsFacotrs=F)

gold = read.csv("intl_cat_gold.csv")

gold$language_decoded = ""

 tab = table(gold$language)


setwd("~/Desktop/")
options(stringsAsFacotrs=F)

gold = read.csv("intl_cat_gold.csv")

gold$language_decoded = ""

for(i in 1:nrow(gold)){
  if(gold$language[i] == "de"){
    gold$language_decoded[i] = "German"
  }
  if(gold$language[i] == "es"){
    gold$language_decoded[i] = "Spanish"
  }
  if(gold$language[i] == "fr"){
    gold$language_decoded[i] = "French"
  }
  if(gold$language[i] == "it"){
    gold$language_decoded[i] = "Italian"
  }
  if(gold$language[i] == "pt"){
    gold$language_decoded[i] = "Portuguese"
  }
  if(gold$language[i] == "tr"){
    gold$language_decoded[i] = "Turkish"
  }
  if(gold$language[i] == "ja"){
    gold$language_decoded[i] = "Japanese"
  }
  if(gold$language[i] == "pl"){
    gold$language_decoded[i] = "Polish"
  }
  if(gold$language[i] == "ru"){
    gold$language_decoded[i] = "Russian"
  }
  if(gold$language[i] == "sv"){
    gold$language_decoded[i] = "Swedish"
  }
  if(gold$language[i] == "nl"){
    gold$language_decoded[i] = "Dutch"
  }
  if(gold$language[i] == "ko"){
    gold$language_decoded[i] = "Korean"
  }
  if(gold$language[i] == "zh"){
    gold$language_decoded[i] = "Chinese"
  }
  if(gold$language[i] == "th"){
    gold$language_decoded[i] = "Thai"
  }
  if(gold$language[i] == ""){
    gold$language_decoded[i] = "Not Specified"
  }
  print(i)
}


for(i in 1:nrow(gold)){
  if(gold$sub_category[i] == ""){
    
    if(gold$unit_okay_gold[i] == "all_wrong"){
      gold$unit_okay_gold[i] = "category_incorrect"
    }
    if(gold$unit_okay_gold[i] == "subcategory_needs_correction"){
      gold$unit_okay_gold[i] = "category_correct"
    } 
  }
  print(i)
}

name = names(gold)
new_names = gsub("X_", "_", name)
colnames(gold) = new_names

write.csv(gold, "intl_cat_revised_gold_120_units.csv", row.names=F, na="")

