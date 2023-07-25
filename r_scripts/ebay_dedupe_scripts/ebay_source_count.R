
setwd("~/Dropbox/ebay_dupe_concepts/Feb_28/Source/")

data = read.csv("complete_source_20001_units.csv", stringsAsFactors=F)

uni = unique(data$conceptname)

data$total_kids = ""
data$total_kids_what_if = 0

data$unique_id = 0

library(stringr)

for (i in 1:nrow(data)){
count_comma = str_count(data$Top10Children[i], ",")
data$total_kids_what_if[i] = ifelse(count_comma + 1 <= 5, 5, count_comma + 1)
print(i)
}

table(data$total_kids)

data$total_kids = ""

for (i in 1:nrow(data)){

  total = unlist(strsplit(data$Top10Children[13], ","))
  counter = length(total)
  new_total = total + 1
  data$total_kids[i] = new_total 
}

uni = unique(data$Top10Children)

tab = as.data.frame(table(data$Top10Children))
dupes = tab[tab$Freq > 1, ]


data$del1=""
data$del2=""
data$newdel2 = ""


#splitting columns: 
for (i in 1:nrow(data)){
  
  array = unlist(strsplit(data$Top10Children[i], ", "))
  len = length(array)
  if(len==1){
    data$del1[i] = data$Top10Children[i]
    data$del2[i] = ""
  }
  if(len >1) {
  del1 = array[1:ceiling(len/2)]
  del2 = array[ceiling(len/2+1): len]
  data$del1[i]= paste(del1, collapse = ",")
  data$del2[i]= paste(del2, collapse = ",")
  }
  print(i)
}
write.csv(data,"ebay_delimited_source_10001_units.csv", row.names=F, na="")

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/")
data_for spelling = read.csv("ebay_delimited_source_10001_units.csv", stringsAsFactors=F)


#for non-dedupe: add parent to child2
data$newdel2 = ""

for (i in 1:nrow(data)){
  if (data$del2[i] !=""){
  conceptname = data$conceptname[i]
  del2 = data$del2[i]
  data$newdel2[i] = paste(del2, conceptname, sep = ",")
    }
  if (data$del2[i] ==""){
  conceptname = data$conceptname[i]
  del2 = data$del2[i]
  data$newdel2[i] = paste(del2, conceptname, sep = "")
  }
  paste(i)
}

data$newdel1 = data$del1

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/")

write.csv(data,"ebay_delimited_with_parent_source_10001_units.csv", row.names=F, na="")

data_forspelling = read.csv("ebay_delimited_source_10001_units.csv", stringsAsFactors=F)

data_forspelling$spell_list = ""

#splitting the children into a new df associated by parrent for spellchecker.rb

data_forspelling$spell_list = paste(data_forspelling$conceptname, data_forspelling$top10children, sep = ", " )
new_df = data.frame(parent=character(0),child = character(0))

for (i in 1:nrow(data_forspelling)){
split = unlist(strsplit(data_forspelling$spell_list[i], ", "))
new = merge(data_forspelling$conceptname[i],split )
colnames(new) = c("parent","child")
new_df = rbind(new_df,new)
print(i)
}

uni = unique(chck$parent)

setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/")
write.csv(new_df,"parsed_for_spellchecker_39414_units.csv", row.names=F, na="")


# paste all keywords that failed spllchkr with appropriate parent

p_list = read.csv("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/ebay_delimited_with_parent_source_10001_units.csv")
chck = read.csv("~/Desktop/ruby_scripts/parsed_for_spellchecker_39414_units_spellchecked.csv", stringsAsFactors=F)

fail = chck[chck$fail %in% "true",]

new_df2 = data.frame(parent = p_list$conceptname)
new_df2$child = ""

for (i in 1:nrow(new_df2)){
test = fail[fail$parent %in% new_df2$parent[i],]
com = paste(test$child,collapse=",")
new_df2$child[i] = com
print(i)
}
setwd("~/Dropbox/ebay_dupe_concepts/Trial 2/Source/")

write.csv(new_df2,"fail_spellchker_with_all_parents.csv", row.names=F, na ="")


only = new_df2[!(new_df2$child %in% ""),]

write.csv(only,"mispelled_only_to_run.csv", row.names=F, na="")

# paste all keywords that passed spllchkr with appropriate parent

pass = chck[chck$fail %in% "false",]

new_dfp = data.frame(parent = p_list$conceptname)
new_dfp$child = ""

for (i in 1:nrow(new_df2)){
  test = pass[pass$parent %in% new_dfp$parent[i],]
  com = paste(test$child,collapse=",")
  new_dfp$child[i] = com
  print(i)
}
  
#split items into two columns
  
write.csv(new_dfp,"pass_spellchecker_with_all_parents.csv", row.names=F, na = "")

only$del1=""
only$del2=""


for (i in 1:nrow(only)){
  
  array = unlist(strsplit(only$child[i], ","))
  len = length(array)
  if(len==1){
    only$del1[i] = only$child[i]
    only$del2[i] = ""
  }
  if(len >1) {
    del1 = array[1:ceiling(len/2)]
    del2 = array[ceiling(len/2+1): len]
    only$del1[i]= paste(del1, collapse = ",")
    only$del2[i]= paste(del2, collapse = ",")
  }
  print(i)
}

write.csv(only,"mispelled_only_to_run.csv", row.names=F, na="")






