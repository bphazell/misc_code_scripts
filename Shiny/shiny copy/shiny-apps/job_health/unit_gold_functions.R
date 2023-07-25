### gold_functions to deal with the units table
# 
# state descriptions at https://crowdflower.atlassian.net/wiki/display/ENGR/Builder+Database+Schema
translate_states <- function(x) {
  x[x == 1] = "new"
  x[x == 2] = "judgable"
  x[x == 3] = "judging"
  x[x == 4] = "judged"
  x[x == 5] = "ordering"
  x[x == 6] = "golden"
  x[x == 7] = "hidden_gold"
  x[x == 8] = "canceled"
  x[x == 9] = "finalized"
  return(x)
}

get_percent_contested <- function(x,y) {
 if (y > 0) {
   return(x/y)
 } else {
   return(0)
 }
}

get_percent_contested_vectorized <- function(x_vector, y_vector) {
  contested_v = c()
  for (i in 1:length(x_vector)) {
    contested_v[i] = get_percent_contested(x_vector[i], y_vector[i])
  }
  return(contested_v)
}