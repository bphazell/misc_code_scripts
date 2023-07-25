
setwd("~/Desktop/")

csv = read.csv("wedding.csv", stringsAsFactors=F)

new_df = data.frame(name = "", city ="") 
name = csv$Names

for(i in 1:length(name)){ 
  test = unlist(strsplit(name[i], ","))
  if(length(test) <= 2 ){
  for(j in 1:length(test)){
    new_df[i,j] = test[j]
  }
  }
  if(length(test) > 2){
    new_df[i,1] =  paste(test[1], test[2], sep = ", ")  
    new_df[i, 2] = test[3]
    }
print(i)
}


