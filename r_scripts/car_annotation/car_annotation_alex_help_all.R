

setwd("~/Desktop/car_annotation/aggregated_car_annotation_test/")

# Call it "agg"
sour = read.csv("Apple images with results.csv")

#subset data to look at only one image (25 total)
id1 = sour[sour$img_id == 1,]
#subsets data to only look the 'aggregated_image' in order to run wget
id = id1[7]

id_orig = id1[5]

#writes files for wget to run
write.table(id_orig, "original_image_test_1.csv", row.names=F, col.names = F, sep = ",")

output_dir = '/asdasd'
#downloads each file from list
for (i in 1:nrow(sour)){
  #folder = paste0(output_dir, "/", sprint("%05d",sour$img_id[i]))
  folder = sprintf("%s/%05d", output_dir, sour$img_id[i])
  #dir.create(folder, showWarnings = TRUE, recursive = TRUE)
  
  tilename = gsub(".jpg","",gsub(".*_tiles-","tiles-",sour$image_url[i]))
  cmd = sprintf("wget -O %s/%s.png %s ", folder, tilename, sour$confidence_map_url[i])
  print(cmd)
  #system(cmd)
}

# Think about this one \/
#sprintf("wget -O %05d.png %s",1:25, id_orig[,1])

#system("cat agg_test_downoad_id_1.csv | xargs wget -O")


#identifies all .png files
files = list.files(pattern = "*.png")

#renames list of files to avoid extension errors
for (i in 1:length(files)){
  file.rename(files[i], gsub(".png(.*)", paste0(i,".png"), files[i]))  
}

setwd("~/Desktop/car_annotation/aggregated_car_annotation_test/image_1_for_compile/")
list.files(pattern = ".png")






  

