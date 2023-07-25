shinyUI(fluidPage(
	titlePanel("Demo2 For Uploads"),


	sidebarLayout(
		sidebarPanel(
		selectInput("data_type",
      label="Select the File Format",
      choices=list("Comma Separated (.csv)" = ",",
                "Tab Separated (.tsv)" = "/t",
                 "Pipe Separated" = "|",
                 "Excel (.xlsx)" = "excel"),
                  selected = ","),
		br(),
		radioButtons("quote","Quote",
					c('None' = '',
					  'Double Quote' = '"',
					  'Single Quote' = "'"),
						'Double Quote'),

		fileInput("file1", label="Upload File"),
		
		downloadButton("download_file", "Download File"),
		br(),
		br(),
		uiOutput("choose_columns"),
		br(),
		uiOutput("unique_identifer"),
		br()
		#downloadButton("downlaod_dupes", "Split Duplicates")





			),
		mainPanel(
			tabsetPanel(
				tabPanel("Full File",
					tableOutput('contents')
				),
				tabPanel("Plot", 
					plotOutput("plot")
				),
				tabPanel("Summary",
					uiOutput("summary")
					

					)


					)


			)

			)

		)



	)

	