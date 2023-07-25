#reads CSV into 'file'
file = read.csv('FILE_NAME.csv')

#removes all columns besides those listed below in ()
keeps <- c("COLUMN1", "COLUMN2", "COLUMN3")

file = file[,keeps]

#write into a new CSV
write.csv(file, file='FILE_NAME_CLEANED.csv', na="", row.names=F)