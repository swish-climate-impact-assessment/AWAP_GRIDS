
################################################################
# name:extract-point-from-awap-grids

# aim daily weather for any point location from online BoM weather grids

# depends on some github packages
require(awaptools)
#http://swish-climate-impact-assessment.github.io/tools/awaptools/awaptools-downloads.html
require(swishdbtools)
#http://swish-climate-impact-assessment.github.io/tools/swishdbtools/swishdbtools-downloads.html
require(gisviz)
# http://ivanhanigan.github.io/gisviz/

# and this from CRAN
if(!require(raster)) install.packages('raster'); require(raster)

# get weather data, beware that each grid is a couple of megabytes
vars <- c("maxave","minave","totals","vprph09","vprph15") #,"solarave") 
# solar only available after 1990
for(measure in vars)
{
  #measure <- vars[1]
  get_awap_data(start = '1960-01-01',end = '1960-01-02', measure)
}

# get location
locn <- geocode("daintree rainforest")
# this uses google maps API, better check this
# lon       lat
# 1 145.4185 -16.17003
## Treat data frame as spatial points
epsg <- make_EPSG()
shp <- SpatialPointsDataFrame(cbind(locn$lon,locn$lat),locn,
                              proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))
# now loop over grids and extract met data
cfiles <-  dir(pattern="grid$")

for (i in seq_len(length(cfiles))) {
  #i <- 1 ## for stepping thru
  gridname <- cfiles[[i]]
  r <- raster(gridname)
  #image(r) # plot to look at
  e <- extract(r, shp, df=T)
  #str(e) ## print for debugging
  e1 <- shp
  e1@data$values <- e[,2]
  e1@data$gridname <- gridname
  # write to to target file
  write.table(e1@data,"output.csv",
    col.names = i == 1, append = i>1 , sep = ",", row.names = FALSE)
}

# further work is required to format the column with the gridname to get out the date and weather paramaters.
