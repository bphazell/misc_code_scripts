

options(stringsAsFactors = F)
agg = read.csv("~/Dropbox/ebay_dupe_concepts/Apr_10/Spelling/spelling_a413521 2.csv")
sour = read.csv("~/Dropbox/ebay_dupe_concepts/Apr_10/Source/source_for_dedupe_incomplete_wordorder.csv")

spelling_postprocess(sour,agg)

spelling_postprocess = function(sour, agg){
  names(agg)
  df = agg[names(agg) %in% c("parent","part1")]
  names(df)
  colnames(df) = c("mispelled", "conceptname")
  comb = merge(sour, df, by = "conceptname", all.x = T)
  
  new_vector = comb$mispelled
  new_vector = gsub("\n", ", ", new_vector)
  new_vector = gsub("none","",new_vector)
  new_vector = gsub("^,","",new_vector)
  new_vector = gsub(", $","",new_vector)
  comb$mispelled = new_vector
  comb = comb[order(comb$unique_id),]

  setwd("~/Dropbox/ebay_dupe_concepts/Apr_10/Spelling/")
  write.csv(comb, "spelling_postprocessed_for_pack.csv", na="", row.names=F)
 
}







