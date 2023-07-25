setwd("~/Desktop/")
options(stringsAsFactors = F)
train = read.csv("stanford_training_data.csv")

# Stanford Sentiment 

calc_logic_indep = function(train, question){
  train[paste0(question, "_correct")] = F
  #train[!is.na(train[paste0(question, "_azure_prediction"),]
  train[paste0(question, "_azure_prediction") == train[question], paste0(question, "_correct"] = T                     
  return(train)
  
}
  

df = calc_logic_indep(train, "stanford_yn")
  


  
train$stanford_yn_correct = F
train = train[!is.na(train$stanford_sentiment_azure_prediction),]
train[train$stanford_yn_azure_prediction == train$stanford_yn,]$stanford_yn_correct = T

for( n in seq(0,0.9, by=0.1)){
  #print(n)
  s = train[train$stanford_yn_azure_probability >= n,]
  s.acc = nrow(s[s$stanford_yn_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

stanford_yes = train[train$stanford_yn == "yes",]
stanford_yes$stanford_sentimenty_correct = F
stanford_yes[stanford_yes$stanford_sentiment_azure_prediction== stanford_yes$stanford_sentiment,]$stanford_sentimenty_correct = T
#test = related_yes[related_yes$category_azure_prediction == related_yes$category,]

for(n in seq(0, 0.9, by=0.1)){
  s = stanford_yes[stanford_yes$stanford_sentiment_azure_probability >= n,]
  s.acc = nrow(s[s$stanford_sentimenty_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}
