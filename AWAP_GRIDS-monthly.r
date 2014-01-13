require(awaptools)
require(swishdbtools)
# local customisations
workdir <- "data"
setwd(workdir)

startdate <- "2013-11-01"
enddate <- "2013-12-31"
# do
load_monthly(start_date = startdate, end_date = enddate)

# do
filelist <- dir(pattern = "grid.Z$")
for(fname in filelist)
{
  unzip_monthly(fname, aggregation_factor = 1)
}
setwd("..")