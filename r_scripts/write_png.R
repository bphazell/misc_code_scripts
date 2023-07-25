
options(stringsAsFactors=F)
df = read.csv("~/Desktop/norm1_output.csv")

col = "errors_in_normalized"
setwd("~/Desktop/")

pdf("file.pdf")
qplot(x=df[,col], geom='bar', fill=as.character(df[,col])) +  xlab(col) + guides(fill=guide_legend(title=col)) + scale_colour_brewer(palette="Blues") +  theme(axis.text.x = element_text(angle = 45))
dev.off()