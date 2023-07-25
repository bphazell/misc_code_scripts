
agg = read.csv("~/Desktop/dedupe_test.csv")

length(agg$part1[8])

test = agg[!(agg$part1 %in% "none"),]

test2 = test[grep("none.", test$part1),]

test2$new_agg = ""

for (i in 1:nrow(test2)){
strcon = as.numeric(unlist(strsplit(test2$part1.confidence[i], "\n")))
valcon = unlist(strsplit(test2$part1[i], "\n"))

if (strcon[1] > strcon[2]){
  test2$new_agg[i] = valcon[1]
} else {
    test2$new_agg[i] = valcon[2]
  }
}


  




