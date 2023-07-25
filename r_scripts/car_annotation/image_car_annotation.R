

setwd("~/Desktop/car_annotation/aggregated_car_annotation_test/")
dir_out = "~/Desktop/car_annotation/aggregated_car_annotation_test/"
url_col = "image_url"


# Call it "agg"
sour = read.csv("~/Desktop/car_annotation/aggregated_car_annotation_test/Apple images with results.csv")
#creates unique id for for loop
unique_ids = unique(sour$img_id)

#subset data to look at only one image (25 total)
for(i in 1:length(unique_ids)){
  id = sour[sour$img_id == i,]
  #subsets to only the column containing the url info
  id = id["image_url"]
  #creates directory for each unique image
  #dir.create(paste0(dir_out, paste0("unique_", i)))
  #changes name of file to match the unique id
  assign(paste0("unique_", i), id)
  #changes setwd to newly created folder
  setwd(paste0(dir_out, paste0("unique_", i, "/")))
  #writes file in the new folder
  write.table(get(paste0("unique_", i)), paste0("unique_", url_col,i, ".csv"), row.names=F, col.name=F, sep = ",")
  print(i)
}

list_files = list.files(path = dir_out, pattern = "*unique")
#download files
for (i in 1:length(list_files)){
  setwd(paste0(dir_out, "unique_",i,"/"))
  cmd = paste0("cat unique_image_url", i, ".csv | xargs wget")
  system(cmd)
  print(i)      
}

#change name of files to two digit identifier
setwd(dir_out)
more_files = list.files(pattern = "unique")

for(j in 1:length(more_files)){
  setwd(paste0(dir_out, "unique_",j,"/"))
  files = list.files(pattern=".jpg")
  new_files=files

  for (i in 1:length(new_files)){
    #file.rename(files[i], gsub(".tiles(.*)", sprintf("_%04d.jpg",i), files[i]))
    p = ".tiles(.*)"
    f = new_files[i] 
    digit_start =  regexpr(p,f)[1] + nchar('-tiles-')
    last_digits = substr(f, regexpr(p,f)[1] + nchar('-tiles-'), nchar(f)-nchar('.jpg'))
    replacement = sprintf('-tiles-%04s.jpg',last_digits)
    new_files[i] = gsub(p,replacement, f)
    file.rename(files[i], new_files[i])
  }
  
  print(j)
}




#compile images back together

setwd(dir_out)
more_files = list.files(pattern = "unique")

for(j in 1:length(more_files)){
  setwd(paste0(dir_out, "unique_",j,"/"))
  system("montage *.jpg -tile 5x5 -geometry +0+0 img_compiled.jpg")
  print(j)
}


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




setwd("~/Desktop/car_annotation/aggregated_car_annotation_test/image_1_for_compile/")
list.files(pattern = ".png")

#files_revised = list.files(pattern = ".png")
#  for (i in 1:files_revised(files)){
#    s = paste0("00000",gsub("confidence_map","",files[i]))
#    new_name = substring(s,nchar(s)-8)
#    new_name = paste0("confidence_map", new_name)
#    file.rename(files_revised[i], new_name)
#    }







