# data.R

# 1. Check if data needed is available in memory; If it is not, download the file (if necessary) and load data
suppressPackageStartupMessages(library(dplyr));

if (!exists("pm25emissions")){   
    
    if(file.exists("pm25emissions.rds")) {
        pm25emissions <- readRDS('pm25emissions.rds')
        pm25emissionsByState <- readRDS('pm25emissionsByState.rds')
        pm25emissions2008ByState <- readRDS('pm25emissions2008ByState.rds')
        
    }
    else {
        
        
        
        ### 1.A. Download & unzip file if it is not available in the working directory (14 seconds)
        
        if(!file.exists("summarySCC_PM25.rds") | !file.exists("Source_Classification_Code.rds")) {
            localFile <- 'exdata-data-NEI_data.zip';
            download.file(url = 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip', 
                          destfile = localFile, mode="wb", method='internal')
            unzip(localFile)
        }
        
        if(!file.exists("national_county.txt")) {
            download.file(url = 'http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt', 
                          destfile = 'national_county.txt', mode="wb", method='internal')
        }
        
        # build state table 
        states <- as.data.frame(
            rbind(
                cbind(state.abb,state.name, state.x77[,8]),
                c('DC', 'District of Columbia', 68),
                c('PR', 'Puerto Rico',3515), 
                c('VI', 'US Virgin Islands', 134))
        );
        colnames(states) <- c('stateCode', 'state', 'area');
        states$stateCode = as.character(states$stateCode);
        states$area = as.numeric(as.character(states$area));
        
        ### 1.B. load rds file using readRDS into corresponding data.frames (takes about 35 sec)
        
        fips <- read.csv('national_county.txt', sep=',', stringsAsFactors = FALSE, header = FALSE);
        colnames(fips) <- c('stateCode', 'stateFips', 'countyFips', 'county', 'fipsClass');
        fips <- mutate(fips, fips = paste0(formatC(stateFips, width=2, flag="0"), 
                                           formatC(countyFips, width=3, flag="0")) );
        fips <- left_join(fips, states, by = c("stateCode" = "stateCode"))
        fips$stateCode = as.factor(fips$stateCode);
        fips$county = as.factor(fips$county);
        
        emissionSource <- readRDS("Source_Classification_Code.rds");
        emissionSource$SCC = as.character(emissionSource$SCC);
        emissionSource <- dplyr::rename(emissionSource, category = Data.Category, sector = EI.Sector, name = Short.Name)
        
        
        pm25emissions <- readRDS("summarySCC_PM25.rds");
        
        pm25emissions <- pm25emissions %>% 
            inner_join(fips, by = c("fips" = "fips")) %>%
            inner_join(emissionSource, by = c("SCC" = "SCC")) %>%
            #select(year, category, sector, stateCode, state, area, county, Emissions) %>% 
            group_by(year, category, sector, stateCode, state, area, county, fips) %>% 
            summarize(emissions = sum(Emissions, na.rm = TRUE)) %>% 
            select(year, category, sector, stateCode, state, area, county, fips, emissions);
        
        # save final data as R object    
        saveRDS(pm25emissions,'pm25emissions.rds')
        saveRDS(states,'states.rds')
        saveRDS(fips,'fips.rds')
    }
}

pm25emissions2008BySource <- pm25emissions %>% 
    filter(year == 2008) %>%
    group_by(stateCode, state, county, fips, category) %>% 
    summarize(emissions = sum(emissions, na.rm = TRUE)) %>% 
    arrange(desc(emissions), state, county, fips, category);


# additional summary tables
pm25emissionsByCounty <- pm25emissions %>% 
    group_by(year, stateCode, state, county, fips) %>% 
    summarize(emissions = sum(emissions, na.rm = TRUE)) %>% 
    arrange(year,desc(emissions), state, county, fips);

pm25emissions2008ByCounty <- pm25emissionsByCounty %>% filter(year == 2008) %>% arrange(desc(emissions), state, county);

pm25emissionsByState <- pm25emissionsByCounty %>% 
    group_by(year, stateCode, state) %>% 
    summarize(emissions = sum(emissions, na.rm = TRUE)) %>% 
    arrange(year,desc(emissions), state);

pm25emissions2008ByState <- pm25emissionsByState %>% filter(year == 2008) %>% arrange(desc(emissions), state);

# save final summary data as R object    

saveRDS(pm25emissionsByState,'pm25emissionsByState.rds')
saveRDS(pm25emissions2008ByState,'pm25emissions2008ByState.rds')

saveRDS(pm25emissionsByCounty,'pm25emissionsByCounty.rds')
saveRDS(pm25emissions2008ByCounty,'pm25emissions2008ByCounty.rds')
saveRDS(pm25emissions2008BySource,'pm25emissions2008BySource.rds')


