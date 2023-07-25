#reads CSV into 'file'
file = read.csv('FILE_NAME.csv')

#assign important columns to 'important_columns'
important_columns = file[,c("column1","column2")]

#dedupe data using important columns
deduped = (file[-which(duplicated(important_columns)),])

#write into a new CSV
write.csv(deduped, file='FILE_NAME_DEDUPED.csv', na="", row.names=F)