
################################################################
# name:clean
# Project: AWAP_GRIDS
# Author: ivanhanigan
# Maintainer: Who to complain to <ivan.hanigan@gmail.com>
require(ProjectTemplate)
load.project()

ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'gislibrary')
start_at <- '2012-01-01'
end_at <- '2012-01-02'
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
                           paste(measure_i,"_join_stations",
                                 sep = "")
                           )
tbl_exists
for(date_i in datelist)
{
#  date_i <- datelist[2]
  date_i <- as.Date(date_i, origin = '1970-01-01')
  date_i <- as.character(date_i)
  print(date_i)

  date_name <- gsub('-','',date_i)

  if(which(date_i == datelist) == 1 & nrow(tbl_exists))
  {
  dbSendQuery(ch,
  #  cat(
    paste("drop table awap_grids.",measure_i,"_join_stations",
          sep = "")
    )
  }

  if(which(date_i == datelist) == 1)
  {
  dbSendQuery(ch,
  #  cat(
    paste("SELECT pt.stnum, cast('",date_i,"' as date) as date,
      ST_Value(rt.rast, pt.the_geom) as ",measure_i,"
    into awap_grids.",measure_i,"_join_stations
    FROM awap_grids.",measure_i,"_",date_name," rt,
         weather_bom.combstats pt
    WHERE ST_Intersects(rast, the_geom)
    ", sep ="")
    )
  } else {
  dbSendQuery(ch,
  #  cat(
    paste("insert into awap_grids.",measure_i,"_join_stations
    SELECT pt.stnum, cast('",date_i,"' as date) as date,
      ST_Value(rt.rast, pt.the_geom) as ",measure_i,"
    FROM awap_grids.",measure_i,"_",date_name," rt,
         weather_bom.combstats pt
    WHERE ST_Intersects(rast, the_geom)
    ", sep ="")
    )
  }
}

qc <- dbGetQuery(ch,
                 "select *
                 from awap_grids.maxave_join_stations
                 where stnum = 70351
                 order by date
                 ")
qc
