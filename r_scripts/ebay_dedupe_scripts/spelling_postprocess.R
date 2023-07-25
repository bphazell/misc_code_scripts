#needs additonal work 

options(stringsAsFactors = F)
agg = read.csv("~/Dropbox/ebay_dupe_concepts/Apr_10/Spelling/spelling_a413521 2.csv")

sour = read.csv("~/Dropbox/ebay_dupe_concepts/Apr_10/Source/source_for_dedupe_incomplete_wordorder.csv")

new_df = data.frame(parent = sour$conceptname, mispelled = "")



for (i in 1:nrow(new_df)){
  for(j in 1:nrow(agg)){
    if (new_df$parent[i] == agg$parent[j]){
      new_df$mispelled[i] = paste(agg$part1[j], sep = ",")
    }
  }
  print(i)
}

sour$mispelled = new_df$mispelled
sour$total_kids = NULL
sour$total_kids_what_if=NULL
sour$del1=NULL
sour$del2=NULL

sour2 = sour
sour2$mispelled = gsub("none","",sour2$mispelled)

setwd("~/Desktop/")

write.csv(sour2,"spelling_postprocessed.csv",row.names=F)

spel = read.csv("~/Dropbox/ebay_dupe_concepts/Trial 2/For Ebay//spelling_postprocessed.csv")

sour2$mispelled = gsub("\n", ", ", sour2$mispelled)

write.csv(spel,"spelling_postprocessed.csv",row.names=F)

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/spelling/")
write.csv(spel,"spelling_postprocessed.csv",row.names=F)






