source('../.Rprofile.apps')

require('shiny')
require('devtools')
require('stringr')
require('rCharts')
require('rMaps')

# Code to make a message that shiny is loading
# Make the loading bar
loadingBar <- tags$div(class="progress progress-striped active",
                       tags$div(class="bar", style="width: 100%;"))
# Code for loading message
loadingMsg <- tags$div(class="modal shiny-progress", tabindex="-1", role="dialog", 
                       "aria-labelledby"="myModalLabel", "aria-hidden"="true",
                       tags$div(class="modal-header",
                                tags$h3(id="myModalHeader", "Loading...")),
                       tags$div(class="modal-footer",
                                loadingBar))
# The conditional panel to show when shiny is busy
loadingPanel <- conditionalPanel(paste("input.get_job > 0 && input.job_id > 0 &&", 
                                       "$('html').hasClass('shiny-busy')"),
                                 loadingMsg)

shinyUI(pageWithSidebar(
  headerPanel("Job Heart Monitor"),
  sidebarPanel(
    includeHTML("../shared/mixpanel.js"),
    HTML("<script>mixpanel.track('job_health')</script>"),
    h4("Enter a Job ID:"),
    HTML('<div class="row-fluid"><span class="span9">
     <input class=\"shiny-bound-input span9\" type=\"number\" id=\"job_id\" value=\"0\"></span>  
    <span class="span3"><button id="get_job" type="button" class="btn btn-info action-button shiny-bound-input">
    Submit</button></span></div>'),
    div(class="row-fluid",
        div("Don't forget to refresh the page for every new job id.", class="span7")
    ),
    br(),
    div(class="row-fluid",
        div(
          htmlOutput("job_summary_message"), 
          class="span10")
    ),
    div(class="row-fluid",
        div(
          htmlOutput("createJobHyperlink"), 
          class="span10")
    ),
    div(class="row-fluid",
        div(h4("Updates Log"),
            p("You changed the following:"),
            htmlOutput("enableQuiz"),
            htmlOutput("updateMjw"),
            htmlOutput("updateMjip"),
            htmlOutput("updatePay"),
            htmlOutput("updateAfterGold"),
            htmlOutput("updateRejectAt"),
            class="span10")
    ),
    div(class="row-fluid",
        div(h4("Search Settings Table"), 
            class="span10")
    ),
    div(class="row-fluid",
        div(
          dataTableOutput("settingsTable"), 
          class="span10")
    ),
    tags$style(type="text/css", ".dataTables_length select { visibility: hidden; }"),
    tags$style(type="text/css", ".dataTables_length label { visibility: hidden; }"),
    tags$style(type="text/css", ".shiny-datatable-output { overflow: scroll; }"),
    tagList(
      tags$head(
        tags$link(rel="stylesheet", type="text/css",href="style.css"),
        tags$link(rel="stylesheet", href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css"),
        tags$script(src="http://code.jquery.com/jquery-1.9.1.js"),
        tags$script(src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"),
        #tags$style(type="text/css", ".jslider { max-width: 245px; }"),
        #tags$style(type='text/css', ".well { max-width: 250px; }"),
        tags$style(type='text/css', ".row-fluid .span5 {width: 20%}\n.row-fluid .span7 {width: 75%}")
      )
    ),
    htmlOutput("renderLogo")
    #HTML('<script type="text/javascript" src="api_call.js"></script>')
  ),
  mainPanel(
    tabsetPanel(
      id="tab",
      #     tabPanel("",
      #              p("Load job data and click on the tabs to view recommendations.")),
      tabPanel("Alert Summary",
               loadingPanel,
               div(class="row-fluid",
                   div(htmlOutput("alerts_summary"), 
                   class="span10")
      )
    ),
    tabPanel("Quality Analysis",
             loadingPanel,
             div(class="row-fluid",
                 div(htmlOutput("quality_settings_warnings"), class="span12"),
                 div(htmlOutput("quality_settings_cautions"), class="span12")
             ),
             br(),
             div(class="row-fluid",
                 div(htmlOutput("quality_gold_errors"), class="span6"),
                 div(htmlOutput("quality_times_warnings"), class="span6")
             ),
             tabsetPanel(
               tabPanel("Test Question Quality:",
                   div(class="row-fluid",
                      div(p("Test Question Distributions"),
                        #a("Missed TQs Bar Chart", target="_blank", href="http://www.highcharts.com/demo/column-rotated-labels/grid-light"), 
                        showOutput("missed_contested_golds_chart", "highcharts"),
                        htmlOutput("gold_div_summary"),
                        class="well span12")),
                      div(class="row-fluid",
                          div(h4("Table of Missed & Contested Test Questions:"),
                              dataTableOutput("missedContestedTable"), class="span12")   
                      )
              ),
              tabPanel("Contributor Times & Quality:",
                  div(class="row-fluid",
                    div(p("Is anyone speeding?"),
                       #HTML('<script type="text/javascript" src="draggable_functions.js"></script>'),                           
                       showOutput("durations_chart", "highcharts"),
                       htmlOutput("bubbles_truncated"),
                       class="well span6"),
                    div(p("Are trusted contributors completing judgments?"),
                       showOutput("judgments_trust_chart", "highcharts"),
                       class="well span6")),
                  div(class="row-fluid",
                      div(h4("Table of Top Quartile Fastest Workers"),
                          dataTableOutput("fastWorkerTable"), class="span12")
                  ),
                  hr(),
                  div(class="row-fluid",
                    div(p("Map of Judgments"),
                      uiOutput("selectJudgments"),
                      showOutput("judgments_map", "datamaps"),
                      class="well span12")
                  )
              ) # Close Contributor Times tab
                    # div(p("Pending Graph Idea on Gold Value Distros"), 
                    #     a("Provided Gold Answers Bar Chart", target="_blank", href="http://www.highcharts.com/demo/column-rotated-labels/grid-light"),
                    #     class="span6 well"),
                    #div(p("Pending Graph Idea on Answer Distros"), 
                    #     a("Bar Chart Group by Gold Answers and Unit Answers", target="_blank", href="http://www.highcharts.com/demo/column-basic/grid-light"),
                    #     class="span5 well"),
                    # tableOutput("unit_summary") #,
                    #showOutput("durations_chart", "highcharts")
      ) #close tabset for Quality Analysis
    ),
    tabPanel("Throughput Analysis",
             loadingPanel,
             div(class="row-fluid",
                 div(htmlOutput("throughput_errors"), class="span6"),
                 div(htmlOutput("throughput_warnings"), class="span6")
             ),
             showOutput("tput_bar", "highcharts"),
             htmlOutput("maxed_out_summary"),
             htmlOutput("not_in_yet_summary"),
             htmlOutput("checked_out_summary"),
             htmlOutput("tainted_summary"),
             htmlOutput("working_summary"),
             #p("There will be a table here"),#,
             div(class="row-fluid alert alert-info",
                 htmlOutput("job_settings_message"))
    ),
    tabPanel("(Job History)",
             loadingPanel,
             div(class="row-fluid",
                 div(h3("Things WILL happen here."), class="span10")
             ),
             div(class="row-fluid",
                 div(dataTableOutput("renderHistory"), class="span10")
             ),
             div(class="row-fluid",
                 div(p("None of the useful updates are currently reflected in history json (payment, country, and skill updates all happen in Make). We will expose history here as soon as CF starts tracking these changes again (papertrail). Stay put!"), class="span10")
             )
             
    )
  )
)
))
