setwd("~/Downloads/")

#update name to match what mews spits out
#example: read.csv("source file name")

#Start Need to Modify
agg = read.csv("a407555.csv", stringsAsFactors=F)
#End: Need to Modify

ebay_pt_postprocess = function(agg){
group_vector = agg[,"group_member"]
group_vector = gsub("\n","|", group_vector)
agg$new_group_vector = group_vector
new_agg = agg[,c("pt","q1",	"q1.confidence",	"category_name",	"categoryleafid","new_group_vector","image_url",	"item_id_orig",	"title")]
colnames(new_agg)[colnames(new_agg) == "new_group_vector"] = "group_member"
colnames(new_agg)[colnames(new_agg) == "item_id_orig"] = "item_id"
setwd("~/Desktop/")
write.table(new_agg,"ebay_postprocessed_update_name.tsv", sep = "\t", na="", col.names=T, quote=T, row.names=F)
}

ebay_pt_postprocess(agg)







