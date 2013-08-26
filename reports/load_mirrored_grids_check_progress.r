require(swishdbtools)
p <- getPassword(remote=T)
ch <- connect2postgres("brawn.anu.edu.au","ewedb", user="gislibrary", p)
for(i in 1:10){
  tbls <- pgListTables(ch, "awap_grids")
  print(nrow(tbls))
  print(nrow(tbls)/76977)
  Sys.sleep(time=5*60)
}