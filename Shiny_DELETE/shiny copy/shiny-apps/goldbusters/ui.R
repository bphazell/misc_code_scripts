######### this is the ui part of the Goldbusters app ###################
source('../.Rprofile.apps')

library(shiny)
print("at least i'm running")
# Define UI
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Make your job a golddigging job!"),

  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    includeHTML("../shared/mixpanel.js"),
    HTML("<script>mixpanel.track('goldbusters')</script>"),
    selectInput("make_spotcheck",
                label = "Golds with Reasons or Spotcheck?",
                choices = c("Golds" = "gold",
                            "Spotcheck!"= "spotcheck"),
                selected = "gold"),
    numericInput("jobID", h4("Id of the job to be goldified:"), ""),
    br(),
    p("This job will be copied with data, modified CML, disabled Golds,
      and advanced setting optimized for the GoldBusters."),
    br(),
    #h4("Type any Gold-specific Instructions here (as HTML):"),
    #HTML('<textarea id="foo" rows="10" cols="60" width="100%"><li>This task is very subjective,
    #     don\'t forget to include musltiple correct answers in your Golds!</li>
    #     <li>Question X demands your special attention because...</li>
    #     <li>Please help us find units that are Y! We\'d like to have a few Golds with Y tags.
    #     You can skip the N tags because they are too popular.</li></textarea>'),
    #br(),
    #p("You can also make edits to Instructions directly in the job after it gets processed."),
    br(),
    h4(a(href='https://crowdflower.atlassian.net/wiki/display/PROD/GoldBusters',
         "Detailed Description Here", target="_blank"))
  ),

  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    HTML("<script>mixpanel.track_links('a', 'goldbusters tab_or_link_click', function(ele) { return { type: $(ele).text()}})</script>"),
    tabsetPanel(
      tabPanel("Send to GoldBusters",
               htmlOutput("link_and_comment"),
               p(textOutput("get_json")), #1
               p(textOutput("transform_css")), #2
               p(textOutput("transform_instructions")), #3
               p(textOutput("transform_title")), #4
               p(textOutput("transform_cml")), #5
               p(textOutput("copy_job")), #6
               p(textOutput("copy_job_with_settings")), #7
               p(textOutput("update_title")), #8
               p(textOutput("update_css")), #9
               p(textOutput("update_instructions")), #10
               p(textOutput("update_cml")), #11
               p("***If every line above has turned grey, your job is being goldified. Patience!"),
               htmlOutput("mixpanelEvent_job_id_goldified")
      ),
      tabPanel("View Goldified CML (debug manually)",
               downloadButton('downloadCML', 'Download CML as file'),
               h4("You can also examine the CML below. Do NOT copy and paste from this screen, use the download button instead (preseves newlines)."),
               p(textOutput("new_cml"))
      ),
      tabPanel("Make a Gold Report",
               p("In your GoldBusters job, go to \"Results\" and generate a full report. Download."),
               p("Upload the full report here."),
               fileInput("files", h4("Full report from a GoldBusters job:"), multiple=FALSE),
               h4(textOutput("report_stats")),
               downloadButton('downloadGolds', '<h4>Download Golds as Gold Report</h4>'),
               h4(textOutput("skip_lecture")),
               downloadButton('downloadSkips', 'Download Skips'),
               h4(textOutput("sample_skip_text")),
               htmlOutput("sample_skip_reasons"),
               HTML("<script>mixpanel.track_links('#downloadGolds', 'goldbusters downloadGolds')</script>"),
               HTML("<script>mixpanel.track_links('#downloadSkips', 'goldbusters downloadSkips')</script>"),
               htmlOutput("mixpanelEvent_job_id")
      )
    )
    # would you like to add instructions?

  )))
