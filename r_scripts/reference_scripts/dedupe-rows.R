setwd("~/Desktop/twelvefold/")

bob = read.csv('agg_job1_249407_10_11.csv')
sally = read.csv('source_job2_249372_10_11 .csv')

no_exxes = function(df){
  name = names(df)
  new_names = gsub('X_', '_', name)
  colnames(df) = new_names
  return(df)
}

fuzzy_dedupe = function(df1, col){
  for (i in 1:length(names)){
    dummy = df1[df1[, col] %in% names[i], ]
    dummy = dummy[1, ]
    rows = which(df1[, col] == names[i], arr.ind = TRUE)
    df1 = df1[-rows, ]
    df1 = rbind(df1, dummy)
  }
}

pull_uniques = function(df1, df2, col){
  count = data.frame(table(df1[, col]))
  dubs = count[count[, 2] > 1, ]
  names = as.character(unique(dubs[, 1]))
  fuzzy_dedupe(df1, col)
  deduped = df1[!(df1[, col] %in% df2[, col]), ]
  return(deduped)
}

result = pull_uniques(bob, sally, 'weblink')


write.csv(dedupe, "agg_report_10_11_dedupezz_pm.csv", row.names = FALSE, na = '')







