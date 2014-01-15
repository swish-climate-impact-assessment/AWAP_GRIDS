require(raster)
require(swishdbtools)
pwd <- getPassword()

#list of your grids
cfiles <- list.files('data', pattern = 'tif', full.names=T)

#make a brick
b <- brick(stack(cfiles[1:12]))
#calc mean
m <- cellStats(b, mean)
plot(b)

shp <- readOGR2(h='115.146.84.135', d='ewedb',u='gislibrary',
                layer = 'weather_bom.combstats', p = pwd)

for (i in 1:12) #seq_len(length(cfiles))) {
  {
  #i <- 1
  r <- raster(cfiles[[i]])
  e <- extract(r, shp, df=T)
  #str(e) ## print for debugging
  e1 <- shp
  e1@data$values <- e[,2]
  #  write.table(data.frame(file = i, extract = e),"test.csv",
  #  col.names = i == 1, append = i>1 , sep = ",", row.names = FALSE)
}

head(e1@data)
subset(e1@data[e1@data$stnum == 91004,])


e <- extract(b, shp, df=T)
str(e)
str(shp@data)

b2 <- overlay(b, fun = cumsum)
tail(b)
tail(b2)
nrow(b2)
str(raster(cfiles[1]))
b2 <- overlay(b, fun = function(x) {return((rank(x)-1)/(length(x)-1))})
str(b2)
tail(b2)
e <- extract(b2, shp, df=T)
str(e)
str(shp@data)
head(e)