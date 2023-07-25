library(readr)
uber = read_csv('~/Downloads/aac33687-562d-4edd-8511-d1ef560af2e1_training_data.csv')
uber$ticket_type_correct = F
uber = uber[!is.na(uber$ticket_type_prediction),]
uber[uber$ticket_type_prediction == uber$ticket_type,]$ticket_type_correct = T
for (n in seq(0,0.9,by=0.1)) {
  s = uber[uber$ticket_type_probability >= n,]
  s.acc = nrow(s[s$ticket_type_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}


uber_yes = uber[uber$ticket_type == "yes",]
uber_yes$category_correct = F
uber_yes[uber_yes$category == uber_yes$category_prediction,]$category_correct = T
for (n in seq(0,0.9,by=0.1)) {
  s = uber_yes[uber_yes$category_probability >= n,]
  s.acc = nrow(s[s$category_correct == T,])/nrow(s)
  print(paste(n, s.acc, nrow(s), sep=" "))
}
