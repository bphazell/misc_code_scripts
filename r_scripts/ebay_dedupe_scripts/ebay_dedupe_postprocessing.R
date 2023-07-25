setwd('~/Desktop/ebay_dedupe/')
s = read.csv('source_test_launch.csv', stringsAsFactors = FALSE)
a1 = read.csv('final_lv1_a302144 .csv', stringsAsFactors = FALSE)
a2 = read.csv('final_lv1_og_296686 .csv', stringsAsFactors = FALSE)
a3 = read.csv('final_lv2_302142 .csv', stringsAsFactors = FALSE)

a1 = a1[, c('primary_keyword', 'delimited', 'part1', 'part2')]
a2 = a2[, c('primary_keyword', 'delimited', 'part1', 'part2')]
a3 = a3[, c('primary_keyword', 'delimited', 'part1', 'part2')]

all = rbind(a1,a2,a3)

fuzzy_dedupe = function(df1, col){
  count = data.frame(table(df1[, col]))
  dubs = count[count[, 2] > 1, ]
  names = as.character(unique(dubs[, 1]))
  if(length(names) > 0){
    for (i in 1:length(names)){
      dummy = df1[df1[, col] %in% names[i], ]
      dummy = dummy[1, ]
      rows = which(df1[, col] == names[i], arr.ind = TRUE)
      df1 = df1[-rows, ]
      df1 = rbind(df1, dummy)
    }
  }
  return(df1)
}

deduped = fuzzy_dedupe(all, "primary_keyword")

#Checks for dupes
count = unique(s$primary_keyword)
if(length(count)!=nrow(s)) paste('There seems to be dupes.  Ivestigate further.')

#This combines part1 and part2 columns into the same column.  
combined = function(df1, name1, name2){
  name1 = as.character(name1)
  name2 = as.character(name2)
  part1 = df1[, name1]
  part2 = df1[, name2]
  tf = paste(part1, part2, sep = '\n')
  df1$result = tf
  return(df1)
}

combdedupe = combined(deduped, "part1", "part2")

#Remove all 'nones' from a column
r_nones = function(df1, name1){
  name1 = as.character(name1)
  foo = df1[ , name1]
  mod_result = gsub('none\n', '', foo)
  mod_result = gsub('\nnone', '', mod_result)
  mod_result = gsub('none', '', mod_result)
  df1$result = mod_result
  return(df1)
}

nonone = r_nones(combdedupe, "result")

#Select only relavent columns.  Takes in an array of strings for column names
select = function(df1, names){
  names = as.character(names)
  df1 = df1[, names]
  return(df1)
}

names = c("primary_keyword", "delimited", "result")
nonsel = select(nonone, names)

#Creates new csv for units that have not been run.  Here source is df1, and agg is df2.
new_source = function(df1, df2, name1, name2){
  name1 = as.character(name1)
  name2 = as.character(name2)
  new_s = df1[!(df1[, name1] %in% df2[, name2]), ]
  return(new_s)
}

agg = combined(a, 'part1', 'part2')
agg = r_nones(agg, 'result')
columns = c('primary_keyword', 'delimited', 'result')
output = select(agg, columns)
colnames(output) = c('primary_keyword', 'children_and_siblings', 'result')

new_s = new_source(s, a, 'primary_keyword', 'primary_keyword')

write.csv(new_s, paste('new_source_', nrow(new_s), '_units_left.csv', sep = ''), row.names = FALSE)
write.csv(output, paste('client_', nrow(output), '_untis.csv', sep = ''), row.names = FALSE)

#Separate out all date range rows
mod_hyphens = grep('[0-9][0-9]-[0-9][0-9]', nonsel$primary_keyword)
mod_spaces2 = grep('^[0-9][0-9] [0-9][0-9]', nonsel$primary_keyword)
mod_spaces_long = grep('^[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9]', nonsel$primary_keyword)

nonsel$possible_date_range = ''

nonsel$possible_date_range[mod_hyphens] = 'yes'
nonsel$possible_date_range[mod_spaces2] = 'yes'
nonsel$possible_date_range[mod_spaces_long] = 'yes'

write.csv(nonsel, '10000_pilot_ebay.csv', row.names = FALSE)
bv

