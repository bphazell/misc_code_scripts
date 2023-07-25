
setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/Package/")
options(stringsAsFactors=F)
en = read.csv("en_subcat_for_pack_3447_units.csv")

intl = read.csv("intl_subcat_for_pack_2987_units.csv")


for(i in 1:nrow(en)){
    if(en$broken_link[i] == "true"){
      en$new_subcategory[i] = ""   
    }
    print(i)
}

for(i in 1:nrow(intl)){
  if(intl$broken_link[i] == "true"){
    intl$new_subcategory[i] = ""   
  }
  print(i)
}

en$subcategory_cf = en$new_subcategory
intl$subcategory_cf = intl$new_subcategory

intl = intl[-c(1:6)]

setwd("~/Desktop/")
write.csv(en, "subcat_en_for_final_pack_3447_units.csv",row.names=F, na="")
write.csv(intl, "subcat_intl_for_final_pack_2987_units.csv",row.names=F, na="")

setwd("~/Desktop/")
en = read.csv("subcat_en_for_final_pack_3447_units.csv")
intl = read.csv("subcat_intl_for_final_pack_2987_units.csv")
intl$category = NULL

combined = rbind.fill(en,intl)

nen = names(en)
nintl = names(intl)

mismatch = nintl[!(nintl %in% nen)]

combined = rbind(en,intl)

write.csv(combined,"reset_subcat_en_intl_for_final_pack_6434_units.csv", row.names=F, na="")


