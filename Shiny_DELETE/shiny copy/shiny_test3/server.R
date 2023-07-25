require('shiny')
require('plyr')
require('datasets')
require('devtools')

options(stringsAsFactors = FALSE)


shinyServer(
  function(input, output) {

output$filetable <- renderTable(function(){
	if(is.null(input$file)){
		return(NULL)
	}

	in_file <- input$file
	in_file

	sample_data = read.csv(in_file$datapath, na.strings="NaN")
	sample_data

	})
  

  }
)