# ui.R

library(shiny)
states <- readRDS('states.rds')

# UI for the application 

shinyUI(fluidPage(
    # Application title
    titlePanel("PM25 Emissions Analysis"),
    sidebarLayout(
        #position = "left",
        # Sidebar with user input fields 
        sidebarPanel(
            plotOutput("map"),
            #textInput(inputId="stateCode", label = "Enter State Code", value = "NY"),
            selectInput('stateCode', 'Select State', states$stateCode),
            #submitButton('Submit'),
            h5('You entered'),
            verbatimTextOutput("inputState"),
            h5('Which resulted in a prediction of '),
            verbatimTextOutput("prediction")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel( # position = "below",
                tabPanel("Result - Plot", 
                    h4('Plot of Emissions:'),
                    plotOutput('myPlot'),
                    plotOutput("map2"),
                    h4('Liner Regression Model: '),
                    verbatimTextOutput("model")
                    ),
                tabPanel("Counties", plotOutput("myPlot3")),
                #tabPanel("US Map", plotOutput("googlePlot")),
                tabPanel("Help", verbatimTextOutput("Instructions"))
                #                 ,tabPanel("Summary", verbatimTextOutput("summary")), 
#                 tabPanel("Table", tableOutput("table"))
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
