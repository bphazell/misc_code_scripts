options(stringsAsFactors=F)
df = read.csv("~/Desktop/new_gold_for_check.csv")
# low = -.005
# high = +.02
names(df)

maxx = names(df)[grep("x_gold_max$",names(df))]
maxy = names(df)[grep("y_gold_max$",names(df))]

maxh = names(df)[grep("h_gold_max$",names(df))]
maxw = names(df)[grep("w_gold_max$",names(df))]

minx = names(df)[grep("x_gold_min$",names(df))]
miny = names(df)[grep("y_gold_min$",names(df))]

minh = names(df)[grep("h_gold_min$",names(df))]
minw = names(df)[grep("w_gold_min$",names(df))]

other = names(df)[grep("x_gold_min$|y_gold_min$|x_gold_max$|y_gold_max$|h_gold_max$|w_gold_min$|h_gold_min$|w_gold_max",names(df),invert=T)]
# x
df_maxx = df[maxx]
df_minx = df[minx]

#y
df_maxy = df[maxy]
df_miny = df[miny]

#h
df_maxh = df[maxh]
df_minh = df[minh]

#w
df_maxw = df[maxw]
df_minw = df[minw]

df_other = df[other]

#test = cbind(df_other,df_max,df_min)
#uni = unique(names(test))


df_maxx2 = df_maxx
for(i in 1:nrow(df_maxx)){
  for(j in 1:length(maxx)){
    if (is.na(df_maxx[i,j]) != T){
     # df_maxx2[i,j] = as.numeric(df_maxx[i,j])
     # class(df_max[i,j])
    df_maxx2[i,j] = df_maxx[i,j] -0.01
    }else {
      df_maxx2[i,j] = df_maxx[i,j]
    }
  }
}


df_minx2 = df_minx
for(i in 1:nrow(df_minx)){
  for(j in 1:length(minx)){
    if (is.na(df_minx[i,j]) != T){
      df_minx2[i,j] = df_minx[i,j] 
    } else {
      df_minx2[i,j] = df_minx[i,j] +.01
    }
  }
}

df_maxy2 = df_maxy
for(i in 1:nrow(df_maxy)){
  for(j in 1:length(maxy)){
    if (is.na(df_maxy[i,j]) != T){
      # df_maxx2[i,j] = as.numeric(df_maxx[i,j])
      # class(df_max[i,j])
      df_maxy2[i,j] = df_maxy[i,j] - 0.02
    }else {
      df_maxy2[i,j] = df_maxy[i,j]
    }
  }
}

df_miny2 = df_miny
for(i in 1:nrow(df_miny)){
  for(j in 1:length(miny)){
    if (is.na(df_miny[i,j]) != T){
      df_miny2[i,j] = df_miny[i,j] + 0.02
    } else {
      df_miny2[i,j] = df_miny[i,j]
    }
  }
}

df_maxh2 = df_maxh
for(i in 1:nrow(df_maxh)){
  for(j in 1:length(maxh)){
    if (is.na(df_maxh[i,j]) != T){
      # df_maxx2[i,j] = as.numeric(df_maxx[i,j])
      # class(df_max[i,j])
      df_maxh2[i,j] = df_maxh[i,j] - 0.02
    }else {
      df_maxh2[i,j] = df_maxh[i,j]
    }
  }
}

df_minh2 = df_minh
for(i in 1:nrow(df_minh)){
  for(j in 1:length(minh)){
    if (is.na(df_minh[i,j]) != T){
      df_minh2[i,j] = df_minh[i,j] + 0.02
    } else {
      df_minh2[i,j] = df_minh[i,j]
    }
  }
}

df_maxw2 = df_maxw
for(i in 1:nrow(df_maxw)){
  for(j in 1:length(maxw)){
    if (is.na(df_maxw[i,j]) != T){
      # df_maxx2[i,j] = as.numeric(df_maxx[i,j])
      # class(df_max[i,j])
      df_maxw2[i,j] = df_maxw[i,j] - 0.02
    }else {
      df_maxw2[i,j] = df_maxw[i,j]
    }
  }
}

df_minw2 = df_minw
for(i in 1:nrow(df_minw)){
  for(j in 1:length(minw)){
    if (is.na(df_minw[i,j]) != T){
      df_minw2[i,j] = df_minw[i,j] + 0.02
    } else {
      df_minw2[i,j] = df_minw[i,j]
    }
  }
}


new_df = cbind(df_other,df_minx2,df_maxx2, df_miny2, df_maxy2, df_minh2,df_maxh2,df_minw2,df_maxw2)
uni4 = unique(names(new_df))

uni = unique(names(new_df))
new_df$X_id = 1

uni = unique(names(new_df))
uni1 = unique(names(df))
dupes = names(new_df)[duplicated(names(new_df) == T)]

name = names(new_df)
new_names = gsub("X_","_",name)
names(new_df) = new_names
setwd("~/Desktop/")
write.csv(new_df,"this_one_updated_gold_for_job2.csv",row.names=F,na="")
