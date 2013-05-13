
# based on
# ~/projects/swish-climate-impact-assessment.github.com/tools/ExtractAWAPdata4locations

# this script runs the ExtractAWAPGRIDS functions for sample locations
# depends on swishdbtools package from http:/swish-climate-impact-assessment.github.com
# eg
workingdir <- "~/data/AWAP_GRIDS/data"
setwd("~/data/AWAP_GRIDS")
# eg
percentSample <- 0.1
#fileName <-  "zones.xlsx"
# eg
outputFileName <- "locations.shp"
# eg
outputDataFile <- "check-against-stations.csv"
# eg
StartDate <- "2010-01-01" 
# eg
EndDate <- "2010-01-01" 
  
################################################################
# name: Get-selected-stations
# want to get a set of stations that observed any of our awap variables
require(swishdbtools)
p  <- getPassword(remote = T)
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
dbWriteTable(ch, tempTableName$table, locations, row.names = F)
tested <- sql_subset(ch, tempTableName$fullname, eval = T)
#tested
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

raster_extract_by_day(ch, startdate, enddate,
                      schemaName = tempTableName$schema,
                      tableName = tempTableName$table,
                      pointsLayer = tempTableName_locations,
                      measures = c("maxave", "minave", "totals", "vprph09", "vprph15")
)

output_data <- reformat_awap_data(
  tableName = tempTableName$fullname
)

outputDataFile <- file.path(workingdir, outputDataFile)
write.csv(output_data,outputDataFile, row.names = FALSE)
outputFileName <- outputDataFile
outputFileName

################################################################
# name: get the observed data for these
require(swishdbtools)
require(reshape)
p <- getPassword(remote = T)
ch <- connect2postgres("tern5.qern.qcif.edu.au", "ewedb", "gislibrary", p = p)
# all the stations are in
# selectedStations  <- read_file(file.path(workingdir, "selected-stations.csv"))
check_against_stations <- read.csv("~/data/AWAP_GRIDS/data/check-against-stations.csv")
check_against_stations$date <- as.Date(check_against_stations$date)
head(check_against_stations)
stnum  <- check_against_stations$address[1]
stnum
with(subset(check_against_stations, address == stnum), plot(date, maxave, type = "l"))
selectedStations <- names(table(check_against_stations$address))
head(selectedStations)
length(selectedStations)
hour <- 9
d <- dbGetQuery(ch,
# cat(
 paste("SELECT  station_number as address, name, cast(year || '-' || month || '-' ||  day as date) as date, hour, \"timestamp\" ,     t2.lat ,     lon,
       vapour_pressure_in_hpa
  FROM weather_bom.bom_3hourly_data_1990_2010_master join weather_bom.combstats t2
  on station_number = stnum
  where station_number in ('",
       paste(selectedStations, sep = "", collapse = c("','")),
       "')
  and hour = ", hour ,"
  and quality_of_vapour_pressure = 'Y'
  order by day, hour
 ", sep = "")
)
                
head(d)
str(d)
## with(d,
##      plot(
##        as.POSIXct(timestamp), vapour_pressure_in_hpa,type='b',pch=16
##        )
##      )

##  # get mean absolute difference with the grid vs stations
str(check_against_stations)
df <- merge(check_against_stations, d)
head(df)
# plot(df$vapour_pressure_in_hpa, df$vprph09)
# great stuff.


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
