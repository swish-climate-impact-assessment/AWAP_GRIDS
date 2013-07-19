
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
StartDate <- "1990-01-01" 
# eg
EndDate <- "2010-07-01" 
  
################################################################
# name: Get-selected-stations
# want to get a set of stations that observed any of our awap variables
require(swishdbtools)
#p  <- getPassword(remote = T)
#ch <- connect2postgres("tern5.qern.qcif.edu.au", "ewedb", "gislibrary", p = p)
ch <- connect2postgres2("ewedb")
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

if(!require(oz)) install.packages("oz"); require(oz)
require(maps)
require(fields)
png("../reports/selected-stations.png")
with(stations, plot(lon, lat, pch = 16, xlim =c(112,155), cex = .5))
with(locations, points(long, lat, pch = 19, col = 'red'))
oz(add = T)
map.scale(ratio=F)
dev.off()

p <- getPassword(remote = T)
# check a grid
# r <- readGDAL2("tern5.qern.qcif.edu.au","gislibrary","ewedb","awap_grids","totals_19900101",p=p)
# image(r)
# odd missings
#r2 <- readGDAL2("115.146.92.162","gislibrary","ewedb","awap_grids","totals_19900101",p=p)
#dev.off()
#image(r2)
# checked download again and not missing.

# make a temperature map
r <- readGDAL2("tern5.qern.qcif.edu.au","gislibrary","ewedb","awap_grids","maxave_20130118",p=p)
png("reports/grid-nsw.png", width = 500, height = 400)

zs <- c(15,48)
par(oma=c( 0,0,0,4)) # margin of 4 spaces width at right hand side
oz(sections=4, xlim=c(140,155), ylim = c(-38,-28))
image(r, add = T,  zlim=zs, col=tim.colors())
oz(add=T)
map.scale(ratio=F)
box()
title(main="maximum temperature (C) 2013-01-18")
par(oma=c( 0,0,0,1))# reset margin to be much smaller.
image.plot( legend.only=TRUE, zlim=zs) 

dev.off()


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
st <- Sys.time()
raster_extract_by_day(ch, startdate, enddate,
                      schemaName = tempTableName$schema,
                      tableName = tempTableName$table,
                      pointsLayer = tempTableName_locations,
                      measures = c("maxave", "minave", "totals", "vprph09", "vprph15")
)
<<<<<<< HEAD
#tempTableName$fullname
=======
end <- Sys.time()
end - st
# Time difference of 6.842461 hours
system.time(
>>>>>>> 3fa8a5e24e9114a77f7681db091afb3d0c55f688
output_data <- reformat_awap_data(
  tableName = paste(sch, tab, sep = ".")
)
)
outputDataFile <- file.path(workingdir, outputDataFile)
write.csv(output_data,outputDataFile, row.names = FALSE)
outputFileName <- outputDataFile
outputFileName

################################################################
# name: get the observed data for these
require(swishdbtools)
require(reshape)
#p <- getPassword(remote = T)
ch <- connect2postgres2("ewedb")
# all the stations are in
# selectedStations  <- read_file(file.path(workingdir, "selected-stations.csv"))
check_against_stations <- read.csv("~/data/AWAP_GRIDS/data/check-against-stations.csv")
check_against_stations$date <- as.Date(check_against_stations$date)
head(check_against_stations)
summary(check_against_stations)
check_against_stations$totals <- ifelse(is.na(check_against_stations$totals),0,check_against_stations$totals)
stnum_ids  <- sample(1:93, 4)
locations[stnum_ids,]
stnums <- locations[stnum_ids,1]
stnames <- locations[stnum_ids,2]
png("reports/sampled-timeseries-from-grid.png", width = 800, height = 500)
par(mfrow = c(2,2))
for(j in 1:4){
  with(subset(check_against_stations, address == stnums[j]), plot(date, maxave, type = "l"))
  title(main = paste("maxt, ", stnames[j], "(", format(locations$long[j], digits = 4), ", ", format(locations$lat[j], digits = 4), ")"), cex = .6)
}
dev.off()

selectedStations <- names(table(check_against_stations$address))
head(selectedStations)
length(selectedStations)
for(hour in c(9,15))
{
#hour <- 9
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
                
#head(d)
#str(d)
## with(d,
##      plot(
##        as.POSIXct(timestamp), vapour_pressure_in_hpa,type='b',pch=16
##        )
##      )

##  # get mean absolute difference with the grid vs stations
#str(check_against_stations)
df <- merge(check_against_stations, d)
#head(df)
Lab.palette <- colorRampPalette(c("lightblue", "orange", "red"), space = "Lab")
# plots 
  if(hour == 9){
  fit <- lm(df$vprph09 ~ df$vapour_pressure_in_hpa)
  summary(fit)
  # Multiple R-squared: 0.969,
  png("reports/vprph09.png")
  #plot(df$vapour_pressure_in_hpa, df$vprph09)
  smoothScatter(df$vapour_pressure_in_hpa, df$vprph09, colramp = Lab.palette)
  #abline(0,1, col = 'blue')
  abline(fit, col = 'black')
  legend("topright", legend = paste("R2 is ", format(summary(fit)$adj.r.squared, digits = 4)))
  dev.off()
  } else {
  fit <- lm(df$vprph15 ~ df$vapour_pressure_in_hpa)
  #summary(fit)
  png("reports/vprph15.png")
  smoothScatter(df$vapour_pressure_in_hpa, df$vprph15, colramp = Lab.palette)
  #abline(0,1, col = 'blue')
  abline(fit, col = 'black')
  legend("topright", legend = paste("R2 is ", format(summary(fit)$adj.r.squared, digits = 4)))
  dev.off()  
  }
}
# great stuff. now temps and rain
names(sql_subset(ch, "weather_bom.bom_daily_data_1990_2010", limit = 1, eval = T))
# [1] "station_number"                                                 
# [2] "year"                                                           
# [3] "month"                                                          
# [4] "day"  
# [5] "global_solar_exposure_at_location_derived_from_satellite_data_i"
# [6] "quality_of_global_solar_exposure_value"                         
# [7] "precipitation_in_the_24_hours_before_9am_local_time_in_mm"      
# [8] "quality_of_precipitation_value"                                 
# [9] "number_of_days_of_rain_within_the_days_of_accumulation"         
# [10] "accumulated_number_of_days_over_which_the_precipitation_was_mea"
# [11] "maximum_temperature_in_24_hours_after_9am_local_time_in_degrees"
# [12] "quality_of_maximum_temperature_in_24_hours_after_9am_local_time"
# [13] "days_of_accumulation_of_maximum_temperature"                    
# [14] "minimum_temperature_in_24_hours_before_9am_local_time_in_degree"
# [15] "quality_of_minimum_temperature_in_24_hours_before_9am_local_tim"
d <- dbGetQuery(ch,
                # cat(
                paste("SELECT  station_number as address, name, cast(year || '-' || month || '-' ||  day as date) as date, t2.lat ,     lon,
       maximum_temperature_in_24_hours_after_9am_local_time_in_degrees,
                      quality_of_maximum_temperature_in_24_hours_after_9am_local_time,
                      minimum_temperature_in_24_hours_before_9am_local_time_in_degree,
                      quality_of_minimum_temperature_in_24_hours_before_9am_local_tim,
                      precipitation_in_the_24_hours_before_9am_local_time_in_mm,
                      quality_of_precipitation_value
                      FROM weather_bom.bom_daily_data_1990_2010 join weather_bom.combstats t2
                      on station_number = stnum
                      where station_number in ('",
       paste(selectedStations, sep = "", collapse = c("','")),
                      "') 
                      ", sep = "")
)
str(d)

str(check_against_stations)
df <- merge(check_against_stations, d)
head(df)
  
# plots 
fit <- lm(df$maxave ~ df$maximum_temperature_in_24_hours_after_9am_local_time_in_degrees)
summary(fit)
png("reports/maxave.png")
smoothScatter(df$maximum_temperature_in_24_hours_after_9am_local_time_in_degrees, df$maxave, colramp = Lab.palette)
#abline(0,1, col = 'blue')
abline(fit, col = 'black')
legend("topright", legend = paste("R2 is ", format(summary(fit)$adj.r.squared, digits = 4)))
dev.off()

fit <- lm(df$minave ~ df$minimum_temperature_in_24_hours_before_9am_local_time_in_degree)
#summary(fit)
png("reports/minave.png")
smoothScatter(df$minimum_temperature_in_24_hours_before_9am_local_time_in_degree, df$minave, colramp = Lab.palette)
#abline(0,1, col = 'blue')
abline(fit, col = 'black')
legend("topright", legend = paste("R2 is ", format(summary(fit)$adj.r.squared, digits = 4)))
dev.off()  

fit <- lm(df$totals ~ df$precipitation_in_the_24_hours_before_9am_local_time_in_mm)
#summary(fit)
png("reports/totals.png")
smoothScatter(df$precipitation_in_the_24_hours_before_9am_local_time_in_mm, df$totals, colramp = Lab.palette)
#abline(0,1, col = 'blue')
abline(fit, col = 'black')
legend("topright", legend = paste("R2 is ", format(summary(fit)$adj.r.squared, digits = 4)))
dev.off()  


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
#   df <- sql_subset(ch, paste(sch, tab, sep = "."), limit = 2, eval = T)
# print(df)
# }
  dbSendQuery(ch, 
              sprintf("drop table %s.%s", sch, tab)
  )
}
