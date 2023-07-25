setwd ("~/Desktop")

output = read.csv("international_units_only_reordered copy.csv")



name = names(combined)
new_names = gsub("X_","_", name)
colnames(combined) = new_names

combined[is.na(combined)] = ""

write.csv(combined,"spotcheck_gold_101_units.csv",row.names=FALSE)

randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

sam = randomRows(output,125)

write.csv(sam,"international_audit.csv",row.names=FALSE)


