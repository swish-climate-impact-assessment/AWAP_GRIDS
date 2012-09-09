
# newnode CHECK 
# newnode check grid
files <- dir('data', pattern='.grid')
f <- files[1]
print(f)
# to select a differnt one
  
d <- read.asciigrid2(file.path('data',f))
str(d)
# compare with http://www.bom.gov.au/jsp/awap/vprp/archive.jsp?colour=colour&map=vprph15&year=2010&month=12&day=30&period=daily&area=nat
# far out that colour scheme is dodgy!
image(d, col = rainbow(19))
dev.copy(jpeg, 'fig1.jpg')
dev.off()
# newnode check csv
read.table(file.path('data',sub("grid","csv",f)), nrows = 10, sep=',', header=T)

d<-dbGetQuery(delphe,
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
 
 d2 <- dbGetQuery(delphe,
  "SELECT  stnum, yy as year, mm as month, dd as day, hh as hour, 
      to_timestamp(yy || '-' || mm || '-' || dd || ' ' || hh || ':' || 0, 'YYYY-MM-DD HH24:MI') as timestamp2,
      avg(val) as vprph
  FROM awap_grids.vprph_master tab1
      join 
      (       
      select t2.stnum, t1.*
      from awap_grids.awap_grid_05_stns t1,
      (select * from weather_bom.combstats where stnum = 70014) t2
      where st_contains(t1.the_geom,st_centroid(t2.the_geom))
      ) tab2
      on tab1.long = tab2.long and tab1.lat = tab2.lat
      group by stnum, yy, mm, dd, hh
  order by yy, mm , dd, hh
  ")
      d2
      with(d2, lines(as.POSIXct(timestamp2), vprph, type='b',pch=16,col='red'))
 
      d3 <- merge(d,d2, all=T)
      with(d3, plot(vprph, vapour_pressure_in_hpa,xlim=c(3,10),ylim=c(3,10)))
      lines(abline(0,1))
      dev.copy(jpeg,'fig2.jpg')
      dev.off()

# newnode IDW
dbGetQuery(delphe,'select * from weather_bom.combstats where stnum = 70014')
d3 <- dbGetQuery(delphe,
 'select *,
  st_distance(
   t1.the_geom, 
   t2.the_geom_pt
  ) as distances        
  from awap_grids.awap_grid_05_stns t2,
  (select * from weather_bom.combstats where stnum = 70014) t1
  where st_distance(
   t1.the_geom, 
   t2.the_geom_pt
   ) <= 0.05
 order by distances desc
 ')
d3[,c(1:2,5:10,13)]
d4 <- dbGetQuery(delphe,
 "select stnum, name, table2.yy as year, mm as month, dd as day, hh as hour,
 to_timestamp(yy || '-' || mm || '-' || dd || ' ' || hh, 'YYYY-MM-DD HH24') as timestamp2,
 sum(table2.val * (1/(table1.distances^2))) / sum(1/(table1.distances^2)) as weighted_data 
 from
 (
  select stnum, name, t2.*,
  st_distance(
   t1.the_geom, 
   t2.the_geom_pt
  ) as distances        
  from awap_grids.awap_grid_05_stns t2,
  (select * from weather_bom.combstats where stnum = 70014) t1
  where st_distance(
   t1.the_geom, 
   t2.the_geom_pt
   ) <= 0.05
  ) table1
 join awap_grids.vprph_master as table2
 on table1.long = table2.long and
    table1.lat = table2.lat
 group by table1.stnum,name,table2.yy, mm, dd, hh, to_timestamp(yy || '-' || mm || '-' || dd || ' ' || hh , 'YYYY-MM-DD HH24')
 order by yy, mm, dd, hh
 ")
str(d4)
head(d4)
head(d)
with(d4, plot(weighted_data, type='b',pch=16))
d5 <- merge(d,d4)
with(d5, plot(weighted_data,  vapour_pressure_in_hpa,xlim=c(3,10),ylim=c(3,10)))
lines(abline(0,1))
dev.copy(jpeg, res = 150,'fig2.jpg')
dev.off();dev.off()
