# select builder_worker_id, 
# units_per_page, 
# country,
# channel_id,
# created_at,
# finished_at,
# EXTRACT(epoch FROM (finished_at-created_at)) as duration_seconds,
# EXTRACT(epoch FROM (finished_at-created_at))/units_per_page as duration_per_unit
# from worker_ui_assignments 
# where job_id = 454645
# and state = 'completed'

assignment_duration_query <- function(job_id) {
  part1 = "select builder_worker_id, 
units_per_page, 
country,
channel_id,
created_at,
finished_at,
EXTRACT(epoch FROM (finished_at-created_at)) as duration_seconds,
EXTRACT(epoch FROM (finished_at-created_at))/units_per_page as duration_per_unit
from worker_ui_assignments 
where job_id = "
  part2 = " and state = 'completed'"
  query = paste0(part1, job_id, part2)
  return(query)
}