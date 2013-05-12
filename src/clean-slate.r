
################################################################
# name:clean-slate
require(ProjectTemplate)
load.project()
pwd  <- getPassword(remote = T)
ch <- connect2postgres("tern5.qern.qcif.edu.au", "ewedb", "gislibrary", p = pwd)
grids2remove  <- pgListTables(ch, "awap_grids")
head(grids2remove)
# check
dbGetQuery(ch, sprintf("select * from awap_grids.%s", grids2remove[20,1]))
for(grid_i in grids2remove[-1,1])
  {
#    grid_i <- grids2remove[1,1]    
    print(grid_i)    
    dbSendQuery(ch,
                sprintf("drop table awap_grids.%s; ", grid_i)
                )      
  }
