
################################################################
# name:pgListTables-test
require(ProjectTemplate)
load.project()

require(swishdbtools)
ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user=
                       'gislibrary', p = 'gislibrary')
tbls <- pgListTables(conn=ch, schema='awap_grids', pattern='maxave')
tbls$date <- paste(substr(gsub("maxave_","",tbls[,1]),1,4),
        substr(gsub("maxave_","",tbls[,1]),5,6),
        substr(gsub("maxave_","",tbls[,1]),7,8),
        sep="-")
tbls$date <- as.Date(tbls$date)
head(tbls)
plot(tbls$date, rep(1,nrow(tbls)), type = 'h')
tbls[tbls$date < as.Date('1999-01-01'),]
tbls[tbls$date >= as.Date('2006-07-01') & tbls$date < as.Date('2007-01-01'),]
tbls[tbls$date >= as.Date('2000-01-01') & tbls$date < as.Date('2004-01-01'),]
