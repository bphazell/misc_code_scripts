setwd("~/Desktop/ebay_dedupe/")

pilot = read.csv("10000_pilot_ebay.csv",stringsAsFactors=FALSE)
sour = read.csv("source292357.csv",stringsAsFactors=FALSE)



both = sour[sour$primary_keyword %in% pilot$primary_keyword,]

fuzzy_dedupe = function(df1, col){
  count = data.frame(table(df1[, col]))
  dubs = count[count[, 2] > 1, ]
  names = as.character(unique(dubs[, 1]))
  if(length(names) > 0){
    for (i in 1:length(names)){
      dummy = df1[df1[, col] %in% names[i], ]
      dummy = dummy[1, ]
      rows = which(df1[, col] == names[i], arr.ind = TRUE)
      df1 = df1[-rows, ]
      df1 = rbind(df1, dummy)
    }
  }
  return(df1)
}

dupe = fuzzy_dedupe(both, "primary_keyword")

uniq = unique(dupe$primary_keyword)

d1 = dupe$delimited1
d2 = dupe$delimited2



d1sub = gsub('\n',',',d1)
d2sub = gsub('\n',',',d2)

df = data.frame(dupe,d1sub,d2sub)




write.csv(dupe,"ebay_source_3jobs_11_7.csv", row.names=FALSE)