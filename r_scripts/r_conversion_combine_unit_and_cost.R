
setwd("~/Downloads/")
options(stringsAsFactors=F)
   master=read.csv("Crowd cost and fee.csv")
   names(master) = paste0(names(master), "_crowd_cost")
   toadd = read.csv("units counts.csv")
   names(toadd) = paste0(names(toadd), "_unit_count")

new_df = merge(master,toadd, by.x="Row.Labels_crowd_cost", by.y="team_unit_count", all.x=T)

write.csv(new_df, "combined_price_unit_analysis_incomplete.csv",row.names=F, na="")
