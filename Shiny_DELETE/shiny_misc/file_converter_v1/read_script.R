

read_data = function(input, type, quote){

	print(input)
	print(type)
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
 
 	#df = as.data.frame
	print(df)
	return(df)

}

remove_x = function(df){
	name = names(df)
	new_names = gsub("X_", "_", name)
	colnames(df) = new_names
	return(df)

}


split_dupes = function(df, unique_identifier){
  array = df[unique_identifier]
  dupes = df[duplicated(array) == T,]
  #non_dupes = df[duplicated(df[unique_identifier]) == T,]
  #files = list(dupes, non_dupes)
  return(dupes)
}




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
  return(array)
  }

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

output_summary = function(output, unique_identifier){

  rows = nrow(output)
  unique_array = output[unique_identifier]
  dupes = unique_array[duplicated(unique_array) == T,]
  dupe_length = length(dupes)
  summary = paste(paste0("<h4>Duplicates</h4><p>Total Rows =","<strong>",rows, "</strong></p>"), paste0("<p>Duplicates = <strong>", dupe_length, "</strong></p>"), sep = "\n")
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
    print(i)
    }
  }

    summary = c(summary," <hr> ",  "<h4>Answer Distributions</h4>")
  
  for(i in 1:length(names)){
    array = output[i]
    name = names(array)
    uni = unique(array)
    len = nrow(uni)
    if(len > 1 & len < 8){
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



