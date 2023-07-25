diff.names = function(df1, df2) {
  names1 = names(df1)
  names2 = names(df2)
  missing_1 = names2[!(names2 %in% names1)]
  missing_2 = names1[!(names1 %in% names2)]
  miss1 = as.data.frame(missing_1)
  miss1$missing_from_dataframe = '1'
  miss2 = as.data.frame(missing_2)
  miss2$missing_from_dataframe = '2'
  colnames(miss1)[1] = 'column_name'
  colnames(miss2)[1] = 'column_name'
  missing_names = rbind(miss1, miss2)
  missing_names = missing_names[, c('missing_from_dataframe', 'column_name')]
  print('These column names are in the first dataframe BUT NOT the second dataframe:')
  print(missing_2)
  print('These column names are in the second second dataframe BUT NOT the first dataframe:')
  print(missing_1)
  print("There is now a dataframe where the first row is which dataframe the column is missing from and the second column is the name that is missing.")
  return(missing_names)
}