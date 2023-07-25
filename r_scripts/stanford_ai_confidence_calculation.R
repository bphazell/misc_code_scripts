setwd("~/Desktop/")
options(stringsAsFactors = F)
train = read.csv("stanford_training_data.csv")

# Stanford Sentiment 

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

#brock_sentiment

train$brock_yn_correct = F
train = train[!is.na(train$brock_yn_azure_prediction),]
train[train$brock_yn_azure_prediction == train$brock_yn,]$brock_yn_correct = T

for( n in seq(0,0.9, by=0.1)){
  s = train[train$brock_yn_azure_probability >= n,]
  s.acc = nrow(s[s$brock_yn_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

brock_yes = train[train$brock_yn == "yes",]
brock_yes$brock_sentiment_correct = F
brock_yes[brock_yes$brock_sentiment_azure_prediction== brock_yes$brock_sentiment,]$brock_sentiment_correct = T

for(n in seq(0, 0.9, by=0.1)){
  s = brock_yes[brock_yes$brock_sentiment_azure_probability >= n,]
  s.acc = nrow(s[s$brock_sentiment_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

#judge_sentiment

train$judge_yn_correct = F
train = train[!is.na(train$judge_yn_azure_prediction),]
train[train$judge_yn_azure_prediction == train$judge_yn,]$judge_yn_correct = T

for( n in seq(0,0.9, by=0.1)){
  #print(n)
  s = train[train$judge_yn_azure_probability >= n,]
  s.acc = nrow(s[s$judge_yn_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

judge_yes = train[train$judge_yn == "yes",]
judge_yes$judge_sentiment_correct = F
judge_yes[judge_yes$judge_sentiment_azure_prediction== judge_yes$judge_sentiment,]$judge_sentiment_correct = T

for(n in seq(0, 0.9, by=0.1)){
  s = judge_yes[judge_yes$judge_sentiment_azure_probability >= n,]
  s.acc = nrow(s[s$judge_sentiment_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

