

read_data = function(input, type, quote){


  if(type == "/t"){
    df = read.delim(input, header=T, sep = "\t", row.names=NULL, quote=quote, stringsAsFactors=F)
  }
  if(type == "|"){
    df = read.delim(input, header=T, sep = "|", row.names=NULL, quote=quote, stringsAsFactors=F)
  }
  if(type == ","){

   df = read.csv(input, quote=quote, stringsAsFactors=F)
 }
 if(type == "excel"){

  #read.xls2 seems to work for all files, xls does not  
  #df = read.xls(input, sheet=1, method="csv", perl="perl")
  df = read.xlsx2(input,header=TRUE,sheetIndex=1)

    #df = names(df)
  }
    print("running read_data")

  #df = as.data.frame
 
   return(df)

 }
#remove X -----------------------------------------------------------------------------

remove_x = function(df){
  name = names(df)
  new_names = gsub("X_", "_", name)
  colnames(df) = new_names
  return(df)

}

#Split duplicates ----------------------------------------------------------------------
split_dupes = function(df, unique_identifier){
  dupe_array = df[unique_identifier]
  dupes = df[duplicated(dupe_array) == T,]
  non_dupes = df[duplicated(dupe_array) == F,]
  files = list(dupes, non_dupes)
  print(paste0("this is the unique identifier", unique_identifier))
  return(files)

}


#Dropdown return column selected ------------------------------------------------------------------------

return_columns = function(df){
  colname = names(df)
  array = character(0)

  for(i in 1:length(colname)){
    len = length(unique(df[i]))
    if(len == 1 && is.na(unique(df[i]))) {
      next
    }
    else {
      array = c(array, colname[i])
    }       
  }
  array
  return(array)
}

  #Return Unique Rows ---------------------------------------------------------------------------------

  return_unique = function(df){
    colname = names(df)
    array = character(0)

    for(i in 1:length(colname)){
      len = length(unique(df[i]))
      if(len == 1 && is.na(unique(df[i]))) {
        next
      }
      else  {
        array = c(array, colname[i])
      }       
    }
    return(array)
  }
# URL Validator -------------------------------------------------------------------------------------------


url_validator = function(df, col){
  df$error_code = ""
  df$url_exist = ""
  for(i in 1:nrow(df)){
    array = df[col]  
    url = array[i,]
    cmd = paste0("curl -s --head http://", url, "/ --max-time 5 | head -n 1")
    output = system(cmd, intern=T)
    if(length(output) > 0){
      df$error_code[i] = output
      if(grepl("404", output)){
        df$url_exist[i] = "false"
      } else {
        df$url_exist[i] = "true" 
      }
    } else {
      df$url_exist[i] = "no response"
      print(" no response just went off fool")
    }
    
  }
  url_array = df["url_exist"]
  broke = df[url_array == "no response",]
  broke2 = df[url_array == "false",]
  broke = rbind(broke, broke2)
  not_broke = df[url_array == "true",]
  files= list(broke, not_broke)
  print("running url_validator")
  return(files)
}
#Output Summary ---------------------------------------------------------------------------------------
output_summary = function(output, unique_identifier){

  rows = nrow(output)
  unique_array = output[unique_identifier]
  dupes = unique_array[duplicated(unique_array) == T,]
  dupe_length = length(dupes)
  #Dupes
  summary = paste(paste0("<h4>Duplicates</h4><p>Total Rows =","<strong>",rows, "</strong></p>"), paste0("<p>Duplicates = <strong>", dupe_length, "</strong></p>"), sep = "\n")
  #Blanks
  summary = c(summary, " <hr><h4>Blanks</h4>")
  names = names(output)
  
  for(i in 1:length(names)){
    col_array = output[i]
    blanks = col_array[col_array == "" ]
    if(length(blanks) > 0){
      len = length(blanks)
      name = names(col_array)
      col_sum = paste0("<p>",name, " blanks = <strong>", len, "/", rows, "</strong><p>")
      summary = c(summary, col_sum)

    }
  }
#Answer distros
  summary = c(summary," <hr> ",  "<h4>Answer Distributions</h4>")
  
  for(i in 1:length(names)){
    array = output[i]
    name = names(array)
    uni = unique(array)
    len = nrow(uni)
    if(len > 1 & len < 12){
      summary = c(summary, "<strong>",names[i], "</strong><br>")
      for(j in 1:nrow(uni)){
        uni_variable = uni[j,]
        occurance = length(array[array == uni_variable])
        
        sum = paste0(uni_variable, " ", occurance, " / ", nrow(array),"</p>")
        summary = c(summary, sum) 
      }
      
    }
  }
  


  return(summary) 
}    

  # ggplot_show = function(col){

  #   plot = ggplot(data=df, aes(x=col)) + geom_bar(aes(fill=col))
  #   return(plot)

  # }


# Table Limiter
# worker_table= profile_similar_workers()
# if (length(worker_table$X_worker_id) > 50){
# max_count = min(50, nrow(worker_table))
# worker_table = worker_table[1:max_count,]
# }



