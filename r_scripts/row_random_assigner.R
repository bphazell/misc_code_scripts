
setwd("~/Desktop/")

df = read.csv("ai_candidate_jobs_v2-unique_candidate_jobs-2017-01-25-00-38-31.csv")
df = df[sample(nrow(df)),]
part = c("Brian",
        "Jack",
        "Kevin",
        "Nick",
        "Patrick",
        "Andy", 
        "Glenn",
        "Jessica",
        "Kirsten",
        "Matt",
        "Romeo", 
        "Camille", 
        "Sydney") 

each = nrow(df)/length(part)
for(i in seq(each,nrow(df), each)){
  df$Assignee[(i-each):i] = part[round((i/each),)]
}

write.csv(df, "ai_candidate_jobs.csv", row.names=F, na="")

