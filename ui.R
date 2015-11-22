# ui.R

library(shiny)
library(plotly)
library(rCharts)

#load state code for the drop-down list
states <- readRDS('./data/states.rds')


# UI for the application 
shinyUI(fluidPage(#theme = "bootstrap.css",
    # Application title
    titlePanel("PM25 Emissions Analysis"),
    #sidebar
    sidebarLayout( #position = "left", fluid = TRUE,
        # Sidebar with Instructions and user input fields 
        sidebarPanel( width = 4,
            h4("What?", style = "color: steelblue"),
            p("This application provides a comparative overview of fine particle (PM2.5) emissions",
                "in the United States."),
            h4("How?", style = "color: steelblue"),
            p("Click the ", strong("Documentation", style = "color: darkgreen"), 
              " tab to learn how to use this."),
            #p("Visit the ", strong("What is the receipe?", style = "color: darkgreen"), " tab to see how it is made."),
            h4("Ready to try?", style = "color: steelblue"),
            # display US map with states shaded based on emission
            plotOutput("USmap"), #, width = "100%", height = "400px"), #plotlyOutput("myPlot3"),
            helpText("Want to see the details of your state?"),
            selectInput('stateCode', 'Select a State from below:', states$stateCode),
            #submitButton('Submit'),
            # display the state map with counties shaded based on emission
            plotOutput("stateMap")
        ),
        # main panel with plots (and prediction) generated based on user input
        mainPanel(
            tabsetPanel( # position = "below",
                tabPanel("Emissions Analysis", 
                         h4('Trend of Emissions:'),
                         plotOutput('trendPlot'),
                         br(),
                         h4('Emissions By County:'),
                         plotlyOutput("countyPlot"),
                         br(),
                         #showOutput("barPlot"),#,"nvd3"),
                         htmlOutput("barPlot"),
                         #chartOutput("barPlot"),
                         #br(),
                         h4('Liner Regression Model: '),
                         verbatimTextOutput("model")
                ),
                #tabPanel("Emissions in all states",dataTableOutput("stateTable")),
                tabPanel("Emissions Data",dataTableOutput("countyTable")),
                tabPanel("Documentation", #"How do I use this?", 
                         h5("This application provides a comparative overview of fine particle (PM25) emissions across USA.")
                ),
                tabPanel("What is the receipe?",includeMarkdown("prompt.Rmd"))
            )
        )
    )
))

