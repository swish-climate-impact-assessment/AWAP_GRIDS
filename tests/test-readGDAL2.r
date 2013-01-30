
################################################################
  # name:test-readGDAL
  require(raster)
  readGDAL2 <- function(hostip=NA,user=NA,db=NA, schema= NA, table=NA, p = NA) {
   if (!require(rgdal)) install.packages('rgdal', repos='http://cran.csiro.au'); require(rgdal)
   if(is.na(p)){
   pwd=readline('enter password (ctrl-L will clear the console after): ')
   } else {
   pwd <- p
   }
   r <- readGDAL(sprintf('PG:host=%s
                           user=%s
                           dbname=%s
                           password=%s
                           table=%s
                           schema=%s
                           port=5432',hostip,user,db,pwd, table, schema)
                          # layer=layer
                 )
   return(r)
  }
  
  r <- readGDAL2('115.146.84.135', 'gislibrary', 'ewedb',
                 schema = 'awap_grids', table = 'tmax2013010820130108'
                 )
  # bah
  r <-
                 readGDAL("PG:host=115.146.84.135 port=5432 dbname='ewedb' user='gislibrary' password='gislibrary' schema='awap_grids' table=maxave_20130108")
  
  r2 <- raster(r)
  r3 <- aggregate(r2, fact=2, fun = mean)
  writeGDAL(r2, 'data/test1.TIF',drivername="GTiff")
  writeRaster(r3, 'data/test2.TIF',format="GTiff")
  
                                          #writeGDAL(r3, "PG:host=115.146.84.135 port=5432 dbname='ewedb' user='gislibrary' password='gislibrary' schema='awap_grids' table=tmax20130108201301082")
# gdalinfo  "PG:host=115.146.84.135 port=5432 dbname='ewedb' user='gislibrary' password='gislibrary' schema='awap_grids' table=tmax2013010820130108"
