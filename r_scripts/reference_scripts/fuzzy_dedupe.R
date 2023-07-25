setwd("~/Desktop/ebay_dedupe/")

no_exxes = function(df){
  name = names(df)
  new_names = gsub('X_', '_', name)
  colnames(df) = new_names
  return(df)
}

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

sourc = read.csv ("source_test_launch.csv", stringsAsFactors = FALSE)

agg = read.csv("a296686_10_29.csv", stringsAsFactors = FALSE)
agname = names(agg)

aggp1 = agg[ , "part1"]


aggp2 = agg[ , "part2"]

test = paste(agg$)
