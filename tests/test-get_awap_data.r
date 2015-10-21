
################################################################
# name:get_awap_data
# test
setwd("~/data/AWAP_GRIDS/RawData")
# functions
#require(devtools)
#install_github('awaptools','swish-climate-impact-assessment')
require(awaptools)
#install_github('swishdbtools','swish-climate-impact-assessment')
require(swishdbtools)
require(gisviz)
# http://ivanhanigan.github.io/gisviz/
library(reshape)
variableslist <- variableslist()  
vars <- c("maxave","minave","totals","vprph09","vprph15","solarave")
for(measure in vars[c(1,2,4,5)])
{
  get_awap_data(start = '2015-07-24',end = '2015-07-27', measure)
}
# fileslist <- dir(pattern="grid$")
# par(mfrow = c(2,2))
# for(fi in fileslist){
# r <- readGDAL(fname=fi)
#   image(r)
#   title(fi)
# }

#locn <- geocode("daintree rainforest")
address2 <- c("1 Lineaus way acton canberra", "daintree rainforest", "hobart",
              "bourke")
locn <- gGeoCode2(address2)
# this uses google maps API, better check this
# address     long       lat
# 1 1 Lineaus way acton canberra 149.1164 -35.27676
# 2          daintree rainforest 145.4185 -16.17003

## Treat data frame as spatial points
epsg <- make_EPSG()
shp <- SpatialPointsDataFrame(cbind(locn$lon,locn$lat),locn,
                              proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))
shp@data
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

dat <- read.csv("output.csv", stringsAsFactors = F)
head(dat)
dat$date <- matrix(unlist(strsplit(dat$gridname, "_")), ncol = 2, byrow=TRUE)[,2]
dat$date <- paste(substr(dat$date,1,4), substr(dat$date,5,6), substr(dat$date,7,8), sep = "-")
dat$measure <- matrix(unlist(strsplit(dat$gridname, "_")), ncol = 2, byrow=TRUE)[,1]


dat <- arrange(dat[,c("address", "long", "lat", "date", "measure", "values")], address, date, measure)
head(dat)

dat2 <- cast(dat, address +    long     +  lat    +   date ~ measure, value = 'values',
      fun.aggregate= 'mean')
dat2

plot(r)
plot(shp, add = T)
title(gridname)
dev.off()
