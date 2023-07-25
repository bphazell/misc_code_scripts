library(readr)

#Name of data file and column names
trainingDataFile = '602c9_training_data.csv' #Training Data File Name
crowd_answer = 'sentiment' #name of column w/ crowd answers
azure_prediction = 'sentiment_azure_prediction' #name of AI prediction column
azure_probability = 'sentiment_azure_probability' #name of AI probabilty column

#Script Actions
tD = read.csv(trainingDataFile)
tD = tD[!is.na(tD[[azure_prediction]]),] #removes rows that the AI didn't answer

tD$AI_correct = F
tD[tD[[azure_prediction]] == tD[[crowd_answer]],]$AI_correct=T

print(paste("Route", "Acc", "AI Answered Rows", sep=" | "))
for (n in seq(0,0.9,by=0.05)) {
  s = tD[tD[[azure_probability]] >= n,] #Probabilty of prediction
  s.acc = nrow(s[s$AI_correct == T,])/nrow(s) #only check the 'True'
  print(paste(n, s.acc, nrow(s), sep=" | "))
}
