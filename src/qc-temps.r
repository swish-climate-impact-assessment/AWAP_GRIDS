
###########################################################################
# newnode: qc-temps
delphe <- connect2postgres('130.56.102.41', 'delphe', 'ivan_hanigan')
qc1 <- dbGetQuery(delphe,
"SELECT station_number,
       maximum_temperature_in_24_hours_after_9am_local_time_in_degrees,

       minimum_temperature_in_24_hours_before_9am_local_time_in_degree,

       date
  FROM weather_bom.bom_daily_data_2000
  where station_number = 70014
  order by date
")

merged <- read.csv("~/AWAP_GRIDS/merged.csv")
merged$date <- as.Date(merged$date)
#qc <- subset(merged, stnum == 70014)
qc <- subset(merged, sla_code == 805357029)
head(qc)
with(qc, plot(date, maxave, type = 'l'))
with(qc1, lines(date,
                maximum_temperature_in_24_hours_after_9am_local_time_in_degrees,
                col = 'red')
     )
