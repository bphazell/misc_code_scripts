result =  system("curl -I http://cf-tr.s3.amazonaws.com/32464955.pdf", intern=TRUE) 


system("curl -I")

foo = length(grep(pattern = "404", result))
test = ifelse(foo[1] == 1, "yes", "no")

unique_id$broken = 0


setwd ("~/Desktop")

unique_id = read.csv("unique_pdfs_wlinks.csv", stringsAsFactors = FALSE)
colnames(unique_id)[7] = 'working'
unique_id$working = ''
for(i in 1:nrow(unique_id)){
  
  result =  system(paste("curl -I", unique_id$links[1]), intern=TRUE)
  foo = length(grep(pattern = "404", result))
  dummy = ifelse(foo[1] == 1, "no", "yes")
  unique_id$working[i] = dummy
  
}
write.csv(unique_id,"tr_pdf_link_status2.csv")
