# 24/7/2013 ihanigan
# data = multiple years of monthly rainfall data in a raster grid format. 
# aim = combine rainfall in a seasonal basis in one grid
# (i.e. M-J-J-A-S-O 1900, 1901 etc.) calculate mean of each cell. 
# assumption1 = filenames have year, month embedded so they will be sorted in order when listed 
# assumption2 = all months are available, from 1:12 for all years in
# study period
# notes: 
# this requires the files are listed in the right order by name, and all months are present. might be better to use grep on the file name and strsplit/substr to extract the month identifier more precisely? 
#writeRaster(m, filename=paste("mean",years[i],".asc"))
homedir <- "~/AWAP_GRIDS_RAIN"
# first make sure there are no left over files from previous runs
oldfiles <- list.files(pattern = '.tif', full.names=T) 
for(oldfile in oldfiles)
{
  print(oldfile)
  file.remove(oldfile)
}
################################################
setwd("/ResearchData/AWAP_GRIDS_RAIN_MONTHLY")
if(!require(raster)) install.packages("raster", dependencies = T); require(raster)
if(!require(rgdal)) install.packages("rgdal", dependencies = T); require(rgdal)
years <- c(1900:1903)
lengthYears <- length(years)
cfiles <- list.files(pattern = '.tif', full.names=T) 
# loop thru
# NEED TO SET THE FILESOFSEASEON_I counter EACH TIME YOU start

#season <- "hot" # for labelling
for(season in c("hot", "cool"))
{
  if(season == "cool")
  {
    filesOfSeason_i <- c(5,6,7,8,9,10)  
    endat <- lengthYears
  } else {
    filesOfSeason_i <- c(11,12,13,14,15,16) 
    endat <- lengthYears - 1
  }
  
  for (year in 1:endat){ 
    ## setup for checking month 
    # year  <- endat
    
    
    ## checking
    print(cat("####################\n\n"))
    print(cfiles[filesOfSeason_i])
    
    b <- brick(stack(cfiles[filesOfSeason_i])) 
    ## calculate mean 
    m <- mean(b) 
    ## checking 
    # image(m) 
    writeRaster(m, file.path(homedir,sprintf("season_%s_%s.tif", season, year)), drivername="GTiff")
    filesOfSeason_i <- filesOfSeason_i + 12
  } 
}

##### now we will overall average
setwd(homedir)
for(season in c("cool", "hot"))
{
  cfiles <- list.files(pattern = season, full.names=T)   
  print(cfiles)
  b <- brick(stack(cfiles)) 
  ## calculate mean 
  m <- mean(b) 
  ## checking 
  # image(m) 
  writeRaster(m, file.path(homedir,sprintf("season_%s.tif", season)), drivername="GTiff")
}

# qc
cool <- raster("season_cool.tif")
hot <- raster("season_hot.tif")
par(mfrow = c(2,1))
image(cool)
image(hot)

