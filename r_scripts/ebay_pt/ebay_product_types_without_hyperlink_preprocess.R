
setwd("~/Downloads/")

#update name to match what mews spits out
#example: read.csv("source file name")

#Start Need to Modify
sour = read.delim("Combined_musical_instruments_AU_first_part_-_20.03.2014.tsv",header=T, sep = "\t", row.names=NULL, quote="", stringsAsFactors=F)
#End: Need to Modify



setwd("~/Desktop/")
write.csv(sour, "ebay_product_types_preprocessed_change_name.csv", row.names=F, na="")
}

ebay_pt_preprocess(sour)









