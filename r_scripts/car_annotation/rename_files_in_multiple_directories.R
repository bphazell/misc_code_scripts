
setwd("~/Desktop/image_magick/output/")
directoryfiles=list.files("~/Desktop/image_magick/output/")

for (j in 1:length(directoryfiles)){
  directory_sub = list.files(paste("~/Desktop/image_magick/output/",directoryfiles[j], sep=""), pattern = "*.jpg")
  for(i in 1:length(directory_sub)){

      file.rename(paste0(directoryfiles[j], "/",directory_sub[i]), paste0(directoryfiles[j], '_', directory_sub[i])) 
    #print(paste("sub_file_", i ))
    
  }
  print(paste("big_file_", j ))
}





