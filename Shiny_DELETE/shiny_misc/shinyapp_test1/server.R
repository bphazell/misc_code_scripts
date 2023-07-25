
require('gdata')
source("read_script.R")

shinyServer(
  function(input, output) {

output$filetable <- renderTable(function(){
	if(is.null(input$file)){
		return(NULL)
	}
	data_type = input$data_type
	inFile = input$file

	file_data = inFile$datapath
	print("server line 16")
	df =read_data(file_data, data_type)
	print("server line 18")
	df

	})

output$csv_confirmed <- renderText({
	if(input$write_csv != 0){
	"CSV written to desktop"

	}

output$csv_confirmed <-



#output$download_data <- downloadHandler(
#filename = function() { paste(input$file, '.csv', sep='') },
#content = function(file) {
 #     write.csv(input$file, filename(), na="",row.names=F)
  #  }
	


	#)


  

  }
)

