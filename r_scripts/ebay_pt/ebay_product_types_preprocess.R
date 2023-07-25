
setwd("~/Downloads/")

#update name to match what mews spits out
#example: read.csv("source file name")

#Start Need to Modify
sour = read.delim("Combined_musical_instruments_AU_first_part_-_20.03.2014.tsv",header=T, sep = "\t", row.names=NULL, quote="", stringsAsFactors=F)
#End: Need to Modify

ebay_pt_preprocess = function(sour){
names(sour)[names(sour) == "Item_id"] = "Item_id_orig"
sour$Item_id = sour$Item_id_orig
vector = sour[,"Item_id"]
for (i in 1:length(vector)){
  vector2 = vector[i]
  new_vector = unlist(strsplit(vector2, '"'))[2]
  sour$Item_id[i] = new_vector
  print(i)
}

setwd("~/Desktop/")
write.csv(sour, "ebay_product_types_preprocessed_change_name.csv", row.names=F, na="")
}

ebay_pt_preprocess(sour)









