# functions.R

#
## Custom functions used within server.R 
#

#source('./code/functions.R')

# libraries needed
suppressPackageStartupMessages(library(dplyr));
suppressPackageStartupMessages(library(maps));
suppressPackageStartupMessages(library(mapproj));

#load state data 
if (!exists("states")){states <- readRDS('./data/states.rds')}

# legend for all maps
legendText <- c("0 - 25%","25 - 50%","50 - 75%","75 - 100%")
#legendText <- c("1. 0 - 25%","2. 25 - 50%","3. 50 - 75%","4. 75 - 100%")

#color shades to use for States and Counties on US map
colorShades <- colorRampPalette(c("lightblue", "darkblue"))(4)


# function to show states on US map with color based on quartile
quartileStateUSMap <- function() {
    
    pm25emissions2008ByState$bucket <- as.integer(cut(pm25emissions2008ByState$emissions, 
                                                      quantile(pm25emissions2008ByState$emissions), 
                                                      include.lowest = TRUE, ordered = TRUE));
    # get state data in the same order as state.fips, as "map" function expect that order
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
        vState <- 'USA'
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
        map("county", grep(vState,countyOrder$polyname,value=TRUE), 
            fill = TRUE, col = countyFills, 
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))     
        
        # overlay county borders
        map("county", grep(vState,countyOrder$polyname,value=TRUE), 
            fill = FALSE, col = 'white', add = TRUE,
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))
        
    } else {
        # if no state is selected, plot for all counties in the whole country
        
        # generate vector of fill colors for map
        countyFills <- colorShades[countyOrder$bucket]
        
        # map for all states with counties shaded
        map("county", fill = TRUE, col = countyFills, 
            resolution = 0, lty = 0, projection = "polyconic", 
            myborder = 0, mar = c(0,0,0,0))
        
        # overlay state borders
        map("state", col = "white", fill = FALSE, add = TRUE,
            lty = 1, lwd = .2, projection = "polyconic",
            myborder = 0, mar = c(0,0,0,0))
        
    }
    
    # add a legend
    legend("bottomleft", cex = .75, 
           legend = legendText, #horiz = TRUE,
           fill = colorShades[], title = 'Quartile'
    )
    
    title(paste0("PM25 Emissions for ", vState))
    
}


# combinedPlotState  <- function(inStateCode='') {
#
#     # plot the emission at the counties for the selected state
#     plot_ly(plotDataState, x = county, y = emissions, #text = paste("County: ", county),
#             mode = "markers", color = bucket);
#  
#     nPlot(emissions ~ county, group = 'category', data = countyDataBySource, type = 'multiBarHorizontalChart')
#     xPlot(emissions ~ county, group = 'category',data = countyDataBySource, type = 'line-dotted')
#     nPlot(emissions ~ fips, group = 'category', data = countyDataBySource, type = 'stackedAreaChart')#, id = 'chart')
#     
# }

