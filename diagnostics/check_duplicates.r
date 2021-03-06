
################################################################
# name:check-duplicates
# in 23oct2007, and from 08jan2009 to  17apr2010, vprph09 and vprph15
# are the same.
require(ProjectTemplate)
load.project()
require(devtools)
install_github("awaptools", "swish-climate-impact-assessment")
ch <- connect2postgres2("ewedb")
pwd <- get_passwordTable()
pwd <- pwd[which(pwd$V3 == 'ewedb'),5]
datesList <- seq(as.Date("2010-01-02"), as.Date("2010-01-05"), 1)
date_j <- datesList[1]
print(date_j)

r <- readGDAL2("115.146.84.135", "gislibrary", "ewedb", "awap_grids",
               "maxave_20130305", pwd)
image(r)
#rm(sus_dates)
system.time(
sus_dates <- check_duplicates(ch, dates = datesList, measures = c("vprph09", "vprph15"), measure_name = "vprph")
  )

system.time(
sus_dates <- check_duplicates(ch, dates = datesList, measures = c("maxave", "minave"), measure_name = "temp")
  )
#unlist(sus_dates)
