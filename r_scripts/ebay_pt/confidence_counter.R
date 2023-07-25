
setwd("~/Dropbox/ebay_product_type/files for q1 confidence reports/Jewelry & Watches//")

output = data.frame(category_name = character(0), categoryleafid = integer(0), coming_from = character(0), group_member = character(0), image_url = character(0),
                    item_id = integer(0), title = character(0), chosen_category = character(0), chosen_category.confidence = integer(0))

filenames = list.files("~/Dropbox/ebay_product_type/files for q1 confidence reports/Jewelry & Watches/", pattern = "*.tsv", full.names=T)
dataframes = list()

for (i in seq_along(filenames)){
  dataframes[[i]] = read.delim(filenames[i],header=T, sep = "\t", row.names=NULL, stringsAsFactors=F)
    print(paste("Reading ", i))
}

for (i in 1:length(dataframes)){
  output = rbind.fill(output, dataframes[[i]])
  print(paste("Combining ", i))
}
confidence = grep(".confidence", colnames(output))
output_con = output[,confidence]

chosen_con = output_con[,"chosen_category.confidence"]
q1_con = output_con[,"q1.confidence"]

total = c(chosen_con,q1_con)
total = na.omit(total)
total = as.data.frame(total)
total$range = ""

for (i in 1:nrow(total)) {
  if(total$total[i] <= 0.4999) {
    total$range[i] = "0 - 0.499"
  } else if (total$total[i] >= 0.5 && total$total[i] <= 0.6999 ){
    total$range[i] = "0.5 - 0.699"
  } else if (total$total[i] >= 0.7 && total$total[i] <= 0.8999){
    total$range[i] = "0.7 - 0.899"
  } else {
    total$range[i] = "0.9 - 1"
  }
  print(i)
}

a0_0.499 = total[total$range == "0 - 0.499",]
b0.5_0.699 = total[total$range == "0.5 - 0.699",]
c0.7_0.899 = total[total$range == "0.7 - 0.899",]
d0.9_1 = total[total$range == "0.9 - 1",]





summary = as.character(c("total units: ", nrow(output), "0 - 0.499:", nrow(a0_0.499), "0.5 - 0.699:", nrow(b0.5_0.699), 
                         "0.7 - 0.899:", nrow(c0.7_0.899), "0.9 - 1:", nrow(d0.9_1)))

setwd("~/Desktop/")


write.table(summary, "Jewlery_and_Watches.txt", row.names=F, quote=F)






