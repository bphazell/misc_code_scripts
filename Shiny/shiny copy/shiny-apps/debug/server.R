message("Blah")
source('../.Rprofile.apps')
library(shiny)
library(datasets)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {

  # Return the requested dataset
  datasetInput <- reactive({
    switch(input$dataset,
           "rock" = rock,
           "pressure" = pressure,
           "cars" = cars)
  })

  # Generate a summary of the dataset
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })

  output$debug.libpath <- renderPrint({.libPaths()})
  output$debug.cwd <- renderPrint({getwd()})
  output$debug.env <- renderPrint({Sys.getenv()})
  output$debug.session_info = renderPrint({sessionInfo()})

  # Show the first "n" observations
  output$view <- renderTable({
    head(datasetInput(), n = input$obs)
  })
})
