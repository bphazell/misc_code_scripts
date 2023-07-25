

read_data = function(input, type){
	print("did you make it here? read_script line 4")
	print(input)
	print(type)
	if(type == "/t"){
		df = read.delim(input, header=T, sep = "\t", row.names=NULL, quote="", stringsAsFactors=F)
	}
	if(type == "|"){
		df = read.delim(input, header=T, sep = "|", row.names=NULL, quote="", stringsAsFactors=F)
	}
	if(type == "csv"){
		print("did you make it here? read_script line 12")
		df = read.csv(input, stringsAsFactors=F)
	}
	if(type == "excel"){
		print("here right line 18")
		#df = read.xls(input, sheet=1, method="csv", perl="perl")
		df = read.xlsx2(input,header=TRUE,sheetIndex=1)
		print("this ok 20")
		#df = names(df)
	}
 
 	#df = as.data.frame
	print(df)
	return(df)

}

write_data = function(df, name){

	write.csv(df, name, na="", row.names=F)
}



