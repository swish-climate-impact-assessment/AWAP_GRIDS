
################################################################
# name:scope
# This workflow will deliver weather data from the EWEDB to a local directory.
# Ivan Hanigan 2012-12-14

# README:
#   Running this workflow will cause a GUI box to appear for your password.
# Sometimes this GUI box is behind other windows.
# 
# Either change the inputs above, or set interactively to TRUE.
# In interactively mode a GUI box will open where you can change the values, 
# or leave blank to accept the defaults.
# 
# NB dates need quotation marks if using the GUI box.
# 
# TODO:
#   There are missing days in  solarave, vprph09, vprph15.
# Try downloading again to see if fixed now.
# Add the population weighted averaging approach.

if(!require(fgui)) install.packages("fgui", repos='http://cran.csiro.au'); require(fgui)
if(!require(swishdbtools)) print('Please download the swishdbtools package and install it.')
# for instance 
# install.packages("~/tools/swishdbtools_1.0_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source");
require(swishdbtools)


# # user definitions, or setup interactively
# username <- 'gislibrary'
# spatialzones <- 'SD'
# outdir <- '~/'
# startdate <- '1995-01-01'
# enddate <-  '1997-01-01'
# interactively <- TRUE 
# 
if (exists('username')) {
  u <- username
} else {
  u <- 'gislibrary'
}
if (exists('spatialzones')) {
  s <- spatialzones
} else {
  s <- 'SD'
}
if (exists('outdir')) {
  o <- outdir
} else {
  o <- '~/'
}
if (exists('startdate')){
  startdate <- as.Date(startdate) 
} else {
  startdate <- '1995-01-01'
}
if (exists('enddate')){    
  enddate <- as.Date(enddate)
} else {
  enddate <-  '1997-01-01'
}
if (exists('interactively')){    
  interactively <- interactively
} else {
  interactively <- TRUE
}
# if these all exist don't run the scope gui?
#if(!exists('username') & !exists('spatialzones') & !exists('outdir')){
# or set 

if(interactively == TRUE){
  scope <- function(usernameOrBlank=u, 
                    spatialzonesOrBlank = s, 
                    outdirOrBlank=o,
                    startdateOrBlank=startdate,
                    enddateOrBlank=enddate){
    L <- list(
      u <- usernameOrBlank,
      s <- spatialzonesOrBlank,
      o <- outdirOrBlank,
      startdate <- startdateOrBlank,
      enddate <- enddateOrBlank
    )
    return(L)
  }
  Listed <- guiv(scope)
  Listed
  u <- Listed[1]
  s <- Listed[2]
  o <- Listed[[3]][1]
  startdate <- as.Date(Listed[[4]][1])
  enddate <- as.Date(Listed[[5]][1])
}
# don't let password get hardcoded
p <- getPassword()

# ch <- connect2postgres(h = '115.146.84.135', 
#                        d =  'ewedb', 
#                        u = u, 
#                        p = p)


# dat <- dbGetQuery(ch,
#                  "SELECT date, year, sla_code, minave, maxave, solarave, vprph09,vprph15
#                  FROM weather_sla.weather_sla
#                  where sla_code = 105051100 order by date
# ")
# with(dat, plot(date, maxave, type = 'l'))
