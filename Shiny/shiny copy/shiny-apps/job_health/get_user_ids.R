

##pull from redshift to get all unique users from the job history changes table

get_user_ids <- function(user_list){

	selects = paste("select id, email, admin", sep="")
	from = paste("from builder_users", sep="")
		users = paste("id = ", user_list)
		ors = paste(users, collapse = " or ")
	where = paste("where ", ors, sep="")
	query_items = paste(selects, from, where)
	return(query_items)

}