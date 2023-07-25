

agg = read.csv("~/Desktop/fin_agg.csv")

sour = read.csv("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/ebay_delimited_source_10001_units.csv")

agg$new_agg = ""

#combine part 1 and 2. Replace 'new line' with comma sep values

agg$new_agg = paste(agg$part1, agg$part2, sep="\n")

agg$new_agg = gsub("none","",agg$new_agg)
agg$new_agg = gsub("\n",", ", agg$new_agg)
agg$new_agg = gsub("^,","", agg$new_agg)
agg$new_agg = gsub(", $","", agg$new_agg)
agg$new_agg = gsub(", ,",",", agg$new_agg)
agg$new_agg = gsub("^ ","", agg$new_agg)

check = agg[!(agg$new_agg %in% ""),]

new_df = data.frame(parent = sour$conceptname, word_order = "")


for(i in 1:nrow(new_df)){
  for(j in 1:nrow(agg)){
    if(new_df$parent[i] == agg$conceptname[j]){
      new_df$word_order[i] = agg$new_agg[j] 
    }
  }
  print(i)
}

sour$word_order = ""
sour$word_order = new_df$word_order

sour$total_kids = NULL
sour$total_kids_what_if=NULL
sour$del1=NULL
sour$del2=NULL

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/word_order/")
setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/For Ebay//")

write.csv(sour, "word_order_postprocessed.csv", row.names=F)



#aggregation to take the value with the highest confidence value "none" or "listed item"

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


#remove "none" with a length greater than 2
for(i in 1:nrow(test2)){
if(length(unlist(strsplit(test2$new_agg[i],"\n")))>2){
  test2$new_agg[i] =gsub("none","",test2$new_agg[i])
}
}



#combine part 1 and 2. Replace 'new line' with comma sep values




