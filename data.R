# data.R

##
## Script for initial data load from rds files into server session for the web app
##

#setwd("~/R/training/DataProducts/pm25emissions")
#source('./code/data.R')

pm25emissionsByState <- readRDS('./data/pm25emissionsByState.rds')
pm25emissions2008BySource <- readRDS('./data/pm25emissions2008BySource.rds')

pm25emissions <- readRDS('./data/pm25emissions.rds')
pm25emissions$stateCode <- as.character(pm25emissions$stateCode)

pm25emissions2008ByState <- readRDS('./data/pm25emissions2008ByState.rds')
pm25emissions2008ByState$stateCode <- as.character(pm25emissions2008ByState$stateCode)
pm25emissions2008ByState$emissions = round(pm25emissions2008ByState$emissions)

pm25emissions2008ByCounty <- readRDS('./data/pm25emissions2008ByCounty.rds')
pm25emissions2008ByCounty$stateCode <- as.character(pm25emissions2008ByCounty$stateCode)
pm25emissions2008ByCounty$emissions = round(pm25emissions2008ByCounty$emissions)


states <- readRDS('./data/states.rds')
fips <- readRDS('./data/fips.rds')

