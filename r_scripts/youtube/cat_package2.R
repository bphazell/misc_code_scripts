

setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/")

pack = read.csv("Package/en_cat_package_broken_link_all_correct_3419_units.csv")

output = read.csv("source data/test_no_space_en_cat_output_for_subcat_3317_units.csv")


total = rbind.fill(output, pack)

broke = total[grep("^__", total$channel_name),]

no_broken = total[!(total$X_unit_id %in% broke$X_unit_id),]

music = no_broken[no_broken$category_cf == "Music",]

not_music = no_broken[no_broken$category_cf != "Music",]

done = not_music[not_music$package %in% "done",]

high_conf = done[done$unit_okay.confidence == 1,]
low_conf = not_music[not_music$unit_okay.confidence != 1,]

new_pack = rbind(broke, high_conf )

to_next_job = total[!(total$X_unit_id %in% new_pack$X_unit_id),]

setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/")

write.csv(new_pack, "en_cat_package_broken_plus_high_conf_no_music_1773_units.csv", row.names=F, na="")

write.csv(to_next_job, "en_cat_output_for_en_subcat_4963_units.csv", row.names=F, na="")



