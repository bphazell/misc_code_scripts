setwd("~/Desktop/")

g = read.csv("test_forloop.csv",stringsAsFactors=FALSE)

name = names(g)




for(i in 1:nrow(g)){
  if (is.na(g$url_unverified_foundconfidence[i])) {next}
  if (g$url_unverified_foundconfidence[i] >= .8){
    g$grade[i] <- "fair"
  }
  else {
    g$grade[i] <- "Not fair"
  }
}
count(g$grade =="fair")

count(g$grade =="Not fair")

g$url_unverified_foundconfidence = as.numeric(g$url_unverified_foundconfidence)
arrray = is.na(g$url_unverified_foundconfidence)

for(i in 1:nrow(complete)){
  if (i < nrow(complete)){
    complete$biz_url[i] <- complete$company_web_address[i+1]
  }
  else {
    complete$biz_url[i] <- "www.ebay.com"
  }
}



for(i in 1:nrow(g)){
  if(i > nrow (g)){
  g$new_link[i] <- g$url_cf[i+1]
}
  else {
    g$new_link = "www.ebay.com"
  }
}

count(g$new_link == "www.ebay.com")



