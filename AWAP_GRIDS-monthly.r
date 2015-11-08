require(devtools)
install_github("swish-climate-impact-assessment/awaptools")
require(awaptools)
#install_github("swishdbtools", "swish-climate-impact-assessment")
require(swishdbtools)
# local customisations
workdir <- "data"
setwd(workdir)
dir()
startdate <- "2014-01-01"
enddate <- "2015-10-30"
# do
load_monthly(start_date = startdate, end_date = enddate)

# do
filelist <- dir(pattern = "grid.Z$")
for(fname in filelist)
{
  #fname = filelist[1]
  #fname
  unzip_monthly(fname, aggregation_factor = 1)
  fname <- dir(pattern = "grid$")
  r <- readGDAL(fname)
  outfile <- gsub('.grid', '.tif', fname)
  writeGDAL(r, outfile, drivername="GTiff")
  file.remove(fname)
}
setwd("..")
