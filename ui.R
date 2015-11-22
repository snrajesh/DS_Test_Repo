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
                         h4('Emissions By Source:'),
                         plotlyOutput("countyPlot"),
                         br(),
                         #showOutput("barPlot"),
                         #chartOutput("barPlot"),
                         #br(),
                         h4('Liner Regression Model: '),
                         verbatimTextOutput("model")
                ),
                #tabPanel("Emissions in all states",dataTableOutput("stateTable")),
                tabPanel("Emissions Data",dataTableOutput("countyTable")),
                tabPanel("Documentation", #"How do I use this?", 
                         h4('Introduction:'),
                         h5("This application provides a comparative overview of fine particle (PM25) emissions across USA."),
                         br(),
                         h4("Instruction:"), 
                         p('This is a "Walk-Up-And-Use" kind of application. No training is needed to use this application.'),
                         br(),
                         p("1. On the Left-Panel, you will see a ",
                                strong("drop-down list"), "of state-codes."),
                         p("2. Select the ", strong("state-code"), " by scrolling the list (that is all you need to do)."),
                         p("3. As soon as you select the state-code, the application will analyze the data for your state."),
                         p("4. You will see the state map below the drop-down list and the charts on the main-panel ",
                            "are refreshed with the data for your state."),
                         br(),
                         h4("Result:"), 
                         p("1. The state map shows each county color-shaded based on emissions. "), 
                         p("   (a) counties in the darkest blue are the ones with highest emissions (in 76-100 percentile)"),
                         p("   (b) counties in the lightest blue are the ones with lowest emissions (in 0-25 percentile)"),
                         p("   (c) the rest are in 25-75 percentile"),
                        br(),
                        p("2. The first plot on the Main-Panel shows the ", strong("Trend of Emissions"), 
                            " for the selected state over the last 10 years. ",
                            "As well a projected line (in green) showing the trend, derived using linear regression model. ",
                            "The details of the linear regression model is all the way at the bottom of the page."),
                        br(),
                        p("3. The second chart shows the ", strong('Emissions in the counties'), " within the state.", 
                          "It is color-coded to show the different emission sources."),
                        br(),
                        p("4. Click on ", strong('Emissions Data'), 
                          " tab to see latest emissions data at the county level for the state you selected."),
                        br(),
                        p("5. Don't be afraid to click on the additional tabs to see additional information"),
                        br(),
                        h4("Technology:"), 
                        p("This app is built using R tools (R is a programming language and software environment for statistical computing, ", 
                            "and graphics supported by the R Foundation for Statistical Computing). ",  
                            "We used R, Rstudio, and Rstudio's Shinny to build the application and ",
                            "the App is hosted on Rstudio's Shinny servers"),
                        p("The source of the data is the EPA National Emissions Inventory web site ",
                            "(http://www.epa.gov/ttn/chief/eiinformation.html)")
                ),
                #tabPanel("Why do I use this?",includeMarkdown("OneClickPM25Emissions.md")),
                tabPanel("What is the receipe?",includeMarkdown("prompt.Rmd"))
            )
        )
    )
))

