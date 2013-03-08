
################################################################
  # name:check-duplicates
  # in 23oct2007, and from 08jan2009 to  17apr2010, vprph09 and vprph15
  # are the same.
  require(ProjectTemplate)
  load.project()
  ch <- connect2postgres2("ewedb")
  pwd <- get_passwordTable()
  pwd <- pwd[which(pwd$V3 == 'ewedb'),5]
  datesList <- seq(as.Date("2010-01-01"), as.Date("2010-05-01"), 1)
  date_j <- datesList[1]
  print(date_j)
  
  r <- readGDAL2("115.146.84.135", "gislibrary", "ewedb", "awap_grids",
                 "maxave_20130305", pwd)
  image(r)
  rm(sus_dates)
  system.time(
  sus_dates <- check_duplicates(ch, dates = datesList)
    )
  unlist(sus_dates)
  
  # or on db
  measures = c("vprph09","vprph15")
  #measures <- c("maxave","minave", "solarave","totals",
  #suspicious_dates <- list()
  
  dbSendQuery(ch, "drop table sus_dates")
  system.time(
  for(j in 1:length(datesList))
      {
  #      j = 1
        #date_j <- dates[2]
        date_j <- datesList[j]
        date_i <- gsub("-","",date_j)
        print(date_i)
  #      rasters <- list()
  
  ## for(i in 1:length(measures))
  ##       {
          i = 1
          measure <- measures[i]
          print(measure)
          rastername <- paste(measure, "_", date_i, sep ="")
          tableExists <- pgListTables(ch, schema="awap_grids", pattern=rastername)
          if(nrow(tableExists) > 0)
          {
          i = 2
          measure <- measures[i]
          print(measure)
          rastername2 <- paste(measure, "_", date_i, sep ="")
  if(date_j == datesList[1])
    {
  dbSendQuery(ch,
  #          cat(
            paste("
            select cast('",as.character(date_j),"' as date) as
  sus_dates, (foo.rastval2).min, (foo.rastval2).max,
  (foo.rastval2).mean
            into sus_dates
            from
            (
            select t1.*, t2.*, st_summarystats(ST_MapAlgebraExpr(t1.rast, t2.rast,'[rast1.val] / [rast2.val]', '2BUI')) as rastval2
            from awap_grids.",rastername," t1,
            awap_grids.",rastername2," t2
            where st_intersects(t1.rast, t2.rast)
            ) foo
            ", sep = "")
            )
  } else {
  dbSendQuery(ch,
  #          cat(
            paste("insert into sus_dates (sus_dates, min, max, mean)
            select cast('",as.character(date_j),"' as date) as
  sus_dates, (foo.rastval2).min, (foo.rastval2).max,
  (foo.rastval2).mean
  
            from
            (
            select t1.*, t2.*, st_summarystats(ST_MapAlgebraExpr(t1.rast, t2.rast,'[rast1.val] / [rast2.val]', '2BUI')) as rastval2
            from awap_grids.",rastername," t1,
            awap_grids.",rastername2," t2
            where st_intersects(t1.rast, t2.rast)
            ) foo
            ", sep = "")
            )
  }
  }
  }
  )
  sus_dates2 <- sql_subset(ch, 'sus_dates', subset = "mean = 1", eval = T)
  unlist(sus_dates)
  sus_dates2
  dir()
  
  
  ## sql <- sql_subset(ch, paste("awap_grids.",rastername,sep=""), limit = 1, eval = F, check = F)
  ## cat(sql)
  ## compare <- dbGetQuery(ch,
  ## #          cat(
  ##           paste("
  ##           select cast('",as.character(date_j),"' as date) as sus_dates, (foo.rastval2).min, (foo.rastval2).max,  (foo.rastval2).mean
  ##           from
  ##           (
  ##           select t1.*, t2.*, st_summarystats(ST_MapAlgebraExpr(t1.rast, t2.rast,'[rast1.val] / [rast2.val]', '2BUI')) as rastval2
  ##           from awap_grids.",rastername," t1,
  ##           awap_grids.",rastername2," t2
  ##           where st_intersects(t1.rast, t2.rast)
  ##           ) foo
  ##           ", sep = "")
  ##           )
  ## compare
  ## "
  ## select t1.*, t2.*
  ## from awap_grids.vprph09_20100401 t1,
  ## awap_grids.vprph09_20100401 t2
  ## where st_intersects(t1.rast, t2.rast)
  ## ")
  ## dbSendQuery(ch,
  ## #          cat(
  ##           paste("
  ##           select cast('",as.character(date_j),"' as date) as sus_dates, (foo.rastval2).min, (foo.rastval2).max,  (foo.rastval2).mean
  ##           from
  ##           (
  ##           select t1.*, t2.*, st_summarystats(ST_MapAlgebraExpr(t1.rast, t2.rast,'[rast1.val] / [rast2.val]', '2BUI')) as rastval2
  ##           from awap_grids.",rastername," t1,
  ##           awap_grids.",rastername2," t2
  ##           where st_intersects(t1.rast, t2.rast)
  ##           ) foo
  ##           ", sep = "")
  ##           )
  


*** clean-check against stations
#+name:clean
#+begin_src R :session *R* :tangle src/clean.r :exports none :eval no
  ################################################################
  # name:clean
  # Project: AWAP_GRIDS
  # Author: ivanhanigan
  # Maintainer: Who to complain to <ivan.hanigan@gmail.com>
  require(ProjectTemplate)
  load.project()
  
  ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'gislibrary')
  start_at <- '2012-01-01'
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
                             paste(measure_i,"_join_stations",
                                   sep = "")
                             )
  tbl_exists
  for(date_i in datelist)
  {
  #  date_i <- datelist[2]
    date_i <- as.Date(date_i, origin = '1970-01-01')
    date_i <- as.character(date_i)
  #  print(date_i)
  
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
  sql_subset(ch, x='maxave_join_stations', subset="stnum = 70351",
                schema="awap_grids", limit=10, eval=F)
  qc <- sql_subset_into(ch, x='maxave_join_stations', subset="stnum = 70351",
    schema="awap_grids", into_schema = 'awap_grids', into_table = 'maxave_join_stations2', limit=-1, eval=T)
  str(qc)
  qc <- dbGetQuery(ch, "select * from awap_grids.maxave_join_stations2")
  qc <- arrange(qc,by=qc$date)
  with(qc, plot(date, maxave, type = 'l'))
  tail(qc)
  
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
