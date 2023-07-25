## Job Heart Monitor
## May 11, 2014
## 5 min job health
source('../.env')

require('shiny')
require('datasets')
require('data.table')
require('plyr')
require('stringr')
require('reshape2')
require('stringr')
library('XML')
library('rjson')
require('rCharts')

source('check_for_judgments.R')
source('get_job_data.R')
source('get_unit_data.R')
source('get_user_ids.R')
source('get_channel_data.R')
source('get_judgment_data.R')
source('db_call_function.R')
source('run_this_query_function.R')
source('work_available_query_function.R')
source('payrate_satisfaction_query_function.R')
source('dropout_rate_query_function.R')
source('find_cml_elements.R')
source('velocity_violations_query_function.R')
source('everyone_available_query_function.R')
source('worker_stats_query_function.R')
source('unit_gold_functions.R')
source('assignment_duration_query_function.R')
source('convert_times_to_numeric_function.R')

temp_dir = "/tmp/job_health"

system(paste('mkdir -p',temp_dir))

options(stringsAsFactors = F)
options(shiny.maxRequestSize=150*1024^2)
options(scipen=999)

auth_key = CF_SHINY_APPS_API_KEY

db_call = db_call(connection_file = "builder_readonly")
#count html instructions length
instructions_length <- function(json_instructions){ 
  
  inst_array = unlist(lapply(strsplit(json_instructions, 
                                      split="\n")[[1]], function(x) strsplit(x, " ")))
  inst_clean = inst_array[str_detect(inst_array, pattern="\\w+")]
  word_count = length(inst_clean)
  return(word_count)
}

replace_null <- function(x){
  if(is.null(x)){
    x <- "NULL"
  }
  
  if(length(x) == 0){
    x <- "none"
  }
  return(x)
}

replace_blanks <- function(x){
  if(is.null(x)){
    x = "blank"
  }
  return(x)
}

shinyServer(function(input, output){
  
  output$renderLogo <- renderText({
    image_path = "http://cf-public-view.s3.amazonaws.com/coolstuff/electrical-heart-monitor.jpg"
    html_image = paste("<img src=", image_path, " width=\"80%\"/>", sep="")
    paste(html_image)
  }) 
  
  output$createJobHyperlink <- renderText({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = job_id = input$job_id
      link = paste('https://make.crowdflower.com/jobs/', job_id, sep="")
      html = paste('<a target="_blank" href="', link, '">Go To Jobs Page</a>', sep="")
      paste(html)
    }
  })
  
  pull_judgment_count <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if(job_id == 0){
        return(NULL)
      }else{
        print("In pull_judgment_count server") 
        db = db_call
        query = check_for_judgments(job_id)
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="judgments_count_")
        data = run_this_query(db, query, file)
        
        data
      }
    } 
  })
  
  bool_no_judgments_check <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if(job_id == 0){
        return(NULL)
      }else{
        count_file = pull_judgment_count()
        #count = count_file$count
        no_judgments = "false"
        
        if(count_file == "0"){
          no_judgments = "true"
        }
        
        no_judgments
      }
    }
  })
  
  pull_channel_data <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if(job_id == 0){
        return(NULL)
      }else{
        print("In pull_channel_data server")
        db = db_call
        query = get_channel_data(job_id) 
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="builder_channels_")
        data = run_this_query(db, query, file)
        data
      }
    } 
  })
  
  pull_worker_stats <- reactive({
    if(input$get_job == 0 ||  input$job_id == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      print("In pull_worker_stats server 107")
      db = db_call
      query = worker_stats_query(job_id)
      file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="worker_stats_")
      data = run_this_query(db, query, file)
      
      data[is.na(data)] <- c("")
      
      data
    }
  })
  
  pull_judgment_data <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if (job_id == 0) {
        return(NULL)
      }else{
        print("in pull_judgment_data server line")
        db = db_call
        query = get_judgment_data(job_id) 
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="builder_judgments_")
        data = run_this_query(db, query, file)
        data
        
      }
    }
  })
  
  pull_unit_data <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if (job_id == 0) {
        return(NULL)
      }else{
        print("in pull_unit_data server line 127")
        db = db_call
        query = get_unit_data(job_id) 
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="builder_units_")
        data = run_this_query(db, query, file)
        data
        
      }
    }
  })
  
  pull_gold_data <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if (job_id == 0) {
        return(NULL)
      }else{ 
        print("in pull_gold_data server line 153")
        psql = "psql -h cf-redshift.etleap.com -U matt_crowdflower -d matt_crowdflower -p 5439 -A -F\",\" -c "
        query = paste("select id, '\\\"' + replace(cast(data as varchar), '\\\"','\\\"\\\"') + '\\\"' from builder_units where state=6 and job_id =", 
                      job_id, sep="")
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="builder_golds_")
        command = paste(psql, '"', query, '"', ' > ', file)
        system(command)
        units_back = read.csv(file)
        units_back = units_back[-nrow(units_back),]
        units_back
      }
    }
  })
  
  pull_speed_violations <- reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      print("in pull_speed_violations server line 143")
      db = db_call
      query = velocity_violations_query(job_id)
      file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="speed_violations_")
      
      data = run_this_query(db, query, file)
      data
    } 
  })
  
  pull_answer_flags <- reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      worker_stats = pull_worker_stats()
      print("in pull_answer_flags server line 158")
      data = worker_stats[worker_stats$answer_distribution_flags == 1,c("worker_id", "flag_reason")]
      data
    } 
  })
  
  pull_trust_taints <- reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      worker_stats = pull_worker_stats()
      print("in pull_trust_taints server line 171")
      data = worker_stats[worker_stats$trust_taint == 1, c("worker_id", "golden_trust")]
      data
    } 
  })
  
  pull_everyone_tainted <- reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      worker_stats = pull_worker_stats()
      print("in pull_everyone_tainted server line 183")
      data = worker_stats[worker_stats$tainted == 't' | worker_stats$tainted == 'true' | worker_stats$flagged_at != "",
                          c("worker_id", "tainted", "flagged_at", "rejected_at", 
                            "flag_reason", "golden_trust")]
      data
    } 
  })
  
  pull_work_available <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if(job_id == 0){
        return(NULL)
      }else{
        db = db_call
        query = work_available_query()
        print("In pull_work_available Server 201")
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="work_available_")
        data = run_this_query(db, query, file)
        data
      } 
    }
  })
  
  #   pull_payrate_satisfaction <- reactive({
  #     if(input$get_job == 0){
  #       return(NULL)
  #     }else{
  #       job_id = input$job_id
  #       if(job_id == 0){
  #         return(NULL)
  #       } else {
  #         db = db_call
  #         query = payrate_satisfaction_query(job_id)
  #         print("In pull_payrate_satisfaction Server 220")
  #         file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="payrate_satisfaction_")
  #         data = run_this_query(db, query, file)
  #         data
  #       } 
  #     }
  #   })
  
  pull_dropout_rate <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if(job_id == 0){
        return(NULL)
      } else {
        db = db_call
        query = dropout_rate_query(job_id)
        print("In pull_dropout_rate Server 238")
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="dropout_rate_")
        data = run_this_query(db, query, file)
        
        data
      } 
    }
  })
  
  get_cml_fields <- reactive({
    if (input$get_job == 0  || input$job_id == 0) {
      return(NULL)
    } else {
      job_json = get_job_settings_from_json()
      print("In get_cml_fields Server 247")
      cml = job_json$cml
    }
  })
  
  get_history_from_json <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      print("In get_history_from_json server 261")
      command = paste0("curl -X GET http://crowdflower.com/jobs/",
                       input$job_id,
                       "/history.json?key=",
                       auth_key)
      
      history_get = paste(system(command, intern=T), collapse="")
      history = fromJSON(json_str = history_get, unexpected.escape="skip")
      return(history)
    }
  })
  
  get_number_checked_out <- reactive({
    if (input$get_job == 0 || input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      job_id = input$job_id
      worker_stats = pull_worker_stats()
      print("In get_number_checked_out server 280")
      data = sum(worker_stats$no_judgments==1)
      data
    }
  })
  
  pull_user_ids <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      history = get_history_from_json()
      y <- list()
      for(i in 1:length(history)){ 
        y <- append(y, history[[i]]$user_id, after=length(y))
      }
      
      users = unique(y)
      db = db_call
      query = get_user_ids(users)
      print("In pull_user_ids server 298")
      file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="builder_users_")
      data = run_this_query(db, query, file)
      data
    }
    
  })
  
  get_state_counts <- reactive({
    if (input$get_job == 0 || input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      maxed_out = as.numeric(get_num_maxed_out())
      if(is.na(maxed_out)) {
        maxed_out = 0
      }
      workers_with_judgments = pull_judgment_counts()
      print("In get_state_counts server 317")
      workers_with_judgments = workers_with_judgments[workers_with_judgments$tainted != 't' & workers_with_judgments$tainted != 'true' & workers_with_judgments$flagged_at == "",]
      
      max_work_setting = as.numeric(get_max_setting())
      if (max_work_setting!= Inf) { 
        workers_with_judgments = workers_with_judgments[workers_with_judgments$judgments_count < max_work_setting,]
      }
      working = nrow(workers_with_judgments)
      
      if(is.na(working)){
        working = 0
      }
      
      tainted = sum(pull_tainted_breakdown_data()$y)
      if(is.na(tainted)){
        tainted = 0
      }
      
      checked_out = as.numeric(get_number_checked_out())
      if(is.na(checked_out)){
        checked_out = 0
      }
      
      all_available_workers = as.numeric(get_everyone_available())
      if(is.na(all_available_workers)){
        all_available_workers = 0
      }
      
      
      not_in_yet = max(0,all_available_workers - (maxed_out + working + tainted + checked_out))
      all_v = c(maxed_out, working, tainted, checked_out, not_in_yet)
      return(all_v)
    }
  })
  
  get_job_settings_from_json <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      command = paste0("curl https://api.crowdflower.com/v1/jobs/",
                       input$job_id,
                       ".json?key=",
                       auth_key)
      print("In get_job_settings_from_json server 360")
      json_get = paste(system(command, intern=T), collapse="")
      parsed_json = fromJSON(json_str = json_get, unexpected.escape="skip")
      return(parsed_json)
    }
  })
  
  get_units_from_json <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      print("in get_units_from_json server")
      command = paste("curl -X GET https://api.crowdflower.com/v1/jobs/",
                      input$job_id,
                      "/units.json?key=",
                      auth_key, sep="")
      json_get = paste(system(command, intern=T), collapse="")
      parsed_json = fromJSON(json_str = json_get, unexpected.escape="skip")
      
      return(parsed_json)
    }  
  })
  
  
  get_max_setting <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      print("In get_max_setting server 373")
      if (is.null(get_job_settings_from_json()$max_judgments_per_worker) && 
            is.null(get_job_settings_from_json()$max_judgments_per_ip)) {
        this_max = Inf
      } else {
        this_max = min(get_job_settings_from_json()$max_judgments_per_worker,
                       get_job_settings_from_json()$max_judgments_per_ip)
      }
      return(this_max)
    }
  })  
  
  get_max_setting_correct <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      print("In get_max_setting_correct server 389")
      job_json = get_job_settings_from_json()
      num_golds = as.numeric(job_json$golds_count) # TODO for now, just pull the setting. get real number later
      units_per_task = as.numeric(job_json$units_per_assignment)
      gold_per_task = as.numeric(job_json$gold_per_assignment)
      golds_in_quiz_mode = as.numeric(job_json$options$after_gold)
      
      if (gold_per_task > 0) {
        max_correct = floor(((num_golds-golds_in_quiz_mode) / gold_per_task * units_per_task))
      } else {
        max_correct = Inf
      }
      return(max_correct)
    }
  })
  
  
  get_num_maxed_out <- renderText({
    if (input$get_job == 0 || input$job_id == 0){
      return(NULL)
    } else {
      print("In get_num_maxed_out server 410")
      max_work_setting = as.numeric(get_max_setting())
      workers_with_work = pull_judgment_counts()
      
      workers_who_maxed_out = 
        workers_with_work[workers_with_work$judgments_count >= max_work_setting,]
      
      num_maxed_out = nrow(workers_who_maxed_out)
      return(num_maxed_out)
    }
  })
  
  get_everyone_available <- reactive ({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      job_id = input$job_id
      print("in get_everyone_available server 428")
      db = db_call
      json = get_job_settings_from_json()
      skill_vector = names(json$minimum_requirements$skill_scores)
      
      country_include_vector = unlist(
        lapply(json$included_countries, function(x) x$code)
      )
      
      country_exclude_vector =  unlist(
        lapply(json$excluded_countries, function(x) x$code)
      )
      
      min_required_skills = json$minimum_requirements$min_score
      query = everyone_available_query(skills = skill_vector,
                                       countries_include = country_include_vector,
                                       countries_exclude = country_exclude_vector,
                                       min_score = min_required_skills)
      
      
      file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="everyone_available_")
      data = run_this_query(db, query, file)
      #data = read.csv(paste0(temp_dir,"/",
      #                       "everyone_available_385528_May_23_15:38:15_2014.csv"))
      #data= data[1,]
      data
    }
  })
  
  output$tput_bar <- renderChart({
    if (input$get_job == 0 || input$job_id==0) {
      # User has not uploaded a file yet
      p1 <- rCharts::Highcharts$new()
      p1$addParams(dom = 'tput_bar')
      return(p1)
    } else {
      print("in output$tput_bar server 464")
      job_id = input$job_id
      states = c("maxed out", "working",
                 "tainted","checked_out", "not_in_yet")
      div_names = c("maxed_out_div",
                    "working_div",
                    "tainted_div",
                    "checked_out_div",
                    "not_in_yet_div")
      colors = c('#043322', #dark green,
                 '#24E85A',#light green,
                 '#FF6B3C',#red,
                 '#00A1E8',#blue,
                 '#C4CDFF' #grey
      )
      state_counts = get_state_counts() 
      responses_table_transformed = data.frame(group=states,
                                               y = state_counts, # these are the numbers found in groups
                                               x=rep(as.character(job_id),times=5), # this is a fake grouping variable
                                               series_order = 5:1,
                                               legend_order = 1:5,
                                               color_vector = colors,
                                               info = c("<b>Maxed out</b>",
                                                        "<b>Active workers who can still make more judgments</b>",
                                                        "<b>Tainted workers</b>",
                                                        "<b>Checked the job out, didn't make judgments</b>",
                                                        "<b>Never entered the job</b>"), # this is a vector of html vars describing tooltips
                                               click_action = div_names
      )
      
      
      data_list = lapply(split(responses_table_transformed, responses_table_transformed$legend_order),
                         function(x) {
                           res <- lapply(split(x, rownames(x)), as.list)
                           names(res) <- NULL
                           return(res)
                         })
      
      h1 <- rCharts::Highcharts$new()
      invisible(sapply(data_list, function(x) {
        h1$series(data = x, type = "bar", name = x[[1]]$group, index=x[[1]]$series_order, legendIndex=x[[1]]$legend_order,
                  color = x[[1]]$color_vector)
      }
      ))
      
      h1$plotOptions(
        series = list(
          stacking = "normal",
          pointWidth = 300,
          minPointLength = 5,
          cursor = 'pointer',
          events = list(
            # click = "#! function() { alert('You just clicked the graph'); } !#") # simplest test
            # this.options.data[0] then column name to access data
            # click = "#! function() { window.open(this.options.data[0].click_action); } !#")
            #
            # hide all elements, then show the one corresponding to the bar
            click = "#! function() { 
            var my_divs = document.getElementsByClassName('bar_divs');
            for (var i = 0; i < my_divs.length; i++) {
            my_divs[i].style.display= 'none';
            }
            document.getElementById(this.options.data[0].click_action).style.display='block'; } !#")
        )
      )
      
      h1$tooltip(useHTML = T, 
                 formatter = "#! function() { return('<b>' +  this.point.y + '</b><br>' + this.point.info )} !#")
      
      h1$addParams(dom = 'tput_bar')
      return(h1)
      
    }
    
  })
  
  history_table <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      
      history = get_history_from_json()
      users = pull_user_ids()
      print("in history_table server 549")
      dates = names(history) # convert this to posixt objects later
      order_frame = data.frame(date = dates, index = 1:length(dates))
      # order dates to understand how you would go through the list
      order_frame = order_frame[order(order_frame$date),]
      
      all_changes = data.frame(time = "", author = "", author_email = "", what = "", from="", to = "")
      
      for (i in order_frame$index){
        change_ids = c()
        change_from = list()
        change_to = list()
        this = history[[i]]
        meta_data = c(this$`_id`$`$oid`, this$created_at, this$event, this$user_id, this$job_id)
        event_data = paste(unlist(this$event_data), "")
        x1 = this$before_update
        x2 = this$after_update
        all_names = unique(c(names(x1), names(x2)))
        for (n in all_names) {
          if (!is.null(x1[[n]]) && !is.null(x2[[n]]) && 
                length(x1[[n]]) > 0 && length(x2[[n]]) > 0){
            if (!identical(x1[[n]],x2[[n]])) {
              if (is.list(x1[[n]]) || is.list(x2[[n]])) {
                els1 = x1[[n]]
                els2 = x2[[n]]
                all_names_again = unique(c(names(els1), names(els2)))
                for (k in all_names_again){
                  if (!identical(els1[[k]],els2[[k]])){
                    change_ids = paste(n,":", k)
                    change_from = paste(unlist(els1[[k]]), collapse=" ; ")
                    change_to = paste(unlist(els2[[k]]), collapse=" ; ")
                    all_changes = rbind(all_changes, 
                                        data.frame(time = order_frame$date[i],
                                                   author = this$user_id,
                                                   author_email = users$email[users$id == this$user_id],
                                                   what = change_ids, 
                                                   from = change_from, to = change_to))
                    
                  }
                }
              } else {
                change_ids = paste(n)
                change_from = paste(x1[[n]], collapse = " ; ")
                change_to = paste(x2[[n]], collapse = " ; ")
                all_changes = rbind(all_changes, 
                                    data.frame(time = order_frame$date[i],
                                               author = this$user_id,
                                               author_email = users$email[users$id == this$user_id],
                                               what = change_ids, 
                                               from = change_from, to = change_to))
                
              }
            }
          }
        }	
      }
      all_changes
    }
  })
  
  output$renderHistory <- renderDataTable({
    if (input$get_job == 0 || input$job_id == 0){
      #no job id chosen
      return(NULL)
    }else{
      ###remove instruction changes...too BIG
      print("in output$renderHistory server 617")
      make_history = history_table()
      make_history
    }
  })
  
  output$maxed_out_summary <- renderText({
    if (input$get_job == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      line1 = "<div class=\"bar_divs well\" id=\"maxed_out_div\" style=\"display: none;\">"
      title ="<h4>Maxed Out</h4>"
      num_maxed_out = get_num_maxed_out()
      max_setting = get_max_setting()
      max_setting_correct = get_max_setting_correct()
      
      print("in output$maxed_out_summary server 634")
      overview = paste0(num_maxed_out," workers have maxed out")
      comment = "(This means that they cannot do any more work)"
      max_work_line = paste("Max work per worker is set to:",max_setting)
      
      max_possible_line = paste("This job's params would allow for a work limit of:",max_setting_correct)
      rec_line = "The gist is:<br>"
      
      if (max_setting == Inf) {
        
        if (max_setting_correct == Inf) {
          
          response = "There are no Test Questions in this job. 
                      Technically, workers can work as much as they want to. 
                      We'd recommend setting a reasonable max work limit."
        } else  {
          
          response = paste("Max work limit is not set. This is not good news.
                         Set the limit to",max_setting_correct,"or lower.")
        }
      } else if (max_setting_correct == Inf) {
        response = "There are no Test Questions in this job. 
        Technically, workers can work as much as they want to. 
        We'd recommend setting a reasonable max work limit."
      } else if (max_setting_correct <= max_setting) {
        response = paste("The work limit is set too high! Set it to <b>", max_setting_correct, "</b>or lower immediately")
      } else if (max_setting_correct > max_setting) {
        response = paste("The work limit can be safely increased to <b>", 
                         max_setting_correct,
                         "</b>.")
      } else {
        response ="Something weird has happened. We've got nothing to say."
      }
      
      last_line = paste(rec_line,response)
      closing_div = "</div>"
      summary = paste(line1, title, overview, comment, max_work_line, 
                      max_possible_line, last_line, closing_div, sep="<br>")
      paste(summary)
    }
  })
  
  output$job_summary_message <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("<p>No job data to return.</p>")
    } else {
      #Data to grab
      json = get_job_settings_from_json()
      units = pull_unit_data()
      
      print("in output$job_summary_message server 685")
      #Variables to Display
      job_title = json$title 
      job_state = json$state
      
      inprogress_new_units = units[units$state < 6,]
      
      enabled_golds = units[units$state == 6,]
      disabled_golds = units[units$state == 7,]
      
      canceled_units = units[units$state == 8,]
      finalized_units = units[units$state == 9,]
      
      num_gold_units = nrow(enabled_golds)
      num_disabled_golds = nrow(disabled_golds)
      num_finalized_units = nrow(finalized_units)
      num_new_units = nrow(inprogress_new_units)
      num_canceled_units = nrow(canceled_units)
      
      if(num_canceled_units > 0){
        canceled_message = paste("<li>Canceled Units: ", num_canceled_units, "</li>")
      } else {
        canceled_message = ""
      }
      
      if(num_disabled_golds > 0){
        tq_message = paste("<li> Enabled TQs: ", num_gold_units, "</li>",
                           "<li> Disabled TQs:", num_disabled_golds, "</li>")
      } else {
        tq_message = paste("<li> Test Questions: ", num_gold_units, "</li>")
      }
      
      overall_message = paste("<h5>Job Summary</h5>",
                              "<ul class=\"unstyled\"><li>Job Title:<br>", job_title, "</li><br>",
                              "<li>State: ", job_state, "</li>",
                              "<li>Finalized Units: ", num_finalized_units, "</li>",
                              "<li>In Progress &amp; New Units: ", num_new_units, "</li>",
                              canceled_message, tq_message,
                              "</ul>", sep="")
      
      paste(overall_message)
    } 
  })
  
  output$job_settings_message <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      #Data to grab
      json = get_job_settings_from_json()
      channels = pull_channel_data()
      
      print("in output$job_settings_message server 738")
      #Max Work Settings
      #mjw = json$max_judgments_per_worker
      #mjip = json$max_judgments_per_ip
      
      #Skills Required
      skill_names = paste(replace_null(names(json$minimum_requirements$skill_scores)), collapse=", ")
      
      included_countries <- sapply(json$included_countries, function(x){
        item = x$name
        item
      })
      
      excluded_countries <- sapply(json$excluded_countries, function(y){
        item = y$name
        item
      })
      
      targeted_countries = paste(replace_null(included_countries), collapse=", ")
      removed_countries = paste(replace_null(excluded_countries), collapse=", ")
      
      #min account age
      min_age = replace_null(json$minimum_account_age_seconds)
      if(min_age != "NULL"){
        min_age = min_age/(86400)
      }
      
      #Units and Payments
      upa = json$units_per_assignment
      ppt = json$payment_cents
      
      #Check for certain Channels
      if(length(grep("cf_internal", channels$channel_name)) > 0){ 
        internal_message = paste("Internal Channel: Enabled <br>")
      } else{
        internal_message = paste("Internal Channel: Disabled <br>")
      }
      
      if(length(grep("clixsense", channels$channel_name)) > 0){ 
        clixsense_message = paste("Clixsense: Enabled <br>")
      } else{
        clixsense_message = paste("Clixsense: Disabled <br>")
      }
      
      if(length(grep("prodege", channels$channel_name)) > 0){ 
        probux_message = paste("Probux: Enabled <br>")
      } else{
        probux_message = paste("Probux: Disabled <br>")
      }
      
      if(length(grep("neodev", channels$channel_name)) > 0){ 
        neobux_message = paste("Neobux: Enabled <br>")
      } else{
        neobux_message = paste("Neobux: Disabled <br>")
      }
      
      channels_message = paste(internal_message, neobux_message, probux_message, clixsense_message)
      
      
      #Number of Channels
      num_channels = length(channels$channel_name)
      
      countries_message = paste("<h5>Countries Overview</h5><p>",
                                "Targeted Countries: ", targeted_countries,
                                "<br><br>Excluded Countries: ", removed_countries, 
                                "</p>", sep="")
      
      channels_message = paste("<h5>Channels Overview</h5><p>",
                               "Number of Channels Enabled: ", 
                               num_channels, "<br>",
                               channels_message, "</p>", sep="")
      
      skills_other_message = paste("<h5>Skill &amp; Age Requirements</h5><p>",
                                   "Skills: ", skill_names, "<br>", 
                                   "Minimum Account Age (in days): ", min_age, "</p>", sep="")
      
      pay_message = paste("<h5>Payment Settings</h5><p>",
                          "Payment in Cents per Task: ", ppt,
                          "<br>Units per Task: ", upa, "</p>", sep="")
      
      overall_message = paste("<div class=\"span3\">", channels_message, pay_message, "</div><div class=\"span4\">", countries_message,
                              "</div><div class=\"span5\">", skills_other_message, "</div>", sep="")
      
      paste(overall_message)
    } 
  })
  
  output$alerts_summary <- reactive ({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>Awaiting Job ID to pull, make sure to press Submit.</p>")
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        no_judgments_message = paste("<div class=\"alert alert-info\"><p><b>We've detected that this job has yet to collect any judgments.</b>
                                     <br>Many of this apps features require at least a few judgments to be helpful. However you can still check
                                     the Throughput bar Graph under Throughput Analysis as well as the Settings Summary table in the sidebar
                                     panel to the left.</p></div>")
        alerts = alerts_truncated_table()
      } else {
        alerts = all_alerts_table()
        no_judgments_message = ""
      }
      
      print("in output$alerts_summary server 828")
      
      if(alerts[["inst_alert"]] == "long"){
        inst_summary = "<div class=\"alert\"><h4>TL;DR Warning:</h4>
        <p>Your instructions are quite long.<br> See <b>Throughput Analysis &gt; Job Suggestions</b> for more about this issue.</p></div>"
      } else if(alerts[["inst_alert"]] == "short") {
        inst_summary = "<div class=\"alert\"><h4>Edge Case Warning</h4>
        <p>Your instructions are on the short side.<br> See <b>Quality Analysis &gt; Job Suggestions</b> for more about information on this.</p></div>"
      } else {
        inst_summary = paste("<div class=\"alert alert-success\"><h4>Instructions Length Warning</h4><p> Good Job! We believe the instructions are 
                             of a reasonable length for a micro-task.</p>",
                             "<p>Instructions Word Count: <b>", alerts[["length_inst"]],
                             "</b><br> Suggested Word Count: <b>100 - 1,000</b> words</p></div>", sep="")
      }
      
      if(alerts[["unit_alert"]] == "long"){
        task_summary = "<div class=\"alert\"><h4>Long Task Warning:</h4>
        <p>We detected quite a few required fields per task.<br> See the <b>Throughput Analysis &gt; Job Suggestions</b> for more information about this.</p></div>"
      } else if(alerts[["unit_alert"]] == "short") {
        task_summary = "<div class=\"alert\"><h4>Short Task Warning:</h4>
        <p>We've noticed that you do not have very many required fields per task.<br> See <b>Quality Analysis &gt; Job Suggestions</b> for more about this.</p></div>"
      } else {
        task_summary = paste("<div class=\"alert alert-success\"><h4>Task Length Warning</h4><p> Good Job! We believe the are 
                             a reasonable amount of required fields for a micro-task.</p>",
                             "<p>Number of Required Flags per Task: <b>", alerts[["vpa"]],
                             "</b><br> Suggested Word Count: <b>5 - 20</b> words</p></div>", sep="")
      }
      
      if(alerts[["pay_alert"]] == "over"){
        pay_summary = paste("<div class=\"alert\"><h4>Over Payment Warning:</h4>
                            <p>We believe you might be overpaying for this type of task.<br> See <b>Quality Analysis &gt; Job Suggestions</b> for a suggested Pay per Task.</p></div>")
      } else if(alerts[["pay_alert"]] == "under") {
        pay_summary = paste("<div class=\"alert\"><h4>Under Payment Warning:</h4>
                            <p>We think you need to pay a little more for this task.<br> See <b>Throughput Analysis &gt; Job Suggestions</b> to further understand this problem.</p></div>")
      } else {
        pay_summary = paste("<div class=\"alert alert-success\"><h4>Payment per Task Warning</h4><p> Good Job! Based on the requirements
                            to complete this job you are paying an acceptable amount.</p>",
                            "<p>Actual Payment per Task: <b>", alerts[["actual_pay"]],
                            "</b><br> Suggested Payment per Task: <b>", alerts[["suggested_pay"]],
                            "</b></p></div>", sep="")
      }
      
      if(alerts[["strict_reject"]] != "none"){
        reject_summary = "<div class=\"alert alert-error\"><h4>Strict Minimum Accuracy</h4>
        <p>Your Minimum Accuracy setting might be too strict. See<br> <b>Throughput Analysis &gt; Contributor Concerns</b> for more details.</p></div>"
      }else{
        reject_summary = paste("<div class=\"alert alert-success\"><h4>Strict Minimum Accuracy Warning</h4><p> Good Job! Based on the Minimum Test Questions
                               setting we believe the Minimum Accuracy setting will not effect good contributors.</p>",
                               "<p>Minimum Accuracy: <b>", alerts[["reject_at"]],
                               "</b><br> Minimum Test Questions: <b>", alerts[["after_gold"]],
                               "</b></p></div>", sep="")
      }
      
      if(alerts[["after_gold_alert"]] == "big_quiz"){
        after_gold_summary = "<div class=\"alert alert-error\"><h4>Big Minimum Test Questions in Quiz/Work Mode</h4>
        <p>We noticed that the Minimum Test Questions is set larger than a single task.<br> See <b>Throughput Analysis &gt; Contributor Concerns</b> the effect of this.</p></div>"
      } else if (alerts[["after_gold_alert"]] == "small_quiz"){
        after_gold_summary = "<div class=\"alert alert-error\"><h4>Small Minimum Test Questions in Quiz/Work Mode</h4>
        <p>We noticed that the Minimum Test Questions is set smaller than a single task.<br> See <b>Quality Analysis &gt; Job Setting Concerns</b> for the effect of this.</p></div>"
      } else {
        after_gold_summary = paste("<div class=\"alert alert-success\"><h4>Minimum Test Question</h4><p> Good Job! Based on the task
                                   size and quiz mode settings we believe you have the correct amount of Minimum TQs..</p>",
                                   "<p>Minimum Test Questions: <b>", alerts[["after_gold"]],
                                   "</b></p></div>", sep="")
      }
      
      if(alerts[["mjw_alert"]] == "true"){
        mjw_summary = "<div class=\"alert alert-error\"><h4>Max Judgments per Contributor Disabled</h4>
        <p>This setting appears to be missing. We suggest that you enable it. 
        <br>See <b>Throughput Analysis &gt; Maxed Out Graph Summary</b> for instructions on how best to set this.</p></div>"
      } else {
        mjw_summary = paste("<div class=\"alert alert-success\"><h4>Max Judgments per Contributor Enabled</h4><p> Well Done!
                            It looks like you did remember to set Max Judgments per Contributor. Check the Throughput bar 
                            graph to see if you've set this optimally.</p>",
                            "<p>Max Judgments per Contributor: <b>", alerts[["mjw"]],
                            "</b></p></div>", sep="")
      }
      
      if(alerts[["mjip_alert"]] == "true"){
        mjip_summary = "<div class=\"alert alert-error\"><h4>Max Judgments per IP Disabled</h4>
        <p>This setting appeats to be missing. We suggest that you enable it. 
        We suggest this be equal to or at most double the Max Judgments per Contributor setting.</p></div>"
      } else {
        mjip_summary = paste("<div class=\"alert alert-success\"><h4>Max Judgments per Contributor Enabled</h4><p> Well Done!
                             It looks like you did remember to set Max Judgments per IP. We suggest that you make sure this
                             settings is inline with Max Judgments per Worker (equal to or at most double that value).</p>",
                             "<p>Max Judgments per IP: <b>", alerts[["mjip"]],
                             "</b></p></div>", sep="")
      }
      
      if(alerts[["skill_alert"]] == "true"){
        skill_summary = "<div class=\"alert alert-error\"><h4>No Level Crowd Detected</h4>
        <p>We did not detect a leveled crowd being used. For the sake of quality we suggest you use at least level 1 contributors.</p></div>"
      } else {
        skill_summary = paste("<div class=\"alert alert-success\"><h4>Level Crowds Enabled</h4><p> Well Done!
                              You remembered to select a level crowd.</p>",
                              "<p>Required Skills: <b>", alerts[["skill_names"]],
                              "</b></p></div>", sep="")
      }
      
      if(alerts[["qm_alert"]] == "true"){
        qm_summary = "<div class=\"alert alert-error\"><h4>Quiz Mode Disabled</h4>
        <p>Quiz Mode is not on in this task. Unless this task is without Test Questions or a special case we suggest you enable Quiz Mode.</p></div>"
      } else {
        qm_summary = paste("<div class=\"alert alert-success\"><h4>Quiz Mode Enabled</h4><p> Good Choice!
                           We always suggest that you use quiz mode when applicable.</p></div>", sep="")
      }
      
      
      if(check_judgments == "true" || alerts[["no_golds_alert"]] != "true"){
        no_golds_summary = ""
      }else{
        no_golds_summary = "<div class=\"alert alert-error\"><h4>No Test Questions</h4>
        <p>There are no test questions in this job.<br> See <b>Quality Analysis &gt; Test Question Quality Concerns</b> for more information about this warning.</p></div>" 
      } 
      
      if(check_judgments == "true" || alerts[["three_alert"]] != "true"){
        three_alert_summary = ""
      } else {
        three_alert_summary = "<div class=\"alert alert-error\"><h4>Completions Under 3 Seconds</h4>
        <p>There are contributors completing units in under 3 seconds.<br> See the 
        <b>Quality Analysis &gt; Times Quality Concerns</b> section and graph for more information on these contributors.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["top_quarter_judg_alert"]]!= "true"){
        top_quarter_summary = ""
      } else {
        top_quarter_summary = "<div class=\"alert alert-error\"><h4>Fastest 25% Contributing 40%+ of the Judgments</h4>
        <p>We noticeds that the fastest contributors are submitting much more judgments.<br> See the <b>Quality Analysis &gt; Times Quality Concerns</b>
        section for how to deal with this.</p></div>"
      }
      
      if(alerts[["too_small_alert"]] == "true"){
        too_small_summary = "<div class=\"alert alert-error\"><h4>Small Contributor Pool</h4>
        <p>You may need to target more contributors.<br> See <b>Throughput Analysis &gt; Contributor Suggestions and bar graph</b>
        for more details on this issue.</p></div>"
      } else {
        too_small_summary = ""
      }
      
      if(check_judgments == "true" ||  alerts[["failure_alert"]] != "true"){
        failure_summary = ""
      } else {
        failure_summary = "<div class=\"alert alert-error\"><h4>High Failure Rate</h4>
        <p>Many contributors are failing out of this task.<br> See <b>Throughput Analysis &gt; Contributor Concerns and bar graph</b> about how they are failing.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["maxed_alert"]] != "true"){
        maxed_summary = ""
      } else {
        maxed_summary = "<div class=\"alert alert-error\"><h4>Many Maxed Out Contributors</h4>
        <p>Quite a few contributors have reached max work and can no longer work in the task.<br> See <b>Throughput Analysis &gt; Maxed Out Graph Summary</b>
        to make sure you've set this optimally.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["viable_alert"]] != "true"){
        viable_summary = ""
      } else {
        viable_summary = "<div class=\"alert\"><h4>Dwindling Active Contributors</h4>
        <p>Not many active contributors are left.<br> See <b>Throughput Analysis &gt; bar graph</b> for the exact number.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["lookers_alert"]] != "true"){
        lookers_summary = ""
      } else {
        lookers_summary = "<div class=\"alert\"><h4>High Drop Out Rate</h4>
        <p>Many contributors are not working very long on this task. 
        <br>Check on their progress in <b>Throughput Analysis &gt; bar graph</b>.</p></div>"
      } 
      
      if(check_judgments == "true" || alerts[["dont_care_alert"]] != "true"){
        dont_care_summary = ""
      } else {
        dont_care_summary = "<div class=\"alert\"><h4>Many Not Reached</h4>
        <p>A large group of contributors have not attempted to enter the task.
        <br> See <b>Throughput Analysis &gt; Contibutor Suggestions</b> section for how to fix this.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["few_golds_alert"]] != "true"){
        few_golds_summary = ""
      } else {
        few_golds_summary = "<div class=\"alert alert-error\"><h4>Not Enough Test Questions</h4>
        <p>Given the number of units in the job you may want to increase the number of enabled Test Questions. 
        <br>See <b>Quality Analysis &gt; Job Test Question Concerns</b> for a suggested amount.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["tq_missed_alert"]] != "true"){
        tq_missed_summary = ""
      } else {
        tq_missed_summary = "<div class=\"alert alert-error\"><h4>Highly Missed Test Questions</h4>
        <p>We detected a large portion of highly missed test questions. 
        <br> See <b>Quality Analysis &gt; Table of Missed &amp; Contested TQs</b> to investigate which ones are troublesome.</p></div>"
      }
      
      if(check_judgments == "true" || alerts[["tq_contested_alert"]] != "true"){
        tq_contested_summary = ""
      }else{
        tq_contested_summary = "<div class=\"alert alert-error\"><h4>Highly Contested Test Questions</h4>
        <p>We detected a large number of highly contested Test Questions.<br> See <b>Quality Analysis &gt; Table of Missed &amp; Contested TQs</b> for more information on those test questions.</p></div>"
      }
      
      all_summary = paste(no_judgments_message, mjw_summary, mjip_summary, skill_summary, qm_summary, 
                          reject_summary, after_gold_summary, no_golds_summary, 
                          tq_contested_summary, tq_missed_summary, three_alert_summary, 
                          top_quarter_summary, too_small_summary, failure_summary,
                          maxed_summary, few_golds_summary, viable_summary, dont_care_summary, 
                          lookers_summary, pay_summary, inst_summary, task_summary, sep="")
    }
  })
  
  make_reject_at_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_reject_at_button")
      reject_at_button = paste("<button id=\"call_reject_at\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Update Minimum Accuracy</button>")
      reject_at_button
    }
  })
  
  output$throughput_errors <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>Awaiting Data.</p>")
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        return("<p>We cannot detect any throughput errors at this time since the job has yet to collect any judgmets (trusted, untrusted, quiz mode).</p>")
      } else {
        alerts = all_alerts_table()
        print("In output$throughput_errors server 1016")
        
        after_gold_button = make_after_gold_button()
        reject_at_button = make_reject_at_button()
        
        #reject_at = json$options$reject_at
        if(alerts[["too_small_alert"]] == "true"){
          too_small = paste("<p><i class=\"icon-minus-sign\"></i><u>Small Contributor Pool</u>: Consider broadening your target (more countries, levels, etc) 
                          or resetting your throughput expectations.<br><br> There are only <b>", alerts[["num_available"]], "</b> workers available to complete this task.</p>")
        } else {
          too_small=""
        }
        
        if(alerts[["failure_alert"]] == "true"){
          failure_message = paste("<p><i class=\"icon-remove-sign\"></i><u>Percent Tainted</u>: Check on the Test Questions and the Minimum Accuracy setting.<br><br><b>",
                                  alerts[["percent_tainted"]], "%</b> of all contributors who entered the job are tainted.</p>", sep="")
        } else {
          failure_message = ""
        }
        
        if(alerts[["maxed_alert"]] == "true"){
          maxed_message = paste("<p><i class=\"icon-resize-full\"></i><u>Percent Maxed</u>: If the job is not near to finishing you may want to add more TQs or up the max judgments settings.<br><br><b>", 
                                alerts[["percent_maxed"]], "%</b> of in task contributors have maxed out.</p>", sep="")
        } else {
          maxed_message = ""
        }
        
        if(alerts[["after_gold_alert"]] == "big_quiz"){
          after_gold_message = paste("<p><i class=\"icon-qrcode\"></i><u> Weird After Gold Setting</u>: Careful, your Minimum Questions in Quiz Mode is 
          greater than the size of a Quiz Mode Task. This means contributors could get through to work more before
          we calculate their accuracy.<br>", after_gold_button, "</p>", sep="")
        } else {
          after_gold_message = ""
        }
        
        if(alerts[["strict_reject"]] == "strict_quiz"){
          strict_reject_message = paste("<p><i class=\"icon-asterisk\"></i><u>Strict Minimum Accuracy Setting</u>: We suggest that you lower the Minimum Accuracy otherwise
        you could lose a lot of good contributors.<br><br>Minimum Accuracy: <b>", alerts[["reject_at"]], 
                                        "</b><br>Number of TQs Needed To Pass: <b>", alerts[["after_gold"]], "</b><br>Suggested Minimum Accuracy: <b>",
                                        alerts[["suggested_reject_at"]], "</b><br>", reject_at_button, "</p>", sep="")
        }else if (alerts[["strict_reject"]] == "strict_work"){
          strict_reject_message = paste("<p><i class=\"icon-asterisk\"></i><u> Strict Minimum Accuracy Setting</u>: We suggest that you lower the Minimum Accuracy otherwise
        you could lose a lot of good contributors and your job could become costly.<br><br>", "Minimum Accuracy: <b>", alerts[["reject_at"]], 
                                        "</b><br>Number of Correct TQs Needed To Continue: <b>", alerts[["after_gold"]], "</b><br>Suggested Minimum Accuracy: <b>",
                                        alerts[["suggested_reject_at"]], "</b><br>", reject_at_button, "</p>", sep="")
        } else {
          strict_reject_message = ""
        }
        
        if(too_small == "" && failure_message == "" && maxed_message == "" && after_gold_message == "" && strict_reject_message == ""){
          paste("<div class=\"alert alert-success\"><p><i class=\"icon-ok\"></i>
              <big>Throughput Contributor Concerns:</big>
              <br>We did not detect any throughput concerns<br></p>",
                "<ul class=\"unstyled\"><li> Number Available: <b>", alerts[["num_available"]],
                "</b></li><li> Percent Tainted: <b>", alerts[["percent_tainted"]],
                "%</b></li><li> Percent Maxed Out: <b>", alerts[["percent_maxed"]],
                "%</b></li></ul></div>", sep="")
        } else {
          paste("<div class=\"alert alert-error\">", "<p><big>Throughput Contributor Concerns:</big></p>",
                too_small, failure_message, maxed_message, after_gold_message, strict_reject_message, "</div>")
        }
      }
    } 
  })
  
  update_reject_at <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$call_reject_at == 0 || is.null(input$call_reject_at)) {
        return(NULL)
      } else {
        job_id = input$job_id
        print("in update_reject_at server")
        alerts = all_alerts_table()
        new_reject = alerts[["suggested_reject_at"]]
        
        command = paste("curl -X PUT --data-urlencode \"job[options][reject_at]=", new_reject,
                        "\" https://api.crowdflower.com/v1/jobs/",
                        job_id, ".json?key=", auth_key, sep="")
        
        return(command)
      }
    }
  })
  
  output$updateRejectAt <- renderText ({
    if (input$get_job == 0 || input$job_id == 0 || input$call_reject_at == 0 || is.null(input$call_reject_at)) {
      return(NULL)
    } else {
      print("in output$updateRejectAt server")
      command = update_reject_at()
      system(command, intern=T)
      paste("Minimum Accuracy has been updated.")
    }
  })
  
  output$throughput_warnings <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("<p>Waiting for Data.</p>")
    } else {
      judgments_check = bool_no_judgments_check()
      if(judgments_check == "true"){
        return("<p>We do not have any suggestions to increase the throughput. Use the throughput bargraph below to see how many contributors 
               you are targetting. <br><b>IF the task is running and there are plenty of workers available</b> the job may be suffering
               from a task wall malfunction.</p>")
      }else{
        job_id = input$job_id
        
        alerts = all_alerts_table()
        print("In output$throughput_warnings server 1083")
        
        click_task_settings = paste("<a target=\"blank\" href=\"https://make.crowdflower.com/jobs/", 
                                    job_id, "/settings/task\"><b>Click Here to Update Task Payments or Size</b></a>", sep="")
        add_click = ""
        
        if(alerts[["viable_alert"]] == "true"){
          viable_message = paste("<p><u>Dwindling Active Group</u>: <b>", alerts[["percent_viable"]], 
                                 "%</b> of the contributors who entered the task are still eligible to complete work.</p>", sep="")
        } else {
          viable_message = ""
        }
        
        if(alerts[["lookers_alert"]] == "true"){
          lookers_message = paste("<p><u>Percent Dropouts:</u> You may want to up the Payment per Task or broaden your contributor target.<br><br><b>", 
                                  alerts[["percent_check_out"]], "%</b> of contributors who entered the task only looked at the task and did not submit judgments.</p>", sep="")
        } else {
          lookers_message = ""
        }
        
        if(alerts[["dont_care_alert"]] == "true"){
          dont_care_message = paste("<p><u>Percent Not Reached:</u> You may want to increase the pay or make the job a little easier.<br><br><b>", 
                                    alerts[["percent_dont_care"]], "%</b> of eligible contributors did not attempt to enter the task.</p>", sep="")
        } else {
          dont_care_message = ""
        }
        
        if(alerts[["pay_alert"]] == "under"){
          under_pay_message = paste("<p><u>Under Payment Warning</u>: Please consider increasing the contributor pay or 
                            decreasing the assignment size.</p>", "<p>Current Pay per Task: <b>", 
                                    alerts[["actual_pay"]], "</b><br>Suggested Pay per Task: <b>", alerts[["suggested_pay"]], "</b></p>")
        } else {
          under_pay_message = ""
        }
        
        if(alerts[["inst_alert"]] == "long"){
          long_instructions_message = paste("<p><u>TLDR Warning</u>: We suggest breaking  it down into simplier jobs or add essential tips and tricks into the task itself.</p>",
                                            "<p>Instructions Word Count: <b>", alerts[["length_inst"]],
                                            "</b><br>Suggested Word Count: <b>100 - 1,000</b></p>", sep="") 
        } else {
          long_instructions_message = ""
        }
        
        if(alerts[["unit_alert"]] == "long"){
          long_task_message = paste("<p><u>Long Task Warning</u>: You may want to decrease the Units per Task. 
                           <br><small>If this is an image moderations type task you may ignore this message.</small></p>", 
                                    "<p>Number of Required Fields per Task: <b>", 
                                    alerts[["vpa"]],"</b><br>Suggested Number of Required Fields: <b>5 - 20</b></p>", sep="")
        } else {
          long_task_message = ""
        }
        
        if(long_task_message != "" || under_pay_message != ""){
          add_click = click_task_settings
        }
        
        if(viable_message == "" && lookers_message == "" && 
             dont_care_message == "" && under_pay_message == "" && long_instructions_message == "" && long_task_message == ""){
          paste("<div class=\"alert alert-success\"><p>
              <i class=\"icon-ok\"></i>
              <big>Throughput Contributor Suggestions/FYIs:</big>
              <br>We do not have any suggestions at this time. Make sure to review any issues in the Throughput
              Contributor Concerns section above.</p><ul class=\"unstyled\"><li>Percent Active: <b>", alerts[["percent_viable"]],
                "%</b></li><li>Percent Dropouts: <b>", alerts[["percent_check_out"]],
                "%</b></li><li> Percent Not Reached: <b>", alerts[["dont_care_alert"]],
                "%</b></li></ul></div>", sep="")
        } else {
          paste("<div class=\"alert\">", "<p><big>Throughput Contributor Suggestions/FYIs:</big></p>",
                viable_message, lookers_message, dont_care_message,
                under_pay_message, long_instructions_message, long_task_message, add_click, "</div>")
        }
      }
    }
  })
  
  output$settingsTable <- renderDataTable({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>Waiting for job JSON.</p>")
    } else {
      json = get_job_settings_from_json()
      print("In output$settingsTable server 1154")
      
      included_countries <- sapply(json$included_countries, function(x){
        item = x$name
        item
      })
      
      excluded_countries <- sapply(json$excluded_countries, function(y){
        item = y$name
        item
      })
      
      
      name = c("included countries", "excluded countries", "max judgments per worker",
               "max judgments per ip", "track aliases", "require worker login", "flag on rate limit",
               "desired requirements", "minimum account age seconds", "minimum requirements",
               "judgments per unit", "min unit confidence", "expected judgments per unit",
               "variable judgments mode", "max judgments per task", "confidence fields", 
               "units per task", "pages per task", "payment cents per task", 
               "task expiration seconds", "auto order", "units remained finalized", 
               "critical webhook", "auto order threshold", "auto order timeout", 
               "design verified", "project number", "quiz mode",
               "minimum test questions in job", "test questions per task", 
               "hide correct answers", "minimum accuracy")
      
      value = c(paste(replace_null(included_countries), collapse="\n"),
                paste(replace_null(excluded_countries), collapse="\n"), 
                replace_null(json$max_judgments_per_worker),
                replace_null(json$max_judgments_per_ip),
                replace_null(json$options$track_clones),
                replace_null(json$require_worker_login),
                replace_null(json$options$flag_on_rate_limit),
                replace_null(json$desired_requirements), 
                replace_null(json$minimum_account_age_seconds),
                paste(replace_null(names(json$minimum_requirements$skill_scores)), collapse="\n"),
                json$judgments_per_unit, replace_null(json$min_unit_confidence), 
                replace_null(json$expected_judgments_per_unit), 
                replace_null(json$variable_judgments_mode),
                replace_null(json$max_judgments_per_unit), 
                paste(replace_null(json$confidence_fields), collapse="\n"),
                json$units_per_assignment, replace_null(json$pages_per_assignment), 
                json$payment_cents, replace_null(json$options$req_ttl_in_seconds),
                replace_null(json$auto_order), replace_null(json$units_remain_finalized),
                replace_null(json$options$critical_webhook), replace_null(json$auto_order_threshold),
                replace_null(json$auto_order_timeout), replace_null(json$design_verified), 
                replace_null(json$project_number), replace_null(json$options$front_load),
                replace_null(json$options$after_gold), replace_null(json$gold_per_assignment),
                replace_null(json$options$hide_correct_answers), replace_null(json$options$reject_at)
      )
      
      location = c(rep("behavior settings", times=10), rep("task/judgment settings", times=17), 
                   rep("tq settings", times=5))
      
      tags = c(rep("quality, language, survey", times=2), 
               rep("quality, speed, critical", times=2), 
               "quality, speed, critical, internal, survey",
               "quality, throughput", 
               "speed, quality", 
               "deprecated, skills", 
               "quality, throughput", 
               "skills, quality, throughput",
               "task, cost, critical",
               "variable",
               "cost, estimate, variable",
               "variable",
               "variable",
               "variable, confidence, cml",
               "task, cost, critical",
               "admin, deprecated",
               "cost, price, critical, throughput",
               "task, throughput, contributors",
               rep("api, webhook", times=5),
               "throughput, contributors",
               "task",
               "test questions, gold, quiz, cost",
               "after_gold, test questions, task, quality, cost",
               "task, test questions, gold, quality",
               "regex, test questions, gold",
               "reject_at, test questions, gold, quality, cost")
      
      
      settings <- cbind(location, tags, name, value)
      settings = as.data.frame(settings)
      settings
      
    } 
  }, options = list(aLengthMenu = c(7, 10, 15, 20), iDisplayLength = 7, 
                    oSearch = list( bCaseInsensitive = TRUE)))
  
  enabled_golds_table <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      units = pull_unit_data()
      print("In enabled_golds_table server")
      enabled_golds = units[units$state == 6,]
      #disabled_golds = units[units$state == 7,]
      if(is.null(enabled_golds) || nrow(enabled_golds) == 0){
        return(NULL)
      } else{
        enabled_golds$missed_percent = enabled_golds$missed_count/enabled_golds$judgments_count
        enabled_golds$contested_percent = enabled_golds$contested_count/enabled_golds$missed_count
        
        for(i in 1:nrow(enabled_golds)){
          if(enabled_golds$missed_count[i] == 0 & enabled_golds$contested_count[i] > 0){
            enabled_golds$contested_percent[i] = 0  
          }
        }
        
        enabled_golds
      }
    }
  })
  
  enabled_golds_content_table <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      job_id = input$job_id
      enabled_golds = enabled_golds_table()
      print("In enabled_golds_content_table server")
      
      if(is.null(enabled_golds) || nrow(enabled_golds) == 0){
        return(NULL)
      } else{
        
        highly_missed = enabled_golds[enabled_golds$missed_percent > .67,]
        highly_contested = enabled_golds[enabled_golds$contested_percent > .50,]
        
        highly_missed_contested = rbind(highly_missed, highly_contested)
        highly_missed_contested = highly_missed_contested[!is.na(highly_missed_contested$id),]
        
        
        if(!is.null(highly_missed_contested) && nrow(highly_missed_contested) != 0 && !is.na(highly_missed_contested$id)){
          
          gold_data = pull_gold_data()
          
          gold_json = lapply(gold_data$X.column., function(x){
            gold_json = fromJSON(x)
          })
          
          gold_columns = names(gold_json[[1]])
          grab_answers = matrix(, nrow = length(gold_json), ncol = length(gold_columns))
          
          for(i in 1:length(gold_json)){
            gold_content = gold_json[[i]]
            for(j in 1:length(gold_columns)){
              col_name = gold_columns[j]
              grab_answers[i,j] = replace_blanks(paste(gold_content[[col_name]], collapse=" or "))
            } 
          }
          grabs = as.data.frame(grab_answers)
          
          for(i in 1:length(gold_columns)){  
            colnames(grabs)[i] <- gold_columns[i]
          }
          gold_id = gold_data$id
          grabs = cbind(gold_id, grabs)
          
          gold_answer_values = merge(highly_missed_contested, grabs, by.x = "id", by.y = "gold_id")
          
          drop = c("state", "agreement", "replace", "_golden")
          gold_answer_values = gold_answer_values[,!(names(gold_answer_values) %in% drop)]
          
          ##Add link to table
          for(i in 1:nrow(gold_answer_values)){
            gold_answer_values$id[i] = paste("<a target=\"_blank\" href=\"https://crowdflower.com/jobs/", job_id, "/golds/", 
                                             gold_answer_values$id[i], "/edit\">", gold_answer_values$id[i], "</a>", sep="") 
          }
          gold_answer_values = gold_answer_values[order(gold_answer_values$missed_count, decreasing=T),] 
          gold_answer_values
        } else{
          return(NULL)
        }
      }
    }
  })
  
  output$missedContestedTable <- renderDataTable({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      #input$tab
      print("In output$missedContestedTable server")
      display_table = enabled_golds_content_table()
      
      if(!is.null(display_table) && nrow(display_table) != 0 && !is.na(display_table$id)){
        display_table = display_table[order(display_table$missed_count, decreasing=T),] 
        display_table
      } else{
        return(NULL)
      }
    }
  })
  
  
  ###Quality Warnings
  output$quality_gold_errors <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>Waiting to pull builder_units.</p>")
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        return("<p>This tab requires that the job has already collected a few judgments. If you are worried about job settings
               see the Job Settings Table to the left. If you are worried about settings related to throughput see the Throughput Bar under
               the Throughput Analysis tab.</p>")
      }else{
        #Grab Flags and Feedback
        alerts = all_alerts_table()
        print("In output$quality_gold_errors server 1307")
        if(alerts[["no_golds_alert"]] != "true"){
          
          #More than 19% of golds are missed +67% of the time
          if(alerts[["tq_missed_alert"]] == "true"){
            tq_missed_message = paste("<p><i class=\"icon-edit\"></i><u>Highly Missed TQ's</u>: 
                                    We would update them before digging into Quality too much.<br><br><b>",
                                      alerts[["num_highly_missed"]], " </b>Test Questions are missed +67% of the time.</p>")
          } else {
            tq_missed_message = ""
          }
          
          #More than 19% of golds are contested +50% of the time
          if(alerts[["tq_missed_alert"]] == "true"){
            tq_contested_message = paste("<p><i class=\"icon-edit\"></i><u>Highly Contested TQ's</u>: 
                                       You may want to check some of the highly contested test questions.<br><br><b>",
                                         alerts[["num_highly_contested"]], " </b>Test Questions have been contested by more than half of contributors
                                       who missed them.</p>")
          } else{
            tq_contested_message = "" 
          }
          
          #Enough Golds
          #wrt number of units for every 100 units there should be AT LEAST 10 units.
          if(alerts[["few_golds_alert"]] == "true"){
            enough_golds_message = "<p><i class=\"icon-list-alt\"></i><u>Too Few TQs</u>: Careful. There are very few golds given the number of units."
            suggest_golds_message = paste("<br><br>We suggest you have <b>100</b> test questions. You'll need to add <b>",
                                          alerts[["suggest_golds"]], "</b> more TQs.</p>")
            enough_golds_message = paste(enough_golds_message, suggest_golds_message, sep="")
          } else {
            enough_golds_message = ""
          }
          
          if(tq_missed_message == "" && enough_golds_message == "" && tq_contested_message == ""){
            paste("<p class=\"alert alert-success\"><i class=\"icon-ok\"></i>
                <big>Test Question Quality Concerns:</big><br>We did not detect any issues with TQs.", 
                  "<br>Number of enabled TQs:", alerts[["num_golds"]],
                  "<br>Number Highly Missed:", alerts[["num_highly_missed"]],
                  "<br>Number Highly Contested:", alerts[["num_highly_contested"]],"</p>")
          } else {
            paste("<div class=\"alert alert-error\">", "<p><big>Test Question Quality Concerns:</big></p>",
                  tq_missed_message, tq_contested_message, enough_golds_message, "</div>")
          }  
        } else {
          paste("<h4 class=\"alert alert-error\"> We've detected no enabled Test Questions in this task. Unless this
              is a survey or a content creation job we highly suggest you use Test Questions.</h4>")
        }
      }
    }
  })
  
  output$quality_times_warnings <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>No job data to return.</p>")
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        return("")
      }else{
        #Alers to Grab
        #input$tab
        alerts = all_alerts_table()
        print("In output$quality_times_warnings server 1363")
        
        summary = paste("<p>Fastest Time: <b>", alerts[["fiver_one"]], "</b><br> Slowest Time: <b>", alerts[["fiver_five"]],
                        "</b><br> Average Time: <b>", alerts[["fiver_three"]],
                        "</b><br> Lower Quartile Time:<b> ", alerts[["fiver_two"]], "</b><br><small>*in seconds</small></p>", sep="")
        
        if(alerts[["top_quarter_judg_alert"]] == "true"){
          top_quarter_judg_message = paste("<p>Over 40% of total judgments are coming from the top 25% fastest workers.</p>", "<p>Total Judgments: <b>", 
                                           alerts[["total_judgments"]], "</b><br> Top 25's Total Judgments: <b>", 
                                           alerts[["num_judgments_fast_quarter"]], "</b><br>",
                                           "Total Number Workers: <b>", alerts[["total_workers_times"]], 
                                           "</b><br>Top 25 Total Workers: <b>", alerts[["num_top_25_workers"]],
                                           "</b></p>")
        } else {
          top_quarter_judg_message = ""
        }
        
        if(alerts[["three_alert"]] == "true"){
          three_message = paste("<p>We found <b>", alerts[["num_workers_under_three"]], "</b> contributors completing a judgment in 3 seconds or less!</p>", sep="")
        } else {
          three_message = ""
        }
        
        if(three_message == "" & top_quarter_judg_message == ""){
          paste("<div class=\"alert alert-success\"<p><i class=\"icon-ok\"></i>
              <big>Completion Times Concerns:</big>
              <br><small>*Newest section, still under construction</small>
              <br>We did not detect any speed demons in this task.</p>", summary, 
                "</div>")
          
        } else{
          paste("<div class=\"alert alert-error\"><p><big>Completion Times Concerns:</big><br>
              <small>*Newest section, still under construction</small></p>",
                three_message, top_quarter_judg_message, "</div>")
        }
      }
    }
  })
  
  make_qm_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_qm_button server")
      qm_button = paste("<button id=\"call_qm\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Enable Quiz Mode</button>")
      qm_button
    }
  })
  
  make_after_gold_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_after_gold_button server")
      after_gold_button = paste("<button id=\"call_after_gold\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Update Minimum TQs Seen</button>")
      after_gold_button
    }
  })
  
  make_mjw_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_mjw_button server")
      mjw_button = paste("<button id=\"call_mjw\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Update Max Judgments per Worker</button>")
      mjw_button
    }
  })
  
  make_mjip_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_mjip_button server")
      mjip_button = paste("<button id=\"call_mjip\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Update Max Judgments per IP</button>")
      mjip_button
    }
  })
  
  
  make_skills_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      skill_button = paste("<button id=\"call_skills\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Use Level 1 Contributors</button>")
      skill_button
    }
  })
  
  output$quality_settings_warnings <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        return("<p><b>It seems this job has yet to collect any judgments</b></p>")
      }else{
        #Data to grab
        job_id = input$job_id
        alerts = all_alerts_table()
        click_tq_settings = paste("<a target=\"_blank\" href=\"https://make.crowdflower.com/jobs/", 
                                  job_id, "/settings/test_questions\"><b>Click Here to Update TQ Settings</b></a><br>", sep="")
        qm_button = make_qm_button()
        after_gold_button = make_after_gold_button()
        mjw_button = make_mjw_button()
        mjip_button = make_mjip_button()
        #skill_button = make_skills_button()
        
        click_skills = paste("<a target=\"_blank\" href=\"https://make.crowdflower.com/jobs/", 
                             job_id, "/settings/skills\"><b>Click Here to Add a Level Crowd</b></a><br>", sep="")
        
        click_behavior = paste("<a target=\"_blank\" href=\"https://make.crowdflower.com/jobs/", 
                               job_id, "/settings/behavior\"><b>Click Here to Add Max Judgment Settings</b></a><br>", sep="")
        
        
        print("In output$quality_settings_warnings server 1443")
        mj_message_overall = ""
        quiz_message_overall = ""
        skill_message_overall = ""
        
        if (alerts[["mjw_alert"]] == "true"){
          mjw_message = paste("<p><i class=\"icon-resize-small\"></i><u>No Max Judgments per Contributor</u>: 
                             Whoa. The max work per judgments setting is empty. This means contributors can 
                             be in the job for as long as they want and have the opportunity to learn TQ's.<br>",
                              mjw_button, "</p>")
        } else {
          mjw_message = ""
        }
        
        if (alerts[["mjip_alert"]] == "true") {
          mjip_message = paste("<p><i class=\"icon-resize-small\"></i><i class=\"icon-warning-sign\"></i>
                             <u>No Max Judgments per IP:</u> Ah oh. There is no Max Work per IP set.
                             This means someone coming from one IP can contribute work with many contributor IDs.<br>",
                               mjip_button, "</p>")
        } else {
          mjip_message = ""
        }
        
        if(mjip_message != "" || mjw_message != ""){
          mj_message_overall = paste(mjw_message, mjip_message, click_behavior, sep="")
        }
        
        
        if(alerts[["qm_alert"]] == "true"){
          qm_message = paste("<p><i class=\"icon-pencil\"></i><u>Quiz Mode Disabled</u>: Is that on purpose?
                           We highly recommend you use Quiz Mode.<br>",
                             qm_button, "</p>", sep="")
        } else {
          qm_message=""
        }
        
        if(alerts[["after_gold_alert"]] == "small_quiz"){
          small_quiz_message = paste("<p><i class=\"icon-qrcode\"></i><u> Weird After Gold Setting</u>: Since the Minimum Questions in Quiz Mode is less 
                                   than the size of a Quiz Mode Task contributors could be exposed to normal units within
                                   Quiz Mode.<br><br>Minimum Questions in Quiz Mode: <b>", alerts[["after_gold"]], "</b><br> Size of QM Task: <b>",
                                     alerts[["upa"]], "</b><br>Suggested Minimum Questions in Quiz Mode: <b>", 
                                     alerts[["upa"]], "</b><br>", after_gold_button,"</p>", sep="")
        } else {
          small_quiz_message = ""
          
        }
        
        if(qm_message != "" || small_quiz_message != ""){
          quiz_message_overall = paste(qm_message, small_quiz_message, click_tq_settings, sep="") 
        }
        
        if(alerts[["skill_alert"]] == "true"){
          skill_message = paste("<p><i class=\"icon-filter\"></i><u>No Leveled Crowd</u>: Hmmm. We highly recommend you use a levelled crowd for all jobs.",
                                "<br><u> Detected Skills</u>:", alerts[["skill_names"]], "</p>")
          skill_message_overall = paste(skill_message, click_skills, sep="")
        } else {
          skill_message = ""
        }
        
        if(mjw_message == "" && mjip_message == "" && skill_message == "" && qm_message == "" && small_quiz_message == ""){
          paste("<div class=\"alert alert-success\"><p><i class=\"icon-ok\"></i>
              <big>Job Settings Concerns:</big>
              <br>We did not detect any issues with the current job settings.</p>
              <ul class=\"unstyled\"><li>Max Judgments per Contributor: <b>", alerts[["mjw"]],
                "</b></li><li> Max Judgments per IP: <b>", alerts[["mjip"]],
                "</b></li><li> Skill Requirements: <b>", alerts[["skill_names"]],
                "</b></li><li> Quiz Mode: <b>", alerts[["quiz_mode"]],
                "</b></li><li> Minimum Test Questions: <b>", alerts[["after_gold"]],
                "</b></li><li> Minimum Accuracy: <b>", alerts[["reject_at"]],
                "</b></li></ul></div>", sep="")
        } else{
          paste("<div class=\"alert alert-error\">", "<p><big>Job Settings Quality Concerns:</big></p>", 
                mj_message_overall, quiz_message_overall, skill_message_overall, "</div>")
        }
      }
    }
  })
  
  enable_quiz_mode <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$call_qm == 0 || is.null(input$call_qm)) {
        return(NULL)
      } else {
        job_id = input$job_id
        command = paste("curl -X PUT --data-urlencode \"job[options][front_load]=true\" https://api.crowdflower.com/v1/jobs/",
                        job_id, ".json?key=", auth_key, sep="")
        print("in enable_quiz_mode line 1550")
        return(command)
      }
    }
  })
  
  output$enableQuiz <- renderText ({
    if (input$get_job == 0 || input$job_id == 0 || input$call_qm == 0 || is.null(input$call_qm)) {
      return(NULL)
    } else {
      command = enable_quiz_mode()
      print("in output$enableQuizCommand  line 1561")
      system(command, intern=T)
      paste("Quiz Mode Enabled")
    }
  })
  
  update_after_gold <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$call_after_gold == 0 || is.null(input$call_after_gold)){
        return(NULL)
      } else {
        job_id = input$job_id
        alerts = all_alerts_table()
        new_after_gold = alerts[["upa"]]
        
        command = paste("curl -X PUT --data-urlencode \"job[options][after_gold]=", new_after_gold,
                        "\" https://api.crowdflower.com/v1/jobs/", job_id, ".json?key=", auth_key, sep="")
        print("in update_after_gold line 1566")
        return(command)
      }
    }
  })
  
  output$updateAfterGold <- renderText ({
    if (input$get_job == 0 || input$job_id == 0) {
      return(NULL)
    } else {
      if( input$call_after_gold == 0 || is.null(input$call_after_gold)){
        return(NULL)
      } else {
        command = update_after_gold()
        print("in output$updateAfterGold line 1586")
        system(command, intern=T)
        paste("Minimum Test Questions has been updated.")
      }
    }
  })
  
  update_mjw <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$call_mjw == 0 || is.null(input$call_mjw)) {
        return(NULL)
      } else {
        job_id = input$job_id
        print("in update_mjw line 1611")
        alerts = all_alerts_table()
        new_mjw = get_max_setting_correct()
        
        if(new_mjw == Inf){
          new_mjw = alerts[["upa"]]
        }
        
        command = paste("curl -X PUT --data-urlencode \"job[max_judgments_per_worker]=", new_mjw,"\" https://api.crowdflower.com/v1/jobs/", job_id, ".json?key=", auth_key, sep="")
        
        return(command)
      }
    }
  })
  
  output$updateMjw <- renderText ({
    if (input$get_job == 0 || input$job_id == 0 || input$call_mjw == 0 || is.null(input$call_mjw)) {
      return(NULL)
    } else {
      command = update_mjw()
      print("in output$updateMjw line 1631")
      system(command, intern=T)
      paste("Max Judgments per Contributor has been updated")
    }
  })
  
  update_mjip <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$call_mjip == 0 || is.null(input$call_mjip)) {
        return(NULL)
      } else {
        job_id = input$job_id
        print("update_mjip line 1646")
        alerts = all_alerts_table()
        new_mjw = get_max_setting_correct()
        
        if(new_mjw == Inf){
          new_mjw = alerts[["upa"]]
        }
        new_mjip = 2 * new_mjw
        
        command = paste("curl -X PUT --data-urlencode \"job[max_judgments_per_ip]=", new_mjip,"\" https://api.crowdflower.com/v1/jobs/", job_id, ".json?key=", auth_key, sep="")
        return(command)
      }
    }
  })
  
  output$updateMjip <- renderText ({
    if (input$get_job == 0 || input$job_id == 0 || input$call_mjip == 0 || is.null(input$call_mjip)) {
      return(NULL)
    } else {
      command = update_mjip()
      print("output$updateMjip line 1666")
      system(command, intern=T)
      paste("Max Judgments per IP has been updated")
    }
  })
  
  update_pay <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$call_pay == 0 || is.null(input$call_pay)) {
        return(NULL)
      } else {
        job_id = input$job_id
        print("in update_pay server")
        alerts = all_alerts_table()
        new_pay = alerts[["suggested_pay"]]
        
        command = paste("curl -X PUT --data-urlencode \"job[payment_cents]=", new_pay,"\" https://api.crowdflower.com/v1/jobs/", job_id, ".json?key=", auth_key, sep="")
        return(command)
      }
    }
  })
  
  output$updatePay <- renderText ({
    if (input$get_job == 0 || input$job_id == 0 || input$call_pay == 0 || is.null(input$call_pay)) {
      return(NULL)
    } else {
      command = update_pay()
      print("output$updatePay")
      system(command, intern=T)
      paste("Payment in cents per Task has been updated")
    }
  })
  
  make_pay_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_pay_button server")
      pay_button = paste("<button id=\"call_pay\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Update Pay (cents) per Task</button>")
      pay_button
    }
  })
  
  make_upa_button <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      print("in make_upa_button server")
      upa_button = paste("<button id=\"call_upa\" type=\"button\" class=\"btn btn-primary action-button shiny-bound-input\">Update Units per Task</button>")
      upa_button
    }
  })
  
  output$quality_settings_cautions <- renderText({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>Waiting to pull job json.</p>")
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        return("")
      }else{
        job_id = input$job_id
        #Data to grab
        alerts = all_alerts_table()
        print("In output$quality_settings_cautions server 1471")
        
        click_task_settings = paste("<a target=\"blank\" href=\"https://make.crowdflower.com/jobs/", 
                                    job_id, "/settings/task\"><b>Click Here to Update Task Payments or Size</b></a>", sep="")
        add_click = ""
        pay_button = make_pay_button()
        upa_button = make_upa_button()
        
        if(alerts[["inst_alert"]] == "short"){
          short_inst_message = paste("<p><u>Edge Case Warning</u>: Are you sure you covered all your cases in the examples section of the instructions? 
                                   <small>You can ignore this warning if the task is a survey.</small></p>",
                                     "<p>Instructions Word Count: <b>", alerts[["length_inst"]],
                                     "</b><br>Suggested Word Count: <b>100 - 1,000</b></p>", sep="")
        } else {
          short_inst_message = ""
        } 
        
        if(alerts[["pay_alert"]] == "over"){
          over_pay_message = paste("<p><u>Over Payment Caution</u>: We believe you might be overpaying for this type of task.
                                 <br><small>If you are getting the results you want within your expected cost then you may ignore this message.</small></p>",
                                   "<p>Current Pay per Task: <b>", alerts[["actual_pay"]], "</b><br>Suggested Pay per Task: <b>", 
                                   alerts[["suggested_pay"]], "</b></br>", pay_button, "</p>", sep="")
        } else {
          over_pay_message = ""
        }
        
        if(alerts[["unit_alert"]] == "short"){
          short_task_message = paste("<p><u>Short Task Warning</u>: You may want to up the Units per Task setting to get more bang for your buck.</p>", 
                                     "<p>Number of Required Fields per Task: <b>", alerts[["vpa"]], "</b><br>Suggested Number of Required Fields: <b>5 - 20</b><br>",
                                     upa_button, "</p>", sep="")
        } else {
          short_task_message = ""
        }
        
        if(over_pay_message != "" || short_task_message != ""){
          add_click = click_task_settings
        }
        
        if(short_inst_message == "" && over_pay_message == "" && short_task_message == ""){
          paste("<div class=\"alert alert-success\"><p><i class=\"icon-ok\"></i>
              <big>Job Settings &amp; Design Suggestions/FYIs:</big>
              <br>We do not have any suggestions on approving job design. 
              Make sure to check the Job Settings Error section above before moving on.</p>",
                "</div>", sep="")
        } else {
          paste("<div class=\"alert\">", "<p><big>Job Settings &amp; Design Suggestions/FYIs:</big></p>", 
                over_pay_message, short_inst_message, short_task_message, add_click, "</div>")
        }
      }
    }
  })
  
  output$fastWorkerTable <- renderDataTable({
    if (input$get_job == 0 || input$job_id == 0) {
      return("<p>No job data to return.</p>")
    } else {
      judgments_check = bool_no_judgments_check()
      if(judgments_check == "true"){
        return("")
      } else{
        #input$tab
        job_id = input$job_id
        
        #Data to Grab
        workers_times = assignment_duration_agg()
        print("In output$fastWorkerTable server 1522")
        
        fiver = fivenum(workers_times$median_duration, na.rm=T)
        
        drop = c("start_time", "end_time", "unlog_mean_log_duration")
        
        workers_times = workers_times[,!(names(workers_times) %in% drop)]
        fast_quarter = workers_times[workers_times$median_duration <= fiver[2],]
        fast_quarter = fast_quarter[order(fast_quarter$median_duration),]
        
        if(nrow(fast_quarter) != 0){ 
          for(i in 1:nrow(fast_quarter)){
            fast_quarter$builder_worker_id[i] = paste("<a target=\"_blank\" href=\"https://crowdflower.com/jobs/", job_id, "/contributors/", 
                                                      fast_quarter$builder_worker_id[i], "\">", fast_quarter$builder_worker_id[i], "</a>", sep="") 
          }
          fast_quarter
        } else {
          return(NULL)
        }
      }
    }
  })
  
  output$quality_cautions <- renderText({
    #if (input$get_job == 0 || input$job_id == 0) {
    # User has not uploaded a file yet
    #  return("<p>No job data to return.</p>")
    #} else {
    #Data to Grab
    #grab scambot data
    
    i = 4
    j = 5
    print("In output$quality_cautions server 1554")
    #Just Paste Contentions
    if(i < j){
      contentions = "<p><u>Most Popular Contentions</u>: FYI, here are some of the popular contentions 
    we are seeing in this job.</p>"
    } else {
      contentions = ""
    }
    
    #Diverse Golds
    #look up given answers wrt possible values in JSON
    #if unique gold answers < .75(unique values)
    if(i < j){
      diverse_message = "<p><u>TQ Diversity</u>: It seems that your provided TQ answers do not encompass all of the provided values on some questions. 
    This might lead to misunderstandings; make sure to address any edge cases within instructions 
    and task design if they are not throughly explained through TQs.</p>"
    } else {
      diverse_message = ""
    }
    
    if(diverse_message == "" && contentions == ""){
      paste("<p class=\"alert alert-success\">
          <i class=\"icon-ok\"></i>
          <big>Quality Cautions:</big>
          <br>Your job is legit. We do not have any suggestions about Golds/Quality settings.</p>")
    } else {
      paste("<div class=\"alert\"><p><big>Quality Cautions:</big></p>",
            contentions, diverse_message, "</div>")
    }
    #}
  })
  
  output$not_in_yet_summary <- renderText({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      line1 = "<div class=\"bar_divs well\" id=\"not_in_yet_div\" style=\"display: none;\">"
      title ="<h4>Not in yet</h4>"
      job_json = get_job_settings_from_json()
      price_per_task = as.numeric(job_json$payment_cents)
      upa = as.numeric(job_json$units_per_assignment)
      price_per_unit = price_per_task/upa
      
      print("In output$not_in_yet_summary server 1598")
      ##### the graph
      h1 = price_available_plot()
      # you need to insert this as html/script, so the chart needs to be processed properly first
      price_chart_html = paste(capture.output(h1$show('inline')), collapse="")
      #####
      overview = paste0("Your job is currently paying ", price_per_task, 
                        " cents for a task of ", upa, " units",
                        " <b>(",round(price_per_unit,2)," cents per unit)</b>")
      comment = "<br>See if the pay is relatively high or low compared to active jobs in the last 2 hours:"
      recommendation = "If your job's pay is low compared to others, contributors may not find it very attractive. Consider raising your pay rate."
      TODO = "Put current pay on the graph. Better histogramming solution. 
    Charts get stuck when I turn off categories."
      closing_div = "</div>"
      price_piece = paste(overview, comment, price_chart_html, recommendation, sep="<br>")
      ###### the price piece ends
      ## complexity will potentially be here too
      summary = paste(line1, title, price_piece,
                      closing_div, sep="<br>")
      paste(summary)
    }
  })
  
  output$checked_out_summary <- renderText({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      line1 = "<div class=\"bar_divs well\" id=\"checked_out_div\" style=\"display: none;\">"
      title ="<h4>Checked the job out, made 0 judgments</h4>"
      job_json = get_job_settings_from_json()
      fields_in_job = job_json$confidence_fields
      num_fields_in_job = length(fields_in_job)
      cml = job_json$cml
      print("In output$checked_out_summary server 1632")
      
      text_fields = find_cml_elements(what_to_find=c("text", "textarea"),
                                      where_to_look=cml) #get_cml_fields()
      #####
      num_checked_out = get_state_counts()[4]
      worker_sum = paste0(num_checked_out, " workers saw your job but did not submit any judgments.<br>
                        This may be a technical issue or a complexity problem.")
      overview = paste0("Your job has ", num_fields_in_job, 
                        " questions in it. <br>", text_fields, " are text fields.")
      comment = "Jobs with many questions displayed at once may appear tideous. Text fields take more time than other fields. If there are 3 or more text questions, consider breaking the job down into multiple jobs, or raising the pay significantly."
      closing_div = "</div>"
      ## complexity will potentially be here too
      summary = paste(line1, title, worker_sum, 
                      overview,comment,
                      closing_div, sep="<br>")
      paste(summary)
    }
  })
  
  price_available_plot <-  reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      price_df = pull_work_available()
      job_json = get_job_settings_from_json()
      price_per_task = as.numeric(job_json$payment_cents)
      upa = as.numeric(job_json$units_per_assignment)
      price_per_unit = price_per_task/upa
      print("In price_available_plot server 1662")
      
      if (nrow(price_df) == 0) {
        for_plot1 = data.frame(active_workers = 1,
                               cent_groups = 1,
                               skills = 1)
      } else {
        for_plot = aggregate(data = price_df, active_workers ~ cents_per_unit + skills, FUN=sum)
        # find last 10 percent of 
        top_10 = quantile(for_plot$cents_per_unit, 0.9)
        for_plot_sub = for_plot[for_plot$cents_per_unit < top_10,]
        for_plot_cuts = as.numeric( 
          sub("[^,]*,([^]]*)\\]", "\\1", 
              as.character(cut(for_plot_sub$cents_per_unit, breaks=20))
          )
        )
        # make sure the current price is not too close to any of existing cutoffs
        unique_cuts = unique(for_plot_cuts)
        cut_diffs = abs(unique_cuts - price_per_unit)
        unique_cuts[cut_diffs < 0.3] = price_per_unit
        
        for_plot_cuts = unique(c(unique_cuts, price_per_unit, 0))
        
        for_plot_sub$cent_groups = as.numeric( 
          sub("[^,]*,([^]]*)\\]", "\\1", as.character(cut(for_plot_sub$cents_per_unit, breaks=for_plot_cuts))
          )
        )
        
        for_plot_sub$cent_labels = gsub(pattern="]", replacement = "",
                                        gsub(pattern = ",", replacement = " - ",
                                             gsub(pattern="\\(",replacement="",
                                                  as.character(cut(for_plot_sub$cents_per_unit, breaks=for_plot_cuts)))
                                        )
        )
        
        for_plot1 = aggregate(data=for_plot_sub, active_workers ~ cent_groups + cent_labels + skills, FUN=sum)
      }
      for_plot1$x = for_plot1$cent_groups
      for_plot1$y = for_plot1$active_workers
      
      data_list = lapply(split(for_plot1, for_plot1$skills),
                         function(x) {
                           res <- lapply(split(x, rownames(x)), as.list)
                           names(res) <- NULL
                           return(res)
                         }
      )
      
      h1 <- rCharts:::Highcharts$new()
      
      lapply(data_list, function(x) {
        h1$series(data=x, type = "column", name=x[[1]]$skills)
      }
      )
      
      h1$plotOptions(
        series = list(
          stacking = "normal",
          pointWidth = 10,
          type= "category")
      )
      h1$yAxis(title = list(text = "Active workers in other jobs"),
               plotlines = list(
                 list(value = 4000,color='red')
               )
      )
      h1$xAxis(title = list(text = "Price per unit, cents")
      )
      h1$tooltip(useHTML = T, 
                 formatter = 
                   "#! function() { return(this.point.cent_labels + ' cents' + '<br>' + 'Crowd: ' + '<span style=\"color:' + this.series.color + '\">' + this.point.skills + '</span>' + '<br>' + this.point.y + ' workers'); } !#")
      
      h1
    } 
  })
  
  
  tainted_bar <- reactive({
    if (input$get_job == 0 || input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      job_id = input$job_id
      print("In price_available_plot server 1745")
      tainted_breakdown_data = pull_tainted_breakdown_data()
      
      data_list = lapply(split(tainted_breakdown_data, tainted_breakdown_data$group),
                         function(x) {
                           res <- lapply(split(x, rownames(x)), as.list)
                           names(res) <- NULL
                           return(res)
                         }
      )
      
      h1 <- rCharts::Highcharts$new()
      invisible(sapply(data_list, function(x) {
        h1$series(data = x, type = "column", name = x[[1]]$group)
      }
      ))
      h1$tooltip(useHTML = T, formatter = 
                   "#! function() { return('<b>' + this.point.group + '</b><br>' + 'Num workers: ' + this.point.y); } !#")
      h1$addParams(dom = 'tainted_bar')
      
      print(h1)
    }
  })
  
  pull_tainted_breakdown_data <- reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    } else {
      job_id = input$job_id
      speed_violations = pull_speed_violations()
      answer_distributions = pull_answer_flags()
      trust_eliminations = pull_trust_taints()
      all_tainted = pull_everyone_tainted()
      print("In pull_tainted_breakdown_data server 1778")
      
      # ideally we would merge these real nice to remove duplicates
      # TODO we should check between these dbs for duplicates
      speed_limit_count = length(unique(speed_violations$worker_id))
      answer_distributions_count = length(unique(answer_distributions$worker_id))
      trust_eliminations_count = length(unique(trust_eliminations$worker_id))
      tained_for_other_reasons = all_tainted$worker_id[!(all_tainted$worker_id 
                                                         %in% c(speed_violations$worker_id,
                                                                answer_distributions$worker_id,
                                                                trust_eliminations$worker_id))]
      tained_for_other_reasons_count = length(unique(tained_for_other_reasons))
      group_categories= c("Speed limit violations", "Answer distribution violations",
                          "Low trust (tq)","Other reasons")
      
      tainted_breakdown_data = data.frame(group=group_categories,
                                          y = c(speed_limit_count,
                                                answer_distributions_count,
                                                trust_eliminations_count,
                                                tained_for_other_reasons_count), # these are the numbers found in groups
                                          x=rep("", times=4), # this is a fake grouping variable
                                          preserve_order = c(5,4,3,2)
      )
      
      return(tainted_breakdown_data)
    }
    
  })
  
  output$tainted_summary <- renderText({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      line1 = "<div class=\"bar_divs well\" id=\"tainted_div\" style=\"display: none;\">"
      title ="<h4>Tainted workers</h4>"
      
      tainted_breakdown = pull_tainted_breakdown_data()
      print("In output$tainted_summary server 1816")
      
      all_tainted = sum(tainted_breakdown$y)
      #print(825)
      ##### the graph
      h1 = tainted_bar()
      # you need to insert this as html/script, so the chart needs to be processed properly first
      chart_html = paste(capture.output(h1$show('inline')), collapse="")
      #####
      overview = paste0("There are ", all_tainted, 
                        " tainted workers in your job.")
      comment = "Check out the breakdown below to see the main reason(s) why they are tainted."
      recommendation = ""
      closing_div = "</div>"
      ###### the price piece ends
      ## complexity will potentially be here too
      summary = paste(line1, title, overview, comment, chart_html,
                      closing_div, sep="<br>")
      paste(summary)
    }
  })
  
  pull_judgment_counts <- reactive({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      job_id = input$job_id
      worker_stats = pull_worker_stats()
      print("In pull_judgment_counts server 1841")
      
      data = worker_stats[worker_stats$num_judgments > 0,c("worker_id", "num_judgments", "tainted", "flagged_at","golds_count")]
      
      names(data) = c("worker_id", "judgments_count", "tainted", "flagged_at","golds_count")
      if (nrow(data) == 0) {
        data[1,] = rep(0, times=ncol(data))
      } 
      
      #print(names(data))
      #print(head(data))
      data
    }
  })
  
  num_judgments_bars <- reactive({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      workers_with_judgments = pull_judgment_counts()
      print("In num_judgments_bars server 1862")
      
      # only take trusted workers
      workers_with_judgments = workers_with_judgments[workers_with_judgments$tainted != 't' & workers_with_judgments$tainted != 'true' & workers_with_judgments$flagged_at == "",]
      max_work_setting = as.numeric(get_max_setting())
      
      if (max_work_setting!= Inf) { 
        workers_with_judgments = workers_with_judgments[workers_with_judgments$judgments_count < max_work_setting,]
      }
      
      #print(head(workers_with_judgments))
      if (nrow(workers_with_judgments) == 0) {
        workers_with_judgments[1,] = rep(0, times=ncol(workers_with_judgments))
        h1 <- rCharts::Highcharts$new()
      } else {
        workers_with_judgments = workers_with_judgments[1:min(nrow(workers_with_judgments),1000),]
        job_id = input$job_id
        # create the index
        workers_with_judgments = workers_with_judgments[order(workers_with_judgments$judgments_count),]
        workers_with_judgments$index = 1:nrow(workers_with_judgments)
        #https://crowdflower.com/jobs/443343/contributors/1863365
        workers_with_judgments$click_action = paste0("https://crowdflower.com/jobs/",
                                                     job_id, 
                                                     "/contributors/",
                                                     workers_with_judgments$worker_id)
        
        workers_with_judgments$worker_id = as.character(workers_with_judgments$worker_id)
        
        workers_with_judgments$x = workers_with_judgments$index # for proper ordering of bars
        workers_with_judgments$y = workers_with_judgments$judgments_count
        
        h1 <- rCharts::Highcharts$new()
        workers_with_judgments = lapply(split(workers_with_judgments, 
                                              1:nrow(workers_with_judgments)), as.list)
        names(workers_with_judgments) = NULL
        h1$series(data = workers_with_judgments, type = "column", name = "Workers")
        
        h1$chart(zoomType='x')
        h1$plotOptions(
          series = list(
            cursor = 'pointer',
            events = list(
              click = 
                "#! function(e) { window.open(e.point.options.click_action); } !#"
            )
          )
        )
        
        h1$tooltip(useHTML = T, formatter = 
                     "#! function() { return('ID: ' + this.point.worker_id + '<br>' + 'Judgments: ' + this.point.y); } !#")
      }
      h1
    }
  })
  
  output$working_summary <- renderText({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      line1 = "<div class=\"bar_divs well\" id=\"working_div\" style=\"display: none;\">"
      title ="<h4>Workers In This Task</h4>"
      workers_with_judgments = pull_judgment_counts()
      print("In output$working_summary server 1925")
      
      workers_with_judgments = workers_with_judgments[workers_with_judgments$tainted != 't' & workers_with_judgments$tainted != 'true' & workers_with_judgments$flagged_at == "",]
      max_work_setting = as.numeric(get_max_setting())
      if (max_work_setting!=Inf) { ## <<<<<<<<<<< TODO: check what gets returned if max is not set
        workers_with_judgments = workers_with_judgments[workers_with_judgments$judgments_count < max_work_setting,]
      }
      num_workers = nrow(workers_with_judgments)
      ########### special message for truncation
      if (num_workers > 1000) {
        trunc_message = paste0("Showing the 1000 most prolific workers. ", num_workers - 1000, " workers left out.")
      } else {
        trunc_message = ""
      }
      
      
      ###
      num_judgments = sum(as.numeric(workers_with_judgments$judgments_count))
      ##### the graph
      h1 = num_judgments_bars()
      # you need to insert this as html/script, so the chart needs to be processed properly first
      chart_html = paste(capture.output(h1$show('inline')), collapse="")
      #####
      overview = paste0("There are ", num_workers, 
                        " workers who can still do work in this job.<br>",
                        "They made ", num_judgments, " judgments so far.")
      recommendation = ""
      closing_div = "</div>"
      ###### the price piece ends
      ## complexity will potentially be here too
      summary = paste(line1, title, overview, chart_html,
                      trunc_message,
                      closing_div, sep="<br>")
      paste(summary)
    }
  })
  
  output$activeTab <- reactive({
    print("In output$activeTab server 1963")
    return(input$tab)
  })
  
  output$unit_summary <- renderTable({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      un = assignment_duration_agg()
      print("In output$unit_summary server 1973")
      head(un)
    }
  }) 
  
  gold_data <- reactive({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      input$tab
      units = pull_unit_data()
      print("In gold_data server 1984")
      
      golds = units[units$state %in% c(6,7),]
      if (nrow(golds) == 0) {
        golds[1,] = rep(0, times=ncol(golds))
        golds$state = "state"
        golds$percent_missed = 0
        golds$percent_contested = 0           
      } else {
        golds$state = translate_states(golds$state)
        golds$percent_missed = golds$missed_count / golds$judgments_count
        golds$percent_contested = get_percent_contested_vectorized(golds$contested_count,
                                                                   golds$missed_count)
      }    
      golds
    }
  })
  
  output$missed_contested_golds_chart  <- renderChart({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      p1 <- rCharts::Highcharts$new()
      p1$addParams(dom = 'missed_contested_golds_chart')
      return(p1)
    } else {
      #input$tab
      job_id = input$job_id
      golds = gold_data()
      print("In output$missed_contested_golds_chart server 2012")
      
      golds = golds[order(golds$percent_missed),]
      golds$index = 1:nrow(golds)
      
      golds$click_action = paste0("https://crowdflower.com/jobs/",
                                  job_id, 
                                  "/golds/",
                                  golds$id,
                                  "/edit")
      
      golds$x = golds$index
      golds$y = golds$percent_missed
      
      golds$percent_contested = round(golds$percent_contested, 2)
      golds$percent_missed = round(golds$percent_missed, 2)
      
      data_list = lapply(split(golds, golds$state),
                         function(x) {
                           res <- lapply(split(x, rownames(x)), as.list)
                           names(res) <- NULL
                           return(res)
                         }
      )
      #print(681)
      h1 <- rCharts::Highcharts$new()
      invisible(sapply(data_list, function(x) {
        h1$series(data = x, type = "column", name = x[[1]]$state)
      }
      ))
      h1$plotOptions(
        series = list(
          cursor = 'pointer',
          events = list(
            click = 
              "#! function(e) { window.open(e.point.options.click_action); } !#"
          )
        )
      )
      h1$tooltip(useHTML = T, formatter = 
                   "#! function() { return('ID: <b>' + this.point.id + '</b><br>' + 'Percent missed: ' + this.point.percent_missed 
               + '<br>' + 'Percent contested: ' + this.point.percent_contested 
               +  '<br>' + 'Agreement: ' + this.point.agreement
               +  '<br>' + 'Num judgments: ' + this.point.judgments_count); } !#")
      h1$addParams(dom = 'missed_contested_golds_chart')
      #print(688)
      h1
    }
  })
  
  output$gold_div_summary <- renderText({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      #input$tab
      golds = gold_data()
      print("In output$gold_div_summary server 2068")
      
      num_golds = nrow(golds)
      num_disabled = sum(golds$state == "hidden_gold")
      message = paste0("There is a total of ", num_golds, " in this job.<br>",
                       num_disabled," are in state 'disabled'.")
    }
  })
  
  pull_assignment_duration <- reactive({
    if(input$get_job == 0){
      return(NULL)
    }else{
      job_id = input$job_id
      if(job_id == 0){
        return(NULL)
      } else {
        db = db_call
        query = assignment_duration_query(job_id)
        print("In pull_assignment_duration server 2087")
        file = tempfile(tmpdir=temp_dir, fileext=".csv", pattern="assignment_duration_")
        data = run_this_query(db, query, file)
        data
      } 
    }
  })
  
  assignment_duration_agg <- reactive({
    if(input$get_job == 0 || input$job_id == 0){
      return(NULL)
    }else{
      raw_duration_data = pull_assignment_duration()
      print("In assignment_duration_agg server 2100")
      agg_duration_data = ddply(raw_duration_data, .(builder_worker_id),
                                summarize,
                                country = country[1],
                                channel = channel_id[1],
                                start_time = created_at[1],
                                end_time = finished_at[length(finished_at)],
                                unlog_mean_log_duration = exp(mean(log(duration_per_unit), na.rm=T)),
                                median_duration = median(duration_per_unit, na.rm=T),
                                num_units = sum(units_per_page))
      return(agg_duration_data)
    }
  })
  
  output$durations_chart  <- renderChart({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      p1 <- rCharts::Highcharts$new()
      p1$addParams(dom = 'durations_chart')
      return(p1)
    } else {
      check_judgments = bool_no_judgments_check()
      if(check_judgments == "true"){
        p2 <- rCharts::Highcharts$new()
        p2$addParams(dom = 'durations_chart')
        return(p2)
      } else{
        #input$tab
        job_id = input$job_id
        durations = assignment_duration_agg()
        worker_stats = pull_worker_stats()
        print("In output$durations_chart server 2124")
        
        worker_stats$is_tainted = F
        worker_stats[worker_stats$tainted == 't' | 
                       worker_stats$tainted == 'true' | 
                       worker_stats$flagged_at != "",]$is_tainted = T
        durations = merge(durations, worker_stats, by.x="builder_worker_id",
                          by.y="worker_id", all.x=T)
        
        
        durations = durations[order(-durations$num_units),]
        durations = durations[1:min(nrow(durations), 1000),] # hardcode to subset the 100 most prolific workers
        durations$index = 1:nrow(durations)
        
        
        durations$click_action = paste0("https://crowdflower.com/jobs/",
                                        job_id, 
                                        "/contributors/",
                                        durations$builder_worker_id)
        
        durations$x = as.numeric(strptime(durations$end_time,
                                          "%Y-%m-%d %H:%M",tz='UTC'))
        durations$x[is.na(durations$x)] = 0
        #sapply(durations$end_time, 
        #                   function(x) convert_times_to_numeric(x)
        #)
        durations$y = durations$median_duration
        durations$z = as.numeric(durations$num_units)
        
        durations$median_duration = round(durations$median_duration, 2)
        durations$golden_trust = as.numeric(durations$golden_trust)
        durations$golden_trust = round(durations$golden_trust, 2)
        
        data_list = lapply(split(durations, durations$is_tainted),
                           function(x) {
                             res <- lapply(split(x, 1:nrow(x)), as.list)
                             names(res) <- NULL
                             return(res)
                           })
        
        
        data_range = range(durations$y, na.rm =T, finite = T)
        
        data_ticks = log10(seq(from=max(1,data_range[1]-2), to = data_range[2]+50, 
                               length.out=10))
        
        
        h1 <- rCharts::Highcharts$new()
        h1$chart(animation = F)
        h1$title(text="Contributors' speed")
        h1$subtitle(text = "1 bubble = 1 contributor, size = num judgments <br> Click bubble to open contributor's page <br>")
        h1$chart(type = 'bubble' , plotBorderWidth=0, zoomType='x')
        # here we set labels and colors for the plot
        tf_pair = c(data_list[[1]][[1]]$is_tainted, data_list[[2]][[1]]$is_tainted)
        colors = c("#B22000", "#00B271") # red green 
        series_names = c("Tainted", "Trusted")
        if (tf_pair[1] == FALSE) {
          colors = rev(colors)
          series_names = rev(series_names)
        }
        
        # add series to plots
        h1$series(data = data_list[[1]], type='bubble', name=series_names[1], color = colors[1],
                  isThresholder=F, dragMin = 0)
        h1$series(data = data_list[[2]], type='bubble', name=series_names[2], color = colors[2],
                  isThresholder=F, dragMin = 0)
        
        
        #       h1$series(data = list(list(min(durations$x) - 10, min(durations$y)),
        #                             list(max(durations$x) + 10, min(durations$y))),
        #                 name="Thresholder",
        #                 type='line', draggable = T,
        #                 draggableSeries = T,
        #                 dragMin = min(durations$y),
        #                 marker = list(enabled = F), tooltip = list( enabled = F), color = "#3399FF")
        #       
        #       h1$series(data=list(), type='bubble', name="Contributors to Remove", dragMin=min(durations$y), 
        #         isThresholder = T, showInLegend = T, color = "#000066")
        
        
        h1$exporting(enabled = T)
        h1$yAxis(type = 'logarithmic',
                 title = list(text = "Seconds per unit"),
                 tickPositions = data_ticks,
                 labels = list(
                   formatter = "#! function() {
                return Math.round(this.value * 100) /100 ;
               } !#")
        )
        
        h1$xAxis(
          labels = list(
            enabled=F
          ),
          minRange = 1
        )
        
        h1$yAxis(labels = list(
          formatter = "#! function() {
                 return Math.round(this.value) ;
               } !#")
        )
        
        h1$plotOptions(
          bubble = list(
            minSize = 3,
            maxSize = 20
          ),
          series = list(
            cursor = 'pointer',
            events = list(
              click = 
                "#! function(e) { window.open(e.point.options.click_action); } !#",
              mouseout = "#! function() {
              this.chart.tooltip.hide();
            } !#",
              drop = "#! function() {
              $('#report').html(
                this.category + ' was set to ' + Highcharts.numberFormat(this.y, 2));
            } !#"
            )
          )
        )
        
        #h1$legend(enabled = F)
        
        h1$tooltip(useHTML = T, formatter = 
                     "#! function() { return('ID: <b>' + this.point.builder_worker_id + '</b><br>' 
                       + '<br>' + 'Country: ' + this.point.country 
                       +  '<br>' + 'Channel: ' + this.point.channel
                       +  '<br>' + 'Num judgments: ' + this.point.num_units 
                 +  '<br>' + 'Seconds per unit: ' + this.point.median_duration
                 + '<br>' + 'Trust: ' + this.point.golden_trust ); } !#")
        
        #h1$set(dom = 'durations_chart')
        h1$addParams(dom = 'durations_chart')
        h1
      }
    }
  })
  
  output$bubbles_truncated  <- renderText({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      return("")
    } else {
      #input$tab
      data = assignment_duration_agg()
      print("In output$bubbles_truncated server 2249")
      
      if (nrow(data) > 1000) {
        message = paste0("Only showing the 1000 most prolific workers. ",
                         nrow(data)-1000,
                         " workers omitted.")
      } else {
        message = ""
      }
      paste(message)
    }
  })
  
  output$judgments_trust_chart <- renderChart({
    if (input$get_job == 0  || input$job_id == 0) {
      # User has not uploaded a file yet
      p1 <- rCharts::Highcharts$new()
      p1$addParams(dom = 'judgments_trust_chart')
      return(p1)
    } else {
      judgments_check = bool_no_judgments_check()
      if(judgments_check == "true"){
        p2 <- rCharts::Highcharts$new()
        p2$addParams(dom = 'judgments_trust_chart')
        return(p2)
      }else{
        
        durations = assignment_duration_agg()
        worker_stats = pull_worker_stats()
        job_id = input$job_id
        
        worker_stats$is_tainted = F
        worker_stats[worker_stats$tainted == 't' | 
                       worker_stats$tainted == 'true' | 
                       worker_stats$flagged_at != "",]$is_tainted = T
        durations = merge(durations, worker_stats, by.x="builder_worker_id",
                          by.y="worker_id", all.x=T)
        
        #print(head(durations))
        durations = durations[order(-durations$num_units),]
        durations = durations[1:min(nrow(durations), 1000),] # hardcode to subset the 100 most prolific workers
        durations$index = 1:nrow(durations)
        #print("WWWWWWWWWWWWWWWWWWW")
        #print(head(durations))
        durations$click_action = paste0("https://crowdflower.com/jobs/",
                                        job_id, 
                                        "/contributors/",
                                        durations$builder_worker_id)
        
        durations$x = durations$num_units
        durations$x[is.na(durations$x)] = 0
        durations$z = 1 # they will al be the same size, choose which
        
        durations$median_duration = round(durations$median_duration, 2)
        durations$golden_trust = as.numeric(durations$golden_trust)
        durations$golden_trust = round(durations$golden_trust, 2)
        durations$y = durations$golden_trust
        
        data_list = lapply(split(durations, durations$is_tainted),
                           function(x) {
                             res <- lapply(split(x, 1:nrow(x)), as.list)
                             names(res) <- NULL
                             return(res)
                           })
        
        h1 <- rCharts::Highcharts$new()
        
        h1$title(text="Judgments vs Trust")
        h1$subtitle(text = "Click point to open contributor's page <br>")
        h1$chart(type = 'scatter' , plotBorderWidth=0, zoomType='x')
        # here we set labels and colors for the plot
        tf_pair = c(data_list[[1]][[1]]$is_tainted, data_list[[2]][[1]]$is_tainted)
        colors = c("#B22000", "#00B271") # red green 
        series_names = c("Tainted", "Trusted")
        if (tf_pair[1] == FALSE) {
          colors = rev(colors)
          series_names = rev(series_names)
        }
        # add series to plots
        h1$series(data = data_list[[1]], name=series_names[1], color = colors[1])
        h1$series(data = data_list[[2]], name=series_names[2], color = colors[2])
        
        h1$exporting(enabled = T)
        h1$yAxis(title = list(text = "Trusts in job")
        )
        
        h1$xAxis(
          minRange = 1
        )
        
        h1$plotOptions(
          series = list(
            cursor = 'pointer',
            events = list(
              click = 
                "#! function(e) { window.open(e.point.options.click_action); } !#",
              mouseout = "#! function() {
      this.chart.tooltip.hide();
      } !#"
            )
          )
        )
        
        h1$tooltip(useHTML = T, formatter = 
                     "#! function() { return('ID: <b>' + this.point.builder_worker_id + '</b><br>' 
           + '<br>' + 'Country: ' + this.point.country 
           +  '<br>' + 'Channel: ' + this.point.channel
           +  '<br>' + 'Num judgments: ' + this.point.num_units 
           +  '<br>' + 'Seconds per unit: ' + this.point.median_duration
           + '<br>' + 'Trust: ' + this.point.golden_trust ); } !#")
        
        h1$addParams(dom = 'judgments_trust_chart')
        
        h1 
      }
    }
  })
  
  output$selectJudgments <- renderUI({
    if (input$get_job == 0 || input$job_id==0) {
      return(NULL)
    }else{
     selectInput("judgment_type", "Judgment Types:",
                 list("All" = "all",
                      "Trusted" = "trusted",
                      "Tainted" = "tainted")) 
      
    }
  })
  
  output$judgments_map <- renderChart2({
    if (input$get_job == 0 || input$job_id==0) {
      # User has not uploaded a file yet
      p1 <- rCharts$new()
      p1$addParams(dom = 'judgments_map')
      return(p1)
    } else {
      judgments_check = bool_no_judgments_check()
      if(judgments_check == "true"){
        p2 <- rCharts::Highcharts$new()
        p2$addParams(dom = 'judgments_trust_chart')
        return(p2)
      }else{
        print("in output$judgments_map server")
        judgments = pull_judgment_data()
        job_id = input$job_id
        #print(head(judgments))
        unit_judgments = judgments[judgments$golden != "t",]
        #print("made unit_judgments")
        #print(head(unit_judgments))
        judgments_by_country = ddply(unit_judgments, .(country), summarize,
                                     num_judg = length(id),
                                     num_tainted = length(tainted[tainted == "t"]),
                                     num_trusted = length(tainted[tainted != "t"]))
        
        #max_number_zeros = max(length(judgments_by_country$num_tainted[judgments_by_country$num_tainted == 0]),
        #                          length(judgments_by_country$num_trusted[judgments_by_country$num_trusted == 0]))
        #print("Max number of zeroes of trusted and untrusted")
        #print(max_number_zeros)
        
        #percent_tainted = round((num_tainted/num_judg * 100), 2))
        #df = data.frame(country = letters[1:max_number_zeros], num_judg = 1:max_number_zeros, num_tainted = 1:max_number_zeros, num_trusted = 1:max_number_zeros)
        #judgments_by_country = rbind(df, judgments_by_country)
        
        
        if(input$judgment_type == 'all'){
          map_it = ichoropleth(num_judg ~ country, data=judgments_by_country, map="world",
                             pal='Blues')
        }else if (input$judgment_type == 'trusted'){
          judgments_minus_zero = judgments_by_country[judgments_by_country$num_trusted != 0,]
          map_it = ichoropleth(num_trusted ~ country, data=judgments_minus_zero, map="world",
                               pal='Greens') 
        }else{
          judgments_minus_zero = judgments_by_country[judgments_by_country$num_tainted != 0,]
          map_it = ichoropleth(num_tainted ~ country, data=judgments_minus_zero, map="world",
                               pal='Reds', ncuts=3)
        }
        
        map_it$set(geographyConfig = list(
          popupTemplate = "#! function(geography, data){
        return '<div class=hoverinfo><strong>' +  geography.properties.name +
        '</strong><br><font color=\"blue\">Judgments: ' + data.num_judg + 
            '</font><br><font color=\"green\">Trusted: ' + data.num_trusted +
             '</font><br><font color=\"red\">Tainted: ' + data.num_tainted + '</font></div>';
        } !#"
        ))
        
        return(map_it)
      }
    }
    
  })
  
  all_alerts_table <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      #All Alerts:
      #data is from:
      json = get_job_settings_from_json()
      workers = get_state_counts()
      workers_times = assignment_duration_agg()
      enabled_golds = enabled_golds_table()
      units = pull_unit_data()
      print("In all_alerts_table server 2274")
      
      #variables:
      #Max Work Settings
      mjw = json$max_judgments_per_worker
      mjip = json$max_judgments_per_ip
      
      #Levelled Crowd
      skills <- json$minimum_requirements$skill_scores
      skill_names = names(skills)
      skill_count = length(skill_names[grepl("level_\\d_contributors", skill_names)])
      
      #Quiz Mode Settings
      quiz_mode = json$options$front_load      
      upa = json$units_per_assignment
      
      if(is.null(json$options$after_gold)){
        after_gold = 1
      } else {
        after_gold = as.numeric(json$options$after_gold)
      }
      
      if(is.null(json$options$reject_at)){
        reject_at = 0
      } else {
        reject_at = as.numeric(json$options$reject_at)    
      }
      
      correct_golds = ceiling((reject_at/100 * after_gold))      
      suggested_reject_at = floor(((after_gold - 1)/after_gold)*100)
      
      #Grab Task and Settings Elements
      cml = json$cml
      instructions = json$instructions
      actual_pay = json$payment_cents
      upa = json$units_per_assignment
      
      #instructions length
      length_inst = instructions_length(instructions)
      
      #Bad Pricing - based on calculator
      find_texts = '<cml:text(area)?(\\s|\\w|=|:|\"|\\[|\'|\\,|\\]|\\{|\\})*(required)'
      find_clicks = 'href=\\"https?://'
      
      #search number is a subset of clicks
      find_search = 'href=\\"https?://(\\w|\\.|/)+(search)'
      
      #task settings
      #Count validated fields number of fields
      find_validates = "validates=\"(\\w|:|\\[|\\]|\\'|\\,|\\{|\\})*\\s?(required)"
      count_validates = str_count(cml, pattern=find_validates)
      vpa = upa * count_validates
      
      #payment markups
      search_markup = 0
      click_markup = 0
      text_markup = 0
      level_markup = 0 #level 3 markup
      level_markup = 0 #level 2 markup
      
      if(str_detect(cml, pattern=find_search)){
        search_markup = .7
      }
      
      if(str_detect(cml, pattern=find_clicks) && !(str_detect(cml, pattern=find_search))){
        click_markup = .2  
      }
      
      if(str_detect(cml, pattern=find_texts)){
        text_markup = .3
      } 
      
      ##Level Mark Ups
      if(!(is.null(json$minimum_requirements$skill_scores$level_3_contributors))){
        level_markup = .3
      }
      
      if(!(is.null(json$minimum_requirements$skill_scores$level_2_contributors))){
        level_markup = .2
      }
      
      pay_per_unit = 1 + click_markup + search_markup + text_markup + level_markup
      suggested_pay = upa * pay_per_unit
      
      error = abs((suggested_pay - actual_pay)/suggested_pay)
      direction = suggested_pay - actual_pay
      
      #worker counts
      available = as.numeric(get_everyone_available())
      
      maxed =  workers[1]
      viable = workers[2]
      tainted = workers[3]
      check_out = workers[4]
      dont_care = workers[5]
      total_worked = viable + maxed + tainted + check_out
      total = total_worked + dont_care
      
      percent_viable = (viable/total_worked)*100
      percent_check_out = (check_out/total_worked) * 100
      percent_dont_care = (dont_care/total) * 100
      percent_maxed = (maxed/total_worked) * 100
      percent_tainted = (tainted/total_worked) * 100
      
      if(is.nan(percent_viable) || is.infinite(percent_viable)){
        percent_viable = 0
      }
      
      if(is.nan(percent_maxed) || is.infinite(percent_maxed)){
        percent_maxed = 0
      }
      
      if(is.nan(percent_tainted) || is.infinite(percent_tainted)){
        percent_tainted = 0
      }
      
      if(is.nan(percent_check_out) || is.infinite(percent_check_out)){
        percent_check_out = 0
      }
      
      if(is.nan(percent_dont_care) || is.infinite(percent_dont_care)){
        percent_dont_care = 0
      }
      
      #workers duration times and judgments
      fiver = fivenum(workers_times$median_duration, na.rm=T)
      under_3_workers = workers_times[workers_times$median_duration <= 3,]
      total_judgments = sum(workers_times$num_units)
      fast_quarter = workers_times[workers_times$median_duration <= fiver[2],]
      num_judgments_fast_quarter = sum(fast_quarter$num_units, na.rm = T)
      
      #gold counts
      num_units = nrow(units)
      num_golds = nrow(enabled_golds)
      
      num_missed = nrow(enabled_golds[enabled_golds$missed_count > 0,])
      
      highly_missed = enabled_golds[enabled_golds$missed_percent > .67,]
      highly_contested = enabled_golds[enabled_golds$contested_percent > .50,]
      highly_contested = highly_contested[!is.na(highly_contested$id), ]
      
      #Constructing Alert Flags for Design and Task Concerns
      if(length_inst > 1000){
        inst_alert = "long"
      } else if(length_inst < 100){
        inst_alert = "short"
      } else{
        inst_alert = "none"
      }
      
      if(vpa > 20){
        unit_alert = "long"
      } else if(vpa < 5){
        unit_alert = "short"
      } else {
        unit_alert ="none"
      }
      
      if(error > .25){
        if(direction < 0){
          pay_alert = "over"
        }
        if(direction > 0){
          pay_alert = "under"
        }
      } else {
        pay_alert = "none"
      }
      
      if(correct_golds == after_gold && !(is.null(quiz_mode))){
        strict_reject = "strict_quiz"
        
      }else if(correct_golds == after_gold && is.null(quiz_mode)){
        strict_reject = "strict_work"
        
      }else{
        strict_reject = "none"
      }
      
      if(!(is.null(quiz_mode)) && upa != after_gold){
        if(after_gold > upa){
          after_gold_alert = "big_quiz"
        }      
        if(after_gold < upa){
          after_gold_alert = "small_quiz"      
        }
      } else {
        after_gold_alert = "none"
      }
      
      if(is.null(mjw)) {
        mjw_alert = "true"
      } else {
        mjw_alert = "false"
      }
      
      if(is.null(mjip)) {
        mjip_alert = "true"
      } else {
        mjip_alert = "false"
      }
      
      if(skill_count == 0){
        skill_alert = "true"
      } else {
        skill_alert = "false"
      }
      
      if(is.null(quiz_mode) || quiz_mode == F || quiz_mode == "false"){
        qm_alert = "true"
        print("Line 2614 qm_alert = true")
      } else {
        qm_alert="false"
      }
      
      #Constructing Alert Flags for Gold Quality Concerns
      if(num_golds != 0 && !is.null(nrow(enabled_golds)) && !is.na(nrow(enabled_golds))){
        no_golds_alert = "false"
        highly_missed = enabled_golds[enabled_golds$missed_percent > .67,]
        highly_contested = enabled_golds[enabled_golds$contested_percent > .50,]
        highly_contested = highly_contested[!is.na(highly_contested$id), ]
        
        num_missed = nrow(enabled_golds[enabled_golds$missed_count > 0,])
        
        if((num_units*.11) < 100){
          suggest_golds = round(num_units*.11) - num_golds
        } else {
          suggest_golds = 100 - num_golds
        }
        
        #More than 19% of golds are missed +67% of the time
        if(nrow(highly_missed) > 0 && !is.na(highly_missed$id) && nrow(highly_missed)/num_golds > .19){
          tq_missed_alert = "true" 
        } else {
          tq_missed_alert = "false"
        }      
        
        
        #More than 19% of golds are contested +50% of the time
        if(nrow(highly_contested) > 0 && !is.na(highly_contested$id) && nrow(highly_contested)/num_missed > .19){
          tq_contested_alert = "true" 
        } else{
          tq_contested_alert = "false" 
        }
        
        #Enough Golds
        #wrt number of units for every 100 units there should be AT LEAST 10 units.
        if(num_golds/num_units < .11 && num_golds < 100){
          few_golds_alert = "true"
        } else {
          few_golds_alert = "false"
        }
        
      } else {
        no_golds_alert = "true"
        tq_missed_alert = "none"
        tq_contested_alert = "none"
        suggest_golds = 0
        few_golds_alert = "none"
        num_golds = 0
        highly_contested = data.frame() #empty data frame, nrows = 0
        highly_missed = data.frame() #empty data frame, nrows = 0
      }
      
      #Constructing Alert Flags for Contributor Time Duration Quality Warnings
      if(nrow(under_3_workers) > 0){
        three_alert ="true"
      } else {
        three_alert = "false"
      }
      
      if(num_judgments_fast_quarter/total_judgments > .4){
        top_quarter_judg_alert = "true"
      } else {
        top_quarter_judg_alert = "false"
      }
      
      #Constructing Throughput Contributor Alerts
      if(available < 100 || is.na(available) || is.null(available)){
        too_small_alert = "true"
      } else {
        too_small_alert= "false"
      }
      
      if(percent_tainted > 35){
        failure_alert = "true"
      } else {
        failure_alert = "false"
      }
      
      if(percent_maxed > 50){
        maxed_alert = "true"
      } else {
        maxed_alert = "false"
      }
      
      if(percent_viable < 20){
        viable_alert = "true"
      } else {
        viable_alert = "false"
      }
      
      if(percent_check_out > 35){
        lookers_alert = "true"
      } else {
        lookers_alert = "false" 
      }
      
      if(percent_dont_care > 50){
        dont_care_alert = "true"
      } else {
        dont_care_alert = "false"
      }
      
      
      all_things = c(replace_null(mjw), replace_null(mjip), paste(skill_names, collapse=", "), replace_null(quiz_mode), after_gold, reject_at, suggested_reject_at, correct_golds, 
                     suggested_pay, actual_pay, length_inst, upa, vpa, num_golds, nrow(highly_missed), 
                     nrow(highly_contested), total_judgments, num_judgments_fast_quarter, length(workers_times$num_units), 
                     length(fast_quarter$num_units), nrow(under_3_workers), available, round(percent_tainted), 
                     round(percent_maxed), round(percent_viable), round(percent_check_out), round(percent_dont_care), 
                     suggest_golds, inst_alert, unit_alert, pay_alert, strict_reject, after_gold_alert, 
                     mjw_alert, mjip_alert, skill_alert, qm_alert, no_golds_alert, three_alert, 
                     top_quarter_judg_alert, too_small_alert, failure_alert, maxed_alert, viable_alert, 
                     lookers_alert, dont_care_alert, few_golds_alert, tq_missed_alert, tq_contested_alert, 
                     round(fiver[1]), round(fiver[5]), round(fiver[3]), round(fiver[2]))
      
      names(all_things) = c("mjw", "mjip", "skill_names", "quiz_mode", "after_gold", "reject_at", "suggested_reject_at", "correct_golds", 
                            "suggested_pay", "actual_pay", "length_inst", "upa", "vpa", "num_golds", "num_highly_missed", 
                            "num_highly_contested","total_judgments", "num_judgments_fast_quarter", "total_workers_times", 
                            "num_top_25_workers", "num_workers_under_three", "num_available", "percent_tainted", 
                            "percent_maxed", "percent_viable", "percent_check_out", "percent_dont_care",
                            "suggest_golds", "inst_alert", "unit_alert", "pay_alert", "strict_reject", 
                            "after_gold_alert", "mjw_alert", "mjip_alert", "skill_alert", "qm_alert", 
                            "no_golds_alert", "three_alert", "top_quarter_judg_alert", "too_small_alert", 
                            "failure_alert", "maxed_alert", "viable_alert", "lookers_alert", "dont_care_alert",
                            "few_golds_alert", "tq_missed_alert", "tq_contested_alert", "fiver_one", 
                            "fiver_five", "fiver_three", "fiver_two")
      
      return(all_things)
    }
  })
  
  alerts_truncated_table <- reactive({
    if (input$get_job == 0 || input$job_id == 0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      #All Alerts:
      #data is from:
      json = get_job_settings_from_json()
      units = pull_unit_data()
      available = as.numeric(get_everyone_available())
      
      print("In alerts_truncated_table server")
      
      #variables:
      #Max Work Settings
      mjw = json$max_judgments_per_worker
      mjip = json$max_judgments_per_ip
      
      #Levelled Crowd
      skills <- json$minimum_requirements$skill_scores
      skill_names = names(skills)
      skill_count = length(skill_names[grepl("level_\\d_contributors", skill_names)])
      
      #Quiz Mode Settings
      quiz_mode = json$options$front_load      
      upa = json$units_per_assignment
      
      if(is.null(json$options$after_gold)){
        after_gold = 1
      } else {
        after_gold = as.numeric(json$options$after_gold)
      }
      
      if(is.null(json$options$reject_at)){
        reject_at = 0
      } else {
        reject_at = as.numeric(json$options$reject_at)    
      }
      
      correct_golds = ceiling((reject_at/100 * after_gold))      
      suggested_reject_at = floor(((after_gold - 1)/after_gold)*100)
      
      #Grab Task and Settings Elements
      cml = json$cml
      instructions = json$instructions
      actual_pay = json$payment_cents
      upa = json$units_per_assignment
      
      #instructions length
      length_inst = instructions_length(instructions)
      
      #Bad Pricing - based on calculator
      find_texts = '<cml:text(area)?(\\s|\\w|=|:|\"|\\[|\'|\\,|\\]|\\{|\\})*(required)'
      find_clicks = 'href=\\"https?://'
      
      #search number is a subset of clicks
      find_search = 'href=\\"https?://(\\w|\\.|/)+(search)'
      
      #task settings
      #Count validated fields number of fields
      find_validates = "validates=\"(\\w|:|\\[|\\]|\\'|\\,|\\{|\\})*\\s?(required)"
      count_validates = str_count(cml, pattern=find_validates)
      vpa = upa * count_validates
      
      #payment markups
      search_markup = 0
      click_markup = 0
      text_markup = 0
      level_markup = 0 #level 3 markup
      level_markup = 0 #level 2 markup
      
      if(str_detect(cml, pattern=find_search)){
        search_markup = .7
      }
      
      if(str_detect(cml, pattern=find_clicks) && !(str_detect(cml, pattern=find_search))){
        click_markup = .2  
      }
      
      if(str_detect(cml, pattern=find_texts)){
        text_markup = .3
      } 
      
      ##Level Mark Ups
      if(!(is.null(json$minimum_requirements$skill_scores$level_3_contributors))){
        level_markup = .3
      }
      
      if(!(is.null(json$minimum_requirements$skill_scores$level_2_contributors))){
        level_markup = .2
      }
      
      pay_per_unit = 1 + click_markup + search_markup + text_markup + level_markup
      suggested_pay = upa * pay_per_unit
      
      error = abs((suggested_pay - actual_pay)/suggested_pay)
      direction = suggested_pay - actual_pay
      
      
      #Constructing Alert Flags for Design and Task Concerns
      if(length_inst > 1000){
        inst_alert = "long"
      } else if(length_inst < 100){
        inst_alert = "short"
      } else{
        inst_alert = "none"
      }
      
      if(vpa > 20){
        unit_alert = "long"
      } else if(vpa < 5){
        unit_alert = "short"
      } else {
        unit_alert ="none"
      }
      
      if(error > .25){
        if(direction < 0){
          pay_alert = "over"
        }
        if(direction > 0){
          pay_alert = "under"
        }
      } else {
        pay_alert = "none"
      }
      
      if(correct_golds == after_gold && !(is.null(quiz_mode))){
        strict_reject = "strict_quiz"
        
      }else if(correct_golds == after_gold && is.null(quiz_mode)){
        strict_reject = "strict_work"
        
      }else{
        strict_reject = "none"
      }
      
      if(!(is.null(quiz_mode)) && upa != after_gold){
        if(after_gold > upa){
          after_gold_alert = "big_quiz"
        }      
        if(after_gold < upa){
          after_gold_alert = "small_quiz"      
        }
      } else {
        after_gold_alert = "none"
      }
      
      if(is.null(mjw)) {
        mjw_alert = "true"
      } else {
        mjw_alert = "false"
      }
      
      if(is.null(mjip)) {
        mjip_alert = "true"
      } else {
        mjip_alert = "false"
      }
      
      if(skill_count == 0){
        skill_alert = "true"
      } else {
        skill_alert = "false"
      }
      
      if(is.null(quiz_mode) || quiz_mode == F || quiz_mode == "false"){
        qm_alert = "true"
        print("Line 2614 qm_alert = true")
      } else {
        qm_alert="false"
      }
      
      if(available < 100 || is.na(available) || is.null(available)){
        too_small_alert = "true"
      } else {
        too_small_alert= "false"
      }
      
      all_things = c(replace_null(mjw), replace_null(mjip), paste(skill_names, collapse=", "), 
                     replace_null(quiz_mode), after_gold, reject_at, suggested_reject_at, correct_golds, 
                     suggested_pay, actual_pay, length_inst, upa, vpa, inst_alert, unit_alert, pay_alert, strict_reject, after_gold_alert, mjw_alert, mjip_alert, skill_alert, qm_alert, too_small_alert)
      
      names(all_things) = c("mjw", "mjip", "skill_names", "quiz_mode", "after_gold", "reject_at", "suggested_reject_at", 
                            "correct_golds", "suggested_pay", "actual_pay", "length_inst", "upa", "vpa", 
                            "inst_alert", "unit_alert", "pay_alert", "strict_reject", 
                            "after_gold_alert", "mjw_alert", "mjip_alert", "skill_alert", "qm_alert", "too_small_alert")
      
      return(all_things)
    }
  })
  
})
