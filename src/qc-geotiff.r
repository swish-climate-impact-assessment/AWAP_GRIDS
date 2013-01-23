
################################################################
# name:test geotiff

  rootdir <- paste(getwd(),'/',variableslist[v,1],sep='')
  #  dir(rootdir)[1]
  cfiles <- dir(rootdir)
  cfiles <- cfiles[grep(as.character(variableslist[v,2]), cfiles)]
  fname <- cfiles[[i]]

  r <- readGDAL(file.path(rootdir,fname))
  outfile <- gsub('.grid', '.TIF', fname)
  writeGDAL(r, file.path(rootdir, outfile), drivername="GTiff")
  r <- readGDAL(file.path(rootdir,outfile))
