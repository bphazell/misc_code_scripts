options(java.parameters = "-Xmx1000m")
options(shiny.maxRequestSize=150*1024^2)
options(stringsAsFactors=F)

require('gdata')
require('ggplot2')
require('devtools')
require('xlsx')
source('read_script.R')

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
		df = as.data.frame(df[1:max_count,])
		df
	}
	df

	})

# Displaying first 50 rows----------------------------------------------

output$first_50 <- renderText({
	inFile <- input$file1

	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	rows = nrow(df)
	string = paste0("<h6 style='color:#1f78b4'>Displaying the first 50 of ",rows," rows in file:</h6>")
	string
	})

output$convert_description <- renderText({
	inFile <- input$file1

	if(is.null(inFile)){
		#string = "<h6 style='color:grey'>First, upload your data</h6>"
		return(NULL)
	}

	string = "<h6 style='color:black'>Make sure your file renders correctly below. If everything looks good, click 'Dowload as CSV' to convert your data.</h6>"
	string
	})




# Render column featuring urls -------------------------------------------------------------------------------------------------------
check_url_find <- reactive({
	inFile <- input$url_finder

	if(is.null(inFile)){
		return(NULL)
	} else{
		#print("check_url_find server 29")
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
			df = as.data.frame(read_data(inFile$datapath, input$data_type, input$quote))
			if(input$add_unique){
				df$unique_id = 1:nrow(df)
			}
  			#names(df) = gsub("X_", "_", names(df))
			print("running grab _file")
			print(nrow(df))
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
			col = input$unique
			print(col)
			print(paste0("in grab unique: ", col))
			col
		}
		}) 

# Download csv featuring all duplicate rows based off unique identifier ---------------------------------------------------------------------------------


output$download_dupes <- downloadHandler(

	filename = function() { 
		gsub("\\.(.*)","_duplicates.csv",input$file1) 
		},

		content = function(file) {
			df = grab_file()
			col = grab_unique()
			print(paste0("this is unique in download_dupes ", col))
			new_df = split_dupes_by_col_duplicates(df,col)

			write.csv(new_df, file, row.names =F, na="")

			})


# Download csv featuring all unique rows based off unique identifier ---------------------------------------------------------------------------------


 output$downlownload_unique <- downloadHandler(

 	filename = function(){
 		gsub("\\.(.*)","_row_unique_only.csv",input$file1) 
 		},
 		content = function(file) {
 			df = grab_file()
 			col = grab_unique()
 			new_df = split_dupes_by_col_unique(df, col)
 			write.csv(new_df, file, row.names =F, na="")
 			})

# Download csv featuring all duplicate rows based off row ---------------------------------------------------------------------------------


output$download_dupes_by_row <- downloadHandler(

	filename = function() { 
		gsub("\\.(.*)","_row_duplicates.csv",input$file1) 
		},

		content = function(file) {
			df = grab_file()
			new_df = dedupe_by_all_rows_duplicates(df)
			write.csv(new_df, file, row.names =F, na="")

			})

output$downlownload_unique_by_row <- downloadHandler(

	filename = function() { 
		gsub("\\.(.*)","_unique_only.csv",input$file1) 
		},

		content = function(file) {
			df = grab_file()
			new_df = dedupe_by_all_rows_unique(df)
			write.csv(new_df, file, row.names =F, na="")

			})


 

# Download Plot selected by "choose_columns" drop down --------------------------------------------------------------------------------------------------
	#Problem: grab_col not reactive, plot writes dafault graph

	output$download_plot <- downloadHandler(
		filename <- function(){
			paste0(grab_col(), "_answer_distribution.png") 
			},
			content <- function(file) {

  	png(file)
  	plot = make_plot()
  	print(plot)
  	dev.off()

  	},
  	contentType = 'image/png'
  	)


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
				write.csv(df,file,row.names=F, na="")
				})
# Render "choose_column" dropdown with headers from csv ---------------------------------------------------------------------------------------------------------------
output$action_plot <- renderUI({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	actionButton("action_plot", "2. Create Plot")


	})


output$choose_columns <- renderUI({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	col = return_columns(df)

	selectInput("plot_display", "1. Select the column you want to graphify", col, selectize = FALSE, multiple = F)

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
	selectInput("unique", "Unique Identifer:", col, selectize = FALSE, multiple = F)

	})


# Column stats to display below graph ----------------------------------------------------------
output$col_summary <- renderText({
	inFile <- input$file1
	if (is.null(inFile)){
		return(NULL)
	} else if (input$action_plot <1){
		return(NULL)
	} else {
	df = grab_file()
	col = grab_col
	print("in output$col_summary")
	col_stats()
}
	

	})

#Render Plot based off "choose columns" dropdown ________________________________________________________________________________________________________________________

output$plot <- renderPlot({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	else if(input$action_plot < 1){
		return(NULL)
	} else {

	df = grab_file()
	col = grab_col()
}


make_plot()
 
})

# Make Plot Function  ---------------------------------------------------------------------------------------------------------------------------------

make_plot = function(){
	df = grab_file()
	col = grab_col()
	df[,col] = as.character(df[,col])
   df = df[order(df[,col]),]
   x_data = df[col]
   x_data <- as.data.frame(sapply(x_data,gsub,pattern="^$",replacement="NA"))
   max_c = max(table(df[col]))
   height_mod = max_c*.10
   cbPalette <- c("#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f", "#ff7f00", 
   	"#cab2d6", "#6a3d9a", "#ffff99", "#b15928", "#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462",
   	 "#b3de69", "#fccde5")
  
 	plot_test <- ggplot(df, aes_string(x_data))
 	plot_test = plot_test + geom_histogram(aes_string(fill = (df[col]))) + 
        stat_bin(geom="text", aes(label = paste0((round((..count..)/sum(..count..)*100)),"%"), vjust=-1)) + expand_limits(y=c(0,max_c+height_mod)) +
        xlab(col)+ scale_fill_manual(values=cbPalette)+ theme(legend.position="none", axis.text.x=element_text(angle=-45,hjust=0))


   return(plot_test)
}

# Make column stats --------------------------------------------------------
col_stats = function(){
	df = grab_file()
	col = grab_col()
	array = df[,col]
	uni = unique(array)
	table = paste0("<hr><h4>",col," </h4><table border='1' cellpadding='5'><tr><td align='center'><b>Value</b></td><td align='center'><b>Count</b></td><td align='center'><b>Percentage</b></td></tr>")
	for(j in 1:length(uni)){
		uni_variable = uni[j]		  
		occurance = length(array[array == uni_variable])
		if (is.na(uni_variable) | uni_variable == ""){
			uni_variable = "NA"
		}
		if(j == length(uni)){

			row = paste0("<tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array), "</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,2)),"%"),"</td></tr></table><br><hr>")
			} else {
				row = paste0("<tr><td align='center'>",uni_variable,"</td><td align='center'>",occurance," / ", length(array),"</td><td align='center'>",paste0((round((occurance)/sum(length(array))*100,2)),"%"),"</td></tr>")
			}
			table = paste0(table,row)
		}
		{HTML(
			table
			)}	
	}


# Render Output Summary in Summary Tab ---------------------------------------------------------------------------------------------------------------------------------------

output$summary <- renderText({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	print("in grab file")
	print(length(df))
	new = output_summary(df)
			{HTML(
				new
				)}

			})


#Render Dupe Summary --------------------------------------------------------------------------------
output$dupe_summary_col <- renderText({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	col = input$unique
			name = names(df[col])
			{HTML(
				dupe_summary_by_col(df,name))}

			})

output$dupe_summary_row <- renderText({
	inFile <- input$file1
	if(is.null(inFile)){
		return(NULL)
	}
	df = grab_file()
	col = input$unique
			name = names(df[col])
			{HTML(
				dupe_summary_by_row(df))}

			})

}

)









