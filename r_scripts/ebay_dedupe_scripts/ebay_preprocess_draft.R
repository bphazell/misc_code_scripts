setwd("~/Desktop/")
options(stringsAsFactors=F)

#NOTE: May need to update column headers

sour = read.csv('~/Dropbox/ebay_dupe_concepts/Feb_28/Source/ebay_source_test_1000_units.csv')

output = ebay_preprocess(sour)

ebay_preprocess = function(sour){
  new_sour = sour
  new_sour$unique_id = ""
  new_sour$del1 = ""
  conceptname_vector = new_sour[,"ConceptName"]
  del1_vector = new_sour[,"del1"]
  new_sour$del2 = ""
  del2_vector = new_sour[,"del2"]
  top10children = new_sour[,"Top10Children"]
  #for Dedupe
  for (i in 1:nrow(new_sour)){
    array = unlist(strsplit(top10children[i], ", "))
    len = length(array)
    if(len==1){
      del1_vector[i] = top10children[i]
      del2_vector[i] = ""
    }
    if(len >1) {
      del1 = array[1:ceiling(len/2)]
      del2 = array[ceiling(len/2+1): len]
      del1_vector[i]= paste(del1, collapse = ", ")
      del2_vector[i]= paste(del2, collapse = ", ")
    }
    new = cbind(new_sour,del1_vector,del2_vector)
    print( paste("Dedupe ", i))
  }
  #for incomplete and wordorder
  new$newdel1 = ""
  new$newdel2 = ""
  newdel1_vector = new[,"newdel1"]
  newdel2_vector = new[,"newdel2"]
  #a
  for(i in 1:nrow(new)){
    if (del2_vector[i] != ""){
      conceptname = conceptname_vector[i]
      newdel2_vector[i] = paste(del2_vector[i], conceptname, sep = ", ")
    }
    if (del2_vector[i] == ""){
      conceptname = conceptname_vector[i]
      newdel2_vector[i] = paste(del2_vector[i], conceptname, sep = "")
    }
    new$unique_id[i] = i
    print( paste("Non_dupe ", i))
    newdel1_vector[i] = del1_vector[i]
  }
  #b
  new_complete = cbind(new,newdel1_vector,newdel2_vector)
  new_complete$del1 = NULL
  new_complete$del2 = NULL
  new_complete$newdel1 = NULL
  new_complete$newdel2 = NULL
  names(new_complete) = c("siteid", "conceptname", "top10children", "unique_id", "del1", "del2", "newdel1", "newdel2")
  return(new_complete) 
}




