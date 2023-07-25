
setwd("~/Dropbox/ebay_dupe_concepts/Apr_10/Source/")
spell = read.csv("for_spelling_script copy_spellchecked.csv")
sour = read.csv("source_for_dedupe_incomplete_wordorder.csv")

# Takes all children that failed the spellchecker and combines them back into one column
#create new dataframe with all of the parent keywords
new_df = data.frame(parent=sour$conceptname, child = "")
#specify only the keywords that failed the spotchecker
misp = spell[spell$fail %in% "true",]

for (i in 1:nrow(new_df)){
  #out of the misp words, we want all of the children associated with the parent in the new_df
  test = misp[misp$parent %in% new_df$parent[i],]
  #collpase this column into a comma separeted string
  com = paste(test$child, collapse=", ")
  #paste this string into the child column of new_df
  new_df$child[i] = com
  print(i)
}


#remove rows where children are blank
misp_child_only = new_df[!(new_df$child %in% ""),]

write.csv(misp_child_only, "misp_child_only_from_spellchecker_for_job.csv", row.names=F)






