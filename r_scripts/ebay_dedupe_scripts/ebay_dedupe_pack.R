
agg = read.csv("~/Desktop/dedupe_agg.csv")

none_dupes = agg[!(agg$part1 %in% "none"),]

none_dupes = none_dupes[grep("none",none_dupes$part1),]

setwd("~/Desktop/")
write.csv(none_dupes, "none_dudpes1.csv", row.names=F)


test2 = read.csv("~/Desktop/none_dudpes1.csv")

for (i in 1:nrow(test2)){
  strcon = as.numeric(unlist(strsplit(test2$part1.confidence[i], "\n")))
  valcon = unlist(strsplit(test2$part1[i], "\n"))
  
  if(length(valcon) < 3){
    if (strcon[1] > strcon[2]){
      test2$new_agg[i] = valcon[1]
    } else {
      test2$new_agg[i] = valcon[2]
    }
  }else{
    test2$new_agg[i] = test2$part1[i]
  }
  print(i)
}

test2$part1 = test2$new_agg
test2$new_agg = NULL


agg_part= agg[!(agg$conceptname %in% test2$conceptname),]

new_agg1 = rbind(agg_part, test2)

none_dupes = new_agg1[!(new_agg1$part1 %in% "none"),]
none_dupes = none_dupes[grep("none",none_dupes$part1),]

none_dupes$part1[4] = "none"

agg_part = new_agg1[!(new_agg1$conceptname %in% none_dupes$conceptname),]

new_agg1 = rbind(agg_part, none_dupes)

uni = unique(new_agg1$part1)

write.csv(new_agg1, "new_agg1.csv",row.names=F)

new_agg1 = read.csv("~/Desktop/new_agg1.csv")

none_dupes = new_agg1[!(new_agg1$part2 %in% "none"),]

none_dupes = none_dupes[grep("none",none_dupes$part2),]

write.csv(none_dupes, "none_dupes.csv", row.names=F)

none_dupes = read.csv("none_dupes.csv")

agg_part = new_agg1[!(new_agg1$conceptname %in% none_dupes$conceptname),]

new_agg1 = rbind(agg_part,none_dupes)

uni = unique(new_agg1$part1)

new_agg1$dedupe = ""
new_agg1$dedupe = paste(new_agg1$part1,new_agg1$part2, sep = "\n")
new_agg1$dedupe = gsub("\n", ", ", new_agg1$dedupe)
new_agg1$dedupe = gsub("none","",new_agg1$dedupe)
new_agg1$dedupe = gsub("^,","",new_agg1$dedupe)
new_agg1$dedupe = gsub(", $","",new_agg1$dedupe)

sour = read.csv("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/ebay_delimited_source_10001_units.csv")

sour$dedupe=""

new_df = data.frame(parent = sour$conceptname, dedupe = "")

for(i in 1:nrow(new_df)){
  for(j in 1:nrow(new_agg1)){
    if(new_df$parent[i] == new_agg1$conceptname[j]){
      new_df$dedupe[i] = new_agg1$dedupe[j]
    }
  }
  print(i)
}

sour$dedupe = new_df$dedupe
sour$total_kids = NULL
sour$total_kids_what_if=NULL
sour$del1=NULL
sour$del2=NULL

setwd("~/Desktop/")
setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/For Ebay///")
write.csv(sour, "dedupe_postprocessed.csv",row.names=F)







