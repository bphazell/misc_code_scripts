

setwd("~/Desktop/car_annotation/aggregated_car_annotation_test/")
dir_out = "~/Desktop/car_annotation/aggregated_car_annotation_test/"
url_col = "confidence_map_url"


# Call it "agg"
options(stringsAsFactors=F)
sour = read.csv("~/Desktop/car_annotation/aggregated_car_annotation_test/Apple images with results.csv")
#creates unique id for for loop
unique_ids = unique(sour$img_id)

#subset data to look at only one image (25 total)
for(i in 1:length(unique_ids)){
#start: attemp reorder files 
id = sour[sour$img_id == i,]
id$identifier_for_map = ""
  for(j in 1:nrow(id)){
    id$identifier_for_map[j] = j
    id$identifier_for_map[j] = sprintf('%04s', id$identifier_for_map[j])
  }
id_test = id[order(id$identifier_for_map, decreasing=T),]
id_test = id_test["confidence_map_url"]
assign(paste0("unique_", i), id_test)
setwd(paste0(dir_out, paste0("unique_", i, "/")))
write.table(get(paste0("unique_", i)), paste0("unique_ordered", url_col,i, ".csv"),, row.names=F, col.name=F, sep = ",")
}

list_files = list.files(path = dir_out, pattern = "*unique")

for (i in 1:length(list_files)){
setwd(paste0(dir_out, "unique_",i,"/"))
cmd = paste0("cat unique_orderedconfidence_map_url", i, ".csv | xargs wget")
system(cmd)
print(i)
}

#change name of files to two digit identifier
setwd(dir_out)
more_files = list.files(pattern = "unique")

for(j in 1:length(more_files)){
  setwd(paste0(dir_out, "unique_",j,"/"))
  files = list.files(pattern=".png")
  new_files=files
  
  for (i in 1:length(new_files)){
    #file.rename(files[i], gsub(".tiles(.*)", sprintf("_%04d.jpg",i), files[i]))
    f = new_files[i] 
    test = gsub(".png", "", f)
    test = paste0(test, ".png")
    f = test
    p = "map.(.*)"
    digit_start =  regexpr(p,f)[1] + nchar('map.')
    last_digits = substr(f, regexpr(p,f)[1] + nchar('map.'), nchar(f)-nchar('.png'))
    replacement = sprintf('map-%04s.png',last_digits)
    new_files[i] = gsub(p,replacement, f)
    file.rename(files[i], new_files[i])
  }
  
  
  
  print(j)
}


setwd(dir_out)
more_files = list.files(pattern = "unique")

for(j in 1:length(more_files)){
  setwd(paste0(dir_out, "unique_",j,"/"))
  system("montage *.png -tile 5x5 -geometry +0+0 compiled.png")
  print(j)
  
}



#end: attempt reorder files






