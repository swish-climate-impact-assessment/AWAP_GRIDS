
################################################################
# name:pgListTables-test
require(ProjectTemplate)
load.project()

require(swishdbtools)
ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'ivan_hanigan')
tbls <- pgListTables(conn=ch, schema='awap_grids', pattern='maxave')
tbls$date <- paste(substr(gsub("maxave_","",tbls[,1]),1,4),
        substr(gsub("maxave_","",tbls[,1]),5,6),
        substr(gsub("maxave_","",tbls[,1]),7,8),
        sep="-")
head(tbls)
