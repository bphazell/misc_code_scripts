shinyUI(fluidPage (
	titlePanel("Data Diver"),


	sidebarLayout(
		sidebarPanel(
			HTML("<h4>Upload Your Data</h4>"),
			selectInput("data_type",
				label="1. Select the File Format",
				choices=list("Comma Separated (.csv)" = ",",
					"Tab Separated (.tsv)" = "/t",
					"Pipe Separated" = "|",
					"Excel (.xlsx)" = "excel"),
				selected = ","),
			br(),

		# selectInput("quote","2. Select Text Delimiter",
  #       choices=c('Double Quote' = '\\"',
  #                'Single' = "\\'"),
  #                 'Double Quote'),	



		radioButtons("quote",
			label="2. Select Text Delimiter",
			choices = list('None' = '',
				'Double Quote' = '"',
				'Single Quote' = "'"),
			'Double Quote'),
		 br(),
		 fileInput("file1", label="3. Upload File")
	
		

		),
		mainPanel(
			tabsetPanel(
				tabPanel("Convert Data",
					htmlOutput("convert_description"),
					br(),
					checkboxInput("add_unique", "Add Unique Identifier"),
					br(),
					downloadButton("download_file", "Download as CSV"),
					br(),
					br(),
					htmlOutput("first_50"),
					br(),
					tableOutput('contents'),
					tags$style(type="text/css", ".img { overflow: visible; }", ".img { height: 150%; }")

				),
				tabPanel("Create Plot",
					HTML("<h6 style='color:black'>You can create a histogram of a column with up to 20 unique values.</h6>"),
					uiOutput("choose_columns"),
					br(),
					uiOutput("action_plot"),
					br(),
					downloadButton("download_plot", "Download Plot"),
					br(),
					plotOutput("plot"),
					br(),
					uiOutput("col_summary")

				),
				tabPanel("Dedupe Data",
					HTML("<h4 style='color:#1f78b4'>Remove Duplicate Rows From the CSV</h4>"),
					uiOutput('dupe_summary_row'),	
					br(),
					downloadButton("download_dupes_by_row", "Download Duplicate Rows"),
					downloadButton("downlownload_unique_by_row", "Dowload Unique Rows"),
					hr(),
					hr(),
					HTML("<h4 style='color:#1f78b4'>Or Remove Rows With Duplicate Values in a Single Column</h4>"),
					 h5("1. Select the column you are using as the unique identifier"),
					uiOutput("unique_identifer"),
					hr(),
					 h5("2. Review the number of duplicate rows"),
					uiOutput('dupe_summary_col'),
					hr(),
					h5("3. Download all rows that are duplicates or unique based off the unique identifier"),
					downloadButton("download_dupes", "Download Rows with Duplicate Values in Column"),
					downloadButton("downlownload_unique", "Download Rows with Unique Values in Column")
					),

				tabPanel("Data Distributions",
					uiOutput("summary")
					)

					)
			)

			)

		)



	)

	