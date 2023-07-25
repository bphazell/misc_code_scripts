#### replay for job csvs - server.R part ###
source('../.Rprofile.apps')

require('shiny')
require('datasets')

options(stringsAsFactors=F)

shinyServer(function(input, output) {
  output$filetable <- renderTable({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    input$files
  })
  
  output$rowStats <- renderText({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    my_spotcheck = read.csv(input$files$datapath, na.strings="NaN", stringsAsFactors=FALSE)
    paste("The SpotCheck you uploaded had", nrow(my_spotcheck),"rows.")
  })
  
  output$textAccuracy <- renderText({
    if (is.null(input$files) && input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    }
    paste("This is your accuracy:")
  })
  
  output$mixpanelEvent_job_id <- renderText({
    if (is.null(input$files)  && input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      if (input$job_id!=0) {
        paste0("<script>mixpanel.track('spotchecker job_id',{job_id: ",input$job_id,"})</script>")
      } else {
        inFile = input$files$name
        job_id = gsub(inFile, pattern="^spotcheck", replacement="")
        job_id = str_extract(job_id, "\\d{6}")
        print(job_id)
        print("job_id")
        paste0("<script>mixpanel.track('spotchecker job_id',{job_id: ",job_id,"})</script>")
      }
    }
  })
  
  output$mixpanelEvent_accuracy <- renderText({
    if (is.null(input$files)  && input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      accuracies = accuracy_reactive()
      pasted_accuracies = ""
      pasted_accuracies = paste0(pasted_accuracies,
                                 paste(round(accuracies,2), collapse="_"))
      paste0("<script>mixpanel.track('spotchecker accuracy',{accuracy: ",pasted_accuracies,"})</script>")
    }
  })
  
  output$tableHeader <- renderText({
    if (is.null(input$files) && input$job_id==0) {
      # User has not uploaded a file yet
      print("null")
      return(NULL)
    } else if (input$expand) {
      paste("...and here are your performance statistics! (expanded)")
    } else
      paste("...and here are your performance statistics!")
  })
  
  output$ave_tableHeader <- renderText({
    if (is.null(input$files) || !input$average) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      paste("Average stats (use with caution):")
    } 
  })
  
  accuracy_reactive <- reactive({
    if (is.null(input$files) && input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else if (input$job_id > 0) {
      inFile = input$job_id
      #tryCatch(
      system(paste('s3cmd --force get s3://crowdflower_prod/spotcheck',
                   inFile,'.csv.zip /tmp/spotcheck', inFile, '.zip',sep=''),
             intern=T)
      #,
      #      finally=stop(paste("Job", input$job_id,
      #                   "is not a SpotCheck or SpotCheck
      #                   Report hasn't been generated yet!")))
      
      system(paste('unzip -o /tmp/spotcheck', inFile, '.zip -d /tmp', sep=''))
      #   tryCatch(my=read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep='')),
      #                error = stop("The csv you required is not available"))
      #   my_spotcheck = read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep=''))
      
      val <- try(read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep='')), silent=TRUE)
      if (inherits(val, "try-error"))
        stop(paste("Sorry, we could not find your file. Either job", input$job_id,
                   "is not a SpotCheck or SpotCheck Report hasn't been generated yet.",
                   "Check", paste("http://crowdflower.com/jobs/",input$job_id,"/reports.",sep=""),
                   "\nRefresh this page before uploading a csv."))
      else
        my_spotcheck = read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep=''))
      log_id = inFile
    } else {
      
      my_spotcheck = read.csv(input$files$datapath, na.strings="NaN", stringsAsFactors=FALSE)
      log_id = input$files$name
    }
    my_spotcheck[is.na(my_spotcheck)]=""
    
    answer_cols = grepl("\\.answer",names(my_spotcheck)) & !grepl("gold_data",names(my_spotcheck))
    gold_cols = grepl("\\.gold_answer",names(my_spotcheck)) & !grepl("gold_data",names(my_spotcheck))
    correct_cols = grepl("\\.correct",names(my_spotcheck)) & !grepl("gold_data",names(my_spotcheck))
    
    answer_names = names(my_spotcheck)[answer_cols]
    gold_names = names(my_spotcheck)[gold_cols]
    correct_names = names(my_spotcheck)[correct_cols]
    
    answer_df = data.frame(my_spotcheck[,answer_cols])
    gold_df = data.frame(my_spotcheck[,gold_cols])
    correct_df = data.frame(my_spotcheck[,correct_cols])
    correct_df
    
    accuracy_matrix = matrix(nrow=1, ncol=length(answer_names), dimnames=list(c("accuracy"),gsub(answer_names,pattern="\\.answer",replacement="")))
    
    for (i in 1:length(answer_names)) {
      # accuracy - the number of correct units over the number of all units
      accuracy = sum(correct_df[,i])/length(correct_df[,i]) # <---------- change this to a constant var
      print(accuracy)
      accuracy_matrix[,i] = accuracy
    }
    
    log_accuracy_matrix = cbind(id = log_id, timestamp=format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                                mean_accuracy=mean(accuracy_matrix),
                                meta_data = paste('[',paste(colnames(accuracy_matrix), collapse=';'),
                                                  ']:[',paste(accuracy_matrix, collapse=';'),']', sep='')) 
    #write.table(log_accuracy_matrix, file='/var/log/shiny-server/spotchecker_logs.csv',
    #            append=TRUE, na="",
    #            col.names=F, row.names=F, sep=',')
    
    accuracy_matrix
  })
  
  
  output$accuracyTable <- renderTable({
    accuracy_matrix = accuracy_reactive()
  })
  
  # the long table with Recall and Precision
  output$spotcheckTable <- renderTable({
    if (is.null(input$files) && input$job_id==0) {
      # User has not uploaded a file yet
      return(NULL)
    } else if (input$job_id > 0) {
      inFile = input$job_id
      #tryCatch(
      system(paste('s3cmd --force get s3://crowdflower_prod/spotcheck',
                   inFile,'.csv.zip /tmp/spotcheck', inFile, '.zip',sep=''))
      #,
      #                finally=stop(paste("Job", input$job_id,
      #                   "is not a SpotCheck or SpotCheck
      #                   Report hasn't been generated yet!")))
      system(paste('unzip -o /tmp/spotcheck', inFile, '.zip -d /tmp', sep=''))
      #my_spotcheck = read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep=''))
      val <- try(read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep='')), silent=TRUE)
      if (inherits(val, "try-error"))
        stop("Couldn't find your file.")
      else
        my_spotcheck = read.csv(paste('/tmp/spotcheck',inFile,'.csv',sep=''))
      
      
    } else {
      
      my_spotcheck = read.csv(input$files$datapath)
    }
    
    my_spotcheck[is.na(my_spotcheck)]=""
    
    answer_cols = grepl("\\.answer",names(my_spotcheck)) & !grepl("gold_data",names(my_spotcheck))
    gold_cols = grepl("\\.gold_answer",names(my_spotcheck)) & !grepl("gold_data",names(my_spotcheck))
    correct_cols = grepl("\\.correct",names(my_spotcheck)) & !grepl("gold_data",names(my_spotcheck))
    
    answer_names = names(my_spotcheck)[answer_cols]
    gold_names = names(my_spotcheck)[gold_cols]
    correct_names = names(my_spotcheck)[correct_cols]
    
    answer_df = data.frame(my_spotcheck[,answer_cols])
    gold_df = data.frame(my_spotcheck[,gold_cols])
    correct_df = data.frame(my_spotcheck[,correct_cols])
    print(correct_df)
    
    cml = list()
    
    for (i in 1:length(answer_names)) {
      # accuracy - the number of correct units over the number of all units
      accuracy = sum(correct_df[,i])/length(correct_df[,i]) # <---------- change this to a constant var
      print(accuracy)
      # get unique values from both answer and gold vectors - these are "levels" of the variable
      var_levels = unique(c(answer_df[,i],gold_df[,i]))
      var_levels = var_levels[!grepl(var_levels,pattern="\n")]
      if (length(var_levels) > 10 && !input$expand) {
        answer_df[,i][answer_df[,i]!=""] = "SOME_INPUT"
        gold_df[,i][gold_df[,i]!=""] = "SOME_INPUT"
        correct_df[,i] = as.numeric(answer_df[,i]==gold_df[,i])
        var_levels = unique(c(answer_df[,i],gold_df[,i]))
        var_levels = var_levels[!grepl(var_levels,pattern="\n")]
      }
      
      var_levels = var_levels[order(var_levels)]
      print(var_levels)
      # now if there are more than 2 levels, there will be separate recall and precision stats for every level!
      
      #if (length(var_levels) >2 ) {
      conf_matrix = matrix(nrow=length(var_levels), ncol=6,
                           dimnames=list(NULL,c("question","answer","gold units w/positive", "accuracy_for_answer","recall","precision")))
      j=1
      for (level in var_levels) {
        answer_level = (answer_df[,i]==level)
        if (level == "") {
          gold_level = (gold_df[,i]==level)
        } else {
          gold_level = grepl(gold_df[,i],pattern=level)
        }
        # cases where answer=level and the unit is correct (so gold=level too) - that's a true positive
        true_positives = sum(answer_level & gold_level) # correctly identified as A
        # cases where answer!=level and the unit is correct (so gold!=level too) - that's a true negative
        true_negatives = sum(!gold_level & !answer_level) # something other than A if A is not the gold answer
        # cases where answer=level BUT the unit is incorrect (so gold!=level) - that's a FALSE positive
        false_positives = sum(!gold_level & answer_level) # identified as A but wrong
        # cases where answer!=level BUT the unit is incorrect (so gold=level OR some other level) - that's a FALSE negative <---- this needs to change!
        false_negatives =sum(gold_level & !answer_level) # not identified as A when it was A
        # false_negatives = sum(abs(correct_df[,i][!answer_level]-1))
        # This is the 1 number for all levels of category
        print((true_positives + true_negatives)/(true_positives + false_positives + false_negatives + true_negatives))
        accuracy = round(sum(correct_df[,i][gold_level])/sum(gold_level),2)
        
        total_units = true_positives + false_positives + false_negatives + true_negatives
        total_golds = sum(gold_level)
        # "Recall" is the precent of units that WERE INDEED "positive" that have been identified correctly
        recall = round(true_positives/(true_positives + false_negatives),2)
        # "Precision" is the percent of units that WERE JUDGED "positive" that were indeed positive (were judged correctly)
        precision = round(true_positives/(true_positives + false_positives),2)
        conf_matrix[j,] = c("",level, total_golds, accuracy, recall, precision)
        j=j+1
      }
      
      conf_matrix[,1]= rep(gsub(answer_names[i], pattern="\\..*", replacement=""), times = length(var_levels))
      
      cml[[i]] = conf_matrix 
    }
    
    final_table = t(cml[[1]])
    if (length(cml)>1) {
      for (num in 2:length(cml)) {
        final_table = cbind(final_table, t(cml[[num]]))
      }
    }
    t(final_table)
  })
})
