
# this script downloads monthly rainfall totals and converts to geotifs
require(devtools)
install_github("swish-climate-impact-assessment/awaptools", ref = "develop")
require(awaptools)
require(rgdal)
workdir <- "data"
setwd(workdir)
startdate <- "2014-01-01"
enddate <- "2014-03-28"
load_monthly(start_date = startdate, end_date = enddate)
filelist <- dir(pattern = "grid.Z$")
for(fname in filelist){unzip_monthly(fname, aggregation_factor = 1)}
compress_gtifs(indir = getwd())
system("rm *.grid")
system("mv GTif/* ./")
setwd("..")
