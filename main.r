
################################################################
# Project: AWAP_GRIDS
# Author: ivanhanigan
# Maintainer: Who to complain to <ivan.hanigan@gmail.com>

# This is the main file for the project
# It should do very little except call the other files

####################
### Set the working directory
if(exists('workdir')){
  workdir <- workdir
} else {
  workdir <- "~/data/AWAP_GRIDS"
}
setwd(workdir)

####################
# Functions for the project

if (!require(ProjectTemplate)) install.packages('ProjectTemplate', repos='http://cran.csiro.au'); require(ProjectTemplate)
load.project()

####################
# user definitions, or setup interactively
startdate <- '2012-01-01'
enddate <-  Sys.Date()-4
interactively <- FALSE
variablenames <- 'maxave,minave,solarave,totals,vprph09,vprph15'
aggregation_factor <- 3
os <- 'linux' # only linux and windoze supported
pgisutils <- "\"C:\\pgutils\\postgis-pg92-binaries-2.0.2w64\\bin\\"
pgutils <- "\"C:\\pgutils\\pgsql\\bin\\"

####################
# run the project (alternately do this from Kepler)
source(file.path(workdir, "src/scoping.r"))
source(file.path(workdir, "src/load.r"))
# source("src/load.r")
# source("src/clean.r")
# source("src/do.r")
