
setwd("~/Desktop/")
options(stringsAsFactors = F)

df = read.csv("clone_of_nda_closed_channel_jobs_completed_by_hyderabad_scammer-query_1-2016-12-09-22-15-57.csv")
Sys.setlocale('LC_ALL','C') 

#gold = df[df$data != '',]

#not_gold = df[df$data == '',]

#transcription = df[grep('Transcribe', df$title),]

df = df[(grep('Chronicle', df$title)),]

df$zendesk_id = ""
for(i in 1:nrow(df)){
if (grepl("zendesk",df$data[i]) == TRUE){
  data = df$data[i]
  ind = unlist(gregexpr("zendesk_id", data))
  z_id = gsub('"', '', substr(data, ind, ind+21))
  df$zendesk_id[i] = z_id
}
}

df$gold_type = ""
for(i in 1:nrow(df)){
  #if (grepl("_golden\":\"true",df$data[i]) == TRUE){
    data = df$data[i]
    ind_start = unlist(gregexpr("type_gold", data))[1]
    ind_end = (unlist(gregexpr("type_gold_reason", data))-4)
    df$gold_type[i] = gsub('"', '', substr(data, ind_start, ind_end))
  #}
}

non_dupes = df[duplicated(df$zendesk_id) == F,]

blanks = df[df$zendesk_id == "",]

non_dupes$zendesk_id[80] == non_dupes$zendesk_id[116]

write.csv(non_dupes, "uber_scam_counts.csv", row.names=F, na="")

write.csv(df, "uber_scam_counts.csv", row.names=F, na="")










