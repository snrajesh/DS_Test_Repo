# ui.R

library(shiny)
#library(plotly)
states <- readRDS('states.rds')

# UI for the application 
shinyUI(fluidPage(#theme = "bootstrap.css",
    # Application title
    titlePanel("PM25 Emissions Analysis"),
    sidebarLayout( #position = "left",
        # Sidebar with Instruction and user input fields 
        sidebarPanel(
            h4("What?", style = "color: steelblue"),
            p("This application provides a comparative overview of Fine particle (PM25) emissions across USA."),
            h4("How?", style = "color: steelblue"),
            #p("Click ",  strong("How do I use this?", style = "color: darkgreen"), " tab to learn how to use this."),
            #p("Visit the ", strong("What is the receipe?", style = "color: darkgreen"), " tab to see how it is made."),
            p("Click the ", strong("Documentation", style = "color: darkgreen"), " tab to learn how to use this."),
            h4("Ready to try?", style = "color: steelblue"),
            plotOutput("USmap"), #, width = "100%", height = "400px"), #plotlyOutput("myPlot3"),
            helpText("Want to see the details of your state?"),
            selectInput('stateCode', 'Select a State from below:', states$stateCode),
            #submitButton('Submit'),
            plotOutput("stateMap")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel( # position = "below",
                tabPanel("Emissions Analysis", 
                         h4('Trend of Emissions:'),
                         plotOutput('trendPlot'),
                         br(),
                         h4('Emissions By County:'),
                         plotlyOutput("myPlot3"),
                         br(),
                         #showOutput("myPlot5","nvd3"),
                         br(),
                         h4('Liner Regression Model: '),
                         verbatimTextOutput("model")
                ),
                #tabPanel("Emissions in all states",dataTableOutput("stateTable")),
                tabPanel("Emissions Data",dataTableOutput("countyTable")),
                tabPanel("Documentation", #"How do I use this?", 
                         h5("This application provides a comparative overview of Fine particle (PM25) emissions across USA.")
                ),
                tabPanel("What is the receipe?",includeMarkdown("README.md"))
            )
        )
    )
))

# shinyUI(pageWithSidebar(
#     # Application title
#     headerPanel("PM25 Emissions"),
#     # Sidebar with user input fields 
#     sidebarPanel(
#         #textInput(inputId="stateCode", label = "Enter State Code", value = "NY"),
#         selectInput('stateCode', 'Select State', states$stateCode),
#         #submitButton('Submit'),
#         #
#         h5('You entered'),
#         verbatimTextOutput("inputState"),
#         h5('Which resulted in a prediction of '),
#         verbatimTextOutput("prediction")
#     ),
#     # Show a plot of the generated distribution
#     mainPanel(
#         h3('Results of prediction'),
#         #
#         h3('Plot of Emissions:'),
#         plotOutput('myPlot'),
#         plotOutput('myPlot2'),
#         h3('Liner Regression Model: '),
#         verbatimTextOutput("model")
#     )
# ))
