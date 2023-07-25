shinyUI(
	fluidPage(



  titlePanel(h2("My Title")),

  sidebarLayout(position = "left",
    sidebarPanel( 
    	h4("sidebar panel"),
    	p("this is a paragraph"),
    	img(src="j0149014.jpg"),
    	br(),
    	br(),
    	selectInput("var",
    		label="Choose a variable to display",
    		choices = c("Percent White", "Percent Black", "Percent Hispanic", 
    			"Percent Asian"),
    		selected = "Percent White"),
    	br(),
    	sliderInput("range",
    		label="Range of interest:",
    		min=0,max=100, value=c(0,100))
    	),
    mainPanel(
    	helpText("This is for extra assitance"),
    	br(),
    	plotOutput("map")
    	
    	)

  )


))