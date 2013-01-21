
################################################################
# name:load
# Project: AWAP_GRIDS
# Author: ivanhanigan
# Maintainer: Who to complain to <ivan.hanigan@gmail.com>

# This file loads all the libraries and data files needed
# Don't do any cleanup here

### Load any needed libraries
#load(LibraryName)
require(ProjectTemplate)
load.project()
sdate <- scope[[1]][1]
print(sdate)
edate <- scope[[2]][1]
print(edate)
year <- as.numeric(substr(sdate, 1,4))
## year2 <- year + 4
## year2
## if(as.numeric(substr(edate, 1,4)) > year2){
##   print('please only specify dates in 5 year chunks, 00-04 or 05-09')
##   stopTrigger <- TRUE
## } else {
##   stopTrigger <- FALSE
## }
vars <- scope[[3]]
print(vars)

### Load in any data files
  #
#if(stopTrigger == FALSE){
  try(dir.create('RawData'))
  setwd('RawData')
  rootdir <- getwd()
#  started <- Sys.time()
  for(i in 1:length(vars[[1]])){
#   i <- 6
#  variable <- variableslist[which(variableslist$measure == vars[[1]][i]),]
  variable <- variableslist[which(variableslist$measure == vars[[1]][i]),]
  vname <- as.character(variable[,1])
  try(dir.create(vname))
  setwd(vname)

  get_data_range(variable=as.character(variable[,1]),measure =as.character(variable[,2]),timestep=as.character(variable[,3]),
                  startdate=as.POSIXct(sdate),
                  enddate=as.POSIXct(edate))

  files <- dir(pattern='.grid.Z')
  for (f in files) {
    # f <- files[1]
    print(f)
    system(sprintf('uncompress %s',f))
    }
  setwd('..')
  }

  setwd('..')
  #}

  ## finished <- Sys.time()
  ## finished - started
  ## system('df -h')
  ## # newnode uncompress
  ## # test with one
  ## started <- Sys.time()
  ## for(i in 1:6){
  ## # i <- 1
  ## variable <- as.character(vars[i,1])
  ## print(variable)
  ## setwd(variable)
  ## files <- dir(pattern='.grid.Z')
  ## # files
  ## for (f in files) {
  ## # f <- files[1]

  ## # print(f)
  ## system(sprintf('uncompress %s',f))
  ## # grid2csv(gsub('.Z','',f))
  ## }
  ## setwd(rootdir)
  ## }
  ## finished <- Sys.time()
  ## finished - started
  ## system('df -h')

#  files
#  alreadyGot <- dir(file.path(workdir,paste('data',year,'-', year2, sep=''), vname), pattern='.grid')
#  alreadyGot[1:10]
#  gsub('.Z','',files) %in% alreadyGot

################################################################
# name:test geotiff

  rootdir <- paste(getwd(),'/',variableslist[v,1],sep='')
  #  dir(rootdir)[1]
  cfiles <- dir(rootdir)
  cfiles <- cfiles[grep(as.character(variableslist[v,2]), cfiles)]
  fname <- cfiles[[i]]

  r <- readGDAL(file.path(rootdir,fname))
  outfile <- gsub('.grid', '.TIF', fname)
  writeGDAL(r, file.path(rootdir, outfile), drivername="GTiff")
  r <- readGDAL(file.path(rootdir,outfile))
