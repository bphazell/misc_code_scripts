
check_for_judgments <- function(job_id){
	selects = paste('select count(id)', sep="")
	from = paste(' from builder_judgments', sep="")
	where = paste(' where job_id=', job_id, sep="")
	query = paste(selects, from, where)
	return(query)
}