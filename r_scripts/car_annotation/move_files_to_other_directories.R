setwd("~/Desktop/Apple_tile_testrun_images/")

list = list.files("~/Desktop/Apple_tile_testrun_images/",full.names=F )

list_for_run = list[1:1250]
list_for_run[1]

for(i in 1:length(list_for_run)){

file.rename(paste0("~/Desktop/Apple_tile_testrun_images/", list_for_run[i]), paste0("~/Desktop/Apple_tile_1250_images/",list_for_run[i]))
print(i)

}


write(list_for_run)



