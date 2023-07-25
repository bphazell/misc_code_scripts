
# you should run this through the 'remove nas function' beforehand. 

options(stringsAsFactors=F)
setwd("~/Dropbox/ebay_dupe_concepts/Feb_28/Incomplete/")

agg = read.csv('~/Dropbox/ebay_dupe_concepts/Feb_28/Incomplete/agg_incomplete_for_script_389681 4.csv')
sour = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Source/complete_source_20001_units.csv")


incomplete_post_process = function(agg, sour){
  #combine part1 and part2 
  agg$incomplete = ""
  part1_vector = agg[,"part1"]
  part2_vector = agg[,"part2"]
  new_vector = paste(part1_vector,part2_vector, sep = "\n")
  new_vector = gsub("\n", ", ", new_vector)
  new_vector = gsub("none","",new_vector)
  new_vector = gsub("^,","",new_vector)
  new_vector = gsub(", $","",new_vector)
  agg$incomplete = new_vector
  
  #create new df with source 'unique_ids'
  sour_vector = sour[,"unique_id"]
  new_df = data.frame(unique_id = sour_vector, incomplete = "")
  
  #match dedupe to source units
  for(i in 1:nrow(new_df)){
    for(j in 1:nrow(agg)){
      if (new_df$unique_id[i] == agg$unique_id[j]){
        new_df$incomplete[i] = agg$incomplete[j]
      }
      
    }
    print(i)
  }
  
  return(new_df)
  
}


test = incomplete_post_process(agg, sour)
