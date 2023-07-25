
options(stringsAsFactors=F)

input = read.csv('~/Desktop/paige_test.csv')

#new_df = input[0,]
name = names(input)
unique = input[ duplicated(input$Search.Term )==F,]
new_df = unique

for(i in 1:nrow(unique)){
  df_unique = input[ input$Search.Term %in% unique$Search.Term[i],]
   for(j in 2:length(name)){
  array1 = df_unique[,j]
  array1 = paste(array1, collapse="\n")
  unique[i,j] = array1
   }
}












