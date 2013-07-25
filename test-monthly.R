
# data = multiple years of monthly rainfall data in a raster grid format. 
# aim = combine rainfall in a seasonal basis in one grid
# (i.e. M-J-J-A-S-O 1900, 1901 etc.) calculate mean of each cell. 
# assumption1 = filenames have year, month embedded so they will be sorted in order when listed 
# assumption2 = all months are available, from 1:12 for all years in
# study period
setwd("/ResearchData/AWAP_GRIDS_RAIN_MONTHLY")
require(raster) 
require(rgdal)
require(swishdbtools)
lsos()

years <- c(1900:1949)
lengthYears <- length(years)
cfiles <- list.files(pattern = '.tif', full.names=T) 
b <- brick(stack(cfiles))
# broke
b <- stack(cfiles)
meansmosas <-  overlay(b,fun=function(x) movingFun(x, fun=sum,n=6, "to", na.rm=TRUE))
str(meansmosas)
require(swishdbtools)
shp <- readOGR2(h='brawn.anu.edu.au', d='ewedb',u='john_snow',
                layer = 'weather_bom.combstats')
plot(shp)
# select a station
shp@data[1,]
##   stnum                     name lat lon ele   new
## 1 91004 BRANXHOLM (SCOTT STREET) -41 147 185 FALSE
shp2  <- shp[shp@data$stnum == 91004, ]
str(shp2)
plot(shp2)
e <- extract(meansmosas, shp2, df=T)
str(e) ## print for debugging

#
r1 <- readGDAL(cfiles[1])
r2 <- readGDAL(cfiles[2])
r3 <- readGDAL(cfiles[3])
rasters1 <- list(r1, r2, r3)
str(rasters1[[1]])
rasters1[[1]][1][1]

