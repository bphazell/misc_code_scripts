
setwd("~/Desktop/")
options(stringsAsFactors = F)

df = read.csv("amex_match.csv")

df$match_p = ""

for(i in 1:nrow(df)){
  print(i)
  if(df$broken_link[i] == "FALSE"){
    am_name = strsplit(gsub(" ", "", df$sit_company_name[i]), "")[[1]]
    cf_name = strsplit(gsub(" ", "", df$company_name[i]), "")[[1]]
    map = length(intersect(am_name, cf_name)) /  max(length(unique(am_name)), length(unique(cf_name)))
    df$match_p[i] = map
  }
}

for (n in seq(0,0.9, by=0.10)) {
  s = df[df[["match_p"]] >= n,] #Probabilty of prediction
  print(paste(n, nrow(s), sep=" | "))
}

write.csv(df, "amex_job2_output_with_match.csv", na="")




