
# newnode get_data
# authors: Joseph Guillaume and Francis Markham
get_data<-function(variable,measure,timestep,startdate,enddate){
  url="http://www.bom.gov.au/web03/ncc/www/awap/{variable}/{measure}/{timestep}/grid/0.05/history/nat/{startdate}{enddate}.grid.Z"
  url=gsub("{variable}",variable,url,fixed=TRUE)
  url=gsub("{measure}",measure,url,fixed=TRUE)
  url=gsub("{timestep}",timestep,url,fixed=TRUE)
  url=gsub("{startdate}",startdate,url,fixed=TRUE)
  url=gsub("{enddate}",enddate,url,fixed=TRUE)
  download.file(url,sprintf("%s_%s%s.grid.Z",measure,startdate,enddate),mode="wb")
  }
  
get_data_range<-function(variable,measure,timestep,startdate,enddate){
  if (timestep == "daily"){
    thisdate<-startdate
    while (thisdate<=enddate){
      get_data(variable,measure,timestep,format(as.POSIXct(thisdate),"%Y%m%d"),format(as.POSIXct(thisdate),"%Y%m%d"))
      thisdate<-thisdate+as.double(as.difftime(1,units="days"),units="secs")
    }
  } else if (timestep == "month"){
    # Make sure that we go from begin of the month
    startdate <- as.POSIXlt(startdate)
    startdate$mday <- 1
    # Find the first and last day of each month overlapping our range
    data.period.start <- seq(as.Date(startdate), as.Date(enddate), by = 'month')
    data.period.end <- as.Date(sapply(data.period.start, FUN=function(x){as.character(seq(x, x + 40, by = 'month')[2] - 1)}))
    # Download them
    for (i in 1:length(data.period.start)){
      get_data(variable,measure,timestep,format(as.POSIXct(data.period.start[i]),"%Y%m%d"),format(as.POSIXct(data.period.end[i]),"%Y%m%d"))
    }
   
} else {
    stop("Unsupported timestep, only 'daily' and 'month' are currently supported")
  }
}
