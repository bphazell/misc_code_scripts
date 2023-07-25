
setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/For Ebay/")

dedupe = read.csv("dedupe_postprocessed.csv")

incomplete = read.csv("incomplete_postprocessed.csv")

word_order = read.csv("word_order_postprocessed.csv")

spelling = read.csv("spelling_postprocessed.csv")


final = dedupe

final = cbind(dedupe, incomplete$incomplete, word_order$word_order, spelling$mispelled)

names(final)[7] = "misspelled"

final$unique_id = NULL

final = read.csv("~/Desktop/ebay_final_agg.csv")

final$dedupe = gsub("^ ","", final$dedupe)
final$incomplete = gsub("^ ","", final$incomplete)

setwd("~/Desktop/")
write.csv(final, "ebay_final_agg.csv", row.names=F)
