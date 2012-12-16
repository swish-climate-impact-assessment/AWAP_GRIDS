
################################################################
# name:main

if(!require(fgui)) install.packages("fgui", repos='http://cran.csiro.au'); require(fgui)
if(!require(swishdbtools)) print('Please download the swishdbtools package and install it.')
# for instance
# install.packages("~/tools/swishdbtools_1.0_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source");
require(swishdbtools)


# # user definitions, or setup interactively
# startdate <- '1995-01-01'
# enddate <-  '1997-01-01'
# interactively <- TRUE
# variablenames <- 'maxave'

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
# if (variablenames == 'all'){
# variablenames <-  c('totals','maxave','minave','vprph09','vprph15','solarave'))
# }
if (exists('variablenames')){
  variablenames <- variablenames
  variablenames <- strsplit(variablenames, ',')
} else {
  variablenames <- 'maxave, minave'
  variablenames <- strsplit(variablenames, ',')
}
# if these all exist don't run the scope gui?
#if(!exists('username') & !exists('spatialzones') & !exists('outdir')){
# or set

if(interactively == TRUE){
  getscope <- function (
    sdate = startdate,
    edate = enddate,
    variablenames) {
    scope <- list(
      startdate <- sdate,
      enddate <- edate,
      variablenames <- variablenames
    )
    return(scope)
  }
  scope <- guiv(getscope, argList = list(variablenames = c('totals','maxave','minave','vprph09','vprph15','solarave')))

} else {
    scope <- list(
      startdate <- startdate,
      enddate <- enddate,
      variablenames <- variablenames
    )
}
print(scope)
# don't let password get hardcoded
#p <- getPassword()

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
