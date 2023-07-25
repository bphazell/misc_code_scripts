setwd("~/Desktop/")
options(stringsAsFactors = F)

train = read.csv("5zqvk_training_data.csv")
train$related_type_correct = F
train = train[!is.na(train$related_azure_prediction),]
train[train$related_azure_prediction == train$related,]$related_type_correct=T

con_df = data.frame


for( n in seq(0,0.9, by=0.1)){
  print(n)
  s = train[train$related_azure_probability >= n,]
  s.acc = nrow(s[s$related_type_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

related_yes = train[train$related == "yes",]
related_yes$category_correct = F
related_yes[related_yes$category_azure_prediction == related_yes$category,]$category_correct = T
#test = related_yes[related_yes$category_azure_prediction == related_yes$category,]

for(n in seq(0, 0.9, by=0.1)){
  s = related_yes[related_yes$category_azure_probability >= n,]
  s.acc = nrow(s[s$category_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}

