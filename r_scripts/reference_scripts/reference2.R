setwd("~/Desktop/")

is.even = function(x) x%%2 == 0
is.odd = function(x) x%%2 != 0

source_data = read.csv("ebay_delimited_comma.csv", stringsAsFactor=FALSE)
test_job = source_data[1:10000, ]

test_job$delimited1 = ""
test_job$delimited2 = ""

for(i in 1:nrow(test_job)){
  print(paste("starting =======", i))
  dummy = test_job[i,]
  keys = unlist(strsplit(dummy$delimited, ", "))
  numb = length(keys)
  
  if(is.even(numb)){
    test_job$delimited1[i] = paste(keys[1:(numb/2)], collapse = ", ")
    test_job$delimited2[i] = paste(keys [(numb/2 +1):numb], collapse = ", ")
  }
  if(is.odd(numb)){
    
    test_job$delimited1[i] = paste(keys[1:ceiling(numb/2)], collapse = ", ")
    test_job$delimited2[i] = paste(keys[(ceiling(numb/2)+1):numb], collapse = ", ")
  }
  print(paste("ending =======", i))
}

write.csv(test_job,"source_test_launch.csv")