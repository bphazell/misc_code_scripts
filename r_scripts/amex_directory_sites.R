
setwd("~/Desktop/")
options(stringsAsFactors = F)

df = read.csv("amex_url_a976438.csv")
df$domain = df$directory_url

for(i in 1:nrow(df)){
  print(i)
  test = df$domain[i]
  test = gsub("\\.com(.*)", "", test)
  test = gsub("\\.org(.*)", "", test)
  test = gsub("\\.gov(.*)", "", test)
  test = gsub("\\.net(.*)", "", test)
  test = gsub("http://", "", test)
  test = gsub("https://", "", test)
  df$domain[i] = test
}

domains = as.data.frame(table(df$domain))
domains = domains[order(domains$Freq, decreasing = T),]




tab = as.data.frame(table(df$three_layer))
tab = tab[order(df$three_layer),]

write.csv(domains, "amex_directory_domains.csv", row.names=F, na="")

#write.csv(tab, "3_layer_table.csv", row.names=F, na="")
