
setwd('~/Desktop')

df1 = read.csv('source209624 .csv')
df2 = read.csv('source209625 .csv')
df3 = read.csv("source209626 6.csv")
df4 = read.csv("source209628 .csv")
df5 = read.csv("source209629 .csv")
df6 = read.csv("source209630 .csv")
df7 = read.csv("source209631 .csv")
df8 = read.csv("source209632 .csv")
df9 = read.csv("source209633 .csv")
df10 = read.csv("source216369 .csv")

doc_ids1 = as.matrix(unique(df1$docid))
doc_ids2 = as.matrix(unique(df2$docid))
doc_ids3 = as.matrix(unique(df3$docid))
doc_ids4 = as.matrix(unique(df4$docid))
doc_ids5 = as.matrix(unique(df5$docid))
doc_ids6 = as.matrix(unique(df6$docid))
doc_ids7 = as.matrix(unique(df7$docid))
doc_ids8 = as.matrix(unique(df8$docid))
doc_ids9 = as.matrix(unique(df9$docid))
doc_ids10 = as.matrix(unique(df10$docid))

total = as.data.frame(rbind(doc_ids1, doc_ids2, doc_ids3, 
                            doc_ids4, doc_ids5, doc_ids6, 
                            doc_ids7, doc_ids8, doc_ids9, 
                            doc_ids10))

unique_doc_ids = as.data.frame(unique(total))
write.csv(unique_doc_ids,file="unique_pdfs.csv")
