
################################################################
# name:check-duplicates
# in 23oct2007, and from 08jan2009 to  17apr2010, vprph09 and vprph15
# are the same.
require(ProjectTemplate)
load.project()
ch <- connect2postgres2("ewedb")
pwd <- get_passwordTable()
pwd <- pwd[which(pwd$V3 == 'ewedb'),5]
datesList <- seq(as.Date("1980-01-01"), as.Date("2013-03-05"), 1)
date_j <- datesList[1]
print(date_j)

r <- readGDAL2("115.146.84.135", "gislibrary", "ewedb", "awap_grids",
               "vprph09_20130124", pwd)
image(r)
rm(sus_dates)
system.time(
sus_dates <- check_duplicates(ch, dates = datesList, measures = c("maxave","minave"))
  )
#unlist(sus_dates)
sus_dates <- read.table("~/data/AWAP_GRIDS/sus_dates_vprph.csv", quote="\"")
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

# # NOT RUN or on db
# measures = c("vprph09","vprph15")
# #measures <- c("maxave","minave", "solarave","totals",
# #suspicious_dates <- list()
# 
# dbSendQuery(ch, "drop table sus_dates")
# system.time(
# for(j in 1:length(datesList))
#     {
# #      j = 1
#       #date_j <- dates[2]
#       date_j <- datesList[j]
#       date_i <- gsub("-","",date_j)
#       print(date_i)
# #      rasters <- list()
# 
# ## for(i in 1:length(measures))
# ##       {
#         i = 1
#         measure <- measures[i]
#         print(measure)
#         rastername <- paste(measure, "_", date_i, sep ="")
#         tableExists <- pgListTables(ch, schema="awap_grids", pattern=rastername)
#         if(nrow(tableExists) > 0)
#         {
#         i = 2
#         measure <- measures[i]
#         print(measure)
#         rastername2 <- paste(measure, "_", date_i, sep ="")
# if(date_j == datesList[1])
#   {
# dbSendQuery(ch,
# #          cat(
#           paste("
#           select cast('",as.character(date_j),"' as date) as
# sus_dates, (foo.rastval2).min, (foo.rastval2).max,
# (foo.rastval2).mean
#           into sus_dates
#           from
#           (
#           select t1.*, t2.*, st_summarystats(ST_MapAlgebraExpr(t1.rast, t2.rast,'[rast1.val] / [rast2.val]', '2BUI')) as rastval2
#           from awap_grids.",rastername," t1,
#           awap_grids.",rastername2," t2
#           where st_intersects(t1.rast, t2.rast)
#           ) foo
#           ", sep = "")
#           )
# } else {
# dbSendQuery(ch,
# #          cat(
#           paste("insert into sus_dates (sus_dates, min, max, mean)
#           select cast('",as.character(date_j),"' as date) as
# sus_dates, (foo.rastval2).min, (foo.rastval2).max,
# (foo.rastval2).mean
# 
#           from
#           (
#           select t1.*, t2.*, st_summarystats(ST_MapAlgebraExpr(t1.rast, t2.rast,'[rast1.val] / [rast2.val]', '2BUI')) as rastval2
#           from awap_grids.",rastername," t1,
#           awap_grids.",rastername2," t2
#           where st_intersects(t1.rast, t2.rast)
#           ) foo
#           ", sep = "")
#           )
# }
# }
# }
# )
# sus_dates2 <- sql_subset(ch, 'sus_dates', subset = "mean = 1", eval = T)
# unlist(sus_dates)
# sus_dates2
# dir()
