

data = read.csv("~/Dropbox/bloomberg_url/Source/Bloomberg_1000units_pilot.csv",stringsAsFactors=F)
data$broken_link = ""
data$redirect = ""
data$redirect_contain_original_url = ""

system("curl -I i - ")

for (i in 1:10){
  
  result =  system(paste("curl -I", data$company_web_address[i]), intern=TRUE, wait = FALSE)
  if (data$company_web_address[i] != ""){
  foo = length(grep(pattern = "404", result))
  foo2 = length(grep(pattern = "301", result))
  dummy = ifelse(foo[1] == 1, "yes", "no")
  if(foo2[1] == 1){
    dummy2 = "yes"
    final_location = grepl(pattern = paste("Location:.*", data$company_web_address[i], ".*", sep = ""), result)
    location = result[ final_location ]
    final_result = gsub(pattern = "Location: ", replacement = "", location)
    final_result = gsub(pattern = "\r", replacement = "", final_result)
    trues = final_location[ final_location == TRUE ]
    dummy3 = ifelse(length(trues) > 0, final_result, "")
    data$redirect_contain_original_url[i] = dummy3
  }
  else{
    dummy2 = "no"
    data$redirect_contain_original_url[i] = ""
  }
  data$broken_link[i] = dummy
  data$redirect[i] = dummy2
  print(i)
  }
}