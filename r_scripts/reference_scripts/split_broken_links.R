 setwd ("~/Desktop")

complete_gold = read.csv("bio_bus_complete_gold.csv")
unique_id = read.csv("unique_pdfs.csv")

complete_gold[is.na(complete_gold)] = ""
complete_gold[complete_gold == 0] = ""

unique_id_yes = unique_id[unique_id$broken == "yes", ]
unique_id_no = unique_id[unique_id$broken != "yes",]


yes = complete_gold[complete_gold$docid %in% unique_id_yes$V1, ]
no =complete_gold[complete_gold$docid %in% unique_id_no$V1, ]

write.csv(yes, "compiled_broken_links.csv")
write.csv(no, "compiled_gold_working_links.csv")
