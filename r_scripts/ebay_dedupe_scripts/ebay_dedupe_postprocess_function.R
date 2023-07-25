
# you should run this through the 'remove nas function' beforehand. 

#read in the function first
setwd("~/Dropbox/ebay_dupe_concepts/Feb_28/Dedupe/")


agg = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Dedupe/dedupe_removed_nas_20001.csv")
sour = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Source/complete_source_20001_units.csv")

df = agg

test = dedupe_post_process(agg, sour)

test$conceptname = sour$conceptname
test$top10children = sour$top10children

write.csv(test, "dedupe_final_for_pack.csv", row.names = F)


#uses unique_id to match rows between dataframes, you need to add conceptname to output. 
dedupe_post_process = function(agg, sour){
  #combine part1 and part2 
  agg$dedupe = ""
  part1_vector = agg[,"part1"]
  part2_vector = agg[,"part2"]
  new_vector = paste(part1_vector,part2_vector, sep = "\n")
  new_vector = gsub("\n", ", ", new_vector)
  new_vector = gsub("none","",new_vector)
  new_vector = gsub("^,","",new_vector)
  new_vector = gsub(", $","",new_vector)
  agg$dedupe = new_vector
  
  #create new df with source 'unique_ids'
  sour_vector = sour[,"unique_id"]
  new_df = data.frame(unique_id = sour_vector, dedupe = "")
  
  #match dedupe to source units
  for(i in 1:nrow(new_df)){
    for(j in 1:nrow(agg)){
      if (new_df$unique_id[i] == agg$unique_id[j]){
        new_df$dedupe[i] = agg$dedupe[j]
      }
      
    }
    print(i)
  }
  
return(new_df)
  
}
