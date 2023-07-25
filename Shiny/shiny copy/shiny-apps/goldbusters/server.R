######################## the server part of the Goldbusters app ######################
source('../.Rprofile.apps')
source('../.env')

require('shiny')
require('stringr')
library("XML")
library('rjson')

options(stringsAsFactors=F)


source("parse_xml_for_goldbusters.R")

auth_key = CF_GOLD_ACCOUNT_API_KEY

new_css_for_instructions = ".background-yellow { 
padding: 19px;\n
margin-bottom: 20px;\n
background-color: #FFCD45;\n
border: 2px solid #FFC445;\n
-webkit-border-radius: 4px;\n
-moz-border-radius: 4px;\n
border-radius: 4px;\n
-webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,0.05);\n
-moz-box-shadow: inset 0 1px 1px rgba(0,0,0,0.05);\n
box-shadow: inset 0 1px 1px rgba(0,0,0,0.05);\n
}"

shinyServer(function(input, output) {
  
  print("at least i'm running 2")
  
  disqus_js <- reactive({
    if (is.na(input$jobID)) {
      return(NULL)
    } else  {
      job_id = input$jobID
      print("In disqus")
      print(job_id)
      part1 = "<div id=\"disqus_thread\"></div>\n
    <script type=\"text/javascript\">\n
    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */\n
  var disqus_shortname = 'crowdflower'; // required: replace example with your forum shortname\n
  var disqus_identifier = "
      job_id = paste0("'/",job_id,"/';")
      part2 = "/* * * DON'T EDIT BELOW THIS LINE * * */\n
  (function() {\n
  var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;\n
  dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';\n
  (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);\n
  })();\n
  </script>\n"
      ds = paste0(part1,job_id,part2)
      ds
    }
  })
  
  
  output$link_and_comment <- renderText({
    if (is.na(input$jobID)) {
      paste("The new job id will appear here once the program is done.")
    } else {
      start= "<div class=\"well\">"
      new_job_id = copied_job()
      job_preview_link = paste0("https://make.crowdflower.com/jobs/",new_job_id,"/preview")
      line1 = paste0("Alright we're done. New job id is ", new_job_id,".Your job is here: ",
                     "<a href=\"",
                     job_preview_link, "\" target=\"_blank\"> preview job</a>.")
      br = "<br/>"
      line2 = paste0("If there were no errors below, you can launch it to GB. Otherwise, download your CML from ",
                     "\"View Goldified CML (debug manually)\"",
                     ", paste into the new job's CML and debug manually.")
      end = "</div>"
      paste(start, line1, br, line2, end)
    }
  })
  
  output$new_cml <- renderText({
    print("i am in output$new_cml")
    if (is.na(input$jobID)) {
      paste("You will be able to view the updated CML here once the program is done.")
    } else {
      cml_string = transform_cml_reactive()
      paste(cml_string)
    }
  })
  
  output$downloadCML <- downloadHandler(
    
    filename = function() { paste('goldbusters_cml', '.cml', sep='') },
    content = function(file) {
      cml_string=transform_cml_reactive()
      writeLines(cml_string, paste(file,sep=''))
    }
  )
  
  
  ########################## experimantal part #########################
  get_json_ruby <- reactive({
    if (is.na(input$jobID)) {
      return("No job id supplied")
    } else {
      job_id = input$jobID
      print("i am in get_json_ruby")
      json_to_print = paste(system(paste("./run_ruby.sh add_reasons_part1.rb", job_id),
                                   intern=TRUE), collapse="")
      print("got json in get_json_ruby")
      json_to_print
    }
  })
  
  output$get_json <- renderText({
    if (is.na(input$jobID)) {
      paste("1. Get JSON from job")
    } else {
      print("and how about job_url?")
      print_var = ""
      json_text = get_json_ruby()
      if (grepl(json_text, pattern="^\\{\"error\"\\:")) {
        stop(paste("1. Get JSON from job: ERROR! \nWe got the following error message trying to retrieve json:", json_text))
      } else {
        print_var = paste("1. Get JSON from job: SUCCESS")
      }
      print("about to print json in get_json")
      print_var
    }
  })
  
  get_all_elements <- reactive({
    if (is.na(input$jobID)) {
      paste("1. Get JSON from job")
    } else {
      print("getting all elements")
      json_to_print = get_json_ruby()
      print("json_to_print <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
      print(json_to_print)
      parsed_json = fromJSON(json_str = json_to_print)
      list(css=parsed_json$css,cml=parsed_json$problem,
           instructions=parsed_json$instructions,
           title = parsed_json$title,
           js = parsed_json$js)
    }
  })
  
  transform_css_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_css")
      old_css = get_all_elements()$css
      #new_css_for_instructions
      new_css = paste(new_css_for_instructions, "\n",
                      old_css,
                      sep="")
      new_css
    }
  })
  
  transform_title_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_css")
      old_title = get_all_elements()$title
      new_title = paste('GOLD: ', old_title, sep="")
      new_title
    }
  })
  
  transform_cml_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_cml_reactive")
      old_cml = get_all_elements()$cml
      #new_title = paste('GOLD: ', old_title, sep="")
      print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
      spotcheck = input$make_spotcheck == "spotcheck"
      print(spotcheck)
      new_cml = change_cml_R(old_cml, spotcheck)
      disqus_js = disqus_js()
      new_cml = paste(new_cml,
                      disqus_js,
                      sep="\n")
      new_cml
    }
  })
  
  transform_instructions_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_css")
      old_instructions = get_all_elements()$instructions
      new_instructions = paste("<div class='background-yellow'>\n",
                               "<p>Dear Contributor,<br>This is a special Gold Digging task!",
                               " We appreciate your careful work on this one.",
                               " <br>Thanks a lot for your help and Good  Luck!</p>\n</div>\n", old_instructions,
                               sep="")
      new_instructions
    }
  })
  
  copied_job <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      job_id = input$jobID
      command = paste('curl "https://api.crowdflower.com/v1/jobs/',
                      job_id,
                      '/copy.json?key=',
                      auth_key,
                      '&all_units=true&gold=false"',
                      sep="")
      print(command)
      copied_json = paste(system(command, intern=T), collapse="")
      parsed_json = fromJSON(json_str = copied_json)
      new_id = parsed_json$id
      print(paste("Job id ", new_id))
      new_id
    }
  })
  
  updated_setting <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      new_id = copied_job()
      spotcheck = input$make_spotcheck == "spotcheck"
      if (spotcheck) {
        settings_update = paste(system(
          paste("./run_ruby.sh update_settings_spotcheck.rb", new_id),
          intern= T), collapse="")
      } else {
        settings_update = paste(system(
          paste("./run_ruby.sh change_settings.rb", new_id),
          intern= T), collapse="")
      }
      settings_update
    }
  })
  
  output$transform_css <- renderText({
    if (is.na(input$jobID)) {
      paste("2. Transform CSS")
    } else {
      print("I am in transform_css")
      new_css = transform_css_reactive()
      print_var = ""
      if (grepl(new_css, pattern="^\\{\"error\"\\:")) {
        stop(paste("2. Transform CSS: ERROR! \nWe got the following error message trying to retrieve json:", 
                   new_css))
      } else {
        print_var = paste("2. Transform CSS: SUCCESS")
      }
      print_var
    }
  })
  
  output$transform_title <- renderText({
    if (is.na(input$jobID)) {
      paste("4. Transform Title")
    } else {
      print("I am in transform_title")
      new_title = transform_title_reactive()
      print_var = paste("4. Transform Title: SUCCESS. The new title is\"", new_title, "\"")
      print_var
    }
  })
  
  output$transform_cml <- renderText({
    if (is.na(input$jobID)) {
      paste("5. Transform CML")
    } else {
      print("I am in transform_cml")
      new_cml = transform_cml_reactive()
      print_var = paste("5. Transform CML: SUCCESS. New CML has", nchar(new_cml), "characters")
      print_var
    }
  })
  
  output$transform_instructions <- renderText({
    if (is.na(input$jobID)) {
      paste("3. Transform Instrustions")
    } else {
      print("I am in transform_instructions")
      new_instructions = transform_instructions_reactive()
      print_var = paste("3. Transform Instrustions: SUCCESS. New Instrustions have", nchar(new_instructions), "characters")
      print_var
    }
  })
  
  
  
  output$copy_job <- renderText({
    if (is.na(input$jobID)) {
      paste("6. Make a copy of the job")
    } else {
      print("I am in copy_job")
      job_id = copied_job()
      print(job_id)
      if (grepl(job_id, pattern="^\\{\"error\"\\:")) {
        stop(paste("6. Make a copy of the job: ERROR! \nWe got the following error message trying to copy the job:", job_id))
      } else {
        print_var = paste("6. Make a copy of the job: SUCCESS. The new job is at", job_id)
      }
      print_var
    }
  })
  
  output$copy_job_with_settings <- renderText({
    if (is.na(input$jobID)) {
      paste("7. Update Settings. This part takes a little time.")
    } else {
      print("I am in copy_job_with_settings")
      update = updated_setting()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("7. Update Settings: ERROR! \nWe got the following error message when we tried to update job settings:", update))
      } else {
        print_var = paste("7. Update Settings: SUCCESS. This job has been optimized for GoldBUsters.")
      }
      print_var
    }
  })
  
  update_title_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_title = transform_title_reactive()
      print(paste("got new title ", new_title))
      print("about to command")
      updated_title = paste(system(
        paste("./run_ruby.sh update_title.rb ", new_id, " \"",new_title,"\" ", sep=""),
        intern= T), collapse="")
      paste(updated_title)
    }
  })
  
  output$update_title <- renderText({
    if (is.na(input$jobID)) {
      paste("8. Update Title")
    } else {
      print("I am in update_title")
      update = update_title_reactive()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("8. Update Title: ERROR! \nWe got the following error message when we tried to update the title:", update))
      } else {
        print_var = paste("8. Update Settings: SUCCESS.")
      }
      print_var
    }
  })
  
  
  update_instructions_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be update_instructions_reactive")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_instructions = transform_instructions_reactive()
      print(paste("got new instructions ", new_instructions))
      print("about to command")
      new_instructions = gsub(new_instructions, pattern='"', replacement='\\\\"')
      command = paste("./run_ruby.sh update_instructions.rb ",
                      new_id, ' """', new_instructions, '"""', sep="")
      print(command)
      updated_instructions = paste(system(command,
                                          intern= T), collapse="")
      updated_instructions
    }
  })
  
  
  update_css_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be update_instructions_reactive")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_css = transform_css_reactive()
      print(paste("got new css ", new_css))
      print("about to command")
      new_css = gsub(new_css, pattern='"', replacement='\\\\"')
      command = paste("./run_ruby.sh update_css.rb ",
                      new_id, ' """', new_css, '"""', sep="")
      print(command)
      updated_instructions = paste(system(command,
                                          intern= T), collapse="")
      updated_instructions
    }
  })
  
  #   update_js_reactive <- reactive({
  #     if (is.na(input$jobID)) {
  #       paste("This will be update_js_reactive")
  #     } else {
  #       new_id = copied_job()
  #       print(paste("got job id ", new_id))
  #       old_js = get_all_elements()$js
  #       disqus_js = disqus_js()
  #       update_js_reactive = paste(old_js,disqus_js, sep="\n")
  #       print(paste("got new js ", disqus_js))
  #       print("about to command")
  #       update_js_reactive = gsub(update_js_reactive, pattern='"', replacement='\\\\"')
  #       command = paste("./run_ruby.sh update_js.rb ",
  #                       new_id, ' """', update_js_reactive, '"""', sep="")
  #       print(command)
  #       updated_js = paste(system(command,
  #                                           intern= T), collapse="")
  #       updated_js
  #     }
  #   })
  
  update_cml_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be update_instructions_reactive")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_cml = transform_cml_reactive()
      print(paste("got new CML ", new_cml))
      print("about to command")
      new_cml = gsub(new_cml, pattern='"', replacement='\\\\"')
      command = paste("./run_ruby.sh update_cml.rb ",
                      new_id, ' """', new_cml, '"""', sep="")
      print(command)
      updated_instructions = paste(system(command,
                                          intern= T), collapse="")
      paste(updated_instructions)
    }
  })
  
  
  output$update_instructions <- renderText({
    if (is.na(input$jobID)) {
      paste("10. Update Instructions")
    } else {
      print("I am in update_instructions")
      update = update_instructions_reactive()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("10. Update Instructions: ERROR! \nWe got the following error message when we tried to update Instructions:", update))
      } else {
        print_var = paste("10. Update Instructions: SUCCESS.")
      }
      print_var
    }
  })
  
  output$update_css <- renderText({
    if (is.na(input$jobID)) {
      paste("9. Update CSS")
    } else {
      print("I am in update_css")
      update = update_css_reactive()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("9. Update CSS: ERROR! \nWe got the following error message when we tried to update Instructions:", update))
      } else {
        print_var = paste("9. Update CSS: SUCCESS.")
      }
      print_var
    }
  })
  
  output$update_cml <- renderText({
    if (is.na(input$jobID)) {
      paste("11. Update CML. This is the tricky part.")
    } else {
      print("I am in update_cml")
      update = update_cml_reactive()
      print(update)
      
      # store fields that got goldified as a vector
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("11. Update CML: ERROR! \nWe got the following error message when we tried to update CML:", update))
      } else {
        print_var = paste("11. Update CML: SUCCESS.")
      }
      print_var
    }
  })
  #################################################################
  #the make Gold Report part
  goldbusters_report <- reactive({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      report = read.csv(input$files$datapath, na.strings="NaN", stringsAsFactors=FALSE)
      report
    }
  })
  
  gb_skips <- reactive({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      report = goldbusters_report()
      skipped_rows = report[report$skip == "true",]
      skipped_rows
    }
  })
  
  gb_golds <- reactive({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      report = goldbusters_report()
      gold_rows = report[report$skip != "true",]
      gold_rows
    }
  })
  
  output$report_stats <- renderText({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      num_units = nrow(goldbusters_report())
      num_skipped = nrow(gb_skips())
      num_gold = nrow(gb_golds())
      paste0("In this job, GoldBusters have gone through ", num_units," units,",
             " skipping ",num_skipped,", so you have ", num_gold, " Golds with reasons.")
    }
  })
  
  output$skip_lecture <- renderText({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      paste("Although you will not be using the skipped units as Golds, it is highly recommended that you review the skip reasons (\"skip_reason\" in the report below).")
    }
  })
  
  output$downloadGolds <- downloadHandler(
    filename = function() { paste(gsub(input$files$name, pattern="\\.csv", replacement=""),
                                  '_goldbusters_golds.csv', sep='') },
    content = function(file) {
      df = gb_golds()
      if (nrow(df) == 0) {
        return(NULL)
      } else {
        df=gb_golds()
        print(head(df))
        df$gb_who_made_it_id = df$X_worker_id
        df$gb_who_made_it_id_job_id = job_id()
        df$X_golden = "true"
        df$X_id = 1
        df$X_pct_missed =""
        df$X_judgments = ""
        df$X_gold_case =""
        df$X_difficulty = ""
        df$X_hidden =""
        df$X_contention =""
        df$X_pct_contested =""
        df$X_gold_pool =""
        # remove coolumns
        df$X_unit_id = NULL
        df$X_created_at = NULL
        df$X_canary = NULL
        df$X_started_at = NULL
        df$X_channel = NULL
        df$X_trust = NULL
        df$X_worker_id = NULL
        df$X_country = NULL
        df$X_region = NULL
        df$X_city = NULL
        df$X_ip = NULL
        df$skip = NULL
        df$skip_reason = NULL
        df = lapply(df, function(x) gsub(x, pattern="\\&lt;", replacement="<"))
        df = lapply(df, function(x) gsub(x, pattern="\\&gt;", replacement=">"))
        df = data.frame(df)
        names(df) = gsub(names(df), pattern="_testquestion", replacement="_gold")
        which_cols_too_gold = which(grepl(names(df), pattern="_gold_gold") == T)
        print(which_cols_too_gold)
        print(dim(df))
        print(class(df))
        df = df[,-which_cols_too_gold]
        names(df) = gsub(names(df), pattern="X_", replacement="_")
      }
      write.csv(df, paste(file,sep=''), row.names=F, na="")
    }
  )
  
  output$downloadSkips <- downloadHandler(
    filename = function() { paste(gsub(input$files$name, pattern="\\.csv", replacement=""),
                                  '_goldbusters_SKIPS.csv', sep='') },
    content = function(file) {
      df=gb_skips()
      if (nrow(df) == 0) {
        return(NULL)
      } else {
        print(head(df))
      }
      write.csv(df, paste(file,sep=''), row.names=F, na="")
    }
  )
  
  output$sample_skip_text <- renderText({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      paste("Here are some skip reasons (random sample of 10 if you had more than 10 skips):")
    }
  })
  
  job_id <- reactive({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      inFile <- input$files$name
      job_id = gsub(inFile, pattern="^f", replacement="")
      job_id = str_extract(job_id, "\\d{6}")
      return(job_id)
    }
  })
  
  output$sample_skip_reasons <- renderText({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      all_skips = gb_skips()
      num_skips = min(10, nrow(all_skips))
      random_skips = all_skips[sample(1:num_skips), c("X_unit_id", "X_worker_id", "skip_reason")]
      job_id = job_id() # job id for links
      skip_string = "<table class=\"table table-striped\">"
      skip_string = paste(skip_string, "<tr>", sep="\n")
      skip_string = paste(skip_string, "<td>", "Unit Link", "</td>", sep="\n")
      skip_string = paste(skip_string, "<td>", "Worker ID", "</td>", sep="\n")
      skip_string = paste(skip_string, "<td>", "Skip Reason", "</td>", sep="\n")
      skip_string = paste(skip_string, "</tr>", sep="\n")
      for (i in 1:nrow(random_skips)) {
        row = random_skips[i,]
        skip_string = paste(skip_string, "<tr>", sep="\n")
        unit_link = paste0("https://crowdflower.com/jobs/", job_id, "/units/", row$X_unit_id)
        href= paste0("<a href=\"", unit_link, "\" target=\"_blank\">",
                     row$X_unit_id,
                     "</a>")
        # add the link
        skip_string = paste(skip_string, "<td>", href, "</td>", sep="\n")
        # add the worker id
        skip_string = paste(skip_string, "<td>", row$X_worker_id, "</td>", sep="\n")
        # add the skip reason
        skip_string = paste(skip_string, "<td>", row$skip_reason, "</td>", sep="\n")
        # close the row
        skip_string = paste(skip_string, "</tr>", sep="\n")
      }
      skip_string = paste(skip_string, "</table>", sep="\n")
      paste(skip_string)
    }
  })
  
  ##########################################
  output$mixpanelEvent_job_id <- renderText({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      paste0("<script>mixpanel.track('goldbusters convert_report job_id',{job_id: ",job_id(),"})</script>")
    }
  })
  
  
  output$mixpanelEvent_job_id_goldified <- renderText({
    if (is.na(input$jobID)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      paste0("<script>mixpanel.track('goldbusters goldify job_id',{job_id: ",input$jobID,"})</script>")
    }
  })
  
})

