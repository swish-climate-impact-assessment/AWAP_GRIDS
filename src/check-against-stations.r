
require(ProjectTemplate)
load.project()
require(swishdbtools)
p <- getPassword()
ch <- connect2postgres(h = 'tern5.qern.qcif.edu.au', db = 'ewedb', user= 'gislibrary', p = p)
pgListTables(ch, "weather_bom")
stations  <- sql_subset(ch, "weather_bom.combstats", eval = T)
stations <- subset(stations, lat > -50 & lon < 160)
sampled  <- sample(stations$stnum, 0.015*nrow(stations))
sampled  <- stations[which(stations$stnum %in% sampled),]
nrow(sampled)
plot(sampled$lon, sampled$lat, pch = 16)
# send lat long to postgis


# get the observed data for these
d<-dbGetQuery(ch,
 'SELECT  name, year, month, day, hour, "timestamp" ,     t2.lat ,     lon,
       vapour_pressure_in_hpa
  FROM weather_bom.bom_3hourly_data_2010 join weather_bom.combstats t2
  on station_number = stnum
  where station_number = 70014
  and month  =8 and (hour = 9 or hour = 15)
  order by day, hour
 ')
 d
 str(d)
 with(d, plot(as.POSIXct(timestamp), vapour_pressure_in_hpa, type='b',pch=16))



 # extract_awap_by_day

 # get mean absolute difference with the grid vs stations
