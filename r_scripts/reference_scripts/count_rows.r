setwd("~/Desktop/")

oned = read.csv("f350956_1d.csv")

occ = as.data.frame(table(oned$X_worker_id))

colnames(occ) = c("contributors", "occurences")

sig = occ[occ$occurences >= 50,]

write.csv(sig,"bburljob1d_contributors.csv",row.names=FALSE)

onea = read.csv("bburljob1a_contributors.csv")
oneb= read.csv("bburljob1b_contributors.csb")
onec= read.csv("bburljob1c_contributors.csv")
oned= read.csv("bburljob1d_contributors.csv")

colnames(onec) = c("contributor_ids","occurences")
colnames(oneb) = c("contributor_ids","occurences")
colnames(onea) = c("contributor_ids","occurences")
colnames(oned) = c("contributor_ids","occurences")

combine = rbind(onea,oneb,onec,oned)

unqcombine = as.data.frame(unique(combine$contributor_ids))

write.csv(unqcombine,"bburljob1_all_contributors.csv",row.names=FALSE)


