setwd("~/Desktop/twelvefold/")

no_exxes = function(df){
  name = names(df)
  new_names = gsub('X_', '_', name)
  colnames(df) = new_names
  return(df)
}

#to remove unfinalized units from full report

job_1_agg_report = read.csv ("agg_job1_249407_10_8_pm .csv", stringsAsFactors = FALSE)
job_2_source_report =read.csv ("source_job_2_249372_10_8_pm .csv", stringsAsFactors = FALSE)

agg_unit_ids = job_1_agg_report[ ,"weblink"]

source_unit_ids = job_2_source_report[ ,"weblink"]

both = as.data.frame(agg_unit_ids[agg_unit_ids %in% source_unit_ids])

job_1_agg_report_both = job_1_agg_report[job_1_agg_report$weblink %in% both[, 1], ]

dedupe = job_1_agg_report[!(job_1_agg_report$weblink %in% both[,1]),]
dedupe = no_exxes(dedupe)
dedupe[is.na(dedupe)] = ''
dedupe = dedupe[dedupe$link_check != "broken", ]
write.csv(dedupe, "agg_report_10_8_dedupezz_pm.csv", row.names = FALSE, na = '')






