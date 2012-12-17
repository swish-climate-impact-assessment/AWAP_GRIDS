
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
# run the project (alternately do this from Kepler)
source(file.path(workdir, "src/scoping.r"))
source(file.path(workdir, "src/load.r"))
# source("src/load.r")
# source("src/clean.r")
# source("src/do.r")
