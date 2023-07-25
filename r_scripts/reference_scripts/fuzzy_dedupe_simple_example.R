
col = "animal"
one = data.frame(animal = c("cow", "chicken", "bunny", "cow", "bunny"), extra = c("one", "two", "three", "four", "five"))


fuzzy_dedupe = function(one,col){
count = as.data.frame(table(one[,col]))
dubs = count[count[,2] > 1,]
names = as.character(unique(dubs[,1]))

if(length(names) > 0){
for(i in 1:length(names)){
  dummy = one[one[,col] %in% names[i],]
  dummy = dummy[1,]
  rows = which(one[,col] == names[i], arr.ind = T)
  one = one[-rows,]
  one = rbind(one, dummy)  
}
}
return(one)
}

df = fuzzy_dedupe(one, "animal")


