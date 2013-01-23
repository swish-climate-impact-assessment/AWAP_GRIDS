
################################################################
  # name:load
  # Project: AWAP_GRIDS
  # Author: ivanhanigan
  # Maintainer: Who to complain to <ivan.hanigan@gmail.com>

  # This file loads all the libraries and data files needed
  # Don't do any cleanup here

  ### Load any needed libraries
  #load(LibraryName)
  require(ProjectTemplate)
  load.project()
  sdate <- scope[[1]][1]
  print(sdate)
  edate <- scope[[2]][1]
  print(edate)
  year <- as.numeric(substr(sdate, 1,4))
  ## year2 <- year + 4
  ## year2
  ## if(as.numeric(substr(edate, 1,4)) > year2){
  ##   print('please only specify dates in 5 year chunks, 00-04 or 05-09')
  ##   stopTrigger <- TRUE
  ## } else {
  ##   stopTrigger <- FALSE
  ## }
  vars <- scope[[3]]
  print(vars)

  ### Load in any data files
    #
  #if(stopTrigger == FALSE){
  # deprecated  try(dir.create('RawData'))
    setwd('data')
    rootdir <- getwd()
  #  started <- Sys.time()
    for(i in 1:length(vars[[1]])){
#     i <- 1
  #  variable <- variableslist[which(variableslist$measure == vars[[1]][i]),]
    variable <- variableslist[which(variableslist$measure == vars[[1]][i]),]
    vname <- as.character(variable[,1])
    #try(dir.create(vname))
    #setwd(vname)
    # TODO recognise if day not available to download
    get_data_range(variable=as.character(variable[,1]),measure =as.character(variable[,2]),timestep=as.character(variable[,3]),
                    startdate=as.POSIXct(sdate),
                    enddate=as.POSIXct(edate))

    files <- dir(pattern='.grid.Z')
    if(os == 'linux'){
    for (f in files) {
      # f <- files[1]
      print(f)
      system(sprintf('uncompress %s',f))
    }
    } else {
     for (f in files) {
     if(!require(uncompress)) "find the old uncompress package off cran";
     require(uncompress)
     #f <- files[1]
     print(f)
     handle <- file(f, "rb")
     data <- readBin(handle, "raw", 99999999)
     close(handle)
     uncomp_data <- uncompress(data)
     handle <- file(gsub('.Z','',f), "wb")
     writeBin(uncomp_data, handle)
     close(handle)
     # clean up
     file.remove(f)
     }
    }
    files <- dir(pattern=".grid")
    for(fname in files){
      # fname <- files[1]
      r <- raster(fname)
  #    writeGDAL(r, gsub('.grid','test1.TIF',fname), drivername="GTiff")
      #r <- raster(r)
      r <- aggregate(r, fact = aggregation_factor, fun = mean)
      writeRaster(r, gsub('.grid','.TIF',fname), format="GTiff",
    overwrite = TRUE)
      file.remove(fname)
    }
    files <- dir(pattern=".tif")
    for(fname in files){
#    fname <- files[1]
      outname <- gsub('.tif',paste("_aggby",aggregation_factor, sep=""), fname)
      if(os == 'linux'){

       system(
#         cat(
           paste("raster2pgsql -s 4283 -I -C -M ",fname," -F awap_grids.",outname," > ",outname,".sql", sep="")
           )
       system(
         #cat(
         paste("psql -h 115.146.84.135 -U gislibrary -d ewedb -f ",outname,".sql",
               sep = ""))
     } else {
       sink('raster2sql.bat')
       cat(paste(pgisutils,"raster2pgsql\" -s 4283 -I -C -M ",fname," -F awap_grids.",outname," > ",outname,".sql\n",sep=""))

       cat(
       paste(pgutils,"psql\" -h 115.146.84.135 -U gislibrary -d ewedb -f ",outname,".sql", sep = ""))
       sink()
       system('raster2sql.bat')
       file.remove('raster2sql.bat')
     }
    }
    files <- dir()
    # cleanup
    for(fname in files){        
      file.remove(fname)
    }
    #setwd('..')
    }

    setwd('..')
