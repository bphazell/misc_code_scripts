
options(stringsAsFactors = F)
setwd("~/Desktop/")

map = read.csv("hotel_mappings.csv")
#base csv to attach others
bkg = read.csv("bkg_rooms.csv")

agoda = read.csv("agoda_rooms.csv")

new_bkg = bkg[0]
# iterates through mapping file
for(i in 1:nrow(map)){
 # identify bkg and agoda mapping pair
 bkg_id = map$bkg_hotel_id[i]
 agoda_id = map$agoda_hotel_id[i] 
 # identify rows that map to agoda and bkg id
 bk_rows = bkg[bkg$bkg_hotel_id %in% bkg_id,]
 agoda_rows = agoda[agoda$hotel_id %in% agoda_id,]
 names(agoda_rows)[1] = "agoda_hotel_id"
 # create placeholder for collpased csv
 agoda_cond = agoda_rows[1,]
 # collapse all agoda rows
 for(i in 2:length(names(agoda_rows))){
    agoda_cond[i] = paste(agoda_rows[[i]], collapse="|")
 }
 # identify where bkg matches agoda condensed rows
  int = names(bk_rows)[names(bk_rows) %in% names(agoda_cond)]
# write over bkg_rows with condensed agoda rows
  bk_rows[int] = agoda_cond
  new_bkg = rbind(new_bkg, bk_rows)
}

write.csv(new_bkg, "bkg_agoda_mapped_for_job1.csv", row.names=F, na="")

