
setwd("~/Desktop/")
df = read.csv("Batch2 public 150000.csv")

half = nrow(df)/2

df1 = df[1:half,]
df2 = df[(half+1):nrow(df),]

write.csv(df1, "Batch2_public_row_1_to_67500.csv",row.names=F, na="" )
write.csv(df1, "Batch2_public_row_67501_to_135000.csv",row.names=F, na="" )