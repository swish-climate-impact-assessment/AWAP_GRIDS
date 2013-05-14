
################################################################
# name:calculate-for-grid

# based on
# ~/projects/swish-climate-impact-assessment.github.com/tools/ExtractAWAPdata4locations

# this script runs the ExtractAWAPGRIDS functions for sample locations
# depends on swishdbtools package from http:/swish-climate-impact-assessment.github.com
# eg
workingdir <- "~/data/AWAP_GRIDS/data" 
# eg
outputFileName <- "locations.shp"
# eg
outputDataFile <- "calculate-for-grid.csv"
# eg
StartDate <- "2013-01-10" 
# eg
EndDate <- "2013-01-20" 
  
################################################################
# name: Get-test-grid-locations
require(rgdal)
res=0.1
xs=seq(112,155,res)
ys=seq(-45,-9,res)
d=expand.grid(xs,ys)
head(d)
#points(gr1, pch = 16)

epsg <- make_EPSG()
df <- SpatialPointsDataFrame(cbind(d$Var1,d$Var2),d,
                              proj4string=CRS(epsg$prj4[epsg$code %in% '4283']))

setwd(workingdir)
if(file.exists(outputFileName))
{
  for(ext in c(".shp", ".shx", ".dbf", ".prj"))
  {
    file.remove(gsub(".shp",ext,outputFileName))
  }
}
writeOGR(df,outputFileName,gsub(".shp","",outputFileName),"ESRI Shapefile")
tempTableName <- outputFileName

################################################################
# name: send2postgis
require(swishdbtools)
ch <- connect2postgres2("ewedb")
locations <- read_file(file.path(workingdir,tempTableName))
locations <- locations@data
tempTableName <- swish_temptable()
names(locations) <- c("long", "lat")
dbWriteTable(ch, tempTableName$table, locations, row.names = F)
tested <- sql_subset(ch, tempTableName$fullname, eval = T)
#head(tested)
tempTableName <- tempTableName$fullname
tempTableName

# points2geom
sch <- strsplit(tempTableName, "\\.")[[1]][1]
tbl <- strsplit(tempTableName, "\\.")[[1]][2]
sql <- points2geom(
  schema=sch,
  tablename=tbl,
  col_lat= "lat",col_long="long", srid="4283"
)
# cat(sql)
dbSendQuery(ch, sql)
tbl

################################################################
# name: R_raster_extract_by_day
require(swishdbtools)
require(awaptools)
if(!require(reshape))  install.packages("reshape", repos="http://cran.csiro.au/"); require(reshape);
tempTableName_locations <- tbl
startdate <- StartDate
enddate <- EndDate
ch<-connect2postgres2("ewedb")
tempTableName <- swish_temptable("ewedb")
# address doesn't exist
dbSendQuery(ch, sprintf("alter table %s.%s add column address serial",tempTableName$schema, tempTableName_locations))
raster_extract_by_day(ch, startdate, enddate,
                      schemaName = tempTableName$schema,
                      tableName = tempTableName$table,
                      pointsLayer = tempTableName_locations,
                      measures = c("maxave", "minave") 
)
# test_out <- sql_subset(ch, tempTableName$fullname, eval = T)
# test_out_loc <- sql_subset(ch, paste("gislibrary.", tempTableName_locations, sep =""), eval = T)
# head(test_out)
# head(test_out_loc)
# test_out <- merge(test_out_loc, test_out)
# head(test_out)
# points(test_out$long, test_out$lat, col = test_out$value)


# "minave", "totals", "vprph09", "vprph15")
output_data <- reformat_awap_data(
  tableName = tempTableName$fullname
)

outputDataFile <- file.path(workingdir, outputDataFile)
write.csv(output_data,outputDataFile, row.names = FALSE)
outputFileName <- outputDataFile
outputFileName


################################################################
# name: intersect pixels with coast
pgListTables(ch, "boundaries_electorates")
sql_subset(ch, 
           "boundaries_electorates.electorates2009"
           , limit = 1, eval = T)
loc_tab <- paste(sep = "",tempTableName$schema,".",tempTableName_locations)
sql <- sql_subset(ch, 
           loc_tab
           , limit = 1, eval = F)
cat(sql)
dbSendQuery(ch,
           paste("
select long, lat, t1.gid, address, elect_div 
into tempfoobar
from ", loc_tab, " t1,
boundaries_electorates.electorates2009 t2
where st_contains(t2.the_geom, t1.the_geom)
                 ", sep = "")
           )
sql_subset(ch, paste(sep = ".", tempTableName$schema, "tempfoobar"), limit = 1, eval = T)
dbSendQuery(ch,
            paste("
select t1.*, case when t2.elect_div is not null then 1 else 0 end as landmask 
into tempfoobar1
from ", loc_tab, " t1
left join
john_snow.tempfoobar t2
on t1.address = t2.address
", sep = "")
            )
df <- sql_subset(ch, paste(sep = ".", tempTableName$schema, "tempfoobar1"), limit = -1, eval = T)
with(df, plot(long, lat, col = landmask, pch = 16))
head(df)
write.csv(df, "landmask.csv", row.names = F)
################################################################
# name: visualise a pixel
head(output_data)
which(test_out_loc$long == 150 & test_out_loc$lat == -30)
subset(output_data, address == 65031)
with(subset(output_data, address == 65031), plot(date, maxave, type= "l"))

# TODO figure out how to turn these into a raster?
head(test_out_loc)
head(output_data)

################################################################
# name: tidy up
require(swishdbtools)
ch<-connect2postgres2("ewedb")
sch <- swish_temptable("ewedb")
sch <- sch$schema
tbls <- pgListTables(ch, sch, table="foo", match = FALSE)
tbls
for(tab in tbls[,1])
{
  dbSendQuery(ch, 
              sprintf("drop table %s.%s", sch, tab)
  )
}
