
################################################################
# name:check-duplicates
# in 23oct2007, and from 08jan2009 to  17apr2010, vprph09 and vprph15
# are the same.
require(ProjectTemplate)
load.project()
ch <- connect2postgres2("ewedb")
pwd <- get_passwordTable()
pwd <- pwd[which(pwd$V3 == 'ewedb'),5]
datesList <- seq(as.Date("2007-10-01"), as.Date("2007-10-31"), 1)
date_j <- datesList[1]
print(date_i)


system.time(
sus_dates <- check_duplicates(ch, dates = datesList)
  )
