
################################################################
# name:test-uncompress
#http://cran.r-project.org/src/contrib/Archive/uncompress/uncompress_1.34.tar.gz
install.packages("C:/Users/Ivan/Downloads/uncompress_1.34.tar.gz", repos = NULL, type = "source")
require(uncompress)
?uncompress


files <- dir(pattern='.grid.Z')
strt=Sys.time()
for (f in files) {
   f <- files[1]
  print(f)
  handle <- file(f, "rb")
  data <- readBin(handle, "raw", 99999999)
  close(handle)
  uncomp_data <- uncompress(data)
  handle <- file(gsub('.Z','',f), "wb")
  writeBin(uncomp_data, handle)
  close(handle)
  
  # clean up
  #file.remove(f)
}

endd=Sys.time()
print(endd-strt)

sink('test.bat')
cat("\"C:\\pgutils\\postgis-pg92-binaries-2.0.2w64\\bin\\raster2pgsql\" -s 4283 -I -C -M *.grid -F awap_grids.maxave_aggby3 > maxave_aggby3.sql")
sink()
system('test.bat')
