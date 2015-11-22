#server.R

##
## server side script for the shinny app, that does the calculations and provide data back to User session
##

#setwd("~/R/training/DataProducts/pm25emissions")
#source('./code/initialDataLoad.R') # if data is needs to be reloaded from scratch


#
## 1. Code that executed once when application starts 
# 

    # A. load necessary libraries (only once when application start on the server)
    library(shiny)
    suppressPackageStartupMessages(library(dplyr));
    suppressPackageStartupMessages(library(ggplot2));
    suppressPackageStartupMessages(library(plotly));
    suppressPackageStartupMessages(library(rCharts));
    suppressPackageStartupMessages(library(maps));
    suppressPackageStartupMessages(library(mapproj));
    suppressPackageStartupMessages(library(googleVis));
    #library(UsingR)
    #Sys.setenv("plotly_username" = "snrajesh")
    #Sys.setenv("plotly_api_key" = "0t65w3ld8k")
    
    # B. load cleanedup and sumarized data from backup file into data frame (Data.R)
    source('./code/data.R')
    
    
    # C. load custom functions that are called later (within user sessions or reactive sessions)
    #   1. quartileStateUSMap() # function to show states on US map with color based on quartile
    #   2. quartileCountyMap('NY') ## function to show counties of a state with color based on quartile
    source('./code/functions.R')

#
# 2. server logic for the application
#
    
shinyServer(
    function(input, output) {
        
        #
        # 1. non-reactive section - executed only once per user session or page refresh
        #
        
        # plot US map at state level (main US map on side-panel)
        output$USmap <- renderPlot({quartileStateUSMap()});
        output$stateMap <- renderPlot({quartileCountyMap('')});
        
        # table with state level summary emissions data for 2008
        outData1 <- mutate(pm25emissions2008ByState, emissions = round(emissions))
        output$stateTable <- renderDataTable({outData1}) #, options = list(pageLength = 55))
       
        
        #
        # 2. reactive sections - executed once per interaction/change
        #
        
        inputState <- reactive({toupper(input$stateCode)})
        
        # plot the counties of the selected state within the state map
        #   (State map displayed on side-panel after state selection)
        outPlot2 <- reactive({quartileCountyMap(inputState())});
        output$stateMap <- renderPlot({outPlot2()});
        
        # line plot to show the trend year-over-year, with liner model
        #   (1st plot - timeseries - on the main panel)
        
        # get the data over year for the selected state
        plotData <- reactive({filter(pm25emissionsByState, stateCode == inputState());})
        
        # plot emissions for each year, as well as add lm line (using ggplot)
        outPlot <- reactive({    
            ggplot(plotData(), aes(year, emissions)) + 
                geom_point(color = 'steelblue', size = 4) + 
                theme_bw() +
                geom_smooth(method='lm', se = FALSE, col = 'green') + 
                labs( x = "Year", y = "Total Emissions (Tons)",  
                      title = paste("Emissions for the state:", inputState())
                );
            #plot1
        });
        
        output$trendPlot <- renderPlot({outPlot()});
        
        # linear regression model for the state
        trend <- reactive({
            xSlope <- sign(lm(emissions ~ year, plotData())$coefficients['year'])
            if (xSlope > 0) {'Increasing'} else {'Decreasing'}
            #if (is.na(input$stateCode) | input$stateCode == '' ) {'NA'}
        })
        output$prediction <- renderPrint({trend()}); 
        
        lmod <- reactive({
            xSlope <- lm(emissions ~ year, plotData());
            #xSlope
            if  (nrow(plotData()) == 0) {'NA'} else {summary(xSlope)}
            
        })
        
        output$model <- renderPrint({lmod()}); 
        
        
        # plot the emission for each counties for the selected state by source-type (using plotly)
        #   (2nd plot -interactive - on main-panel after trend)

        # get county level data at source level
        countyDataBySource <- reactive({filter(pm25emissions2008BySource, stateCode == inputState())});
    
        outPlot3 <- reactive({
            plot_ly(countyDataBySource(), x = county, y = emissions, #text = paste("County: ", county),
                     mode = "markers", color = category);
        });
        
        output$countyPlot <- renderPlotly({outPlot3()});
        
        # plot the emission for each counties for the selected state by source-type (using rChart)
        #   (3rd plot -bar - on main-panel )
        outPlot4 <- reactive({
            plotData <- select(ungroup(countyDataBySource()),county, emissions,category);
            nPlot(emissions ~ county, group = 'category', data = plotData, 
                  type = 'multiBarHorizontalChart');
        });
        output$barPlot <- renderPlotly({outPlot4()});
        

        # get county level summary data for 2008 for table
        countyData <- reactive({filter(pm25emissions2008ByCounty, stateCode == inputState())});
        
        # Table of emission data for the counties of the selected state
        output$countyTable <- renderDataTable({countyData()}) #, options = list(pageLength = 50))
        
        
    }
)

