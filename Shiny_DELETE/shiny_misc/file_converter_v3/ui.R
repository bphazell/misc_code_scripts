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
		downloadButton("download_file", "Download File"),
		br()
		

			),
		mainPanel(
			tabsetPanel(
				tabPanel("Full File",
					tableOutput('contents')
				),
				tabPanel("Plot",
					uiOutput("choose_columns"),
					br(),
					uiOutput("action_plot"),
					br(),
					plotOutput("plot"),
					br(),
					downloadButton("download_plot", "Download Plot")

				),
				tabPanel("Summary",
					uiOutput("unique_identifer"),
					br(),
					downloadButton("download_dupes", "Download Duplicate Units"),
					downloadButton("downlownload_unique", "Dowload Unique Units"),
					uiOutput("summary")
					),

				tabPanel("URL Verifer (beta)",
					uiOutput("url_column"),
					br(),
					actionButton('url_finder', "Check Working URLs"),
					br(),
					br(),
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

	