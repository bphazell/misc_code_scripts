
setwd("~/Downloads//")
options(stringsAsFactors = F)


sour = read.csv("carreer_source (2).csv")
new_df = sour[0,]

uni = unique(sour$unique_id)


for (i in 1:length(uni)){

  df = sour[sour$unique_id %in% uni[i],]
    df$employer_correct_yn_gold = df$employer_correct_yn_gold[1]
    df$employer_found_yn_gold = df$employer_found_yn_gold[1]
    df$employer_name_add_gold = df$employer_name_add_gold[1]
    df$employer_name_corrected_gold = df$employer_name_corrected_gold[1]
    df$end_date_gold = df$end_date_gold[1]
    df$end_date_rel_gold = df$end_date_rel_gold[1]
    df$end_date_yn_gold = df$end_date_yn_gold[1]
    df$name_correct_yn_gold = df$name_correct_yn_gold[1]
    df$person_name_corrected_gold = df$person_name_corrected_gold[1]
    df$start_date_gold = df$start_date_gold[1]
    df$start_date_yn_gold = df$start_date_yn_gold[1]
    df$title_add_gold = df$title_add_gold[1]
    df$title_correct_yn_gold = df$title_correct_yn_gold[1]
    df$title_corrected_gold = df$title_corrected_gold[1]
    df$title_found_yn_gold = df$title_found_yn_gold[1]
    new_df = rbind(new_df, df)
  print(i)
}

#rename
new_df$spotcheck_employer_correct_yn_gold= ""
new_df$employer_found_gold_correct= ""
new_df$employer_name_add_gold_correct  =""
new_df$employer_name_corrected_gold_correct  = ""
new_df$end_date_gold_correct  = ""
new_df$end_date_rel_gold_correct  = ""
new_df$end_date_yn_gold_correct  = ""
new_df$name_correct_yn_gold_correct  = ""
new_df$person_name_corrected_gold_correct  = ""
new_df$start_date_gold_correct  = ""
new_df$start_date_yn_gold_correct  = ""
new_df$title_add_gold_correct  = ""
new_df$title_correct_yn_gold_correct  = ""
new_df$title_corrected_gold_correct  = ""
new_df$title_found_yn_gold_correct  = ""

for(i in 1:nrow(new_df)){
  
  #start employer correct
  if(new_df$employer_correct_yn_gold[i] != "" | new_df$employer_correct_yn[i] !=""){
  if(new_df$employer_correct_yn_gold[i] == new_df$employer_correct_yn[i]){
 new_df$spotcheck_employer_correct_yn_gold[i] = 1 
} else {
  new_df$spotcheck_employer_correct_yn_gold[i] = 0
}
}

mean_spotcheck_employer_correct_yn_gold = mean(as.numeric(new_df$spotcheck_employer_correct_yn_gold), na.rm=T)
new_df[170, "spotcheck_employer_correct_yn_gold"] = mean_spotcheck_employer_correct_yn_gold



#end employer correct

#start employer found

  if(new_df$employer_found_yn_gold[i] != "" | new_df$employer_found_yn[i] !=""){
  if(new_df$employer_found_yn_gold[i] == new_df$employer_found_yn[i]){
    new_df$employer_name_add_gold_correct[i] = 1 
} else {
    new_df$employer_name_add_gold_correct[i] = 0
  }
}


#end employer found
#start employer name add

if(new_df$employer_name_add_gold[i] != "" | new_df$employer_name_add[i] !=""){
  if(new_df$employer_name_add_gold[i] == new_df$employer_name_add[i]){
    new_df$employer_name_corrected_gold_correct[i] = 1 
  } else {
    new_df$employer_name_corrected_gold_correct[i] = 0
  }
}
#end employer name add
#start employer name corrected

if(new_df$employer_name_corrected_gold[i] != "" | new_df$employer_name_corrected[i] !=""){
  if(new_df$employer_name_corrected_gold[i] == new_df$employer_name_corrected[i]){
    new_df$employer_name_corrected_gold_correct[i] = 1 
  } else {
    new_df$employer_name_corrected_gold_correct[i] = 0
  }
}
#end employer name corrected
#start end date
if(new_df$end_date_gold[i] != "" | new_df$end_date[i] !=""){
  if(new_df$end_date_gold[i] == new_df$end_date[i]){
    new_df$end_date_gold_correct[i] = 1 
  } else {
    new_df$end_date_gold_correct[i] = 0
  }
}
#end end date
#start relative end date 
if(new_df$end_date_rel_gold[i] != "" | new_df$end_date_rel[i] !=""){
  if(new_df$end_date_rel_gold[i] == new_df$end_date_rel[i]){
    new_df$end_date_rel_gold_correct[i] = 1 
  } else {
    new_df$end_date_rel_gold_correct[i] = 0
  }
}
#end relative end date
#start end date y/n
if(new_df$end_date_yn_gold[i] != "" | new_df$end_date_yn[i] !=""){
  if(new_df$end_date_yn_gold[i] == new_df$end_date_yn[i]){
    new_df$end_date_yn_gold_correct[i] = 1 
  } else {
    new_df$end_date_yn_gold_correct[i] = 0
  }
}
#end end date y/n
#start  name y/n
if(new_df$name_correct_yn_gold[i] != "" | new_df$name_correct_yn[i] !=""){
  if(new_df$name_correct_yn_gold[i] == new_df$name_correct_yn[i]){
    new_df$name_correct_yn_gold_correct[i] = 1 
  } else {
    new_df$name_correct_yn_gold_correct[i] = 0
  }
}
#end name y/n
#start name corrected
if(new_df$person_name_corrected_gold[i] != "" | new_df$person_name_corrected[i] !=""){
  if(new_df$person_name_corrected_gold[i] == new_df$person_name_corrected[i]){
    new_df$person_name_corrected_gold_correct[i] = 1 
  } else {
    new_df$person_name_corrected_gold_correct[i] = 0
  }
}
#end name corrected
#start start date
if(new_df$start_date_gold[i] != "" | new_df$start_date[i] !=""){
  if(new_df$start_date_gold[i] == new_df$start_date[i]){
    new_df$start_date_gold_correct[i] = 1 
  } else {
    new_df$start_date_gold_correct[i] = 0
  }
}
#end start date
#start start date y/n
if(new_df$start_date_yn_gold[i] != "" | new_df$start_date_yn[i] !=""){
  if(new_df$start_date_yn_gold[i] == new_df$start_date_yn[i]){
    new_df$start_date_yn_gold_correct[i] = 1 
  } else {
    new_df$start_date_yn_gold_correct[i] = 0
  }
}
#end start date y/n
#start title add
if(new_df$title_add_gold[i] != "" | new_df$title_add[i] !=""){
  if(new_df$title_add_gold[i] == new_df$title_add[i]){
    new_df$title_add_gold_correct[i] = 1 
  } else {
    new_df$title_add_gold_correct[i] = 0
  }
}
#end title add
#start title correct y/n
if(new_df$title_correct_yn_gold[i] != "" | new_df$title_correct_yn[i] !=""){
  if(new_df$title_correct_yn_gold[i] == new_df$title_correct_yn[i]){
    new_df$title_correct_yn_gold_correct[i] = 1 
  } else {
    new_df$title_correct_yn_gold_correct[i] = 0
  }
}
#end title correct y/n
#start title corrected
if(new_df$title_corrected_gold[i] != "" | new_df$title_corrected[i] !=""){
  if(new_df$title_corrected_gold[i] == new_df$title_corrected[i]){
    new_df$title_corrected_gold_correct[i] = 1 
  } else {
    new_df$title_corrected_gold_correct[i] = 0
  }
}
#end title corrected
#start
if(new_df$title_found_yn_gold[i] != "" | new_df$title_found_yn[i] !=""){
  if(new_df$title_found_yn_gold[i] == new_df$title_found_yn[i]){
    new_df$title_found_yn_gold_correct[i] = 1 
  } else {
    new_df$title_found_yn_gold_correct[i] = 0
  }
}
}


write.csv(new_df, "test_mean.csv", row.names = FALSE, na = "")


  





