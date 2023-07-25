sn <– read.csv("FILE_NAME.csv", header = T)

table(sn$COLUMN) # Creates frequency table in alphabetical order
MY_TABLE.freq <– table(sn$COLUMN) # Saves table
MY_TABLE.freq # Print table

MY_TABLE.freq <– MY_TABLE.freq[order(MY_TABLE.freq, decreasing = T)] # Sorts by frequency, saves table
MY_TABLE.freq # Print table

prop.table(MY_TABLE.freq) # Give proportions of total
round(prop.table(MY_TABLE.freq), 2) # Give proportions w/2 decimal places