# data = multiple years of monthly rainfall data in a raster grid format.
# aim = combine rainfall in a monthly basis in one grid (i.e. January 1970-2012, Feb1970-2012 etc.) calculate mean of each cell.
# assumption1 = filenames have year, month embedded so they will be sorted in order when listed
# assumption2 = all months are available, from 1:12 for all years in study period
require(raster)
years <- c(1900:1949)
cfiles <- list.files('data', pattern = '.tif', full.names=T)
length(years)
for (i in 1:12){
  ## setup for checking
  # i <- 12
  filesOfMonth_i <- seq(i,length(years)*12,12)
  ## checking
  # cfiles[filesOfMonth_i]
  b <- brick(stack(cfiles[filesOfMonth_i]))   
  ## calculate mean
  m <- mean(b)
  ## checking
  # image(m)
  writeRaster(m, sprintf("month_%s.tif", i), drivername="GTiff")
}
