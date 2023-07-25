
setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/Package/")
options(stringsAsFactors=F)

en_cat = read.csv("en_cat_package_broken_plus_high_conf_no_music_1773_units.csv")
intl_cat = read.csv("intl_cat_package_all_correct_1_confidence_575_units.csv")

mismatch = intl_cat[!(names(intl_cat) %in% names(en_cat))]

intl_cat$language_decoded = NULL

pack = rbind(en_cat,intl_cat)

pack = pack[-c(1:6)]

broken = pack[grep("^__", pack$channel_name),]

new_pack = pack[!(pack$channel_name %in% broken$channel_name),]

new_pack$corrected_category_gold = NULL
new_pack$subcategory_cf = new_pack$sub_category

setwd("~/Desktop/")
write.csv(new_pack, "cat_en_intl_for_final_pack_1535_units.csv",row.names=F, na="")
