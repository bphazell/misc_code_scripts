options(stringsAsFactors = F)
df = read.csv("~/Desktop/url_test.csv")

df$url_exist = ""
df_with_url = df

df$company_web_address
col = "company_web_address"

new_df = url_validator(df, col)

 url_validator = function(df, col){

for(i in 1:nrow(df)){
array = df[col]  
url = array[i,]
cmd = paste0("curl -s --head http://", url, "/ --max-time  | head -n 1")
output = system(cmd, intern=T)
if(length(output) > 0){
  df$error_code = output
if(grepl("404", output)){
  df$url_exist[i] = "false"
} else {
  df$url_exist[i] = "true" 
}
} else {
  df$url_exist[i] = "no response"
}
print(i)
}
url_array = df["url_exist"]
broke = df[url_array == "no response",]
return(broke)

}

broke = df[df$url_exist == "broke",]
broke = broke[broke$company_web_address != "",]
