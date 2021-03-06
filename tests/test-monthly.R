
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
#meansmosas <-  overlay(b,fun=function(x) movingFun(x, fun=sum,n=6, "to", na.rm=TRUE))
# Error in file(fnamevals, "wb") : cannot open the connection
# In addition: Warning message:
#   In file(fnamevals, "wb") :
#   cannot open file '/tmp/R_raster_tmp/ivan_hanigan/raster_tmp_2013-07-25_160646_04951.gri': No such file or directory
#str(meansmosas)
if(!exists("pwd")) 
{
  pwd <- get_passwordTable()
  pwd <- pwd[which(    pwd$V3 == "gislibrary"),"V5"]
}
shp <- readOGR2(h='brawn.anu.edu.au', d='ewedb',u='gislibrary',
                layer = 'weather_bom.combstats', pwd)
plot(shp)
# select a station
shp@data[1,]
##   stnum                     name lat lon ele   new
## 1 91004 BRANXHOLM (SCOTT STREET) -41 147 185 FALSE
shp2  <- shp[shp@data$stnum == 91004, ]
sampled  <- sample(shp$stnum, 0.01 * nrow(shp))
length(sampled)
# 81
shp2  <- shp[which(shp$stnum %in% sampled),]
str(shp2)
plot(shp2, add = T, col = 'red')
axis(1); axis(2)
# e <- extract(meansmosas, shp2, df=T)
system.time(
e <- extract(b, shp2, df=T)
)
# user  system elapsed 
# 366.178   4.961 464.571 
nrow(e[,1:3])
length(cfiles)
file.info(cfiles[1])
system.time(
  b <- stack(cfiles)
)
# user  system elapsed 
# 360.326   2.612 363.834 
system.time(
  e <- extract(b, shp, df=T)
)
# user  system elapsed 
# 460.866   4.196 466.189 

nrow(e[,1:3])
output <- cbind(shp@data$stnum,e)
rm(e)
gc()
df <- output[1:20,]
df[,1:4]
require(reshape2)
require(awaptools)
reformat_awap_data
dat <- melt(df, id.vars=c("shp@data$stnum","ID"))
str(dat)
head(dat)
table(dat[,"shp@data$stnum"])
names(dat) <- c("stnum", "id", "raster_layer", "value")
dat$raster_layer <- as.character(dat$raster_layer)


dat$date <- matrix(unlist(strsplit(dat$raster_layer, "_")), ncol = 2, byrow=TRUE)[,2]
dat$date <- paste(substr(dat$date,1,4), substr(dat$date,5,6), substr(dat$date,7,8), sep = "-")
head(dat)
qc <- subset(dat,stnum == 91004)
qc$date <- as.Date(qc$date)
str(qc)
with(qc, plot(date, value, type  ="h"))
dev.off()

# r1 <- readGDAL(cfiles[1])
# r2 <- readGDAL(cfiles[2])
# r3 <- readGDAL(cfiles[3])
# rasters1 <- list(r1, r2, r3)
# str(rasters1[[1]])
# rasters1[[1]][1][1]
# 
