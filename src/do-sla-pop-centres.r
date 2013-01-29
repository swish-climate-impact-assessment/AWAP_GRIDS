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

              dbGetQuery(ewedb,
              # cat(
              paste('delete from public.',pwcName,'
              where ',varID,' is null',sep='')
              )