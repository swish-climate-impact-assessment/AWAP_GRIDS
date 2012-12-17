
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
vars <- scope[[3]]
print(vars)

### Load in any data files
  # # solar
  i <- 1
  variable <- variableslist[which(variableslist$measure == vars[[1]][i]),]
  get_data_range(variable=as.character(variable[,1]),measure =as.character(variable[,2]),timestep=as.character(variable[,3]),
                  startdate=as.POSIXct(sdate),
                  enddate=as.POSIXct(edate))
  ## dir.create('data1995-1999')
  ## setwd('data1995-1999')
  ## rootdir <- getwd()
  ## started <- Sys.time()
  ## for(i in 1:6){
  ## # i <- 1
  ## vname <- as.character(vars[i,1])
  ## #print(vname)
  ## dir.create(vname)
  ## setwd(vname)
  ## get_data_range(variable=vars[i,1],measure =vars[i,2],timestep=vars[i,3],
  ##                startdate=as.POSIXct("1995-01-01"),
  ##                enddate=as.POSIXct("1999-12-31"))
  ## setwd(rootdir)
  ## }
  ## finished <- Sys.time()
  ## finished - started
  ## system('df -h')
  ## # newnode uncompress
  ## # test with one
  ## started <- Sys.time()
  ## for(i in 1:6){
  ## # i <- 1
  ## vname <- as.character(vars[i,1])
  ## print(vname)
  ## setwd(vname)
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
