shinyUI(fluidPage (
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
		br(),
		checkboxInput("add_unique", "Add Unique Identifier"),
		br(),

		fileInput("file1", label="Upload File"),
		div(class="btn btn-success", 
		downloadButton("download_file", "Download File")),
		br(),
		br(),
		uiOutput("choose_columns"),
		br(),
		uiOutput("unique_identifer"),
		br(),
		downloadButton("downlaod_dupes", "Download Duplicate Units"),
		downloadButton("downlownload_unique", "Dowload Unique Units")





			),
		mainPanel(
			tabsetPanel(
				tabPanel("Full File",
					tableOutput('contents')
				),
				tabPanel("Plot", 
					plotOutput("plot"),
					br(),
					downloadButton("download_plot", "Download Plot")

				),
				tabPanel("Summary",
					uiOutput("summary")
					),

				tabPanel("URL Verifer (beta)",
					uiOutput("url_column"),
					br(),
					actionButton('url_finder', "Check Working URLs"),
					downloadButton("download_broke_urls", "Download Non-workind URLs"),
					downloadButton("download_working_urls", "Download Working URLs"),
					br(),
					tableOutput('url_contents')

					)

					)


			


			)

			)

		)



	)

	