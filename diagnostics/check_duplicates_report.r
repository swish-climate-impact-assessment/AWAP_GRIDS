sus_dates <- read.table("~/data/AWAP_GRIDS/sus_dates.csv", quote="\"")
sus_dates$date <- paste(substr(gsub(paste(measure_i,"_",sep=""),"",sus_dates[,1]),1,4),
  substr(gsub(paste(measure_i,"_",sep=""),"",sus_dates[,1]),5,6),
  substr(gsub(paste(measure_i,"_",sep=""),"",sus_dates[,1]),7,8),
  sep="-")
sus_dates$date <- as.Date(sus_dates$date)
head(sus_dates)

full_dates <- as.data.frame(c(as.Date('2007-10-23'), seq(as.Date('2009-01-08'), as.Date('2010-04-17'),1)))
names(full_dates) <- 'date'
sus_dates2 <- merge(full_dates, sus_dates, all.x=TRUE)
sus_dates2[which(is.na(sus_dates2$V1)),]
head(sus_dates2)
