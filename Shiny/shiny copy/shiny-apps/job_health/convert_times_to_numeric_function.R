require('stringr')

convert_times_to_numeric <- function(x){
  
  dash.pattern.short='[0-9]{2}[-][0-9]{2}[-][0-9]{2}' # yy/mm/dd verify
  dash.pattern.long='[0-9]{4}[-][0-9]{2}[-][0-9]{2}' # yyyy/mm/dd verify
  slash.pattern.short='[0-9]{2}[/][0-9]{2}[/][0-9]{2}' # mm/dd/yy verify
  slash.pattern.long='(1[0-2]|[1-9])[/]([1-3][0-9]|[1-9])[/][0-9]{2}' # mm/dd/yyyy
  
  if(!is.null(x)){
    # mm/dd/yyyy
    if(str_detect(x,slash.pattern.long)) { # WORKS
      if(str_detect(x,'[0-9]{2}:[0-9]{2}:[0-9]{2}')){ # with seconds
        y <- as.numeric(strptime(x,"%m/%d/%Y %H:%M:%S",tz='UTC'))
      } else { # w/o seconds
        y <- as.numeric(strptime(x,"%m/%d/%Y %H:%M",tz='UTC'))
      }
    } else { # WORKS
      if(str_detect(x,'[0-9]{2}:[0-9]{2}:[0-9]{2}')){ # with seconds
        y <-as.numeric(strptime(x,"%m/%d/%y %H:%M:%S",tz='UTC'))
      } else { # w/o seconds
        y <- as.numeric(strptime(x,"%m/%d/%y %H:%M",tz='UTC'))
      }
    }
  } else{ # $started_at cases
    y <- as.numeric(strptime(x,"%Y-%m-%d %H:%M",tz='UTC'))
  }
  return(y)
}
