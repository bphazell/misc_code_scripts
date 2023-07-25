create_hash_key <- function(file, key){
    if (length(key) > 1) {
	file$hash_key = 
		apply(file[, key], 1, function(x) paste(x, collapse="\t"))
    } else {
        file$hash_key = file[, key]
    }
    return(file$hash_key)
}