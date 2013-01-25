
################################################################
  # name:load
  ################################################################
  # name:load
  # Project: AWAP_GRIDS
  # Author: ivanhanigan
  # Maintainer: Who to complain to <ivan.hanigan@gmail.com>

  # This file loads all the libraries and data files needed
  # Don't do any cleanup here

  ### Load any needed libraries
  #load(LibraryName)
  setwd(workdir)
  require(ProjectTemplate)
  load.project()
  ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb',
                         user = 'gislibrary',
                         p='gislibrary')
  print(paste('root directory:', workdir))
  setwd('data')

  start_at <- scope[[1]][1]
  print(start_at)
  end_at <- scope[[2]][1]
  print(end_at)

  vars <- scope[[3]]
  #  print(vars)
  #}
  #  started <- Sys.time()
  datelist_full <- as.data.frame(seq(as.Date(start_at),
    as.Date(end_at), 1))
  names(datelist_full) <- 'date'
  for(i in 1:length(vars[[1]])){
  #    i = 1
    measure_i <- vars[[1]][i]
    variable <- variableslist[which(variableslist$measure == measure_i),]
    vname <- as.character(variable[,1])

   tbls <- pgListTables(conn=ch, schema='awap_grids', pattern = measure_i)
#     pattern=paste(measure_i,"_", gsub("-","",sdate), sep=""))
   tbls$date <- paste(substr(gsub("maxave_","",tbls[,1]),1,4),
           substr(gsub("maxave_","",tbls[,1]),5,6),
           substr(gsub("maxave_","",tbls[,1]),7,8),
           sep="-")
   tbls$date <- as.Date(tbls$date)
   datelist <-  which(datelist_full$date %in% tbls$date)
   datelist <- datelist_full[-datelist,]

    for(date_i in datelist){
    {
      date_i <- as.Date(date_i, origin = '1970-01-01')
      date_i <- as.character(date_i)
    #  print(date_i)

      sdate <- date_i
      edate <- date_i

      get_data_range(variable=as.character(variable[,1]),
                     measure=as.character(variable[,2]),
                     timestep=as.character(variable[,3]),
                     startdate=as.POSIXct(sdate),
                     enddate=as.POSIXct(edate))

      fname <- sprintf("%s_%s%s.grid.Z",measure_i,gsub("-","",sdate),gsub("-","",edate))

      if(file.info(fname)$size == 0)
        {
          file.remove(fname)
          next
        }

      if(os == 'linux')
        {
          uncompress_linux(filename = fname)
        } else {
          Decompress7Zip(zipFileName= fname, outputDirectory=getwd(), TRUE)
        }

      raster_aggregate(filename = gsub('.Z$','',fname),
        aggregationfactor = aggregation_factor, delete = TRUE)

      load2postgres_raster(filename = gsub(".grid.Z", ".tif", fname))

    }

  }

  setwd(workdir)
