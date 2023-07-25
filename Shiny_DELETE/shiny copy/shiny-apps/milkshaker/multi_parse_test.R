current_time = as.POSIXlt(Sys.time(), "UTC")
numeric_time = as.numeric(current_time)
add_10_mins = numeric_time + 600
print("Set Expire to:")
print(add_10_mins)

#Get signature
#args = all query parameters going to be sent out with the request 
# (e.g. api_key, unit, interval, expire, format, etc.) excluding sig.
# args_sorted = sort_args_alphabetically_by_key(args)
# args_concat = join(args_sorted) 
# Output: api_key=ed0b8ff6cc3fbb37a521b40019915f18event=["pages"]
#         expire=1248499222format=jsoninterval=24unit=hour
# sig = md5(args_concat + api_secret)

splits = {}
rows = head(full_file)
cats = rows$services_offered_corrected
name = "services_offered_corrected"
not_cats = rows[!(names(full_file) %in% name),]
new_row = {}


all = rbind(new_row, each_cat)

flat_splits = {}
#for(i in 1:length(splits)){
#  flat_splits = lapply(splits[i], function(x) str_extract(x, '\"(.*)\"'))
#}

cats = full_file$services_offered_corrected[1:3]
split = str_split(cats, "\n")
unlist_split = unlist(split)
counter = str_count(cats, "\n")
new_row = {}

for(i in 1:length(counter)){
    values = rep(full_file$X_unit_id[i], times=(counter[i]+1))
    new_row <- append(new_row, values, after = length(new_row))
}


new_row = {}
rename = {}
for(i in 1:length(answer_columns)){
  answer = full_file[,c(answer_columns[i])]
  counter = str_count(answer, "\n")
  split = unlist(str_split(answer, "\n"))
  #unlist_split = unlist(split)
  rename <- append(rename, split, after = length(rename))
}
 # print(i)
  

  for(j in 1:length(counter)){
   values = full_file$X_unit_id[j]
   if(counter[j] != 0){
   values = rep(full_file$X_unit_id[j], times=(counter[j]+1)) 
   }
   new_row <- append(new_row, values, after = length(new_row))
  }
}

nodata <- as.data.frame(setNames(replicate(5,numeric(0), simplify = F), letters[1:5]))










