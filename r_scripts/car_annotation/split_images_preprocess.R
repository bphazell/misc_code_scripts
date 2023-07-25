
options(stringsAsFactors=F)

#set directory where file is stored
dir = "~/Desktop"
#set name of file
file_name = "sample_car_urls_for_demo.csv"
#name of folder in s3 you will be saving the images
s3_folder_path = "http://cf-public-view.s3.amazonaws.com/PNXXX/Misc./Img_annotation_test/"


setwd(dir)
file = read.csv(file_name, header=F)
new_folder= paste0(dir,"/images_folder/")

dir.create(new_folder)

setwd(new_folder)

write.table(file, "image_urls.csv", row.names = F, sep = ",", col.names=F)

system("cat image_urls.csv | xargs wget --no-check-certificate")

list = list.files(pattern = "*jpg")

for (i in 1:length(list)){
  dummy = list[i]
  cmd = paste0("convert ", dummy, " -crop 2x2@  +adjoin ", substring(dummy, 1, nchar(dummy)-4), "_img_",sprintf("%04s",i),"_split.jpg")
  print(cmd)
  system(cmd)
}

split_dir = paste0(new_folder,"split_images/")
dir.create(split_dir)

split_list = list.files(pattern="*split-")

#rename
for (i in 1:length(split_list)){
dummy  = split_list[i]
start = regexpr("split-", dummy)+6
end = regexpr(".jpg", dummy)-1
org = substring(dummy, start, end)
sub = sprintf("%04s",org)
new = gsub(paste0("split-",org),paste0("split-",sub), dummy)  
old_name = paste0(new_folder,split_list[i])
new_name = paste0(split_dir,new)
file.rename(old_name, new_name)
}
setwd(split_dir)

final_image_urls = list.files(pattern="*jpg")
final_image_urls = data.frame(image_urls = final_image_urls)

# image identifier for postprocess csv

final_image_urls$id = ""
  for(i in 1:nrow(final_image_urls)){
    dummy_split = final_image_urls$image_urls[i]
    index = substr(dummy_split,regexpr("img", dummy_split) + 4, regexpr("_split", dummy_split)-1)
    final_image_urls$id[i] = index
    #prepends image url with s3 path
    final_image_urls$image_urls[i] = paste0(s3_folder_path,final_image_urls$image_urls[i])
    print(i)
    }


write.csv(final_image_urls,"final_image_urls.csv", row.names=F, na="")





