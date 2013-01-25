
################################################################
# name:sqlquery_postgres-test2



  
  
    require(ProjectTemplate)
    load.project()
  
    require(swishdbtools)
    ch <- connect2postgres(hostip='115.146.84.135', db='ewedb', user='gislibrary', p='gislibrary')
  
    variable_j <- "maxave"
    date_i <- '2012-01-01'
  #  debug(sqlquery)
    sqlquery(channel = ch,
      dimensions = paste("stnum, cast('",date_i,"' as date) as date",sep=""),
      variable = 'rt.rast, pt.the_geom',
      variablename = 'gv',
      into = 'awapmaxave_qc',
      append = FALSE,
      grant = 'public_group',
      print = FALSE,
      tablename = paste('awap_grids.',variable_j,'_',gsub('-','',date_i),' rt,\n weather_bom.combstats pt',sep=''),
      operation = "ST_Value",
      force = TRUE,
      where = "ST_Intersects(rast, the_geom)",
      group_by_dimensions = FALSE,
      having = NA)
  #  undebug(sqlquery)
  for(date_i in seq(as.Date('2012-01-21'), as.Date('2013-01-20'), 1))
    {
     date_i <- as.Date(date_i, origin = '1970-01-01')
     date_i <- as.character(date_i)
     print(date_i)
  
  #  debug(sqlquery)
    sqlquery(channel = ch,
      dimensions = paste("stnum, cast('",date_i,"' as date) as date",sep=""),
      variable = 'rt.rast, pt.the_geom',
      variablename = 'gv',
      into = 'awapmaxave_qc',
      append = TRUE,
      grant = 'public_group',
      print = FALSE,
      tablename = paste('awap_grids.',variable_j,'_',gsub('-','',date_i),' rt,\n weather_bom.combstats pt',sep=''),
      operation = "ST_Value",
      force = FALSE,
      where = "ST_Intersects(rast, the_geom)",
      group_by_dimensions = FALSE,
      having = NA)
    }
