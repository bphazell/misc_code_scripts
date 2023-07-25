
require('gdata')
require('ggplot2')
source('read_script.R')
options(shiny.maxRequestSize=150*1024^2)

shinyServer(
	function(input,output){

		output$contents <- renderTable({
			inFile <- input$file1

			if(is.null(inFile)){
			return(NULL)
			}
			df = grab_file()
			if (nrow(df) > 50){
				max_count = min(50, nrow(df))
				df = df[1:max_count,]
				df
			}
			df

			})

		grab_file <- reactive({
		  if(is.null(input$file1)){
			return(NULL)
		   } else {
		   	inFile <- input$file1
		   	df = read_data(inFile$datapath, input$data_type, input$quote)
		   	df
		  }
		})

		grab_col <- reactive({
		  if(is.null(input$file1)){
			return(NULL)
		   } else {
		   	inFile <- input$file1
		   	df = read_data(inFile$datapath, input$data_type, input$quote)
		   	col = input$plot_display
		   	col
		  }
		})

		#Shiny grays out with muliple download handlers

		 # output$downlaod_dupes <- reactive({
		 # 	inFile <- input$file1
		 

			# # if(is.null(inFile)){
			# # return(NULL)
			# # }
		 # 	downloadHandler(

			# filename = function(){
			# 	name = input$file1
			# 	name = gsub("\\.(.*)","_duplicates.csv",input$file1)
			# 	return(name)
			# },

			# 	content = function(file) {
			# 	inFile <- input$file1
			# 	df = grab_file()
			# 	#col = grab_col()
			# 	col = input$unique
			# 	#df = add_identifier(df)


			# df = split_dupes(df,col)
			# #return(files)
			# #dupes =remove_x(df)

			# #no_dupes = remove_x(files[2])

			# write.csv(df,"test.csv",row.names=F, na="")

		 # 	}
		 # 	)
		 # 	})

		output$download_file <- downloadHandler(

			filename = function(){
				name = input$file1
				name = gsub("\\.(.*)",".csv",input$file1)
				return(name)
			},
			content = function(file) {
				inFile <- input$file1
				df = grab_file()
				df =remove_x(df)
				#df = add_identifier(df)
				write.csv(df,file,row.names=F, na="")
			})

		output$choose_columns <- renderUI({
			inFile <- input$file1
			if(is.null(inFile)){
				return(NULL)
			}
			df = grab_file()
			col = return_columns(df)
			
				selectInput("plot_display", "Select Column for Plot", col, selectize = FALSE, multiple = F)

			})

		output$unique_identifer <- renderUI({
			inFile <- input$file1
			if(is.null(inFile)){
				return(NULL)
			}
			df = grab_file()
			col = return_unique(df)
			selectInput("unique", "Select Unique Identifier for Summary", col, selectize = FALSE, multiple = F)

			})

		output$plot <- renderPlot({
			inFile <- input$file1
			if(is.null(inFile)){
				return(NULL)
			}


			df = grab_file()
			col = grab_col()
			df = df[order(df[,col]),]
			#df = df[unique(df[,col]),]

			if (nrow(df) > 50){
				max_count = min(50, nrow(df))
				df = df[1:max_count,]
			}

			plot =qplot(x=df[,col], geom='bar', fill=as.character(df[,col])) +  xlab(col) + guides(fill=guide_legend(title=col)) + scale_colour_brewer(palette="Blues") +  theme(axis.text.x = element_text(angle = 45))

			
			print(plot)
	
			

			})

# Table Limiter
# worker_table= profile_similar_workers()
# if (length(worker_table$X_worker_id) > 50){
# max_count = min(50, nrow(worker_table))
# worker_table = worker_table[1:max_count,]
# }

		output$summary <- renderText({
			inFile <- input$file1
			if(is.null(inFile)){
				return(NULL)
			}
			df = grab_file()
			col = input$unique
			#col = grab_col()
			name = names(df[col])
			{HTML(
			output_summary(df, name))}

			})

	}

	)