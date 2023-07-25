shinyUI(fluidPage(
  titlePanel("My Test App"),
  
  sidebarLayout(
    sidebarPanel(
    selectInput("data_type",
      label="Select the File Format",
      choices=list("Comma Separated (.csv)" = "csv",
                "Tab Separated (.tsv)" = "/t",
                 "Pipe Separated" = "|",
                 "Excel (.xlsx)" = "excel"),
                  `  = "csv"),
    actionButton("write_csv","Write csv to desktop"),
    br(),
    textOutput("csv_confirmed")
    
      
    ),
  
    mainPanel(
      fileInput("file", label="Upload File"),
      br(),
      tableOutput("filetable"),
      br(),
      #downloadButton("download_data", "Download")



      )
  )
))
