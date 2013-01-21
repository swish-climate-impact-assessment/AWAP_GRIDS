
################################################################
# name:clean
# Project: AWAP_GRIDS
# Author: ivanhanigan
# Maintainer: Who to complain to <ivan.hanigan@gmail.com>
require(ProjectTemplate)
load.project()

# All the potentially messy data cleanup
  ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'ivan_hanigan')
  # enter password at console
  shp <- dbGetQuery(ch, 'select stnum, lat, lon from weather_bom.combstats')
#  shp <- dbGetQuery(ch, 'select sla_code, st_x(st_centroid(the_geom)) as lon, st_y(st_centroid(the_geom)) as lat from abs_sla.aussla01')
  nrow(shp)
  if (!require(rgdal)) install.packages('rgdal'); require(rgdal)
  epsg <- make_EPSG()

  ## Treat data frame as spatial points
  shp <- SpatialPointsDataFrame(cbind(shp$lon,shp$lat),shp,
                                proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))
  str(shp)
  head(shp@data)
  ## #writeOGR(shp, 'test.shp', 'test', driver='ESRI Shapefile')


  #################################
  # start getting CCD temperatures
  #setwd(rootdir)
#  started <- Sys.time()
#  for(v in 4:6){
   v = 1
  rootdir <- paste(getwd(),'/',variableslist[v,1],sep='')
#  dir(rootdir)[1]
  cfiles <- dir(rootdir)
  cfiles <- cfiles[grep(as.character(variableslist[v,2]), cfiles)]

#    for (i in seq_len(length(cfiles))) {# solar failed at this day 494:length(cfiles)){
    #   i <- 1
      #i <- grep('20000827',cfiles)
      fname <- cfiles[[i]]
      variablename <- strsplit(fname, '_')[[1]][1]
      timevar <- gsub('.grid', '', strsplit(fname, '_')[[1]][2])
      timevar <- substr(timevar, 1,8)
      year <- substr(timevar, 1,4)
      month <- substr(timevar, 5,6)
      day <- substr(timevar, 7,8)
      timevar <- as.Date(paste(year, month, day, sep = '-'))
      r <- raster(file.path(rootdir,fname))
      e <- extract(r, shp, df=T)
      str(e) ## print for debugging
      image(r)
      plot(shp, add = T)
