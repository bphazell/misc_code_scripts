source('../.env')
auth_key = CF_SHINY_APPS_API_KEY


flag_user <- function(job_id, x) {
  flag_head=paste("curl -X PUT \'https://crowdflower.com/jobs/", job_id,"/contributors/",sep='')
  
  flag_tail=
  paste0("/flag?key=",
    auth_key,
    "&reason=flagged_from_coolstuff_caught_in_scambot_speed_trap\' -d \'\'")
  system(paste(flag_head,x,flag_tail,sep=''))
}