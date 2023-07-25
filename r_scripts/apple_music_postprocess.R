 
options(stringsAsFactors = F)
setwd("~/Desktop/")

CSV_NAME = "music_tracks.csv"
df = read.csv(CSV_NAME)

# converts "" to NA's 
is.na(df) <- df==''

# removes gold and confidence columns 
df = df[, -grep("_gold", names(df))]
df = df[, -grep("confidence", names(df))]

df$final_day = ""
df$final_month = ""
df$final_year = ""


for(i in 1:nrow(df)) {
  print(i)
  
  ### Begin Logic Aware Aggregation ###
  
  # Removes 'Other' if any of the other sites are found
  if(df$discogs[i] == "yes" || df$musicbrainz[i] == "yes" || df$wikipedia[i] == "yes"){
    df$other[i] = NA
    df$other_day[i] = NA
    df$other_month[i] = NA
    df$other_year[i] = NA
  }
  
  # removes date info if found = no
  site_names = (c("discogs", "musicbrainz", "wikipedia", "other"))
  count_values = c()
  
  for(l in 1:length(site_names)){
    count_values = c(count_values, df[[site_names[l]]][i] )
    # applies logic aware aggregation 
    if ((df[[site_names[l]]][i] == "no") || is.na(df[[site_names[l]]][i])){
      df[[paste0(site_names[l],"_day")]][i] = NA
      df[[paste0(site_names[l],"_month")]][i] = NA
      df[[paste0(site_names[l],"_year")]][i] = NA
    }
  }
  
  ### End Logic Aware Aggregation ###
  
  #define row as a variable 
  row = df[i,]
  
  if(!("yes" %in% count_values)){
    # if no sites found, skips  
  } else {
    other = row[,grep("other", names(row))]
    other_date = c(other$other_year, other$other_month, other$other_day)
    # Checks to see if Other is filled out
    # If Other is filled out, automaticall writes Other 
    if(!(is.na(other_date[1]))) {
      df$final_day[i] = df$other_day[i]
      df$final_month[i] = df$other_month[i]
      df$final_year[i] = df$other_year[i]
    } else {
      # if Other not filled out, creates variable for each website
      discogs = row[,grep("discog", names(row))]
      musicbrainz = row[,grep("musicbrainz", names(row))]
      wikipedia = row[,grep("wikipedia", names(row))]

      # creates vector for each site in year / month / day
      discogs_date = c(discogs$discogs_year, discogs$discogs_month, discogs$discogs_day)
      musicbrainz_date = c(musicbrainz$musicbrainz_year, musicbrainz$musicbrainz_month, musicbrainz$musicbrainz_day)
      wikipedia_date = c(wikipedia$wikipedia_year, wikipedia$wikipedia_month, wikipedia$wikipedia_day)
      
      #creates placeholder list for webistes
      websites = list()
      # adds websites to list if site != NA
      if(!(is.na(discogs_date[1]))){
        websites[["discogs"]] = discogs_date
      }
      if(!(is.na(musicbrainz_date[1]))){
        websites[["musicbrainz"]] = musicbrainz_date
      }
      if(!(is.na(wikipedia_date[1]))){
        websites[["wikipedia"]] = wikipedia_date
      }
      
      # if only one result, automatically writes to CSV 
      if(length(websites) == 1){
        df$final_year[i] = websites[[1]][1]
        df$final_month[i] = websites[[1]][2]
        df$final_day[i] = websites[[1]][3]
      } else {
        # Adds count of na's for each site 
        na_count = c()
        add_na_count = function(site, vector){
          count =length(site[grepl("not_found",site)])
          vector = c(vector, count)
          return(vector)
        }
        
        for(j in 1:length(websites)){
          na_count = add_na_count(websites[[j]], na_count)
        }
        
        # Finds site with least amount of NA's 
        min_ind = which(na_count %in% min(na_count))
        
        #### START OF CONDITIONALS ####
        # If there is only one site with minimum NA's:
        if (length(min_ind) == 1) {
          min_site = websites[[min_ind]]
          other_sites = websites[-min_ind]
          true_vector = c()
          # Compares year of least NA's to other websites
          # if year matches either of the other sites, writes 'least NA' to CSV
          for(k in 1:length(other_sites)){
            if (other_sites[[k]][1] == min_site[1]){
              true_vector = c(true_vector, TRUE)
            } else {
              true_vector = c(true_vector, FALSE)
            }
          }
          if (TRUE %in% true_vector){
            df$final_year[i] = min_site[1]
            df$final_month[i] = min_site[2]
            df$final_day[i] = min_site[3]
          } 
        }  
        
        if ((length(min_ind) > 1) || (!(TRUE %in% true_vector))) {
          # If mutiple sites with same # of NA's, checks for aggrement on dates 
          match_count = c()
          for(n in 1:length(websites[min_ind])){
            if(websites[min_ind][n] %in% websites[min_ind][-n]){
              match_count = c(match_count, TRUE)
            } else {
              match_count = c(match_count, FALSE)
            }
          }
          if (TRUE %in% match_count){
            match_ind = which(match_count %in% TRUE)
            matching_site = websites[min_ind][match_ind][1]
            # If at least 2 dates match, writes that date to CSV 
            df$final_year[i] = matching_site[[1]][1]
            df$final_month[i] = matching_site[[1]][2]
            df$final_day[i] = matching_site[[1]][3]
          } else {
            # If sites don't match, identifies one with earliest date 
            websites[min_ind]
            year_vec = c()
            month_vec = c()
            day_vec = c()
            
            for(p in 1:length(websites[min_ind])){
              # creates vecotr for each date field (Y/m/d)
              year_vec = c(year_vec, websites[min_ind][p][[1]][1])
              month_vec = c(month_vec, websites[min_ind][p][[1]][2])
              day_vec = c(day_vec, websites[min_ind][p][[1]][3])
              if(length(min(year_vec)) == 1){
                # Checks for date with earliest Year
                earliest_year_ind = which(year_vec %in% (min(year_vec)))
                earliest_year = websites[min_ind][earliest_year_ind]
                df$final_year[i] = earliest_year[[1]][1]
                df$final_month[i] = earliest_year[[1]][2]
                df$final_day[i] = earliest_year[[1]][3]
              } else if (length(min(month_vec)) == 1){
                # Checks for date with earliest Month
                earliest_month_ind = which(month_vec %in% (min(month_vec)))
                earliest_month = websites[min_ind][earliest_month_ind]
                df$final_year[i] = earliest_month[[1]][1]
                df$final_month[i] = earliest_month[[1]][2]
                df$final_day[i] = earliest_month[[1]][3]
              } else {
                # Checks for date with earliest Day
                earliest_day_ind = which(day_vec %in% (min(day_vec)))
                earliest_day = websites[min_ind][earliest_day_ind]
                df$final_year[i] = earliest_day[[1]][1]
                df$final_month[i] = earliest_day[[1]][2]
                df$final_day[i] = earliest_day[[1]][3]
              }
            }
          }
          
        }
        
        #### END OF CONDITIONALS ####
      }    
    }
  }
}

write.csv(df, paste0(gsub(".csv","", CSV_NAME), "_postprocessed.csv"), row.names=F, na="")
