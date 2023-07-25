wordorder_postprocess = function(sour, agg){
  agg$word_order = ""
  part1_vector = agg[,"part1"]
  part2_vector = agg[,"part2"]
  new_vector = paste(part1_vector,part2_vector, sep = "\n")
  new_vector = gsub("\n", ", ", new_vector)
  new_vector = gsub("none","",new_vector)
  new_vector = gsub("^,","",new_vector)
  new_vector = gsub(", $","",new_vector)
  agg$word_order = new_vector
  agg = agg[names(agg) %in% c("unique_id", "conceptname", "top10children", "word_order")]
  output = merge(sour, agg)
  output = output[order(output$unique_id),]
  return(output)
}