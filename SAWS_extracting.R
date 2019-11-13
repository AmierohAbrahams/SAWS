################################################################################################################

http://marine.weathersa.co.za/Forecasts_Home.html

# Upwelling
  # This script extracts the netCDF wind data and use it accordingly for the aim to calculate upwelling indeces
  # Selects the latest file downloaded

# Load libraries
library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(stringr)
library(tidyverse)
library(reshape2)
library(lubridate)
library(data.table)
# library(plyr)
library(rWind)  
library(circular)

# SET UP FOLDER (USED IN MULTIPLE PLACES).
#
DATADIR <- "/home/amieroh/Documents/SAWS"

NCFILE <- strftime(Sys.Date(), "SA4_00Z_OPS_%Y%m%d.nc")

# #          1         2         3         4
# # 12345678901234567890123456789012345678901
# # SA4_00Z_OPS_20190829_SUBSET.nc

ncFile <- file.path(DATADIR, 'data', NCFILE)

nc <- nc_open(ncFile)
fNameStem <-
  substr(basename(ncFile), 1, 12)
fDate <- substr(basename(ncFile), 13, 20)
x_wind <- ncvar_get(nc, varid = "x_wind") %>%
  round(4)
y_wind <- ncvar_get(nc, varid = "y_wind") %>% 
  round(4)
dimnames(x_wind) <- list(lon = nc$dim$lon$vals,
                         lat = nc$dim$lat$vals,
                         time = nc$dim$time$vals)
dimnames(y_wind) <- list(lon = nc$dim$lon$vals,
                         lat = nc$dim$lat$vals,
                         time = nc$dim$time$vals)
nc_close(nc)
x_wind <- as_tibble(melt(x_wind, value.name = "x_wind"))
y_wind <- as_tibble(melt(y_wind, value.name = "y_wind"))
x_wind$time <- as.POSIXct(x_wind$time * 60 * 60, origin = "1970-01-01 00:00:00")
y_wind$time <- as.POSIXct(y_wind$time * 60 * 60, origin = "1970-01-01 00:00:00")
y_wind <- y_wind %>% 
  select(y_wind)
na.omit(x_wind)
na.omit(y_wind)
x_wind <- x_wind %>% 
  select(lat, lon, x_wind,time)
y_wind <- y_wind %>% 
  select(y_wind)
combined_wind <- cbind(x_wind,y_wind) %>% 
  dplyr::rename(v = y_wind) %>% 
  dplyr::rename(u = x_wind)

load(file.path(DATADIR, 'Rdata/site_list_v4.2.RData'))
     
site_list <- site_list %>% 
  select(site,lat,lon) %>% 
  mutate_if(is.numeric, round, digits = 2) 

site_list$lat <- round(site_list$lat,0)

wind_sites <- combined_wind %>% 
  left_join(site_list, by = c( "lon", "lat")) # Adding the sites to the data

# save(wind_sites, file = "wind_sites.RData")
# Calculating wind speed
wind_sites$u_squared ='^'(wind_sites$u,2)
wind_sites$v_squared ='^'(wind_sites$v,2)
wind_sites <- wind_sites %>% 
  mutate(speed = sqrt(u_squared + v_squared))

# Calculate wind direction 
#wind_abs = sqrt(u_ms^2 + v_ms^2) #speed

wind_sites_complete <- wind_sites %>% 
  mutate(wind_dir_trig_to = atan2(u/speed, v/speed),
         wind_dir_trig_to_degrees = wind_dir_trig_to * 180/pi,
         wind_dir_trig_from_degrees = wind_dir_trig_to_degrees + 180, #convert this wind vector to the meteorological convention of the direction the wind is coming from
         wind_dir_cardinal = 90 - wind_dir_trig_from_degrees) # convert that angle from "trig" coordinates to cardinal coordinates


###### Convert into daily data
wind_daily <- wind_sites_complete %>%
  ungroup() %>%
  mutate(date = as.Date(time))%>% # Changing the date to date format
  dplyr::group_by(lat, lon, date) %>%
 # filter(site %in% selected_sites) %>%  # Matching the sites to wind temp sites
  dplyr::summarise(dir_circ = round(mean.circular(circular(wind_dir_cardinal, units = "degrees")),2), # Direction using the circular function
  mean_speed = round(mean(speed),2)) # Calculating the mean


# Upwelling index

Upwelling_index <- wind_daily %>%  # Making refeerence to the wind daily datta created above
  mutate(ui.saws = mean_speed * (cos(dir_circ - 160))) %>% # applying the ui formula
  drop_na # removing the na values
  
# UI dataset produces the upwelling index
write_csv(Upwelling_index, path = "Upwelling_index.csv")


