setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/Rerun_Broken_Links/Output/")

options(stringsAsFactors=F)

df = read.csv("format_rerun_output_2931_units.csv")

broke = df[df$broken == "Check this box if the link is broken/private/removed or contains no videos",]

for(i in 1:nrow(df)){
  if(df$broken[i] == "true"){
    df$language[i] = ""
    print("true")
  }
  print(i)
}

new_df = df[c("user_id","channel_name","url","wt_segmentation_10","channel_country_code","locale_preference", "category","sub_category", "youtube_format_chosen","broken")]

setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/Rerun_Broken_Links/Package/")
write.csv(new_df, "format_rerun_for_final_pack_2931_units.csv", na="", row.names=F)
