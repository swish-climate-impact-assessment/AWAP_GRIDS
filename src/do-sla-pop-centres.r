require(swishdbtools)
delphe <- connect2postgres('130.56.102.41', db='delphe', user='ivan_hanigan')
ewedb <- connect2postgres('115.146.84.135', db='ewedb', user='gislibrary')
# # there are some CCD with no matching SLA (ie offshore and migratory) so return nulls

# dbGetQuery(ewedb,paste('delete from abs_sla.',ste,'sla06_pwc
# where sla_code is null',sep=''))

# tried with electorates, still hardcoded to do census 06
# but other wise works
cdTblName <- 'ABS_CD.auscd06_master'
dbGetQuery(delphe, 'select * from ABS_CD.auscd06_master limit 1')
varID <- 'sla_code'
pwcName <- 'sla_pwc'
ste <- 'act'
measure_i <- 'maxave'

  
dbGetQuery(delphe,
           # cat(
           paste('drop table public.',pwcName,';
                 SELECT ',varID,', 
                 sum(t3.b3*st_x(st_centroid(the_geom)))/sum(t3.b3) as pwcx, 
                 sum(t3.b3*st_y(st_centroid(the_geom)))/sum(t3.b3) as pwcy
                 into public.',pwcName,'
                 FROM ',cdTblName,' t1
                 left join abs_census06.bcp_cd_',ste,'_b01 t3
                 on  t1.cd_code=t3.region_id 
                 group by ',varID,'
                 having sum(t3.b3)>0;',sep='')
           )
head(zones)
zones <- dbGetQuery(delphe, paste("select * from public.",pwcName,sep = ""))
plot(zones$pwcx, zones$pwcy)

dbWriteTable(ewedb, name=pwcName, zones)


points2geom<-function(schema,tablename,col_lat,col_long){
  table=sprintf("%s.%s",schema,tablename)
  
  cat(sprintf(
    "SELECT AddGeometryColumn('%s', '%s', 'the_geom', 4283, 'POINT', 2);\n",
    schema,tablename))
  
  cat(sprintf(
    "ALTER TABLE %s ADD CONSTRAINT geometry_valid_check CHECK (isvalid(the_geom));\n" ,
    table))
  
  cat(sprintf("
              UPDATE %s
              SET the_geom=GeomFromText(
              'POINT('||
              %s ||
              ' '||
              %s ||')'
              ,4283);\n",table,col_long,col_lat))
}
sql <- points2geom(schema='public',tablename=pwcName,col_lat='pwcy',col_long='pwcx')

dbGetQuery(ewedb,
           # cat(
           paste(
             "SELECT AddGeometryColumn('public', '",pwcName,"', 'the_geom', 4283, 'POINT', 2);

              

              ALTER TABLE public.",pwcName," ADD CONSTRAINT geometry_valid_check CHECK (st_isvalid(the_geom));
         
              UPDATE public.",pwcName,"
              SET the_geom=st_GeomFromText(
              'POINT('||
              pwcx ||
              ' '||
              pwcy ||')'
              ,4283);

 
              alter table public.",pwcName," add column gid serial primary key;
              ALTER TABLE public.",pwcName," ALTER COLUMN the_geom SET NOT NULL;
              CREATE INDEX ",pwcName,"_gist on public.",pwcName," using GIST(the_geom);
              ALTER TABLE public.",pwcName," CLUSTER ON ",pwcName,"_gist;"
             ,sep="")
           )

#               dbGetQuery(ewedb,
#               # cat(
#               paste('delete from public.',pwcName,'
#               where ',varID,' is null',sep='')
#               )


require(ProjectTemplate)
load.project()

ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'gislibrary')
start_at <- '1980-01-01'
end_at <- '2013-01-20'
datelist_full <- as.data.frame(seq(as.Date(start_at),
                                   as.Date(end_at), 1))
names(datelist_full) <- 'date'

measure_i <- 'maxave'
tbls <- pgListTables(conn=ch, schema='awap_grids', pattern = measure_i)

pattern_x <- paste(measure_i,"_",sep="")
tbls$date <- paste(
  substr(gsub(pattern_x,"",tbls[,1]),1,4),
  substr(gsub(pattern_x,"",tbls[,1]),5,6),
  substr(gsub(pattern_x,"",tbls[,1]),7,8),
  sep="-")
tbls$date <- as.Date(tbls$date)
datelist <- which(datelist_full$date %in% tbls$date)

if(length(datelist) == 0)
{
  datelist <- datelist_full[,]
} else {
  datelist <- datelist_full[datelist,]
}

tbl_exists <- pgListTables(conn=ch, schema='awap_grids', pattern =
                             paste(measure_i,"_join_", pwcName,
                                   sep = "")
)
tbl_exists
for(date_i in datelist)
{
  #  date_i <- datelist[1]
  date_i <- as.Date(date_i, origin = '1970-01-01')
  date_i <- as.character(date_i)
    print(date_i)
  
  date_name <- gsub('-','',date_i)
  
  if(which(date_i == datelist) == 1 & nrow(tbl_exists))
  {
    dbSendQuery(ch,
                #  cat(
                paste("drop table awap_grids.",measure_i,"_join_", pwcName,
                      sep = "")
    )
  }
  
  if(which(date_i == datelist) == 1)
  {
    dbSendQuery(ch,
                #  cat(
                paste("SELECT pt.",varID,", cast('",date_i,"' as date) as date,
                      ST_Value(rt.rast, pt.the_geom) as ",measure_i,"
                      into awap_grids.",measure_i,"_join_", pwcName,
                      " FROM awap_grids.",measure_i,"_",date_name," rt,
                      ",pwcName," pt
                      WHERE ST_Intersects(rast, the_geom)
                      ", sep ="")
                )
  } else {
    dbSendQuery(ch,
                #  cat(
                paste("insert into awap_grids.",measure_i,"_join_", pwcName," (",varID,", date, ",measure_i,")",
                      " SELECT pt.",varID,", cast('",date_i,"' as date) as date,
                      ST_Value(rt.rast, pt.the_geom) as ",measure_i,"
                      FROM awap_grids.",measure_i,"_",date_name," rt,
                      ",pwcName," pt
                      WHERE ST_Intersects(rast, the_geom)
                      ", sep ="")
                )
  }
  }

qc <- sql_subset(ewedb, x=paste(measure_i,"_join_", pwcName,sep=""), 
           schema="awap_grids", eval=T)
qc <- arrange(qc,qc$sla_code,qc$date)
#cat(qc)
head(qc)
# qc <- sql_subset_into(ch, x='maxave_join_stations', subset="stnum = 70351",
#                       schema="awap_grids", into_schema = 'awap_grids', into_table = 'maxave_join_stations2', limit=-1, eval=T)
# str(qc)
# qc <- dbGetQuery(ch, "select * from awap_grids.maxave_join_stations2")
# qc <- arrange(qc,by=qc$date)
qc <- subset(qc, sla_code == 805050089)
with(qc, plot(date, maxave, type = 'l'))
source('~/ExcessHeatIndices/src/EHIs_tools.r', echo=TRUE)
qc2 <- EHIs(analyte = qc,
            exposurename = 'maxave',
            datename = 'date',
            referencePeriodStart = as.Date('1980-1-1'),
            referencePeriodEnd = as.Date('2000-12-31'),
            nlags = 32)
head(qc2)
hist(subset(qc2, EHF >= 1)[,'EHF'])
threshold <- quantile(subset(qc2, EHF >= 1)[,'EHF'], probs=0.9)

with(qc, plot(date, maxave, type = 'l'))
with(subset(qc2, EHF > threshold), points(date, maxave, col = 'red', pch = 16))
