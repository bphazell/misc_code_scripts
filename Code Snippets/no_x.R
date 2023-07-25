no_x = function(df) {
  name = names(df)
  new_names = gsub('X_', '_', name)
  colnames(df) = new_names
  return(df)
}