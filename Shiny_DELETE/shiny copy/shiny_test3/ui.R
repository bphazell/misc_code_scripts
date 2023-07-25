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
                  selected = "csv")
    
      
    ),
  
    mainPanel(
      fileInput("file", label="Upload File", accept=c('.csv'), multiple=FALSE),
      br(),
      tableOutput("filetable"),
      br()



      )
  )
))
