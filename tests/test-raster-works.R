# AIM: to test the raster package for time series functions
## func
if(!require(devtools)) install.packages("devtools", depend = T); require(devtools)
install_github("HutchinsonDroughtIndex", "ivanhanigan")
require(HutchinsonDroughtIndex)
wd <- getwd()
setwd("~/data/AWAP_GRIDS/data")
require(raster); require(rgdal)
dir.create("~/temp")
rasterOptions(tmpdir="~/temp")
rasterTmpFile()
rasterOptions()
# format        : raster 
# datatype      : FLT8S 
# overwrite     : FALSE 
# progress      : none 
# timer         : FALSE 
# chunksize     : 1e+07 
# maxmemory     : 1e+08 
# tmpdir        : ~/temp/ 
#   tmptime       : 168 
# setfileext    : TRUE 
# tolerance     : 0.1 
# standardnames : TRUE 
# warn depracat.: TRUE 


## load
awap.grids = dir(pattern = "grid$", full.names=T)
#  list.files('AWAP_GRIDS', pattern=glob2rx('totals*.grid'), full.names=T)
for(i in 1:12){
  #i = 1
  #file.copy(awap.grids[i], sprintf("foo%s.grid", i))}
  r <- raster(awap.grids[i])
  #str(r)
  #image(r)
  fname <- gsub(".grid",".tif", awap.grids[i])
  # TODO project this please lu!
  writeRaster(r, filename= fname, type = "GTiff")
  #file.remove(awap.grids[i])
}
## for some reason brick or stack only don't work, both together do
awap.grids <- dir(pattern = 'tif')[1:12]
rb <- brick(stack(awap.grids)) #takes too l

## I'm not sure what's more efficient, if changing the drought function 
## to do the cal on matrices or just running the function on the vectors

##option 1 modif function
ct <- drought_index_grids(rasterbrick = rb,startyear = 1900, endyear=1900, droughtThreshold=.375)
plot(ct[,1], type = "l")



#### OLD STUff ####
# require(raster)
# require(swishdbtools)
# pwd <- getPassword()
# 
# #list of your grids
# cfiles <- list.files('data', pattern = 'tif', full.names=T)
# 
# #make a brick
# b <- brick(stack(cfiles[1:12]))
# #calc mean
# m <- cellStats(b, mean)
# plot(b)
# 
# shp <- readOGR2(h='115.146.84.135', d='ewedb',u='gislibrary',
#                 layer = 'weather_bom.combstats', p = pwd)
# 
# for (i in 1:12) #seq_len(length(cfiles))) {
#   {
#   #i <- 1
#   r <- raster(cfiles[[i]])
#   e <- extract(r, shp, df=T)
#   #str(e) ## print for debugging
#   e1 <- shp
#   e1@data$values <- e[,2]
#   #  write.table(data.frame(file = i, extract = e),"test.csv",
#   #  col.names = i == 1, append = i>1 , sep = ",", row.names = FALSE)
# }
# 
# head(e1@data)
# subset(e1@data[e1@data$stnum == 91004,])
# 
# 
# e <- extract(b, shp, df=T)
# str(e)
# str(shp@data)
# 
# b2 <- overlay(b, fun = cumsum)
# tail(b)
# tail(b2)
# nrow(b2)
# str(raster(cfiles[1]))
# b2 <- overlay(b, fun = function(x) {return((rank(x)-1)/(length(x)-1))})
# str(b2)
# tail(b2)
# e <- extract(b2, shp, df=T)
# str(e)
# str(shp@data)
# head(e)