
options(stringsAsFactors=F)

setwd("~/Desktop/for_pc/")

dfs = list.files()

for(i in 1:length(dfs)){ 
  assign(paste0("df", i), read.xlsx2(as.character(dfs[i]),header=TRUE,sheetIndex=1))
}

for(i in 1:length(dfs)){ 
  df_t = get(paste0("df", i))
  df_t$file = dfs[i] 
  assign(paste0("df", i), df_t)
}

df1$test=NULL

comp = df1
for( i in 1:(length(dfs)-1)){
  comp = rbind(comp, get(paste0("df",i+1)))
}

comp$group_members = comp$suggestions
  
for (i in 1:nrow(comp)){
  if(comp$group_members[i] == ""){
    comp$group_members[i] = comp$aspect_value[i]
  }
  
}

write.csv(comp,"precision_check_sample_site_US_metas_compliled_78268.csv",row.names=F, na="" )

uni = unique(df17$item_id)

