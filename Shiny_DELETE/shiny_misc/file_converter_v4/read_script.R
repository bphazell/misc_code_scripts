

read_data = function(input, type, quote){

#relace '\\"' with 'quote' to allow for different text delimiters
#     df = read.delim(input, header=T, sep = "\t", row.names=NULL, quote=quote, stringsAsFactors=F)

  if(type == "/t"){
    df = read.delim(input, header=T, sep = "\t", row.names=NULL, quote='\\"', stringsAsFactors=F)
  }
  if(type == "|"){
    df = read.delim(input, header=T, sep = "|", row.names=NULL, quote='\\"', stringsAsFactors=F)
  }
  if(type == ","){

   df = read.csv(input, quote='\\"', stringsAsFactors=F)
 }
 if(type == "excel"){

  #read.xls2 seems to work for all files, xls does not  
  #df = read.xls(input, sheet=1, method="csv", perl="perl")
  print(input)
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
  new_names = gsub("^X", "", name)
  colnames(df) = new_names
  return(df)

}

#Split duplicates by col ----------------------------------------------------------------------
split_dupes_by_col_unique = function(df, unique_identifier){
  dupe_array = df[unique_identifier]
  #dupes = df[duplicated(dupe_array) == T,]
  non_dupes = df[duplicated(dupe_array) == F,]
  non_dupes = remove_x(non_dupes)
  return(non_dupes)

}

split_dupes_by_col_duplicates = function(df, unique_identifier){
  dupe_array = df[unique_identifier]
  dupes = df[duplicated(dupe_array) == T,]
  #non_dupes = df[duplicated(dupe_array) == F,]
  #files = list(dupes, non_dupes)
  #print(paste0("this is the unique identifier", unique_identifier))
  dupes = remove_x(dupes)
  return(dupes)

}

#Split duplicates by all rows ----------------------------------------------------------------------
dedupe_by_all_rows_unique = function(df){
  unique = df[duplicated(df) == F,]
  unique = remove_x(unique)
  return(unique)
  
}

dedupe_by_all_rows_duplicates = function(df){
  dupes = df[duplicated(df) == T,]
  dupes = remove_x(dupes)
  return(dupes)
  
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

  # Make Plot Function  ---------------------------------------------------------------------------------------------------------------------------------

make_plot = function(){
  df = grab_file()
  col = grab_col()

   df = df[order(df[,col]),]
   x_data = df[col]
   max_c = max(table(df[col]))
   max_buff = max_c * .10
  
  plot_test <- ggplot(df, aes_string(x_data))
  plot_test = plot_test + geom_histogram(aes_string(fill = (df[col]))) + 
        stat_bin(geom="text", aes(label = paste0((round((..count..)/sum(..count..)*100)),"%"), vjust=-1)) + expand_limits(y=c(0,max_c+ max_buff)) +
        xlab(col)+ scale_fill_brewer(palette="Spectral")+ theme(legend.position="none", axis.text.x=element_text(angle=-45,hjust=0))

    return(plot_test)
}
# URL Validator -------------------------------------------------------------------------------------------


url_validator = function(df, col){
  col_name = col
  col1 = df[col_name]
  col2 = gsub("http://", "", as.matrix(col1))
  col2 = paste0("http://", col2)
  col2= gsub("http://$","",as.matrix(col2))
  df[col_name] = col2

  df$http_status_code = ""
  df$url_exist = ""

  for(i in 1:nrow(df)){
    array = df[col]  
    url = array[i,]
    if(url != ""){
    cmd = paste0("curl -s --head ", url, "/ --max-time 5 | head -n 1")
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
  } else {
    df$url_exist[i] = "blank"
    print(paste0("url blank row: ", i))
  }
    
  }
  url_array = df["url_exist"]
  broke = df[url_array == "no response" | url_array == "false" | url_array == "blank",]
  not_broke = df[url_array == "true",]
  files= list(broke, not_broke)
  return(files)
}


#duplicates summary ---------------------------------------------------------------------------------------

dupe_summary_by_col= function(output, unique_identifier){

  rows = nrow(output)
  unique_array = output[unique_identifier]
  dupes = unique_array[duplicated(unique_array) == T,]
  dupe_length = length(dupes)
  #Dupes
  print(paste0("in dupe summary",dupe_length))
  if(dupe_length < 1){
  summary = paste0("<h5 >Duplicate values in column : <strong><span style='color:green'>", dupe_length, "</span></strong></h5>")
  } else {
    summary = paste0("<h5>Duplicate values in column : <strong><span style='color:red'>", dupe_length, "</span></strong></h5>")
  }
 # summary = c(summary, "<h6 style='color:grey'>Download all unique and duplicate rows of data based on the column selected as the unique identifier</h6>")
  return(summary)
}

dupe_summary_by_row = function(df){

  rows = nrow(df)
  dupes = df[duplicated(df) == T,]
  dupe_length = nrow(dupes)
  #Dupes
  print(paste0("in dupe summary",dupe_length))
  if(dupe_length < 1){
  summary = paste(paste0("<h5>Duplicate rows in file : <strong><span style='color:green'>", dupe_length, "</span></strong></h5>"),paste0("<p>Total Rows = "," <strong> ",rows, "</strong></p>"), sep = "\n")
  } else {
    summary = paste(paste0("<h5>Duplicate rows in file : <strong><span style='color:red'>", dupe_length, "</span></strong></h5>"),paste0("<p>Total Rows = "," <strong> ",rows, "</strong></p>"), sep = "\n")
  }
  return(summary)
}



#Output Summary ---------------------------------------------------------------------------------------
# output_summary = function(output){

#   rows = nrow(output)
#   summary = ""

# #Answer distros
#   summary = c(summary, "<h4 style='color:MediumBlue'>Answer Distributions</h4><h6 style='color:black'>Lists the count of each unique value for every column. Columns with more than 12 unique values will not display</h6>")
#   names = names(output)

#   for(i in 1:length(names)){
#     array = output[i]
#     name = names(array)
#     uni = unique(array)
#     len = nrow(uni)

#     if(len > 1 & len < 12){
#       summary = c(summary, "<strong>",names[i], "</strong><br>")
#       for(j in 1:nrow(uni)){
#          uni_variable = uni[j,]

#         occurance = length(array[array == uni_variable])

#         if(uni_variable == "" | uni_variable == " " | is.na(uni_variable)){
#           uni_variable = "NA"
#       }
#         #   if(j == 1){

#         # sum = paste0("<ul><li>",uni_variable, " = ", occurance, " / ", nrow(array),"</li>")
#         # } else if (j == nrow(uni)){
#         #   sum = paste0("<li>",uni_variable, " = ", occurance, " / ", nrow(array),"</li></ul>")
#         # }
#         # else {
#         #   sum = paste0("<li>",uni_variable, " = ", occurance, " / ", nrow(array),"</li>")
#         # }

#         if(j == length(uni)){
#           row = paste0("<tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", nrow(array), "</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,2)),"%"),"</td></tr></table><br><hr>")
#           } else if(j == 1) {
#             row = paste0("<table><tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array),"</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,2)),"%"),"</td></tr>")
#             } else {
#               row = paste0("<tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array),"</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,2)),"%"),"</td></tr>")
#             }

#         summary = c(summary, sum) 
#       }

#     }
#   }

output_summary = function(df){
  rows = nrow(df)
  headers = names(df)
  output = "<h4 style='color:MediumBlue'>Answer Distributions</h4><h6 style='color:black'>Lists the count of each unique value for every column. Columns with more than 12 unique values will not display</h6>"
  print("in output function")
  for(i in 1:length(headers)){
   array = df[,i]
   name = names(df[i])
   uni = unique(array)
   len = length(uni)
   print(len)

   if(len > 1 & len < 12){

     for(j in 1:length(uni)){
      uni_variable = uni[j]     
      occurance = length(array[array == uni_variable])
      if (is.na(uni_variable) | uni_variable == "" | uni_variable == " "){
        uni_variable = "NA"
      }
      if(j == 1) {
        row = paste0("<table border='1' cellpadding='5'><th colspan='3'>",name,"</th><tr><td align='center'><b>Value</b></td><td align='center'><b>Count</b></td><td align='center'><b>Percentage</b></td></tr><tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array),"</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,2)),"%"),"</td></tr>")
        } else if( j == len){
          row = paste0("<tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array), "</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,3)),"%"),"</td></tr></table><hr>")
          } else {
            row = paste0("<tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array),"</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,3)),"%"),"</td></tr>")
          }
          output = paste0(output, row)


        }
      }
    }
    output = paste0(output, "<hr><h4 style='color:MediumBlue'>Empty Cells</h4><h6 style='color:black'>Lists the number of empty cells for each column. Columns without any empty cells will not display.</h6>")
    for(i in 1:length(headers)){
      col_array = df[i]
      blanks = col_array[col_array == "" ]
      if(length(blanks) > 1){

        len = length(blanks)
        name = names(col_array)
        col_sum = paste0("<p>",name, "  = <strong>", len, "/", rows, "</strong><p>")
        output = c(output, col_sum)
      }


    }

    
    



  return(output)
}
  

  
#   #Blanks
#   summary = c(summary, " <hr><h4 style='color:MediumBlue'>Empty Cells</h4><h6 style='color:black'>Lists the number of empty cells for each column. Columns without any empty cells will not display.</h6>")
#   names = names(output)
  
#   for(i in 1:length(names)){
#     col_array = output[i]
#     blanks = col_array[col_array == "" ]
#     if(length(blanks) > 1){

#       len = length(blanks)
#       name = names(col_array)
#       col_sum = paste0("<p>",name, "  = <strong>", len, "/", rows, "</strong><p>")
#       summary = c(summary, col_sum)
#     }

    
#   }

#   return(summary) 
# }    



# Table Limiter
# worker_table= profile_similar_workers()
# if (length(worker_table$X_worker_id) > 50){
# max_count = min(50, nrow(worker_table))
# worker_table = worker_table[1:max_count,]
# }



