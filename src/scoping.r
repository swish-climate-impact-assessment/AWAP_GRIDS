
###########################################################################
# newnode: scoping

  require(fgui)
  #require(ProjectTemplate)
  #load.project()
  # # user definitions, or setup interactively
  # startdate <- '1995-01-01'
  # enddate <-  '1997-01-01'
  # interactively <- FALSE
  # variablenames <- 'maxave'

  if (exists('startdate')){
    startdate <- as.Date(startdate)
  } else {
    startdate <- '1995-01-01'
  }
  if (exists('enddate')){
    enddate <- as.Date(enddate)
  } else {
    enddate <-  '1996-01-30'
  }
  if (exists('interactively')){
    interactively <- interactively
  } else {
    interactively <- FALSE
  }
  # if (variablenames == 'all'){
  # variablenames <-  c('totals','maxave','minave','vprph09','vprph15','solarave'))
  # }
  if (exists('variablenames')){
    variablenames <- variablenames
    variablenames <- strsplit(variablenames, ',')
  } else {
    variablenames <- 'maxave,minave,totals'
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
