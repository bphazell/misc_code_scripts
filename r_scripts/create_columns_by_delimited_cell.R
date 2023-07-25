
options(stringsAsFactors=F)
setwd("~/Downloads/")

df = read.csv("test_alex.csv")





for(i in 1:nrow(df)){
  
  array = unlist(strsplit(df$chief_officer_url[i], "//\n"))
  wi_array = unlist(strsplit(df$chief_officer_url_worker_input[i], ","))
  non_dupes = which(duplicated(array) == F)
  new_array = wi_array[(non_dupes)]
  array = new_array 
  df$chief_officer_url_worker_input[i] = paste(array, collapse="\n")
  if(length(array) > 0){
  
  for(j in 1:length(array)){ 
#change the +1 to the number index of the column containing the info you want to split
     df[i,j+3] = array[j]
      
      print(paste0(i, " ", j, "=>", array[j]))
}
}
print(i)

}






