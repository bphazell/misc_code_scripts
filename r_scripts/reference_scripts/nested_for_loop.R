setwd("~/Desktop/")

a_all = read.csv("3a_gold_fixed.csv", stringsAsFactors = FALSE)
a = read.csv("3a_gold_fixed.csv", stringsAsFactors = FALSE)

#gold that is not in quiz mode
a = a[a$X_gold_pool != "quiz",]

b = read.csv("3b_gold_corrected.csv", stringsAsFactors = FALSE)
b = b[b$X_gold_pool != "quiz",]

b2 = b[b$X_gold_pool != "quiz",]


fuzzy_dedupe = function(df1, col){
  count = data.frame(table(df1[, col]))
  dubs = count[count[, 2] > 1, ]
  names = as.character(unique(dubs[, 1]))
  if(length(names) > 0){
    for (i in 1:length(names)){
      dummy = df1[df1[, col] %in% names[i], ]
      dummy = dummy[1, ]
      rows = which(df1[, col] == names[i], arr.ind = TRUE)
      df1 = df1[-rows, ]
      df1 = rbind(df1, dummy)
    }
  }
  return(df1)
}

b2 = fuzzy_dedupe(b2,"long_comp_name")

#ad column to identify golds that were changed
b2$Id_updated = ""

#nested for loops are used to run a loop across multiple data frames. Make sure to enter different!! dummy varialbes for each data frame

for(i in 1:nrow(b2)){
  for(j in 1:nrow(a)){
    if (b2$long_comp_name[i] == a$long_comp_name[j]){
      b2$X_id[i] = a$X_id[j]
      b2$Id_updated[i] = "fixed"
    }
  }
}

fixed = b2$X_id[b2$Id_updated == "fixed"]

idb = b2[b2$X_id %in% a$X_id,]
name = b2[b2$long_comp_name %in% a$long_comp_name,]

ida = a[a$X_id %in% b2$X_id,]

a_all$Id_updated = ""


namea = colnames(a_all)
nameb = colnames(idb)
inter = nameb[!(nameb %in% namea)]

c("x_last_judgement_at", "x_unit_id", "x_unit_id2", "x_last_judgement_at2"
)

b2$original_or_loq = NULL
b2$X_unit_id = NULL
b2$X_last_judgement_at2 = NULL
b2$X_unit_id2 = NULL
b2$id_for_test = NULL
b2$X_last_judgement_at = NULL

a_all$x_last_judgement_at = NULL
a_all$x_unit_id = NULL
a_all$x_unit_id2 = NULL
a_all$x_last_judgement_at2 = NULL


a_all = a_all[!(a_all$X_id %in% idb$X_id),]

a_all = rbind(a_all,idb)

#replace exxes
name = names(a_all)
new_names = gsub("X_","_", name)
colnames(a_all) = new_names


#replace "na's"
a_all[is.na(a_all)] = ""

write.csv(a_all, "job3a_gold_updated.csv",row.names=FALSE)




