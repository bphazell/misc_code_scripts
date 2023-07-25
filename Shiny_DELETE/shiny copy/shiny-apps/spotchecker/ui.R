library(shiny)


shinyUI(pageWithSidebar(
  headerPanel("SpotChecker"),
  sidebarPanel(
    includeHTML("../shared/mixpanel.js"),
    HTML("<script>mixpanel.track('spotchecker')</script>"),
    numericInput("job_id", h4("Paste your job id here"), 0),
    fileInput("files", h4("OR Select a spotcheck file:"), multiple=FALSE),
    h4("***"),
    h4("Accuracy:"),
    helpText("Percent of units where gold (true) values and crowd's answers match."),
    h4("Recall:"),
    helpText("For a given gold response (A), Recall is the percent of units with true A-s that were identified as A-s."),
    helpText(em("true_positives / (true_positives + false_negatives)")),
    h4("Precision:"),
    helpText("For a given crowd response (B), Precision is the percent of the units that the crowd identified as B-s that were indeed B-s"),
    helpText(em("true_positives / (true_positives + false_positives)")),
    h4(a(href='https://jira.crowdflower.com/wiki/display/services/SpotChecker+How+To',
          "SpotChecker How To", target="_blank"))
  ),
  mainPanel(
               h4(textOutput("rowStats")),
               htmlOutput("mixpanelEvent_job_id"),
               htmlOutput("mixpanelEvent_accuracy"),
               h4(textOutput("textAccuracy")),
               tableOutput("accuracyTable"),
               checkboxInput("expand", "Click to expand categories with more than 10 levels."),
               h4(textOutput("tableHeader")),
               tableOutput("spotcheckTable"),
               checkboxInput("average", "Click to show average Recall/Precision"),
               h4(textOutput("ave_tableHeader")),
               tableOutput("ave_spotcheckTable")
               
    )
  
  ))
