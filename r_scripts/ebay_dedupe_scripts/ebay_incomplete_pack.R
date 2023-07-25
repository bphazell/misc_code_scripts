
options(stringsAsFactors=F)

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/incomplete/")

agg = read.csv("incomplete_agg_10001_units.csv")

sour = read.csv("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/ebay_delimited_source_10001_units.csv")

agg$incomplete = ""

agg$incomplete = paste(agg$part1,agg$part2,sep='\n')

agg$incomplete = gsub("none","",agg$incomplete)
agg$incomplete = gsub('\n', ", ", agg$incomplete)
agg$incomplete = gsub('^,', "", agg$incomplete
                      
sour$incomplete = agg$incomplete

sour$total_kids= NULL
sour$total_kids_what_if= NULL
sour$del1 = NULL
sour$del2 = NULL

write.csv(sour,"incomplete_postprocessed.csv",row.names=F)

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/For Ebay/")
write.csv(sour,"incomplete_postprocessed.csv",row.names=F)

