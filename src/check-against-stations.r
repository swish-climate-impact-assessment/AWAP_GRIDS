
# based on
# ~/projects/swish-climate-impact-assessment.github.com/tools/ExtractAWAPdata4locations

# this script runs the ExtractAWAPGRIDS functions for sample locations
# depends on swishdbtools package from http:/swish-climate-impact-assessment.github.comC
# eg
workingdir <- "~/data/AWAP_GRIDS/data" 
# eg
percentSample <- 0.1
#fileName <-  "zones.xlsx"
# eg
outputFileName <- "test.shp"
# eg
outputDataFile <- "check-against-stations.csv"
# eg
StartDate <- "2013-01-10" 
# eg
EndDate <- "2013-01-20" 
  
################################################################
# name: Get-selected-stations
# want to get a set of stations that observed any of our awap variables
require(swishdbtools)
p  <- getPassword(remote=T)
ch <- connect2postgres("tern5.qern.qcif.edu.au", "ewedb", "gislibrary", p = p)
tbls  <- pgListTables(ch, "weather_bom")
tbls
# vprph
sql  <- sql_subset(ch, "weather_bom.bom_3hourly_data_1990_2010_master",
                   select = "distinct station_number",
                   subset = "quality_of_vapour_pressure = 'Y'",
                   eval = T
                   )
head(sql)  
nrow(sql)
# 953
# temp
sql2  <- sql_subset(ch, "weather_bom.bom_3hourly_data_1990_2010_master",
                   select = "distinct station_number",
                   subset = "quality_of_air_temperature = 'Y'",
                   eval = T
                   )
head(sql2)  
nrow(sql2)
# 980
# rain
sql3  <- sql_subset(ch, "weather_bom.bom_3hourly_data_1990_2010_master",
                   select = "distinct station_number",
                   subset = "quality_of_precipitation = 'Y'",
                   eval = T
                   )
head(sql3)  
nrow(sql3)  
# 948
stations  <- merge(sql, sql2)
nrow(stations)
# 953
stations  <- merge(stations, sql3)
nrow(stations)
# 943
write.csv(stations, file.path(workingdir, "selected-stations.csv"), row.names = F)

# or test grid
require(rgdal)
res=0.1
xs=seq(112,155,res)
ys=seq(-45,-9,res)
d=expand.grid(xs,ys)
head(d)
#points(gr1, pch = 16)

epsg <- make_EPSG()
pts <- SpatialPointsDataFrame(cbind(d$Var1,d$Var2),d,
                              proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))
writeOGR(pts, 'test.shp', 'test', driver='ESRI Shapefile')

################################################################
# name: GeoCode-selected-stations
require(swishdbtools)
ch <- connect2postgres2("ewedb")
stations  <- sql_subset(ch, "weather_bom.combstats", eval = T)
nrow(stations)
# 8139
# only on mainland
stations <- subset(stations, lat > -50 & lon < 160)
# only those with observations of all vars
selectedStations  <- read_file(file.path(workingdir, "selected-stations.csv"))
head(stations)
head(selectedStations)
stations  <- merge(stations, selectedStations, by.x = "stnum", by.y = "station_number")
nrow(stations)
# 939
sampled  <- sample(stations$stnum, percentSample * nrow(stations))
length(sampled)
# 93
locations  <- stations[which(stations$stnum %in% sampled),]
names(locations) <- gsub("lon", "long", names(locations))
names(locations) <- gsub("stnum", "address", names(locations))
# not gid
locations <- locations[,-c(which(names(locations) == "gid"))]
nrow(locations)
plot(locations$long, locations$lat, pch = 16)



epsg <- make_EPSG()
df <- SpatialPointsDataFrame(cbind(locations$long,locations$lat),locations,                             
                             proj4string=CRS(epsg$prj4[epsg$code %in% "4283"])
                             )
setwd(workingdir)
if(file.exists(outputFileName))
{
  for(ext in c(".shp", ".shx", ".dbf", ".prj"))
  {
    file.remove(gsub(".shp",ext,outputFileName))
  }
}
writeOGR(df,outputFileName,gsub(".shp","",outputFileName),"ESRI Shapefile")
tempTableName <- outputFileName

################################################################
# name: send2postgis
require(swishdbtools)
ch <- connect2postgres2("ewedb")
locations <- read_file(file.path(workingdir,tempTableName))
locations <- locations@data
tempTableName <- swish_temptable()
names(locations) <- c("long", "lat")
dbWriteTable(ch, tempTableName$table, locations, row.names = F)
tested <- sql_subset(ch, tempTableName$fullname, eval = T)
#head(tested)
tempTableName <- tempTableName$fullname
tempTableName

# points2geom
sch <- strsplit(tempTableName, "\\.")[[1]][1]
tbl <- strsplit(tempTableName, "\\.")[[1]][2]
sql <- points2geom(
  schema=sch,
  tablename=tbl,
  col_lat= "lat",col_long="long", srid="4283"
)
# cat(sql)
dbSendQuery(ch, sql)
tbl

################################################################
# name: R_raster_extract_by_day
require(swishdbtools)
require(awaptools)
if(!require(reshape))  install.packages("reshape", repos="http://cran.csiro.au/"); require(reshape);
tempTableName_locations <- tbl
startdate <- StartDate
enddate <- EndDate
ch<-connect2postgres2("ewedb")
tempTableName <- swish_temptable("ewedb")
# address doesn't exist
dbSendQuery(ch, "alter table gislibrary.foof053d732e0d add column address serial")
raster_extract_by_day(ch, startdate, enddate,
                      schemaName = tempTableName$schema,
                      tableName = tempTableName$table,
                      pointsLayer = tempTableName_locations,
                      measures = c("maxave") 
)
# test_out <- sql_subset(ch, tempTableName$fullname, eval = T)
# test_out_loc <- sql_subset(ch, paste("gislibrary.", tempTableName_locations, sep =""), eval = T)
# head(test_out)
# head(test_out_loc)
# test_out <- merge(test_out_loc, test_out)
# head(test_out)
# points(test_out$long, test_out$lat, col = test_out$value)


# "minave", "totals", "vprph09", "vprph15")
output_data <- reformat_awap_data(
  tableName = tempTableName$fullname
)

outputDataFile <- file.path(workingdir, outputDataFile)
write.csv(output_data,outputDataFile, row.names = FALSE)
outputFileName <- outputDataFile
outputFileName




## # send lat long to postgis


## # get the observed data for these
## d<-dbGetQuery(ch,
##  'SELECT  name, year, month, day, hour, "timestamp" ,     t2.lat ,     lon,
##        vapour_pressure_in_hpa
##   FROM weather_bom.bom_3hourly_data_2010 join weather_bom.combstats t2
##   on station_number = stnum
##   where station_number = 70014
##   and month  =8 and (hour = 9 or hour = 15)
##   order by day, hour
##  ')
##  d
##  str(d)
##  with(d, plot(as.POSIXct(timestamp), vapour_pressure_in_hpa, type='b',pch=16))



##  # extract_awap_by_day

##  # get mean absolute difference with the grid vs stations

################################################################
# name: tidy up
require(swishdbtools)
ch<-connect2postgres2("ewedb")
sch <- swish_temptable("ewedb")
sch <- sch$schema
tbls <- pgListTables(ch, sch, table="foo", match = FALSE)
tbls
for(tab in tbls[,1])
{
  dbSendQuery(ch, 
              sprintf("drop table %s.%s", sch, tab)
  )
}
  
check.against.stations <- read.csv("~/data/AWAP_GRIDS/data/check-against-stations.csv")
head(check.against.stations)
with(subset(check.against.stations, address == 3001), plot(as.Date(date), maxave, type = "l"))
