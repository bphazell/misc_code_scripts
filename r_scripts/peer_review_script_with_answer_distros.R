
options(stringsAsFactors=F)

#set the directory where the lives
dir = "~/Downloads/"
#set the name of the file
  file = "Delivery-Youtube_10514_units.csv"
#set the column that is used as the unique identifier
unique_identifer = "user_id"


output_summary = function(dir, file, unique_identifier){
  setwd(dir)
  output = read.csv(file)
  rows = nrow(output)
  unique_array = output[unique_identifer]
  dupes = unique_array[duplicated(unique_array) == T,]
  dupe_length = length(dupes)
 
  file_rename = paste0("summary_",gsub(".csv",".txt",file))
  summary = as.character(c(paste0("total rows =",rows), paste0("duplicates = ", dupe_length)))
  summary = c(summary, "   ", "Blanks", "   ")
  
  names = names(output)
  
  for(i in 1:length(names)){
    col_array = output[i]
    blanks = col_array[col_array == "" ]
    if(length(blanks) > 0){
    len = length(blanks)
    name = names(col_array)
    col_sum = paste0(" ",name, " blanks = ", len, "/", rows)
    summary = c(summary, col_sum)
    print(i)
    }
  }
  summary = c(summary,"  ",  "Answer Distributions", "   ")
  
  for(i in 1:length(names)){
    array = output[i]
    name = names(array)
    uni = unique(array)
    len = nrow(uni)
    if(len > 1 & len < 6){
      for(j in 1:nrow(uni)){
        uni_variable = uni[j,]
        occurance = length(array[array == uni_variable])
        sum = paste0( name , " ", uni_variable, " ", occurance, " / ", nrow(array))
        summary = c(summary, sum) 
      }
      summary = c(summary, " ")
      
    }
  }
  setwd("~/Desktop/")
  
  write.table(summary, file_rename, row.names=F, quote = F)  
}    

    


output_summary(dir, file, unique_identifier)







