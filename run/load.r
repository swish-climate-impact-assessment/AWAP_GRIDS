
dir.create('data')      
  setwd('data')
  # tmax
  # i <- 2
  # # vars[i,]
  # get_data_range(variable=vars[i,1],measure =vars[i,2],timestep=vars[i,3],startdate=as.POSIXct("2010-01-30"), enddate=as.POSIXct("2010-01-31"))
  # # vp DONT DO TOO MANY DOWNLOADS, PERHAPS A YEAR/MONTH AT A TIME, THEN CONVERTS/DELETES, THEN MORE DOWNLOADS


yy <- '2010'
leapyear<- ifelse( yy %in% c('1988', '1992', '1996', '2000', '2004', '2008', '2012'), T, F)
# http://en.wikipedia.org/wiki/List_of_leap_years
dir.create(yy)
setwd(yy)
strt=Sys.time()
for(mm in as.character(1)){
 print(mm)
 # mm <- as.character(1)
 dir.create(mm)
 setwd(mm)
 for(i in 4:5){
 # i <- 5
 variable<-gsub(' ','',vars[i,1])
 measure<-gsub(' ','',vars[i,2])
 timestep<-gsub(' ','',vars[i,3])
 maxdate <- ifelse(mm %in% c(9,4,6,11), 30, 31)
 if(mm == 2 & leapyear == F){maxdate <- 28}
 if(mm == 2 & leapyear == T){maxdate <- 29}
 get_data_range(variable=variable,measure =measure,timestep=timestep,
  startdate=as.POSIXct(paste(yy,"-",mm,"-01",sep="")),
  enddate=as.POSIXct(paste(yy,"-",mm,"-",maxdate,sep=""))
  )
 }
 setwd(file.path(wd,"data",yy))
}
setwd(file.path(wd,"data"))
end=Sys.time()
print(end-strt)

setwd(file.path(wd,'data',yy))
strt=Sys.time()
for(mm in c(1)){
# mm <- '12'
mm <- as.character(mm)
print(mm)
setwd(mm)
files <- dir(pattern='.grid.Z')

for (f in files) {
# f <- files[3]
 print(f)
 handle <- file(f, "rb")
 data <- readBin(handle, "raw", 99999999)
 close(handle)
 uncomp_data <- uncompress(data)
 handle <- file(gsub('.Z','',f), "wb")
 writeBin(uncomp_data, handle)
 close(handle)
 # newnode convert to long csvfor (f in dir(pattern=".grid$")) {
 grid2csv(gsub('.Z','',f))
 # clean up
 file.remove(f)
 }
setwd(file.path(wd,'data'))
}
endd=Sys.time()
print(endd-strt)
# 49 sec
setwd(wd)

dir()
dbSendUpdate(delphe,
'CREATE TABLE awap_grids.vprph_master (
lat numeric,
long numeric,
yy int4,
mm int4,
dd int4,
hh int4,
val numeric,
constraint vprph_master_pkey primary key (lat, long, yy, mm, dd, hh)
)
')

files <- dir('data', pattern='.csv')
f <- files[1]
print(f)
# to select a differnt one
  
d <- read.csv(file.path('data',f))
st <- Sys.time()
dbWriteTable(delphe, 'awap_grids_indat',d)
en <- Sys.time()
print(en-st)  
# 20 mins

setwd('data')
 # mm <- '1'
 setwd(mm)
 load2postgres(gsub('.grid','.csv',f),'awap_grids','awap_grids_indat', pguser='ivan_hanigan',db='delphe',ip='130.56.102.41')
 # this creates the file sqlquery.txt and should be passed to the psql.exe with COPY
 # but firest make a table for it to go into
 yy <- '2011'
 dbSendUpdate(delphe,
 # cat(
 paste('CREATE TABLE awap_grids.vprph_',yy,' (
 lat numeric,
 long numeric,
 yy int4,
 mm int4,
 dd int4,
 hh int4,
 val numeric,
 constraint vprph_',yy,'_pkey primary key (lat, long, yy, mm, dd, hh),
 constraint month_range check (yy = ',yy,')
 )
 INHERITS (awap_grids.vprph_master)
 ',sep='')
 )
 # test the copy and insert


 st <- Sys.time()
 shell(paste("type sqlquery.txt \"",gsub('.grid','.csv',f),"\" | \"i:\\my dropbox\\tools\\pgutils\\psql\" -h 130.56.102.41 -U ivan_hanigan -d delphe",sep=""))
 en <- Sys.time()
 print(en-st)    
   # # 9 sec from work pc, 3.4 mins over vpn, remember to make pgadmin remember your password
 # unfortunatly emacs nogo with the shell() bit of this so done in plain R console

 # newnode subset to gridcells that have stations
 # first make station grid
 dbSendUpdate(delphe,"select long, lat into awap_grids.awap_grid_05 from awap_grids.awap_grids_indat")
 dbGetQuery(delphe,"SELECT AddGeometryColumn(\'awap_grids\', \'awap_grid_05\', \'the_geom\', 4283, \'POLYGON\', 2);")
 # newnode add grid
# TASK THIS SEEMS TO HAVE CREATED THE WRONG GRID LINES.  MIGHT DELETE THIS?
'
**** TODO TASK remove grid
'
 dbSendUpdate(delphe,
 "UPDATE awap_grids.awap_grid_05 SET the_geom=GeomFromText('POLYGON((
 '|| long-0.05 || ' '|| lat-0.05 ||',
 '|| long-0.05 || ' '|| lat+0.05 ||',
 '|| long+0.05 || ' '|| lat+0.05 ||',
 '|| long+0.05 || ' '|| lat-0.05 ||',
 '|| long-0.05 || ' '|| lat-0.05 ||'
 ))' ,4283);
 alter table awap_grids.awap_grid_05 add column gid serial primary key;")
 dbSendUpdate(delphe,'grant select on awap_grids.awap_grid_05 to public_group')
 dbSendUpdate(delphe,
  'ALTER TABLE awap_grids.awap_grid_05 ALTER COLUMN the_geom SET NOT NULL;
  CREATE INDEX awap_grid_05_index on awap_grids.awap_grid_05 using GIST(the_geom);
  ALTER TABLE awap_grids.awap_grid_05 CLUSTER ON awap_grid_05_index;
  ')
 # realise that contains and within return multiple grid cells, maybe because of polygon?  make point tools
 points_to_geom_query(schema='awap_grids',tablename='awap_grid_05',col_lat='lat',col_long='long')
 dbSendUpdate(delphe,
  "SELECT AddGeometryColumn('awap_grids', 'awap_grid_05', 'the_geom_pt', 4283, 'POINT', 2);
  ALTER TABLE awap_grids.awap_grid_05 ADD CONSTRAINT geometry_valid_check CHECK (isvalid(the_geom_pt));

        UPDATE awap_grids.awap_grid_05
        SET the_geom_pt=GeomFromText(
                'POINT('||
                long ||
                ' '||
                lat ||')'
                ,4283);
                                ")
 # dbSendUpdate(delphe,'drop table awap_grids.awap_grid_05_stns')
 dbSendUpdate(delphe,'
  select distinct t1.long, t1.lat, t1.the_geom, t1.the_geom_pt
  into awap_grids.awap_grid_05_stns
  from awap_grids.awap_grid_05 t1,
  weather_bom.combstats t2
  where st_contains(t1.the_geom,t2.the_geom);
  alter table awap_grids.awap_grid_05_stns add column gid serial primary key;
  ALTER TABLE awap_grids.awap_grid_05_stns ALTER COLUMN the_geom SET NOT NULL;
  CREATE INDEX awap_grid_05_stns_index on awap_grids.awap_grid_05_stns using GIST(the_geom);
  ALTER TABLE awap_grids.awap_grid_05_stns CLUSTER ON awap_grid_05_stns_index;
  ')





 # newnode now do the bulk uploads (via Rconsole, not ess which hates shell)
 setwd(file.path(wd,'data',yy))
 st <- Sys.time()
 for(mm in c(1)){
  # mm <- '3'
  mm <- as.character(mm)
  print(mm)
  setwd(mm)
 # mm <- '1'
 # setwd(mm)
  files <- dir(pattern='.csv')
 f <- files[1]
 load2postgres(gsub('.grid','.csv',f),'awap_grids','awap_grids_indat', pguser='ivan_hanigan',db='delphe',ip='130.56.102.41')


 for(hh in c('09','15')){
  # hh = '09'
  filesi <- files[grep(paste('vprph',hh,sep=''),files)]
  for(filei in filesi){
#  filei <- filesi[1]
   print(filei)
   
   shell(paste("type sqlquery.txt \"",filei,"\" | \"i:\\my dropbox\\tools\\pgutils\\psql\" -h 130.56.102.41 -U ivan_hanigan -d delphe",sep=""))
   
   dbSendUpdate(delphe, 
   # cat(
   paste("INSERT INTO awap_grids.vprph_",yy," (lat,long ,yy ,mm ,dd , hh, val)
   SELECT t1.lat, t1.long, year, month, day, '",hh,"', vprph09
   FROM awap_grids.awap_grids_indat t1
   right join awap_grids.awap_grid_05_stns t2
   on t1.long = t2.long and t1.lat = t2.lat 
   ",sep="")
   )
   dbRemoveTable(delphe, 'awap_grids.awap_grids_indat')

   # TODO drop all pixels with no stations before insert?
   # TODO vacuum database after each loop?  or every 100?
  }
 }
 setwd(file.path(wd,'data')) 
 }
 en <- Sys.time()
 print(en-st)  
 setwd(file.path(wd))
