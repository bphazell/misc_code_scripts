##Packman UI
##initialized March 24, 2014

source('../.Rprofile.apps')

require('shiny')
require('datasets')
require('data.table')
require('plyr')
require('devtools')
require('stringr')


shinyUI(pageWithSidebar(
  headerPanel("Packman"),
  sidebarPanel(
    tags$head(tags$script(src = "js/jquery-ui.min.js")),
    tags$head(tags$script(src = 'js/sort.js')),
    includeHTML("../shared/mixpanel.js"),
    HTML("<script>mixpanel.track('packman')</script>"),
    #htmlOutput("appMessage"),
    textInput("job_id", h4("Enter a Job ID or IDs"), 0),
    br(),
    span(strong("separate multiple job ids with a comma ,"), style="color:blue"),
    br(),
    span("Tip: prepare your comma-separated job ids in your editor, then paste here all at once.", style="color:blue"),
    fileInput("files", h4("Select an agg report:"), multiple=T, accept = 
                c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
    h4("***"),
    h5("Complete the step by step submissions under the numerated tab. Once you've completed that you
       can analyze and download the final product under the Download Results tab."),
    htmlOutput("summaryMessage"),
    htmlOutput("pacman")
  ), #close sidebarPanel
  mainPanel(
    HTML("<script>mixpanel.track_links('a', 'packman tab_or_link_click', function(ele) { return { type: $(ele).text()}})</script>"),
    tabsetPanel(
      tabPanel("File Stats",
               p("Once the file is uploaded you can use this section to generate stats for chosen columns. If you are looking to modify
                 the file see the Operations tab."),
               uiOutput("selectAggCols"),
               actionButton("get_stats", "Generate Stats"),
               htmlOutput("createAggStats"),
               br(),
               downloadButton("downloadFileStats", "Download the File Stats")
               ),
      tabPanel("Operations",
               tabsetPanel(
                 tabPanel("1. Reorder Columns",
                          htmlOutput("mixpanelEvent_job_id_packman"),
                          htmlOutput("reorderTabDesc"),
                          uiOutput("columnSelector"),
                          actionButton("get_reorder", "Continue to Step 2"),
                          h4("Output File Viewer:"),
                          tableOutput("reorderTabTable")),
                 tabPanel("2. Row Data Cleanup",
                          htmlOutput("dataCleanTabDesc"),
                          uiOutput("rowProperCase"),
                          actionButton("get_clean", "Continue to Step 3"),
                          h4("Output File Viewer:"),
                          uiOutput("dataCleanTabTable"),
                          htmlOutput("dataCleanTabWarning")),
                 tabPanel("3. Row Data Dedupe",
                          htmlOutput("rowDedupeTabDesc"),
                          uiOutput("rowDedupeKey"),
                          actionButton("get_dedupe", "Continue to Step 4"),
                          br(),br(),
                          checkboxInput("skip_dedupe", "I'd prefer to skip this step."),
                          htmlOutput("dedupeTabTableMessage"),
                          h4("Output File Viewer (first 15 rows):"),
                          htmlOutput("dedupeTabWarning"),
                          uiOutput("dedupeTabTable")),
                 tabPanel("4. Rename Columns",
                          htmlOutput("renameTabDesc"),
                          htmlOutput("renameTabTable"),
                          br(),
                          actionButton("get_rename", "Finish File")),
                 tabPanel("5. View Built File:",
                          h4("Output format. Showing the top 15 rows."),
                          htmlOutput("builtTabWarning"),
                          uiOutput("builtTabTable"),
                          tags$style(type="text/css", ".shiny-datatable-output { overflow: scroll; }")
                 ),
                 tabPanel("6. Download Results:",
                          textInput("download_name", "Name for the output file (uft-8 without the .csv)", "output"),
                          br(),
                          downloadButton('downloadOutput', 'Download Built File'),
                          h4("***"),
                          br(),
                          uiOutput("selectReportCardCols"),
                          actionButton("get_report", "Generate Report"),
                          htmlOutput("createReportCard"),
                          br(),
                          downloadButton('downloadReport', 'Download Report Card')
                          
               )
               )),
               tabPanel("View Low Confidence Units",
                        dataTableOutput("displayLowUnits")
               ),
               tabPanel("Compare to Source",
                        fileInput("source_file", h4("Upload a job source file:"), multiple=F, accept = 
                                    c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                        tabsetPanel(
                          tabPanel("Missing Units",
                                   p(strong("Warning:"),
                                     span("Make sure that some source column names and agg column names overlap! We use these to make a key.",
                                          style="color:red")),
                                   htmlOutput("missingUnitsText"),
                                   br(),
                                   dataTableOutput("missingUnits")
                          ),
                          tabPanel("Source Viewer",
                                   dataTableOutput("sourceFile"))
                        )
               ),
               tabPanel("View Original File",
                        dataTableOutput("originalFileTabTable"),
                        tags$style(type="text/css", ".data { overflow: scroll; }")
               ),
               tabPanel("Logic Aware Aggregation",
                        fileInput("files_logic", h4("Upload your FULL report here (required):"), multiple=FALSE),
                        textInput("job_id_logic", h4("Add a job id if it's not contained in the name of the file (optional):"), 0),
                        htmlOutput("mixpanelEvent_logic_job_id_packman"),
                        h4(textOutput("sample_skip_text")),
                        h4("If the lines above turned grey, your file is being processed.
                 You can download your file when it's done."),
                        h4(textOutput("logic_agg_ready")),
                        downloadButton('downloadAgg', 'Download your Logic-Aware Agg report!')
               )
  
      ) #close overall tabset
    ) #close mainPanel
  )) #close shiny ui
  