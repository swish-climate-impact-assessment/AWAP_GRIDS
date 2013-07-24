
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
destination_server <- "brawn.anu.edu.au"
  #"tern5.qern.qcif.edu.au" 
source_server <- "tern5.qern.qcif.edu.au" 
  #"115.146.92.162"
fresh <- TRUE
startdate <- '1990-01-01'
enddate <-  Sys.Date()-2
checkDates <- TRUE
interactively <- FALSE
variablenames <- 'solarave' #totals' #vprph09,vprph15' #,solarave maxave,minave' #,totals,
aggregation_factor <- 3
if(length(grep('linux',sessionInfo()[[1]]$os)) == 1)
{
  os <- 'linux'
} else {
  os <- 'windows'
}
#os <- 'linux' # only linux and windoze supported
pgisutils <- "/usr/pgsql-9.2/bin/"
#"\"C:\\pgutils\\postgis-pg92-binaries-2.0.2w64\\bin\\"
pgutils <- "\"C:\\pgutils\\pgsql\\bin\\"

####################
# run the project (alternately do this from Kepler)
source(file.path(workdir, "src/scoping.r"))
if(fresh == TRUE)
{
  source(file.path(workdir, "src/load.r"))  
} else {
  source(file.path(workdir, "src/load_mirrored_grids.r"))  
}

# source("src/load.r")
# source("src/clean.r")
# source("src/do.r")
