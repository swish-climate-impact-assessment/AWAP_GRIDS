
################################################################
# name:remove_duplicates
require(ProjectTemplate)
load.project()
ch <- connect2postgres2("ewedb")


source("diagnostics/check_duplicates_report.r")
sus_dates2
for(date_i in as.character(sus_dates2$date[-c(1:3)]))
  {
#    date_i <- as.character(sus_dates2$date[1])
    print(date_i)
    date_j <- gsub("-","", date_i)
    for(measure_i in c("vprph09", "vprph15"))
      {
#        measure_i <- "vprph09"
        print(measure_i)
        dbSendQuery(ch,
#        cat(
                    sprintf("drop table awap_grids.%s_%s; ", measure_i, date_j)
                    )
      }

  }


# now run the kepler file
# some were missed?
sus_dates <- pgListTables(ch, "awap_grids", "vprph09")
measure_i <- "vprph09"
sus_dates$date <- paste(substr(gsub(paste(measure_i,"_",sep=""),"",sus_dates[,1]),1,4),
    substr(gsub(paste(measure_i,"_",sep=""),"",sus_dates[,1]),5,6),
    substr(gsub(paste(measure_i,"_",sep=""),"",sus_dates[,1]),7,8),
    sep="-")
  sus_dates$date <- as.Date(sus_dates$date)
  head(sus_dates)


  full_dates <- as.data.frame(c(as.Date('2007-10-23'), seq(as.Date('2009-01-08'), as.Date('2010-04-17'),1)))
  names(full_dates) <- 'date'
  sus_dates2 <- merge(full_dates, sus_dates, all.x=TRUE)
  sus_dates2[which(is.na(sus_dates2$relname)),]
  head(sus_dates2)
  tail(sus_dates2)
  subset(sus_dates2, date == as.Date("2009-02-12"))
  pwd <- getPassword()
  r <- readGDAL2("115.146.84.135", "gislibrary", "ewedb", "awap_grids",
                 "vprph09_20090212", pwd)
  image(r)
  #rm(sus_dates)
