
################################################################
# name:pgListTables-test
require(ProjectTemplate)
load.project()

require(swishdbtools)
p <- getPassword(remote=T)
ch <- connect2postgres(h = 'brawn.anu.edu.au', db = 'ewedb', user=
                       'gislibrary', p=p)

measure_i <- 'totals'

tbls <- pgListTables(conn=ch, schema='awap_grids', table=measure_i, match=F)
tbls$date <- paste(substr(gsub(paste(measure_i,"_",sep=""),"",tbls[,1]),1,4),
        substr(gsub(paste(measure_i,"_",sep=""),"",tbls[,1]),5,6),
        substr(gsub(paste(measure_i,"_",sep=""),"",tbls[,1]),7,8),
        sep="-")
tbls$date <- as.Date(tbls$date)
head(tbls)
tbls <- tbls[tbls$date > as.Date('1912-01-01'),]
plot(tbls$date, rep(1,nrow(tbls)), type = 'h')
tbls[tbls$date < as.Date('1999-01-01'),]
tbls[tbls$date >= as.Date('2006-07-01') & tbls$date < as.Date('2007-01-01'),]
tbls[tbls$date >= as.Date('2004-01-01') & tbls$date < as.Date('2005-01-01'),]
