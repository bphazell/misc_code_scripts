
setwd("~/Dropbox/ebay_dupe_concepts/Apr_10/")

sour = read.csv("Source/source_for_dedupe_incomplete_wordorder.csv")

dedupe = read.csv("Dedupe/dedupe_postprocessed.csv")

spelling = read.csv("Spelling/spelling_false_positives_removed.csv")

incomplete = read.csv("Incomplete/incomplete_postprocessed.csv")

wordorder = read.csv("Word_Order/wordorder_postprocessed.csv")

final_pack = function(sour, dedupe, spelling, incomplete, wordorder){
  dedupe = dedupe[,"dedupe"]
  spelling = spelling[,"mispelled"]
  incomplete = incomplete[,"incomplete"]
  wordorder = wordorder[,"word_order"]
  dedupe = gsub("^ ", "", dedupe)
  spelling = gsub("^ ", "", spelling)
  incomplete = gsub("^ ", "", incomplete)
  wordorder = gsub("^ ", "", wordorder)
  combined = cbind(sour,dedupe,wordorder,incomplete,spelling) 
}

test = final_pack(sour, dedupe, spelling, incomplete, wordorder)

test = test[names(test) %in% c("siteid", "conceptname", "top10children", "dedupe","wordorder", "incomplete", "spelling")]

write.csv(test, "ebaydedupe_apr_10_final_pack_10001_units.csv", row.names=F, na="")
