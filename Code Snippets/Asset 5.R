# This script takes a full csv and outputs a dataframe that contains counts
# of the number of IPs a workers has had in the job as well as countries and cities.
# Some judgment and time data is included to help you assess their quality.

df = read.csv({YOUR_FULL_CSV}) # the full csv you want to process

# this script require the plyr package
require(plyr)

# add judgment creation and completion times
df$time_start<-as.numeric(strptime(df$X_started_at,"%m/%d/%Y %H:%M:%S",tz='PST'))/60
df$time_finish<-as.numeric(strptime(df$X_created_at,"%m/%d/%Y %H:%M:%S",tz='PST'))/60

# aggregate the judgments to collect a variety of stats per worker
dip=ddply(df,.(X_worker_id),summarize,ips=list(as.character(unique(X_ip))),
         num_ip=length(unique(X_ip)),num_country=list(unique(X_country)),
         mean_time=mean(time_finish-time_start),sd_time=sd(time_start-time_finish),
         countries=list(as.character(unique(X_country))),
         cities=list(as.character(unique(X_city))),
         num_cities = list(as.character(unique(X_city))),
         judgments=length(X_golden),golds=sum(X_golden=='true'),trust=X_trust[[1]])

# reorder the results based on number of ips
dip=dip[order(dip$num_ip,decreasing=T),]
 Sent at 2:01 PM on Thursday
 Amber:  df = read.csv("f243791.csv",stringsAsFactors=F) # the full csv you want to process

# this script require the plyr package
require(plyr)

# add judgment creation and completion times
df$time_start<-as.numeric(strptime(df$X_started_at,"%m/%d/%Y %H:%M:%S",tz='PST'))/60
df$time_finish<-as.numeric(strptime(df$X_created_at,"%m/%d/%Y %H:%M:%S",tz='PST'))/60

# aggregate the judgments to collect a variety of stats per worker
dip=ddply(df,.(X_worker_id),summarize,ips=list(as.character(unique(X_ip))),
         num_ip=length(unique(X_ip)),num_country=length(unique(X_country)),
         mean_time=mean(time_finish-time_start),sd_time=sd(time_start-time_finish),
         countries=list(as.character(unique(X_country))),
         cities=list(as.character(unique(X_city))),
         num_cities = length(unique(X_city)),
         judgments=length(X_golden),golds=sum(X_golden=='true'),trust=X_trust[[1]])

# reorder the results based on number of ips
dip=dip[order(dip$num_ip,decreasing=T),]