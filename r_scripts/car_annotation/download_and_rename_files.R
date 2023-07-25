

setwd("~/Desktop/car_annotation/aggregated_car_annotation_test/")
sour = read.csv("Apple images with results.csv")

#subset data to look at only one image (25 total)
id = sour[sour$img_id == 1,]
#subsets data to only look the 'aggregated_image' in order to run wget
id = id[7]

#writes files for wget to run
write.table(id, "agg_test_downoad_id_1.csv", row.names=F, col.names = F, sep = ",")

#downloads each file from list
system("cat agg_test_downoad_id_1.csv | xargs wget")

#identifies all .png files
files = list.files(pattern = "*.png")

#renames list of files to avoid extension errors
for (i in 1:length(files)){
  file.rename(files[i], gsub(".png(.*)", paste0(i,".png"), files[i]))  
}






  

