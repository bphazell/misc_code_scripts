
options(stringsAsFactors=F)
setwd("~/Dropbox (CrowdFlower)/ebay_word_order2/source/preprocessed/")



df = read.csv("hag_reordered_final.csv")
index = df[grep("^0:", df$Original),]
index0 = which(df$Original %in% index$Original, arr.ind = T)

new_df = df
new_df$title = ""




for(i in 1:nrow(index)){
  
  if(i + 1  <= length(index0)){
    min = index0[i]
    max = index0[i+1]
    group = df[c((min+1):(max-1)),]  
    # org = paste(group$Original, collapse = ",")
    #new= paste(group$New, collapse = ",")
    title = index$Original[i]
    print(i)
    #new_df$new_group[c((min+1):(max-1))] = new
    #new_df$org_group[c((min+1):(max-1))] = org
    new_df$title[c((min+1):(max-1))] = title
  }  
  
  else{
    min = index0[i]
    max = nrow(new_df)
    group = df[c((min+1):(max)),]  
    #org = paste(group$Original, collapse = ",")
    #new= paste(group$New, collapse = ",")
    title = index$Original[i]
    #new_df$new_group[c((min+1):(max))] = new
    #new_df$org_group[c((min+1):(max))] = org
    new_df$title[c((min+1):(max))] = title
    #print(i)  
  } 
  
}   

final_df = new_df[new_df$New != "",]

#new_df = final_df
# for(i in 1:nrow(new_df)){
#   if(grepl(",", new_df$org_group[i])){
#     new_df$org_group[i] = gsub(paste0(new_df$Original[i],","),"", new_df$org_group[i])
#     new_df$new_group[i] = gsub(paste0(new_df$New[i],","),"", new_df$new_group[i])
#   }
#   else {
#     new_df$org_group[i] = gsub(new_df$Original[i],"", new_df$org_group[i] )
#     new_df$new_group[i] = gsub(new_df$New[i],"", new_df$New[i] )
#   }
#   print(i)

# }



write.csv(final_df, "hag_reordered_preprocessed_18842.csv", na="")


