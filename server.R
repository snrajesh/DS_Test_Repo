#server.R

# load necessary libraries
library(shiny)
#library(UsingR)
library(dplyr)
library(ggplot2)
library(plotly)
Sys.setenv("plotly_username" = "snrajesh")
Sys.setenv("plotly_api_key" = "0t65w3ld8k")

# load cleanedup and sumarized data from file into data frame (Data.R)
pm25emissionsByState <- readRDS('pm25emissionsByState.rds')
pm25emissions <- readRDS('pm25emissions.rds')
pm25emissions$stateCode <- as.character(pm25emissions$stateCode)

pm25emissions2008ByState <- readRDS('pm25emissions2008ByState.rds')
pm25emissions2008ByState$stateCode <- as.character(pm25emissions2008ByState$stateCode)

pm25emissions2008ByCounty <- readRDS('pm25emissions2008ByCounty.rds')
pm25emissions2008ByCounty$stateCode <- as.character(pm25emissions2008ByCounty$stateCode)

states <- readRDS('states.rds')
fips <- readRDS('fips.rds')

#install.packages(c("maps", "mapproj"))

library(maps)
library(mapproj)
library(googleVis)

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
    color <- 'darkblue'; 
    shades <- colorRampPalette(c("lightblue", color))(4)
    fills <- shades[stateOrder$bucket]
    
    # plot choropleth map at the state level
    map("state", fill = TRUE, col = fills, 
        resolution = 0, lty = 0, projection = "polyconic", 
        myborder = 0, mar = c(0,0,0,0))
    
    # overlay state borders
    map("state", col = "white", fill = FALSE, add = TRUE,
        lty = 1, lwd = 1, projection = "polyconic", 
        myborder = 0, mar = c(0,0,0,0))
    
    # add a legend
    legend("bottomleft", cex = .75, #inset = -.01, 
           legend = c("1. 0 - 25%","2. 25 - 50%","3. 50 - 75%","4. 75 - 100%"), 
           fill = shades[],
           title = 'Quartile'
    )
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
    
    
    # generate vector of fill colors for map
    color <- 'darkgreen'; 
    shades <- colorRampPalette(c("lightgreen", color))(4)
    
    # plot choropleth map at the county level for the selected state
    if (inStateCode == '') {
        countyFills <- shades[countyOrder$bucket]
        map("county", fill = TRUE, col = countyFills, 
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))
        
    } else {
        countyFills <- shades[countyOrder[grep(vState,countyOrder$polyname),'bucket']]
        map("county", grep(vState,countyOrder$polyname,value=TRUE), fill = TRUE, col = countyFills, 
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))
    }
    
    # add a legend
    legend("bottomleft", cex = .7, #inset = -.01, 
           legend = c("0 - 25%","25 - 50%","50 - 75%","75 - 100%"), 
           fill = shades[],
           title = 'Quartile'
    )
}


# Define server logic for the application
shinyServer(
    function(input, output) {
        output$map <- renderPlot({quartileStateMap()});
        output$map2 <- renderPlot({quartileCountyMap('AL')});
        
        inputState <- reactive({toupper(input$stateCode)})
        output$inputState <- renderPrint({inputState()})
        
       #output$googlePlot <- renderPrint({print(gvisMotionChart(Fruits, "Fruit", "Year", options = list(width = 600, height = 400)),"chart")})
        
        # Expression to generate plots
        # The expression is wrapped in a call to renderPlot to indicate that the output is a plot
        #   And It is "reactive" and therefore should re-execute automatically when inputs change

        # get the data based on the selected state
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
        
        output$myPlot <- renderPlot({outPlot()});
        
        # plot the counties for the selected state
        outPlot2 <- reactive({quartileCountyMap(inputState())});
        output$map2 <- renderPlot({outPlot2()});
        
#         outPlot3 <- reactive({
#             plotData3 <- pm25emissions %>% 
#                 filter(year == 2008, stateCode == inputState()) %>%
#                 #mutate(county = as.character(county), stateCode = as.character(stateCode)) %>%
#                 group_by(category, county, state) %>%
#                 summarize(emissions = sum(emissions, na.rm = TRUE))
#         });
        
        
                       
        outPlot3 <- reactive({
            plotData3 <- filter(pm25emissions2008ByCounty, stateCode == inputState());
            p <- plot_ly(plotData3, x = county, y = emissions, #text = paste("County: ", county),
                    mode = "markers")#, color = category);
            p
        })
        
        output$myPlot3 <- renderPlot({outPlot3()});
        
#         ggp <- ggplot(data = d, aes(x = carat, y = price)) +
#             geom_point(aes(text = paste("Clarity:", clarity)), size = 4) +
#             geom_smooth(aes(colour = cut, fill = cut), method='lm') + facet_wrap(~ cut);
#         gg <- ggplotly(ggp)

                
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









