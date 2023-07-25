
setwd('~/Desktop/')




sour = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Source/complete_source_20001_units.csv", stringsAsFactors=F)

agg = read.csv("~/Dropbox/ebay_dupe_concepts/Feb_28/Incomplete/agg_incomplete_for_script_389681 4.csv", stringsAsFactors=F)



incomplete_postprocess <- function(sour,df){
  #reads original data frame
  #start part1
  orig_df = agg
  orig_df$new_agg = ""
  orig_df$new_agg2=""
  df$new_agg = ""
  df$new_agg2 = ""
  unique_vector = df[, "unique_id"]
  column_vector = df[, "part1"]
  df = df[!(column_vector %in% "none"),]
  column_vector = df[, "part1"]
  df = df[grep("none", column_vector),]
  confidence = "part1.confidence"
  column_vector = df[, "part1"]
  confidence_vector = df[, confidence]
  df_for_length = df[,"conceptname"]
  for (i in 1:nrow(df)){
    if(length(df_for_length) >0){
      print(paste("part1 ", i))
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
    
  }
  #end for loop part1
  mod_vector = df[,"unique_id"]
  orig_df = orig_df[!(unique_vector %in% mod_vector),]
  orig_df_vector = orig_df[, "part1"]
  orig_df$new_agg = orig_df_vector
  df = rbind(orig_df, df)
  orig_df = df
  
  #start part2
  unique_vector2 = df[, "unique_id"]
  column_vector2 = df[, "part2"]
  df = df[!(column_vector2 %in% "none"),]
  column_vector2 = df[, "part2"]
  df = df[grep("none", column_vector2),]
  confidence2 = "part2.confidence"
  column_vector2 = df[, "part2"]
  confidence_vector2 = df[, confidence2]
  df_for_length2 = df[,"conceptname"]
  for (i in 1:nrow(df)){
    if(length(df_for_length) >0){
      print(paste("part2 ", i))
      confidence_num2 = as.numeric(unlist(strsplit(confidence_vector2[i], "\n")))
      value2 = unlist(strsplit(column_vector2[i], "\n"))
      
      if(length(confidence_num2) >= 2){
        
        minimum2 = (min(confidence_num2))
        remove2 = value2[which(confidence_num2 %in% minimum2)]
        new_value2 = value2[!(value2 %in% remove2)]
        df$new_agg2[i] = paste(new_value2, collapse="\n")
      }
      else{
        df$new_agg2[i] = column_vector2[i]
      }
      
    }
  }
  mod_vector2 = df[,"unique_id"]
  orig_df = orig_df[!(unique_vector2 %in% mod_vector2),]
  orig_df_vector2 = orig_df[, "part2"]
  orig_df$new_agg2 = orig_df_vector2
  df = rbind(orig_df, df)
  
  #overall postprocess
  names(df)
  df = df[names(df) %in% c("conceptname", "del1", "del2", "newdel1","newdel2","top10children","unique_id","part1","part2", "part1.confidence","part2.confidence", "new_agg","new_agg2")]
  #check na logic
  write.csv(df, "check_na_logic_incomplete.csv", row.names=F)
  df = df[names(df) %in% c("conceptname", "del1", "del2", "newdel1","newdel2","top10children","unique_id", "new_agg","new_agg2")]
  colnames(df) = c("conceptname", "del1", "del2", "newdel1","newdel2","top10children","unique_id", "part1","part2")
  
  
  #incomplete prostprocess 
  df$incomplete = ""
  part1_vector = df[,"part1"]
  part2_vector = df[,"part2"]
  new_vector = paste(part1_vector,part2_vector, sep = "\n")
  new_vector = gsub("\n", ", ", new_vector)
  new_vector = gsub("none","",new_vector)
  new_vector = gsub("^,","",new_vector)
  new_vector = gsub(", $","",new_vector)
  df$incomplete = new_vector
  df = df[names(df) %in% c("unique_id", "conceptname", "top10children", "incomplete")]
  output = merge(sour, df)
  output = output[order(output$unique_id),]
  write.csv(output, "incomplete_postprocessed.csv",row.names=F)
  return(output)
}

test =incomplete_postprocess(sour,agg)







