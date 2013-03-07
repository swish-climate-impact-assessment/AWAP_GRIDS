
################################################################
# name:check-duplicates
# in 23oct2007, and from 08jan2009 to  17apr2010, vprph09 and vprph15
# are the same.
require(ProjectTemplate)
load.project()
ch <- connect2postgres2("ewedb")
pwd <- get_passwordTable()
pwd <- pwd[which(pwd$V3 == 'ewedb'),5]
dates <- seq(as.Date("2007-10-01"), as.Date("2007-10-31"), 1)
date_j <- dates[1]
print(date_i)
suspicious_dates <- list()
#measures <- c("maxave","minave", "solarave","totals",
measures <- c("vprph09","vprph15")
for(j in 1:length(dates))
  {
    #date_j <- dates[2]
    date_j <- dates[j]
    date_i <- gsub("-","",date_j)
    print(date_i)
    rasters <- list()
    for(i in 1:length(measures))
    {
#      i = 2
      measure <- measures[i]
#      print(measure)
      rastername <- paste(measure, "_", date_i, sep ="")
      tableExists <- pgListTables(ch, schema="awap_grids", pattern=rastername)
      if(nrow(tableExists) > 0)
      {
        r1 <- readGDAL2("115.146.84.135", "gislibrary", "ewedb",
                        "awap_grids", rastername, p = pwd)
#        image(r1)
        rasters[[i]] <- r1
      }
    }
      ## str(rasters)
    ##   par(mfrow = c(1,2))
    ##   image(rasters[[1]])
    ##   image(rasters[[2]])
    suspect <- identical(rasters[[1]]@data, rasters[[2]]@data)
    #all.equal(head(rasters[[1]]@data), head(rasters[[2]]@data))
    if(suspect)
      {
        counter <- length(suspicious_dates)
        suspicious_dates[[counter + 1]] <- rastername
      }
    rm(suspect)

  }

suspicious_dates
