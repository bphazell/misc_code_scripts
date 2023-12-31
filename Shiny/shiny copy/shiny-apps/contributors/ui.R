###contributor_profile_tab
### Last updated 03/21/2014
 

require('shiny')
require('rCharts')
require('devtools')
require('rworldmap')

shinyUI(pageWithSidebar(
  headerPanel("Contributor Slice-orama 4000"),
  sidebarPanel(
    div(numericInput("job_id", h4("Paste your job id here"), 0), class="span7", align="left"),
    br(),br(),
    div(actionButton("get_file", "Get Data"), class="span5"),
    br(),br(),
    p("No Progress? make sure the file has been generated in the job"),
    h4("*** OR ***"),
    fileInput("files", h4("Select a full report:"), multiple=FALSE, 
              accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
    h4("***"),
    uiOutput("countrySelector"),
    uiOutput("channelSelector"),
    uiOutput("timeSelector"),
    uiOutput("trustSelector"),
    uiOutput("judgSelector"),
    conditionalPanel
    (
      condition = '0==1',
      sliderInput("dummyslider", "", min=0, max=1, value=0)
    ),
    uiOutput("scambotSelector"),
    htmlOutput("summary_message"),
    htmlOutput("futurama"),
    tags$style(type="text/css", ".tab-content { overflow: visible; }", ".svg { height: 150%; }")
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Summary",
               div(h4("Times:"),
                   p("*in fractions of a second. So \"5.53\" is 5 seconds 53 hundreds of a second"),
                uiOutput("summary_times"), class="span8 offset1 well"),
               br(), br(),
               div(h4("Global Map of Judgments"), class="span8"),
               div(plotOutput("worldGraph"), class="span10"),
               div(h4("Most Judgments by Country:"),
                   uiOutput("summary_stats_country"),
                   p("*up to 10"), class="span5"),
               div(h4("Most Judgments by Channel:"),
                uiOutput("summary_stats_channel"), 
                p("*up to 10"), class="span5"),
               br(), br(),
               
               div(h4("Stacked Bar of Judgments by Channel"),
                plotOutput("stackedGraph"), class="span10")
               ),
      tabPanel("Contributor IDs Table",
               uiOutput("titleTextContributors"),
               selectInput(inputId = "sortby_chosen", label= "Sort By:",
                           c("Select One" = "none",
                             "Trust" = "sortby_trust",
                             "Number of Judgments" = "sortby_judgments",
                             "Last Submission" = "sortby_submit",
                             "Number of IPs" = "sortby_ips")),
               selectInput(inputId = "ascending", label= " ",
                           c("Ascending" = "ascending",
                             "Descending" = "descending")),
               textInput(inputId="id_chosen", 
                         label="Search by worker id:", value=""),       
               htmlOutput("create_html_table")
      ), 
      tabPanel("By IPs",
               uiOutput("titleTextIp"),
               selectInput(inputId = "sortby_chosen_ip", label= "Sort By:",
                           c("Select One" = "none_ip",
                             "Trust" = "sortby_trust_ip",
                             "Number of Judgments" = "sortby_judgments_ip",
                             "Last Submission" = "sortby_submit_ip",
                             "Number of IDs" = "sortby_ids")),
               selectInput(inputId = "ascending_ip", label= " ",
                           c("Ascending" = "ascending_ip",
                             "Descending" = "descending_ip")),
               textInput(inputId="ip_chosen", label="Search by IP:", value=""),
               htmlOutput("create_html_table_ip")
      ),
      tabPanel("Scambot", 
               tabsetPanel(
                 tabPanel("Plot & Choose",
                          plotOutput('plot',height=1000),
                          p("The judgments of workers that fall under the red line are highlighted in red. You can reject these people and remove their judgments in Burminator.")),
                 tabPanel("Reject Workers", 
                          uiOutput("dowloadSelector"),
                          uiOutput("actionSelector"),
                          tags$style(type="text/css", 
                                     ".shiny-download-link { background-color: #da4f49;background-image: -moz-linear-gradient(top,#ee5f5b,#bd362f);
                                     background-image: -webkit-gradient(linear,0 0,0 100%,from(#ee5f5b),to(#bd362f));
                                     background-image: -webkit-linear-gradient(top,#ee5f5b,#bd362f);
                                     background-image: -o-linear-gradient(top,#ee5f5b,#bd362f);
                                     background-image: linear-gradient(to bottom,#ee5f5b,#bd362f);
                                     background-repeat: repeat-x;
                                     color: #fff;}"),
                          p(),
                          htmlOutput("flag_some_workers"),
                          htmlOutput("offenders"),
                          p(),
                          p("Burninator How-to:"),
                          p("You can click on blue ids under X_worker_id to see the workers' profile pages in the platform."),
                          p("All times on this page (max_assignment_time and min_assignment_time) are in fractions of a second. So \"5.53\" is 5 seconds 53 hundreds of a second."))
                          ) 
                ),
      tabPanel("Profiles",
               h4("Contributor Profiles by Worker ID"),
               textInput(inputId="id_chosen_profiles", 
                         label="Search for a worker and their judgments:", 
                         value=""),
               htmlOutput("create_profile_table"),
               br(),
               tabsetPanel(
                 tabPanel("Unit Data",
                          
                          h4("Total Number of Units"),
                          uiOutput("profileUnitCount"),
                          h4("Units Seen"),
                          p("Random sample of 15 units"),
                          checkboxInput(inputId="all_units_chosen",
                                        label="Show all units"),
                          htmlOutput("html_unit_table"),
                          h4("Answer Distros"),
                          uiOutput("profileQuestionSelector"),
                          p("*Graph's default order is by most common answers by Individual on non-Golds"),
                          checkboxInput(inputId="units_order_chosen", label="Show most common answers by all"),
                          showOutput("profile_units_distros", "nvd3"),
                          htmlOutput("unitDistrosExplain"),
                          br()
                 ),
                 tabPanel("Gold Data",
                          h4("Total Number of Golds"),
                          uiOutput("profileGoldCount"),
                          h4("Golds Seen"),
                          p("Random sample of 15 golds"),
                          checkboxInput(inputId="all_golds_chosen",
                                        label="Show all golds"),
                          htmlOutput("html_gold_table"),
                          h4("Gold Distros"),
                          uiOutput("profileQuestionSelectorGolds"),
                          p("*Graph's default order is by most common answers by Individual on Golds"),
                          checkboxInput(inputId="golds_order_chosen", label="Show most common answers by all on Golds"),
                          showOutput("profile_golds_distros", "nvd3"),
                          htmlOutput("goldDistrosExplain")),
                 tabPanel("Similar Workers",
                          htmlOutput("similarity_legend"),
                          htmlOutput("create_similar_table")))
               
      ),
      tabPanel("A-Distros",
               h4("Answer Distros"),
               uiOutput("questionSelector"),
               selectInput(inputId = "state_chosen", label= " ",
                           c("All" = "all",
                             "Golds" = "golden",
                             "Units" = "normal")),
               uiOutput("titleDistrosUnits"),
               uiOutput("titleDistrosJudgs"),
               showOutput("plot_distros", "nvd3")
      ),
      tabPanel("Judgment Barplots",
               uiOutput("titleTextGraph"),
               selectInput(inputId = "num_chosen", label="Show Me:",
                           c("50 Workers" = "fiddy",
                             "100 Workers" = "hund",                                       
                             "All" = "all")),
               selectInput(inputId = "group_chosen", label="Color By:",
                           c("Trust" = "trust",
                             "Channel" = "channel",
                             "Country" = "country",
                             "Untrusted" ="untrusted")),
               showOutput("plot_workers", "nvd3"),
               tags$style(type="text/css", ".nv-controlsWrap { visibility: hidden; }")
      )
      
    )
  )        
))  