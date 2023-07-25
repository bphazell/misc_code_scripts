#Run the function below to remove nas from the agg report
# read in function first

options(stringsAsFactors=F)
setwd("~/Dropbox/ebay_dupe_concepts/Feb_28/Dedupe/")

agg = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Incomplete/agg_incomplete_for_script_389681 4.csv")
agg2 = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Word_Order/agg_word_order_for_script.csv")

# remove unneccissary columns

new = agg2[names(agg2) %in% c("X_unit_id", "unique_id", "part1", "part2", "conceptname", "del1", "del2", "top10children", "part1.confidence", "part1.confidence", "part2.confidence")]

# run function on part1 and
# Replace 'part1' column with 'new_agg'
test = remove_nas(new, "part1", "none", "unique_id")
test$part1 = NULL
colnames(test)[10] = "part1"


test2 = remove_nas(test, "part2", "none", "unique_id")
test2$part2 = NULL
colnames(test2)[10] = "part2"

write.csv(test2, "dedupe_removed_nas_20001.csv", row.names = F)
df = new

unique_id = "unique_id"
column = "part1"
subset = "none"



## Function
remove_nas <- function(df, column, subset, unique_id){
  #reads original data frame
  orig_df = df
  orig_df$new_agg = ""
  df$new_agg = ""
  unique_id = as.character(unique_id)
  unique_vector = orig_df[, unique_id]
  subset = as.character(subset)
  column = as.character(column)
  column_vector = df[, column]
  df = df[!(column_vector %in% subset),]
  column_vector = df[, column]
  df = df[grep(subset, column_vector),]
  confidence = paste(column, ".confidence", sep = "")
  column_vector = df[, column]
  confidence_vector = df[, confidence]
  df_for_length = df[,"conceptname"]
  for (i in 1:nrow(df)){
    if(length(df_for_length) >0){
      print(i)
      confidence_num = as.numeric(unlist(strsplit(confidence_vector[i], "\n")))
      value = unlist(strsplit(column_vector[i], "\n"))
      
      if(length(confidence_num) >= 2){
        
        minimum = (min(confidence_num))
        remove = value[which(confidence_num %in% minimum)]
        new_value = value[!(value %in% remove)]
        df$new_agg[i] = paste(new_value, collapse="\n")
      }
      else{
        df$new_agg[i] = column_vector[i]
      }
      
    }
    mod_vector = df[,unique_id]
    orig_df = orig_df[!(unique_vector %in% mod_vector),]
    orig_df_vector = orig_df[, column]
    orig_df$new_agg = orig_df_vector
    df = rbind(orig_df, df)
  } 
  
  return(df)
}

