
options(stringsAsFactors=F)

#set the directory where the lives
dir = "~/Desktop/"
#set the name of the file
file = "data_xu_sample_output.csv"
#set the column that is used as the unique identifier
unique_identifer = "X_unit_id"


output_summary = function(dir, file, unique_identifier){
  setwd(dir)
  output = read.csv(file)
  rows = nrow(output)
  unique_array = output[unique_identifer]
  dupes = unique_array[duplicated(unique_array) == T,]
  dupe_length = length(dupes)
 
  file_rename = paste0("summary_",gsub(".csv",".txt",file))
  summary = as.character(c(paste0("total rows =",rows), paste0("duplicates = ", dupe_length)))
  
  names = names(output)
  
  for(i in 1:length(names)){
    col_array = output[i]
    blanks = col_array[col_array == "" ]
    len = length(blanks)
    name = names(col_array)
    col_sum = paste0(" ",name, " blanks = ", len, "/", rows)
    summary = c(summary, col_sum)
    print(i)
  }
  
  write.table(summary, file_rename, row.names=F, quote = F)  
}


output_summary(dir, file, unique_identifier)







