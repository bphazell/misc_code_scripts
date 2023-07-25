
get_job_data <- function(id){
  selects = paste('select id, user_id, title, minimum_account_age_seconds, \'\\"\' || \\"minimum_requirements\\" || \'\\"\' as minimum_requirements, require_worker_login', sep="")
  from = paste(" from builder_jobs", sep="")
  where = paste(" where id=", id, sep="")
  query = paste(selects, from, where)
  return(query)
}