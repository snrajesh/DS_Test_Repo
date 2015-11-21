#server.R

#
## Code that executed once when application starts 
# 

# A. load necessary libraries (only once when application start on the server)
library(shiny)
#library(UsingR)
library(dplyr)
library(ggplot2)
library(plotly)
library(rCharts)
#install.packages(c("maps", "mapproj"))
library(maps)
library(mapproj)
library(googleVis)
Sys.setenv("plotly_username" = "snrajesh")
Sys.setenv("plotly_api_key" = "0t65w3ld8k")

# B. load cleanedup and sumarized data from file into data frame (Data.R)
pm25emissionsByState <- readRDS('pm25emissionsByState.rds')
pm25emissions <- readRDS('pm25emissions.rds')
pm25emissions$stateCode <- as.character(pm25emissions$stateCode)

pm25emissions2008ByState <- readRDS('pm25emissions2008ByState.rds')
pm25emissions2008ByState$stateCode <- as.character(pm25emissions2008ByState$stateCode)
pm25emissions2008ByState$emissions = round(pm25emissions2008ByState$emissions)

pm25emissions2008ByCounty <- readRDS('pm25emissions2008ByCounty.rds')
pm25emissions2008ByCounty$stateCode <- as.character(pm25emissions2008ByCounty$stateCode)
pm25emissions2008ByCounty$emissions = round(pm25emissions2008ByCounty$emissions)

pm25emissions2008BySource <- readRDS('pm25emissions2008BySource.rds')



states <- readRDS('states.rds')
fips <- readRDS('fips.rds')



#
## E. Additional functions that are called later (within user sessions or reactive sessions)
#

# legend for all maps
legendText <- c("0 - 25%","25 - 50%","50 - 75%","75 - 100%")
#legendText <- c("1. 0 - 25%","2. 25 - 50%","3. 50 - 75%","4. 75 - 100%")

#color shades to use for States and Counties on US map
colorShades <- colorRampPalette(c("lightblue", "darkblue"))(4)


# function to show states on US map with color based on quartile
quartileStateMap <- function() {
    
    pm25emissions2008ByState$bucket <- as.integer(cut(pm25emissions2008ByState$emissions, 
                                                      quantile(pm25emissions2008ByState$emissions), 
                                                      include.lowest = TRUE, ordered = TRUE));
    # get state data in the smae order as state.fips, as "map" function expect that order
    stateOrder <- state.fips %>% 
        mutate(abb = as.character(abb)) %>% 
        left_join(pm25emissions2008ByState, by = c("abb" = "stateCode") );
    
    # generate vector of fill colors for map
    colorFilling <- colorShades[stateOrder$bucket]
    
    # plot choropleth map at the state level
    map("state", fill = TRUE, col = colorFilling, 
        resolution = 0, lty = 0, projection = "polyconic",
        myborder = 0, mar = c(0,0,0,0))
    
    # overlay state borders
    map("state", col = "white", fill = FALSE, add = TRUE,
        lty = 1, lwd = .2, projection = "polyconic",
        myborder = 0, mar = c(0,0,0,0))
    
    # add a legend
    legend("bottomleft", cex = .75, 
           legend = legendText, horiz = TRUE,
           fill = colorShades[], title = 'Quartile'
    )
    title("PM25 Emissions by State, 2008")
}


# function to show counties of a state with color based on quartile
quartileCountyMap <- function(inStateCode='') {
    
    if (inStateCode == '') {
        plotDataState <- pm25emissions2008ByCounty;
        vState <- '.'
    } else {
        plotDataState <- filter(pm25emissions2008ByCounty, stateCode == inStateCode);
        vState <- as.character(states %>% filter(stateCode==inStateCode) %>% 
                                   mutate(state = tolower(state)) %>% select(state));
        
    }
    
    plotDataState$bucket <- as.integer(cut(plotDataState$emissions, 
                                           quantile(plotDataState$emissions), 
                                           include.lowest = TRUE, ordered = TRUE));
    
    # get county data in the same order as county.fips, as "map" function expect that order
    countyOrder <- county.fips %>% 
        mutate(fips = formatC(fips, width=5, flag="0")); 
    countyOrder <- left_join(countyOrder, plotDataState, by = c("fips" = "fips") )
    

    # plot choropleth map at the county level for the selected state
    if (inStateCode != '') {
        
        # generate vector of fill colors for map
        countyFills <- colorShades[countyOrder[grep(vState,countyOrder$polyname),'bucket']]
        
        # map for the input state with counties shaded
        map("county", grep(vState,countyOrder$polyname,value=TRUE), fill = TRUE, col = countyFills, 
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))     
        
    } else {

        # generate vector of fill colors for map
        countyFills <- colorShades[countyOrder$bucket]
        
        # map for all states with counties shaded
        map("county", fill = TRUE, col = countyFills, 
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))
    }
    
    # add a legend
    legend("bottomleft", cex = .75, 
           legend = legendText, #horiz = TRUE,
           fill = colorShades[], title = 'Quartile'
    )
    
    title(paste0("PM25 Emissions for ", vState, ", 2008"))
    

}

combinedPlotState  <- function(inStateCode='') {
    # plot the emission at the counties for the selected state
    plot_ly(plotDataState, x = county, y = emissions, #text = paste("County: ", county),
            mode = "markers", color = bucket);
    
    
}

# Define server logic for the application
shinyServer(
    function(input, output) {
        
        # non-reactive section - executed only once per user session or page refresh
        
        # plot US map at state level
        output$USmap <- renderPlot({quartileStateMap()});
        output$stateMap <- renderPlot({quartileCountyMap('')});
        
        # table with level summary emissions data for 2008
        outData1 <- mutate(pm25emissions2008ByState, emissions = round(emissions))
        output$stateTable <- renderDataTable({outData1}) #, options = list(pageLength = 55))
       
        #
        # reactive sections - executed once per interaction/change
        #
        
        inputState <- reactive({toupper(input$stateCode)})
        
        # plot the counties for the selected state map
        outPlot2 <- reactive({quartileCountyMap(inputState())});
        output$stateMap <- renderPlot({outPlot2()});
        
        # get county level summary data for 2008
        countyData <- reactive({filter(pm25emissions2008ByCounty, stateCode == inputState())});
        
        # Table of emission data for the counties of the selected state
        output$countyTable <- renderDataTable({countyData()}) #, options = list(pageLength = 55))

        # plot the emission at the counties for the selected state
#         outPlot4 <- reactive({
#             plotData <- countyData()
#             plotData$quartile <- as.integer(cut(plotData$emissions, quantile(plotData$emissions), 
#                                                 include.lowest = TRUE, ordered = TRUE));
#             plot_ly(plotData, x = county, y = emissions, text = paste("County: ", county),
#                     mode = "markers", color = quartile);
#         });
        #output$myPlot4 <- renderPlotly({outPlot3()})
        
        # get county level data at source level
        countyDataBySource <- reactive({filter(pm25emissions2008BySource, stateCode == inputState())});
    
        outPlot3 <- reactive({
                plot_ly(countyDataBySource(), x = county, y = emissions, #text = paste("County: ", county),
                         mode = "markers", color = category);
        });
        output$myPlot3 <- renderPlotly({outPlot3()});
        
#         outPlot5 <- reactive({
#             plotData <- countyDataBySource();
#             nPlot(emissions ~ county, group = 'category', data = plotData, 
#                   type = 'multiBarHorizontalChart');
#         });
#         output$myPlot5 <- renderPlotly({outPlot5()});


        #output$myPlot3 <- renderPlotly({outPlot3()});
        
        #         ggp <- ggplot(data = d, aes(x = carat, y = price)) +
        #             geom_point(aes(text = paste("Clarity:", clarity)), size = 4) +
        #             geom_smooth(aes(colour = cut, fill = cut), method='lm') + facet_wrap(~ cut);
        #         gg <- ggplotly(ggp)
        
        
        # get the data over year for the selected state
        plotData <- reactive({filter(pm25emissionsByState, stateCode == inputState());})
        
        outPlot <- reactive({    
            plot1 <- ggplot(plotData(), aes(year, emissions)) + 
                geom_point(color = 'steelblue', size = 4) + 
                theme_bw() +
                geom_smooth(method='lm', se = FALSE, col = 'green') + 
                labs( x = "Year", y = "Total Emissions (Tons)",  
                      title = paste("Emissions for the state:", inputState())
                );
            plot1
        });
        
        output$trendPlot <- renderPlot({outPlot()});

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
        
        
    }
)

