
################################################################
# name:dlAWAP_GRIDS
# Function to download the Australian Water Availability Grids http://www.bom.gov.au/jsp/awap/
# Joseph Guillaume
# January 2009
# modified by Ivan Hanigan
# Feb 2012

# newnode TOOLS
if(!require(devtools)) install.packages("devtools"); require(devtools)
install_github("delphe", "ivanhanigan")
require(delphe)
if(!require(raster)) install.packages('raster');require(raster)
if(!require(maptools)) install.packages('maptools');require(maptools)
#if(!require(uncompress)) install.packages('uncompress');require(uncompress) # deprecated

# newnode variable names
# urls can be like
        # rain                http://www.bom.gov.au/web03/ncc/www/awap/   rainfall/totals/daily/    grid/0.05/history/nat/2010120120101201.grid.Z
        # tmax                http://www.bom.gov.au/web03/ncc/www/awap/   temperature/maxave/daily/ grid/0.05/history/nat/2012020620120206.grid.Z
        # tmin                http://www.bom.gov.au/web03/ncc/www/awap/   temperature/minave/daily/ grid/0.05/history/nat/2012020620120206.grid.Z
        # vapour pressure 9am http://www.bom.gov.au/web03/ncc/www/awap/   vprp/vprph09/daily/       grid/0.05/history/nat/2012020620120206.grid.Z
        # vapour pressure 3pm http://www.bom.gov.au/web03/ncc/www/awap/   vprp/vprph15/daily/       grid/0.05/history/nat/2012020620120206.grid.Z
        # solar               http://www.bom.gov.au/web03/ncc/www/awap/   solar/solarave/daily/     grid/0.05/history/nat/2012020720120207.grid.Z
        # NDVI                http://reg.bom.gov.au/web03/ncc/www/awap/   ndvi/ndviave/month/       grid/history/nat/2012010120120131.grid.Z
vars<-"variable,measure,timestep
rainfall,totals,daily
temperature,maxave,daily
temperature,minave,daily
vprp,vprph09,daily
vprp,vprph15,daily
solar,solarave,daily
ndvi,ndviave,month
"
vars<-read.csv(textConnection(vars))

# newnode get_data
get_data<-function(variable,measure,timestep,startdate,enddate){
url="http://www.bom.gov.au/web03/ncc/www/awap/{variable}/{measure}/{timestep}/grid/0.05/history/nat/{startdate}{enddate}.grid.Z"
url=gsub("{variable}",variable,url,fixed=TRUE)
url=gsub("{measure}",measure,url,fixed=TRUE)
url=gsub("{timestep}",timestep,url,fixed=TRUE)
url=gsub("{startdate}",startdate,url,fixed=TRUE)
url=gsub("{enddate}",enddate,url,fixed=TRUE)
download.file(url,sprintf("%s_%s%s.grid.Z",measure,startdate,enddate),mode="wb")
}

# newnode get_data_range
get_data_range<-function(variable,measure,timestep,startdate,enddate){
        thisdate<-startdate
        while (thisdate<=enddate){
                get_data(variable,measure,timestep,format(as.POSIXct(thisdate),"%Y%m%d"),format(as.POSIXct(thisdate),"%Y%m%d"))
                thisdate<-thisdate+as.double(as.difftime(1,units="days"),units="secs")
        }
}

# newnode read.asciigrid2
#Modified from maptools package
#Reads only the specified number of data items, ignoring BOM's wierd footer
read.asciigrid2<-function (fname, as.image = FALSE, plot.image = FALSE, colname = fname, proj4string = CRS(as.character(NA))) {
    t = file(fname, "r")
    l5 = readLines(t, n = 6)
    l5s = strsplit(l5, "\\s+", perl = T)
    xllcenter = yllcenter = xllcorner = yllcorner = as.numeric(NA)
    for (i in 1:6) {
        fieldname = casefold(l5s[[i]][1])
        if (length(grep("ncols", fieldname)))
            ncols = as.numeric(l5s[[i]][2])
        if (length(grep("nrows", fieldname)))
            nrows = as.numeric(l5s[[i]][2])
        if (length(grep("xllcorner", fieldname)))
            xllcorner = as.numeric(l5s[[i]][2])
        if (length(grep("yllcorner", fieldname)))
            yllcorner = as.numeric(l5s[[i]][2])
        if (length(grep("xllcenter", fieldname)))
            xllcenter = as.numeric(l5s[[i]][2])
        if (length(grep("yllcenter", fieldname)))
            yllcenter = as.numeric(l5s[[i]][2])
        if (length(grep("cellsize", fieldname)))
            cellsize = as.numeric(l5s[[i]][2])
        if (length(grep("nodata_value", fieldname)))
            nodata.value = as.numeric(l5s[[i]][2])
    }
    if (is.na(xllcorner) && !is.na(xllcenter))
        xllcorner = xllcenter - 0.5 * cellsize
    else xllcenter = xllcorner + 0.5 * cellsize
    if (is.na(yllcorner) && !is.na(yllcenter))
        yllcorner = yllcenter - 0.5 * cellsize
    else yllcenter = yllcorner + 0.5 * cellsize
    map = scan(t, as.numeric(0), quiet = TRUE,nmax=nrows*ncols)
    close(t)
    if (length(as.vector(map)) != nrows * ncols)
        stop("dimensions of map do not match that of header")
    map[map == nodata.value] = NA
    if (as.image) {
        img = matrix(map, ncols, nrows)[, nrows:1]
        img = list(z = img, x = xllcorner + cellsize * ((1:ncols) -
            0.5), y = yllcorner + cellsize * ((1:nrows) - 0.5))
        if (plot.image) {
            image(img, asp = 1)
            return(invisible(img))
        }
        else return(img)
    }
    df = data.frame(map)
    names(df) = colname
    grid = GridTopology(c(xllcenter, yllcenter), rep(cellsize,
        2), c(ncols, nrows))
    SpatialGridDataFrame(grid, data = df, proj4string = proj4string)
}

# newnode grid2csv
# filename must be in format generated by get_data: variable_{startdate}{enddate}
grid2csv<-function(filename){
        variable<-strsplit(filename,"_")[[1]][1]
        year<-as.numeric(substr(strsplit(filename,"_")[[1]][2],1,4))
        month<-as.numeric(substr(strsplit(filename,"_")[[1]][2],5,6))
        day<-as.numeric(substr(strsplit(filename,"_")[[1]][2],7,8))
        csv_filename<-sub("grid","csv",filename)
        d<-read.asciigrid2(filename)
        #image(d)
        e<-as.data.frame(d)
        names(e)<-c(variable,"long","lat")
        e$year<-year
        e$month<-month
        e$day<-day
        write.csv(e,csv_filename,row.names=FALSE,na="")
}

################################################################
  # name:dlAWAP_GRIDS



# newnode LOAD
# TESTS
# # tmax
# i <- 2
# vars[i,]
# get_data_range(variable=vars[i,1],measure =vars[i,2],timestep=vars[i,3],
#                startdate=as.POSIXct("2012-11-01"),
#                enddate=as.POSIXct("2012-11-20"))
# # vp
# i <- 4
# vars[i,]
# get_data_range(variable=vars[i,1],measure =vars[i,2],timestep=vars[i,3],
#                startdate=as.POSIXct("2010-12-30"),
#                enddate=as.POSIXct("2010-12-31"))
#
# # solar
# i <- 6
# vars[i,]
# get_data_range(variable=vars[i,1],measure =vars[i,2],timestep=vars[i,3],
#                startdate=as.POSIXct("2010-12-30"),
#                enddate=as.POSIXct("2010-12-31"))
dir.create('data1995-1999')
setwd('data1995-1999')
rootdir <- getwd()
started <- Sys.time()
for(i in 1:6){
# i <- 1
vname <- as.character(vars[i,1])
#print(vname)
dir.create(vname)
setwd(vname)
get_data_range(variable=vars[i,1],measure =vars[i,2],timestep=vars[i,3],
               startdate=as.POSIXct("1995-01-01"),
               enddate=as.POSIXct("1999-12-31"))
setwd(rootdir)
}
finished <- Sys.time()
finished - started
system('df -h')
# newnode uncompress
# test with one
started <- Sys.time()
for(i in 1:6){
# i <- 1
vname <- as.character(vars[i,1])
print(vname)
setwd(vname)
files <- dir(pattern='.grid.Z')
# files
for (f in files) {
# f <- files[1]
# print(f)
system(sprintf('uncompress %s',f))
# grid2csv(gsub('.Z','',f))
}
setwd(rootdir)
}
finished <- Sys.time()
finished - started
system('df -h')


#############################################
# compress into 5 year chuncks
setwd('..')
#rootdir <- getwd()
started <- Sys.time()
#dir()
# manually set to the right directory
system('zip -r data1995-1999 data1995-1999')
finished <- Sys.time()
finished - started
system('df -h')
file.info('data1995-1999.zip')
#############################################
# newnode CHECK

# newnode check grid
print(f)
# to select a differnt one
f <- gsub('.Z','',files[21])
setwd('solar')
d <- read.asciigrid2(f)
str(d)
# compare with http://www.bom.gov.au/jsp/awap/vprp/archive.jsp?colour=colour&map=vprph15&year=2010&month=12&day=30&period=daily&area=nat
# far out that colour scheme is dodgy!
image(d, col = rainbow(19))

# newnode check csv
#read.table(sub("grid","csv",f), nrows = 10, sep=',', header=T)

# newnode TODO
# now I want to get a time series for a pixel based on the name of a town or city
# I think I'll load the CSV to PostGIS for spatial query
# also want to check the error between the station observation and the pixel values.

#################################
# but first lets look at the station locations on a grid
require(delphe)
# args(readOGR2)
# shp <- readOGR2(h='115.146.84.135', d='ewedb',u='ivan_hanigan',
#                  layer = 'weather_bom.combstats')
# plot(shp)
#################################
# try just the raw data
## args(connect2postgres)
ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'ivan_hanigan')
# enter password at console
#shp <- dbGetQuery(ch, 'select stnum, lat, lon from weather_bom.combstats')
shp <- dbGetQuery(ch, 'select sla_code, st_x(st_centroid(the_geom)) as lon, st_y(st_centroid(the_geom)) as lat from abs_sla.aussla01')
nrow(shp)
if (!require(rgdal)) install.packages('rgdal'); require(rgdal)
epsg <- make_EPSG()

## Treat data frame as spatial points
shp <- SpatialPointsDataFrame(cbind(shp$lon,shp$lat),shp,
                              proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))
str(shp)
head(shp@data)
## #writeOGR(shp, 'test.shp', 'test', driver='ESRI Shapefile')
plot(shp)

#################################
# start getting CCD temperatures
#setwd(rootdir)
started <- Sys.time()
for(v in 4:6){
#  v = 1
rootdir <- paste('/home/ResearchData/AWAP_GRIDS/data2000-2004/',vars[v,1],sep='')
#dir(rootdir)[1]
cfiles <- dir(rootdir)
cfiles <- cfiles[grep(as.character(vars[v,2]), cfiles)]

  for (i in seq_len(length(cfiles))) {
  #   i <- 2
    fname <- cfiles[[i]]
    variablename <- strsplit(fname, '_')[[1]][1]
    timevar <- gsub('.grid', '', strsplit(fname, '_')[[1]][2])
    timevar <- substr(timevar, 1,8)
    year <- substr(timevar, 1,4)
    month <- substr(timevar, 5,6)
    day <- substr(timevar, 7,8)
    timevar <- as.Date(paste(year, month, day, sep = '-'))
    r <- raster(file.path(rootdir,fname))
    e <- extract(r, shp, df=T)
    #str(e) ## print for debugging
    #image(r)
    #plot(shp, add = T)
    e1 <- cbind(shp@data, timevar, e[,2])
    names(e1) <- c(names(shp@data), 'date', variablename)
  #  head(e1)
    e1 <- e1[,c('sla_code', 'date', variablename)]
    write.table(e1, paste(variablename, '.csv', sep =''),
      col.names = i == 1, append = i > 1 , sep = ",", row.names = FALSE, na = '')
   ## write.table(e1, paste(variablename, '.csv', sep =''),
   ##    col.names = T, append = F, sep = ",", row.names = FALSE, na = '')
  
  }
}
finished <- Sys.time()
finished - started
file.info(paste(variablename, '.csv', sep =''))
# rather than read in this big file just check the last one
write.table(e1, paste(variablename, '-qc.csv', sep =''),
            col.names = T, append = F , sep = ",", row.names = FALSE)
qc <- read.csv(paste(variablename, '-qc.csv', sep =''))
qc$date <- as.Date(as.character(qc$date))
str(qc)
head(qc)
## Treat data frame as spatial points
qc <- SpatialPointsDataFrame(cbind(qc$lon,qc$lat),qc,
                              proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))
str(qc)
writeOGR(qc, paste(variablename, '-qc.shp', sep =''), paste(variablename, '-qc', sep =''), driver='ESRI Shapefile')

# TODO colourramp <- qc[,variablename]
with(subset(qc, date == as.Date('2010-01-01')),
            plot(lon, lat, pch = 16, col = qc[,variablename])
)


#############
# merge all variables to a single file
gc()
started <- Sys.time()
for(i in 1:6){
  # i <- 3
  vname <- as.character(vars[i,2])
  print(vname)
  datain <- read.csv(paste(vname, '.csv', sep =''))
  #file.remove(paste(vname, '.csv', sep =''))
  head(datain)
  #datain <- datain[,c('sla_code', 'date', vname)]
  if(i != 1){
    dataout <- merge(dataout, datain)
    rm(datain)
  } else {
    dataout <- datain
    rm(datain)
  }

}
system('df -h')
write.csv(dataout, 'merged.csv', row.names=F)
finished <- Sys.time()
finished - started
system('df -h')


