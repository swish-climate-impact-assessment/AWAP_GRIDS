
################################################################
# name:sqlquery-test
require(ProjectTemplate)
load.project()

require(swishdbtools)
p <- getPassword(remote=T)
ch <- connect2postgres(hostip='115.146.84.135', db='ewedb', user='gislibrary', p=p)
sqlquery_postgres(
    channel = ch,
    append = TRUE,
    force = FALSE,
    print = FALSE,
    dimensions = 'stnum, date',
    variable = 'gv',
    variablename = NA,
    into_schema = 'public',
    into_table = 'awapmaxave_qc2',
    from_schema = 'public',
    from_table = 'awapmaxave_qc',
    operation = NA,
    where = "date = '2013-01-02' and stnum = 70351",
    group_by_dimensions = FALSE,
    having = NA,
    grant = 'public_group'
    )

dbGetQuery(ch, 'select * from awapmaxave_qc2 limit 10')
# for dev work

##     channel = ch
##     dimensions = 'stnum, date'
##     variable = 'gv'
##     variablename = NA
##     into_schema = 'public'
##     into_table = 'awapmaxave_qc2'
##     append = TRUE
##     grant = 'public_group'
##     print = TRUE
##     from_schema = 'public'
##     from_table = 'awapmaxave_qc'
##     operation = NA
##     force = FALSE
##     where = "date = '2007-01-01'"
##     group_by_dimensions = FALSE
##     having = NA
