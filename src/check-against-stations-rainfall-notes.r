require(raster)
require(rgdal)
r3 <- readGDAL("~/Downloads//1990010119900101.grid")
image(r3)
setwd("~/Downloads/")
require(awaptools)
require(devtools)
install_github("awaptools", "swish-climate-impact-assessment")
require(awaptools)
raster_aggregate(filename = "1990010119900101.grid",
aggregationfactor = 3, delete = F)
raster_aggregate
install_github("awaptools", "swish-climate-impact-assessment")
raster_aggregate
raster_aggregate(filename = "1990010119900101.grid",
aggregationfactor = 3, delete = F)
r3 <- readGDAL("~/Downloads//1990010119900101.tif")
image(r3)
r4 <- readGDAL("~/Downloads//1990010119900101.grid")
image(r4)
require(swishdbtools)
p <- getPassword()
# p <- getPassword(remote = T)
r <- readGDAL2("tern5.qern.qcif.edu.au","gislibrary","ewedb","awap_grids","totals_19900101",p=p)
image(r)
r5 <- r/r3
r == r3
str(r)
str(r4)
str(r3)
r6 <- ifelse(r@data == NaN, 0, r@data)
str(r6)
head(r@data[r@data$band1 == NaN])
head(r@data[r@data$band1 == NaN,])
r@data[r@data$band1 == NaN,]
r@data[r@data$band1 != NaN,]
r@data[is.na(r@data$band1),]
r@data[!is.na(r@data$band1),]
r@data$band1 <- ifelse(is.na(r@data$band1),0,r@data$band1)
r@data$band1
r@data$band1 == r3@data$band1
r@data$band1 != r3@data$band1
equal(r@data$band1, r3@data$band1)
identical(r@data$band1, r3@data$band1)
