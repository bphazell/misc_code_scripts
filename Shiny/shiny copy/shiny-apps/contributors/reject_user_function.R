source('../.env')
auth_key = CF_SHINY_APPS_API_KEY

reject_user <- function(job_id, x) {
  flag_head=paste("curl -X PUT \'https://crowdflower.com/jobs/", job_id,"/contributors/",sep='')
  
  flag_tail= paste0("/reject?key=",
    auth_key,
    "&reason=scambot_speed_violation_punch_these_guys_in_the_face\' -d \'\'")
  system(paste(flag_head,x,flag_tail,sep=''))
}
