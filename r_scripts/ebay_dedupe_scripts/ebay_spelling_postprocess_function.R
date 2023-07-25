
#unlike the others, you should remove the nas manually as to ensure quality with such a low yield retrun. 

options(stringsAsFactors = F)

agg1 = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Spelling/agg_mispelled_only.csv")

sour2 = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Source/complete_source_20001_units.csv")

setwd("~/Dropbox/ebay_dupe_concepts/Feb_28/Spelling/")

test = spelling_postprocess(agg1, sour2)

write.csv(test, "spelling_final_dedupe_for_pack.csv", row.names=F)

spelling_postprocess = function(agg, sour){
  new_df = data.frame(parent = sour$conceptname, mispelled = "")
  for (i in 1:nrow(new_df)){
    for(j in 1:nrow(agg)){
      if(new_df$parent[i] == agg$parent[j]){
        new_df$mispelled[i] = agg$part1[j]
      }
    }
    print(i)
  }
  return(new_df)
}
