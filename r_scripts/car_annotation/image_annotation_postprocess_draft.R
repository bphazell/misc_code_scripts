
options(stringsAsFactors=F)
dir = "~/Desktop/"
original_url_col = "urls_for_job"
setwd(dir)
source_from_job = "source_from_job.csv"
source_from_agg_job = "output_annotated_images_test.csv"

source_from_job = read.csv(source_from_job)
source_from_agg_job = read.csv(source_from_agg_job)

source_from_job = source_from_job[c("id", original_url_col)]
source_from_agg_job = source_from_agg_job[c("image_url","confidence_map_url")]

new_output = merge(source_from_job,source_from_agg_job, by.x =original_url_col,by.y="image_url", all = T)

unique_ids = new_output$id
unique_ids = unique(unique_ids)

aggregated_images_folder = paste0(dir,"aggregated_images/")
dir.create(aggregated_images_folder)
setwd(aggregated_images_folder)

for(i in 1:length(unique_ids)){
  id_for_rename = new_output[new_output$id == i,]
  #subsets to only the column containing the url info
  id_for_download = id_for_rename["confidence_map_url"]
  #creates directory for each unique image
  dir.create(paste0(dir, "aggregated_images/", paste0("unique_", i)))
  #changes name of file to match the unique id
  assign(paste0("unique_for_download", i), id_for_download)
  assign(paste0("unique_for_rename", i), id_for_rename)
  #changes setwd to newly created folder
  setwd(paste0(dir,"aggregated_images/", paste0("unique_", i, "/")))
  #writes file in the new folder
  write.table(get(paste0("unique_for_download", i)), paste0("unique_for_download_", "confidence_map_url",i, ".csv"), row.names=F, col.name=F, sep = ",")
  #write.csv(get(paste0("unique_for_rename", i)), paste0("unique_for_rename_", i, ".csv"), row.names=F)
  print(i)
}

list_files = list.files(path = aggregated_images_folder, pattern = "*unique")
#download files
for (i in 1:length(list_files)){
  setwd(paste0(aggregated_images_folder, "unique_",i,"/"))
  
  #id_for_rename = paste0("unique_for_rename_", i, ".csv")
  #id_for_rename = read.csv(id_for_rename)
  
  id_for_download = paste0("unique_for_download_confidence_map_url", i, ".csv")
  id_for_download = read.csv(id_for_download)
 #attempt to rewrite file names: work in progress!
  for(j in 1:nrow(id_for_rename)){
    
  match = id_for_rename[paste0(id_for_download, i)$confidence_map_url %in%  id_for_rename$confidence_map_url[j],]
  }
  match
  cmd = paste0("cat unique_for_download_confidence_map_url", i, ".csv | xargs wget")
  system(cmd)
  print(i) 
  folder_list = list.files(pattern="*png")
}



