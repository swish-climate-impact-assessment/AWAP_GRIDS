require(devtools)
install_github("awaptools", "swish-climate-impact-assessment")
require(awaptools)
install_github("swishdbtools", "swish-climate-impact-assessment")
require(swishdbtools)
# local customisations
workdir <- "data"
setwd(workdir)

startdate <- "2000-01-01"
enddate <- "2012-12-31"
# do
load_monthly(start_date = startdate, end_date = enddate)

# do
filelist <- dir(pattern = "grid.Z$")
for(fname in filelist)
{
  unzip_monthly(fname, aggregation_factor = 1)
}
setwd("..")
