library(shiny)
library(leaflet)
library(readxl)
library(dplyr)
library(magrittr)
library(plotly)
library(readr)

calcDist = function(lat1,lon1,lat2,lon2){
  radlat1 = pi*lat1/180
  radlat2 = pi*lat2/180
  theta = lon1-lon2
  radtheta = pi*theta/180
  dist = acos(sin(radlat1)*sin(radlat2)+cos(radlat1)*cos(radlat2)*cos(radtheta))*180/pi*60*1.1515
}

hikingData = lapply(excel_sheets("Data/Full File.xlsx"),read_excel,path="Data/Full File.xlsx") %>% 
  lapply(arrange,Timestamp) %>% 
  lapply(mutate,latd = (Latitude-lag(Latitude))^2,lond = (Longitude-lag(Longitude))^2) %>% 
  lapply(mutate,dist = calcDist(Latitude,Longitude,lag(Latitude),lag(Longitude))) %>% 
  do.call(bind_rows,.) %>% 
  mutate(Elevation = Elevation*3.28)