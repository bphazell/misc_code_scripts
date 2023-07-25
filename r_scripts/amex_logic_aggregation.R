

setwd("~/Desktop/")
options(stringsAsFactors = F)

df = read.csv("revenue_test.csv")

df2 = df

for(i in 1:nrow(df2)){
  if(df2$gd_profile_yn[i] == "no"){
    df2$gd_employees_listed[i] = ""
    df2$gd_employees_listed.confidence[i] = ""
    df2$gd_url[i] = ""
    df2$gd_url.confidence[i] = ""
    df2$gd_url_worker_input[i] = ""
    df2$gd_url_worker_input.confidence[i] = ""
    df2$gd_revenue_listed[i] = ""
    df2$gd_revenue_listed.confidence[i] = ""
    df2$gd_company_size[i] = ""
    df2$gd_company_size.confidence[i] = ""
    df2$gd_lower_revenue[i] = ""
    df2$gd_lower_revenue.confidence[i] = ""
    df2$gd_upper_revenue[i] = ""
    df2$gd_upper_revenue.confidence[i] = ""
  }
  if(df2$owler_profile_yn[i] == "no"){
    df2$owler_employees_listed[i] = ""
    df2$owler_employees_listed.confidence[i] = ""
    df2$owler_url[i] = ""
    df2$owler_url.confidence[i] = ""
    df2$owler_revenue_listed[i] = ""
    df2$owler_revenue_listed.confidence[i] = ""
    df2$owler_revenue[i] = ""
    df2$owler_revenue.confidence[i] = ""
    df2$owler_company_size[i] = ""
    df2$owler_company_size.confidence[i] = ""
  }
  if(df2$gd_profile_yn[i] == "yes"){
    df2$owler_employees_listed[i] = ""
    df2$owler_employees_listed.confidence[i] = ""
    df2$owler_url[i] = ""
    df2$owler_url.confidence[i] = ""
    df2$owler_revenue_listed[i] = ""
    df2$owler_revenue_listed.confidence[i] = ""
    df2$owler_revenue[i] = ""
    df2$owler_revenue.confidence[i] = ""
    df2$owler_company_size[i] = ""
    df2$owler_company_size.confidence[i] = ""
  }
  
  if(df2$gd_revenue_listed[i] != "range"){
    df2$gd_lower_revenue[i] = ""
    df2$gd_lower_revenue.confidence[i] = ""
    df2$gd_upper_revenue[i] = ""
    df2$gd_upper_revenue.confidence[i] = ""
  }
}

gd = nrow(df2[df2$gd_employees_listed == "yes",])
owl = nrow(df2[df2$owler_employees_listed == "yes",])
owl_csv = df2[df2$owler_employees_listed == "yes",]

name = names(df2)
new_names = gsub("X_", "_", name)
names(df2) = new_names

write.csv(df2, "amex_revenue_a977063_output.csv", row.names=F, na="")
