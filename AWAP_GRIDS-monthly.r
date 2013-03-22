require(awaptools)
require(swishdbtools)
# local customisations
workdir <- getwd()
outdir <- "data"
setwd(outdir)
start_date <- "2012-12-01"
start_date <- as.POSIXlt(start_date)
# do
load_monthly(startdate = start_date)

# do
filelist <- dir(pattern = "grid.Z$")
for(fname in filelist)
{
  unzip_monthly(fname, aggregation_factor = 1)
}
setwd(workdir)