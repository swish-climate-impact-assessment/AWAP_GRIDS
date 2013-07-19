
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
  
  # bah
  require(swishdbtools)
  p <- getPassword(remote=T)
#dbSendQuery(ch, "drop table awap_grids.maxave_20130101")
r <- readGDAL2('tern5.qern.qcif.edu.au', 'gislibrary', 'ewedb',
               schema = 'awap_grids', table = 'maxave_19881005', p = p
)
image(r)
writeGDAL(r, '~/test1.TIF',drivername="GTiff")
ch <- connect2postgres("tern5.qern.qcif.edu.au","ewedb", user="gislibrary", p)
tbls <- pgListTables(ch, "awap_grids")
nrow(tbls)
nrow(tbls)/71000


  r <- readGDAL(sprintf("PG:host=115.146.84.135 port=5432 dbname='ewedb' user='gislibrary' password='%s' schema='awap_grids' table=maxave_20130108", p))
  
  r2 <- raster(r)
  r3 <- aggregate(r2, fact=2, fun = mean)
  
  writeRaster(r3, 'data/test2.TIF',format="GTiff")
  
                                          #writeGDAL(r3, "PG:host=115.146.84.135 port=5432 dbname='ewedb' user='gislibrary' password='' schema='awap_grids' table=tmax20130108201301082")
# gdalinfo  "PG:host=115.146.84.135 port=5432 dbname='ewedb' user='gislibrary' password='' schema='awap_grids' table=tmax2013010820130108"
