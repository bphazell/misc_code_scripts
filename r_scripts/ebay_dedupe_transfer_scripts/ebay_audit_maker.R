setwd("~/Dropbox/ebay_dupe_concepts/Feb_28/Dedupe/")

agg = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Dedupe/dedupe_1k_audit_a389531.csv")


#Funciton for Incomplete and Word Order
audit_maker = function(agg, unique_id){
  new_agg = agg
  unique_id = as.character("unique_id")
  unique_vector = new_agg[,unique_id]
  sam = sample(unique_vector, 100)
  new_agg = new_agg[unique_vector %in% sam, ]
  name = names(new_agg) %in% c("X_unit_id", "part1", "part2", "newdel1", "newdel2", "conceptname")
  new_agg = new_agg[name]
 }


test = audit_maker(agg, "unique_id")


#funciton for Dedupe

dedupe_audit = function(agg, unique_id){
  new_df = agg
  unique_id = as.character(unique_id)
  unique_vector = agg[,unique_id]
  sam = sample(unique_vector, 100)
  new_df = new_df[unique_vector %in% sam,]
  name = names(new_df) %in% c("X_unit_id", "part1", "part2", "del1", "del2", "conceptname")
  new_df = new_df[name]
}

test2 = dedupe_audit(agg, "unique_id")



#Without Funciton

audit = as.data.frame(sample(agg$unique_id, 100))
colnames(audit) = "unique_id"

audit2 = agg[agg$unique_id %in% audit$unique_id,]

name = names(audit2) %in% c("X_unit_id", "part1", "part2", "del1", "del2", "conceptname")

final = audit2[name]

name = names(final)
new_names = gsub("X_", "_", name)
colnames(final) = new_names

write.csv(final, "dedupe_1k_audit.csv", row.names = F)
