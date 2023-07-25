
require('gdata')
require('ggplot2')
require('devtools')
require('xlsx')
source('read_script.R')
options(shiny.maxRequestSize=150*1024^2)

shinyServer(
	function(input,output){
# Render tabel in ui ------------------------------------------------------------------------------------------------------------------

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
# Render column featuring urls -------------------------------------------------------------------------------------------------------
check_url_find <- reactive({
	inFile <- input$url_finder

	if(is.null(inFile)){
		return(NULL)
	} else{
		print("check_url_find server 29")
		df = grab_file()
		col = grab_url()
		broke = url_validator(df, col)
		broke
	}
})


output$url_contents <- renderTable({
	inFile <- input$url_finder

	if(is.null(inFile)){
		return(NULL)
	}
	if(input$url_finder == 1){
		broke = check_url_find()
		print("renderTable url_contents")

			as.data.frame(broke[1])
		}

		})

# Grab file from data upload -----------------------------------------------------------------------------------------------------------------

grab_file <- reactive({
	if(is.null(input$file1)){
		return(NULL)
		} else {
			inFile <- input$file1
			df = read_data(inFile$datapath, input$data_type, input$quote)
			if(input$add_unique){
				df$unique_id = 1:nrow(df)
			}
  			names(df) = gsub("X_", "_", names(df))
			print("running grab _file")
			df
		}
		})

# Grab column selected by "choose_columns" dropdown menu --------------------------------------------------------------------------------------

grab_col <- reactive({
	if(is.null(input$file1)){
		return(NULL)
		} else {
			inFile <- input$file1
			col = input$plot_display
			print(col)
			col
		}
		})

# Grab Column featuring unique identifier by "unique_identifer" dropdown menu ----------------------------------------------------------------------

grab_unique <- reactive({
	if(is.null(input$file1)){
		return(NULL)
		} else {
			inFile <- input$file1
			col = input$url_column
			col
		}
		}) 
# Grab Column featuring Web Address by "url_column" dropdown menu ----------------------------------------------------------------------

grab_url <- reactive({
	if(is.null(input$file1)){
		return(NULL)
	}
	inFile <- input$file1
	col = input$url_column
	col

	})

# Download csv featuring all duplicate rows based off unique identifier ---------------------------------------------------------------------------------


output$downlaod_dupes <- downloadHandler(


	filename = function() { 
		gsub("\\.(.*)","_duplicates.csv",input$file1) 
		},

		content = function(file) {
			df = grab_file()
			col = grab_unique()
			new_df = split_dupes(df,col)

			write.csv(new_df[1], file, row.names =F, na="")

			})

# Download csv featuring all non working URLs ---------------------------------------------------------------------------------

output$download_broke_urls <- downloadHandler(
	filename = function() {
		gsub("\\.(.*)","_broken_urls.csv",input$file1) 
	},
	content= function(file){
		new_df = check_url_find()
		write.csv(new_df[1], file, row.names=F, na="")
	}

	)

# Download csv featuring all non working URLs ---------------------------------------------------------------------------------
output$download_working_urls <- downloadHandler(
	filename= function(){
		gsub("\\.(.*)","_working_urls.csv",input$file1) 
		},
	content = function(file){
		new_df = check_url_find()
		write.csv(new_df[2], file, row.names=F, na="")

	}

	)

 # Download csv featuring all unique rows based off unique identifier ---------------------------------------------------------------------------------


 output$downlownload_unique <- downloadHandler(

 	filename = function(){
 		gsub("\\.(.*)","_unique_only.csv",input$file1) 
 		},
 		content = function(file) {
 			df = grab_file()
 			col = grab_unique()
 			new_df = split_dupes(df, col)
 			write.csv(new_df[2], file, row.names =F, na="")
 			})

# Download Plot selected by "choose_columns" drop down --------------------------------------------------------------------------------------------------
	#Problem: grab_col not reactive, plot writes dafault graph

	output$download_plot <- downloadHandler(
		filename <- function(){
			paste0(grab_col(), "_answer_distribution.png") 
			},
			content <- function(file) {
  	#plot = qplot_dl()

  	png(file)
  	plot = make_plot()
  	print(plot)
  	dev.off()

  	},
  	contentType = 'image/png'
  	)

# qplot reactive function (substite for keeping function in download_plot)----------------------------------------------------------------------------------------
qplot_dl <-reactive({
	df = grab_file()
	col = grab_unique()
	plot = qplot(x=df[,col], geom='bar', fill=as.character(df[,col])) +  xlab(col) + guides(fill=guide_legend(title=col)) + scale_colour_brewer(palette="Blues") +  theme(axis.text.x = element_text(angle = 45))
	return(plot)

	})


# Download full csv file -----------------------------------------------------------------------------------------------------------------------------------------

output$download_file <- downloadHandler(

	filename = function(){
		name = input$file1
		name = gsub("\\.(.*)",".csv",input$file1)
		return(name)
		},
		content = function(file) {
			print("download_file")
				#inFile <- input$file1
				df = grab_file()
				df =remove_x(df)
				#df = add_identifier(df)
				write.csv(df,file,row.names=F, na="")
				})
# Render "choose_column" dropdown with headers from csv ---------------------------------------------------------------------------------------------------------------



output$choose_columns <- renderUI({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	col = return_columns(df)

	selectInput("plot_display", "Select Column for Plot", col, selectize = FALSE, multiple = F)

	})
# Render "url_column" dropdown with headers from csv ---------------------------------------------------------------------------------------------------------------

output$url_column <- renderUI({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	col = return_columns(df)
	selectInput("url_column", "Select Column Containing URLs", col, selectize=FALSE, multiple=F)
	})

# Unique Identifier for Summary -----------------------------------------------------------------------------------------------------------------------------------------

output$unique_identifer <- renderUI({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	col = return_unique(df)
	selectInput("unique", "Select Unique Identifier for Summary", col, selectize = FALSE, multiple = F)

	})

#Render Plot based off "choose columns" dropdown ________________________________________________________________________________________________________________________

output$plot <- renderPlot({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	# 		# if (nrow(df) > 50){
	# 		# 	max_count = min(50, nrow(df))
	# 		# 	df = df[1:max_count,]
	# 		# }
	plot = make_plot()

	plot



	})

# Make Plot Function  ---------------------------------------------------------------------------------------------------------------------------------

make_plot = function(){
	df = grab_file()
	col = grab_col()
	print("make_plot")
	print(paste0("make_plot ", grab_col() ))
	df = df[order(df[,col]),]
	plot =qplot(x=df[,col], geom='bar', fill=as.character(df[,col])) +  xlab(col) + guides(fill=guide_legend(title=col)) + scale_colour_brewer(palette="Blues") +  theme(axis.text.x = element_text(angle = 45))
	return(plot)

}




# Table Limiter
# worker_table= profile_similar_workers()
# if (length(worker_table$X_worker_id) > 50){
# max_count = min(50, nrow(worker_table))
# worker_table = worker_table[1:max_count,]
# }

# Render Output Summary in Summary Tab ---------------------------------------------------------------------------------------------------------------------------------------

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