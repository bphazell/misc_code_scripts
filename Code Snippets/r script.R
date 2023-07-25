#set this as the directory that your files are in
setwd('~/Downloads/')

#enter your full report here
full = read.csv('f255035.csv')

#enter your spotcheck report here
spotcheck = read.csv('spotcheck270460.csv')

#the minimum number of contributions a contributor must have to be rated
mincontribs = 50

#clears these our if you're running it multiple times. there's probably a better way to do this.
frequentworkers = NULL
countlist = NULL
totalacc = NULL


count(full, vars = "X_worker_id")
as.data.frame(table(full$X_worker_id))
#Get the number of judgements per worker and store 
countlist = as.data.frame(table(full$X_worker_id))
#Shrink to be only contributors with enough judgements
countlist = countlist[countlist$Freq >= mincontribs,]


#Get new data set of only judgements completed by frequent contributors, and of units
#that are in your spotcheck job
for (i in 1:length(full$X_unit_id)) {
  if (full$X_worker_id[i] %in% countlist$Var1) {
    if(full$X_unit_id[i] %in% spotcheck$X_unit_id) {
      frequentworkers <- rbind(frequentworkers, full[i,])
    }
 }
}

#Pull out the workers IDs of workers in the new data set, and intialize their accuracy ratings
#to zero
totalacc$X_worker_id = subset(frequentworkers$X_worker_id, !duplicated(frequentworkers$X_worker_id))
for (i in 1:length(totalacc$X_worker_id)) {
  totalacc$correct[i] = 0
  totalacc$answered[i] = 0
  totalacc$judgements[i] = 0
}

#loop through each unit
for (i in 1:length(frequentworkers$X_unit_id)) {
  
  #get the unit numbers
  unit = frequentworkers$X_unit_id[i]
  
  #find the worker who created the judgement
  workermatch = match(frequentworkers[i,][11], totalacc$X_worker_id)
  #add 1 to the num of judgements for that worker
  totalacc$judgements[workermatch] = totalacc$judgements[workermatch] + 1
 
  #for each column in the unit
  for (j in 1:ncol(frequentworkers)) {
    
    #find the correspondig row in the spotcheck report
    spotrow = match(unit, spotcheck$X_unit_id)
    #find the the column in the spotcheck report that has the gold answer
    #if it can't be found, it's not a column with answers, so return -1
    spotcol = match(paste(colnames(frequentworkers)[j], ".gold_answer", sep=""), colnames(spotcheck), nomatch = -1)
    
    #if we found the gold answer column
    if (spotcol != -1) {
      #If the worker answer is the same as the gold answer, worker gets a gold star
      if (tolower(as.character(frequentworkers[i,][j])) == tolower(as.character(spotcheck[spotrow,][spotcol]))) {
        totalacc$correct[workermatch] <- totalacc$correct[workermatch] + 1
      }
      #regardless if answer is correct, worker gets datapoint that they may or may have not answered correctly
      totalacc$answered[workermatch] <- totalacc$answered[workermatch] + 1  
    }
  } 
}

#print out the data, if you want to see it in the r console
#
#for (k in 0:length(totalacc$X_worker_id)) {
#  print(totalacc$X_worker_id[k])
#  print(totalacc$judgements[k])
#  print(totalacc$correct[k])
#  print(totalacc$answered[k])
#}

#write the data to a sweet, sweet file
write.csv(totalacc, file ="~/Desktop/workerqa.csv")
print("All done, brah")