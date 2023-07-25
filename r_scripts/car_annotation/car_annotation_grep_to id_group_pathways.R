
setwd("~/Desktop/")

sour = read.csv("car_annotation_testrun_1250.csv")

#create blank df for to fill with id
new_df = sour[0,]
#create blank df for unique ids
unique_df = data.frame(unique)

vector = sour$image_url

#create a list of paths before 'tiles-'
for(i in 1:length(vector)){
var = unlist(strsplit(vector[i], "tiles-"))
unique = var[1]
unique_df = rbind(unique_df, unique)
print(i)

}

#create unique df of paths
uniques = unique(unique_df)

#assign unique id 
for (i in 1:nrow(uniques)){
test = sour[grep(uniques[i,], sour$image_url),]
test$id = i
new_df = rbind(new_df, test)  
}

write.csv(new_df, "car_annotation_source_with_ids.csv", row.names=F, na="")




