
################################################################
# name:load_mirrored_grids

# Project: AWAP_GRIDS
# Author: ivanhanigan
# Maintainer: Who to complain to <ivan.hanigan@gmail.com>

# This file loads all the libraries and data files needed
# Don't do any cleanup here

### Load any needed libraries
#load(LibraryName)
setwd(workdir)
require(ProjectTemplate)
load.project()
## ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb',
##                        user = 'gislibrary')
##
ch <- connect2postgres2("ewedb")
print(paste('root directory:', workdir))
setwd('data')

start_at <- scope[[1]][1]
print(start_at)
end_at <- scope[[2]][1]
print(end_at)

vars <- scope[[3]]
#  print(vars)

#  started <- Sys.time()

for(i in 1:length(vars[[1]])){
#    i = 1
  measure_i <- vars[[1]][i]
  variable <- variableslist[which(variableslist$measure == measure_i),]
  vname <- as.character(variable[,1])
  if(checkDates == TRUE)
    {
      datelist <- DatesUnavailable(ch, measure_i, start_at, end_at)
    } else {
      datelist <- seq(as.Date(start_at), as.Date(end_at), 1)
    }
  for(date_i in datelist)
  {
  # date_i <- datelist[1]
    date_i <- as.Date(date_i, origin = '1970-01-01')
    date_i <- as.character(date_i)
  #  print(date_i)

    sdate <- date_i
    edate <- date_i
  #}
#     get_data_range(variable=as.character(variable[,1]),
#                    measure=as.character(variable[,2]),
#                    timestep=as.character(variable[,3]),
#                    startdate=as.POSIXct(sdate),
#                    enddate=as.POSIXct(edate))

    fname <- sprintf("%s_%s%s.grid.Z",measure_i,gsub("-","",sdate),gsub("-","",edate))
#
#     if(file.info(fname)$size == 0)
#       {
#         file.remove(fname)
#         next
#       }

#     if(os == 'linux')
#       {
#         uncompress_linux(filename = fname)
#       } else {
#         Decompress7Zip(zipFileName= fname, outputDirectory=getwd(), TRUE)
#       }
#     # hack to see if this fixes random breaking
#     if(!file.exists(gsub('.Z$','',fname)))
#     {
#       Sys.sleep(time=10)
#       uncompress_linux(filename = fname)
#     }
#     raster_aggregate(filename = gsub('.Z$','',fname),
#       aggregationfactor = aggregation_factor, delete = TRUE)
     outname <- gsub('.grid.Z',"", fname)
     outname <- substr(outname, 1, nchar(outname) - (8))

    p <- get_passwordTable()
    p <- p[which(p$V3 == "ewedb"), "V5"]
    r <- readGDAL2(source_server, 'gislibrary', 'ewedb',
                   schema = 'awap_grids', table = outname, p = p)
#    image(r)
    writeGDAL(r, gsub(".grid.Z", ".tif", fname), drivername="GTiff")

    load2postgres_raster(
                         ipaddress = destination_server,
                         u = "gislibrary", d = 'ewedb',
                         pgisutils = pgisutils, srid = 4283,
                         filename = gsub(".grid.Z", ".tif", fname),
                         out_schema="awap_grids",
                         out_table=outname, remove = T
                         )
  closeAllConnections()
  }

}

setwd(workdir)
