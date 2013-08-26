require(awaptools)
require(swishdbtools)
# local customisations
workdir <- "/ResearchData/AWAP_GRIDS_RAIN_MONTHLY"
setwd(workdir)
#outdir <- "data"
#setwd(outdir)
start_date <- "1900-01-01"
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