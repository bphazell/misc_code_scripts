
options(stringsAsFacotrs=F)
setwd("~/Dropbox (CrowdFlower)/ebay_word_order2/source/preprocessed/")
df = read.csv('csa_reordered_final.csv')


index = df[grep("^0:", df$Original),]
index0 = which(df$Original %in% index$Original, arr.ind = T)

new_df = df
new_df$new_group = ""
new_df$org_group = ""
new_df$key = ""



  
for(i in 1:nrow(index)){
 #i = 4503
 
  #ind = index0[i]
  if(i + 1  <= length(index0)){
  min = index0[i]
  max = index0[i+1]
  group = df[c((min+1):(max-1)),]  
  org = paste(group$Original, collapse = ",")
  new= paste(group$New, collapse = ",")
  key = index$Original[i]
  print(i)  
  new_df$new_group[c((min+1):(max-1))] = new
  new_df$org_group[c((min+1):(max-1))] = org
  new_df$key[c((min+1):(max-1))] = key
  }  
  
  else{
    min = index0[i]
    max = nrow(new_df)
    group = df[c((min+1):(max)),]  
    org = paste(group$Original, collapse = ",")
    new= paste(group$New, collapse = ",")
    key = index$Original[i+1]
    new_df$new_group[c((min+1):(max))] = new
    new_df$org_group[c((min+1):(max))] = org
    new_df$key[c((min+1):(max))] = key
    #print(i)  
  } 
    
}   





