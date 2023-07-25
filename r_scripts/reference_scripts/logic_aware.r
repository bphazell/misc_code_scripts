############## address logic, borken down by logic chains ###################
### brian's script for adress task aggregation ####################
require('plyr')
options(stringsAsFactors=F)

start_with_full = read.csv('~/Documents/bandphotos/f349417.csv')
start_with_full = start_with_full[start_with_full$X_golden=="false",]
start_with_full = start_with_full[start_with_full$X_tainted!="true",]


aggregation_fun <- function(slice, field, ...) {
  # slice is a slice of a full report
  # field is a field name the way it appears in the doc
  #trust_weigths = aggregate(data=slice, X_trust ~ field, function(x) sum(x)/sum(slice$X_trust))
  #trust_weigths = ddply(slice, .(as.name(field)), summarise, _trust = sum(X_trust)/sum(slice$X_trust))
  trust_weigths = ddply(slice, field, here(summarize), X_trust = sum(X_trust)/sum(slice$X_trust))
  winning_field = trust_weigths[[paste(field)]][trust_weigths$X_trust == max(trust_weigths$X_trust)][1]
  field_confidence = max(trust_weigths$X_trust)
  new_slice = slice[slice[[as.character(as.name(field))]]==winning_field,]
  list(answer=winning_field, data=new_slice, confidence=field_confidence)
  # add confidences
}

unit_ids = unique(start_with_full$X_unit_id)
unit_ids = unit_ids[order(unit_ids)]

# fake agg report

initial_agg = read.csv('~/Documents/bandphotos/a349417.csv')
initial_agg = initial_agg[order(initial_agg$X_unit_id),]

for_headers = read.csv('~/Documents/bandphotos/a349417.csv', header=F)
stored_headers = for_headers[1,]


new_agg = read.csv('~/Documents/bandphotos/a349417.csv')
new_agg = new_agg[order(new_agg$X_unit_id),]

############################ the magic begins here ########################
field_list = list(
  "address_found",
  (list("intl_headquaters",
        list("city_verified",
             list("city_corrected")),
        list("state_verified",
             list("state_corrected")),
        list("zip_verified",
             list("zip_corrected")),
        list("city_verified",
             list("city_corrected")),
        list("address_line_1_verified",
             list("address_line_1_corrected")),
        list("address_line_2_verified",
             list("address_line_2_corrected")),
        list("address_already_correct"))
  ))

for (i in 1:length(field_list)) {
  if (summary(field_list)[2*length(field_list)+i]=="list") {
    print("We must go deeper!")
    field_list1 = field_list[[i]] 
    for (i in 1:length(field_list1)) {
      print("In enumeration HERE")
      if (summary(field_list1)[2*length(field_list1)+i]=="list") {
        print("I guess it's a list then...")
        print("We must go even deeper!")
        field_list2 = field_list1[[i]]
        for (i in 1:length(field_list2)) {
          if (summary(field_list2)[2*length(field_list2)+i]=="list") {
            print("We must go even deeper X2!")
            field_list3 = field_list2[[i]]
            for (i in 1:length(field_list3)) {
              print(field_list3[[i]])
              this_field = field_list3[[i]]
              print("get value")
              print("get value")
              dominant_intl_headquarters = lapply(unit_ids, function(x)  aggregation_fun(slice=new_df2[new_df2$X_unit_id==x,],
                                                                                         field=this_field))
              new_agg[[as.character(as.name(this_field))]] = unlist(lapply(dominant_intl_headquarters, function(x) x$answer))
              new_agg[[paste(this_field, ".confidence", sep="")]] = unlist(lapply(dominant_intl_headquarters, function(x) x$confidence))
            }
          } else {
            print(field_list2[[i]])
            this_field = field_list2[[i]]
            print("get value")
            dominant_intl_headquarters = lapply(unit_ids, function(x)  aggregation_fun(slice=new_df1[new_df1$X_unit_id==x,],
                                                                                       field=this_field))
            new_agg[[as.character(as.name(this_field))]] = unlist(lapply(dominant_intl_headquarters, function(x) x$answer))
            new_agg[[paste(this_field, ".confidence", sep="")]] = unlist(lapply(dominant_intl_headquarters, function(x) x$confidence))
            print("get new df")
            new_rows = lapply(dominant_intl_headquarters, function(x) x$data)
            new_df2 <- ldply(new_rows, data.frame)
            print(dim(new_df2))
          }
        }
      } else {
        print(field_list1[[i]])
        this_field = field_list1[[i]]
        print("get value")
        dominant_intl_headquarters = lapply(unit_ids, function(x)  aggregation_fun(slice=new_df[new_df$X_unit_id==x,],
                                                                                   field=this_field))
        new_agg[[as.character(as.name(this_field))]] = unlist(lapply(dominant_intl_headquarters, function(x) x$answer))
        new_agg[[paste(this_field, ".confidence", sep="")]] = unlist(lapply(dominant_intl_headquarters, function(x) x$confidence))
        print("get new df")
        new_rows = lapply(dominant_intl_headquarters, function(x) x$data)
        new_df1 <- ldply(new_rows, data.frame)
        print(dim(new_df1))
      }
    }
  } else {
    print(field_list[[i]])
    this_field = field_list[[i]]
    print("get value")
    dominant_address_found = lapply(unit_ids, function(x)  aggregation_fun(slice=start_with_full[start_with_full$X_unit_id==x,],
                                                                           field=this_field))
    new_agg[[as.character(as.name(this_field))]] = unlist(lapply(dominant_address_found, function(x) x$answer))
    new_agg[[paste(this_field, ".confidence", sep="")]] = unlist(lapply(dominant_address_found, function(x) x$confidence))
    print("get new df")
    new_rows = lapply(dominant_address_found, function(x) x$data)
    new_df <- ldply(new_rows, data.frame)
    print(dim(new_df))
  }
}

new_agg = rbind(new_agg[1,], new_agg)
new_agg[1,] = stored_headers

write.csv(new_agg, file="~/Documents/logic_aware_agg_for_brian.csv", na="", row.names=F, col.names=NULL)

### trouble units
# 366148388
# 366147502 366148189
# 366147426 366147502 366147761
# 366147393 366147411 366147490 366147499 366147544 366147581 366147633 366147642 366147762 366147788 366147809
# 366147817 366147855 366147889 366148045 366148046 366148066 366148067 366148081 366148092 366148273 366148275
# 366148288 366148334 366148399 366148492 366148521
