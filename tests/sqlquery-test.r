
################################################################
# name:sqlquery-test
require(ProjectTemplate)
load.project()

require(swishdbtools)
ch <- connect2postgres(hostip='115.146.84.135', db='ewedb', user='gislibrary', p='gislibrary')
sqlquery_postgres(
    channel = ch,
    dimensions = 'stnum, date',
    variable = 'gv',
    variablename = NA,
    into_schema = 'public',
    into_table = 'awapmaxave_qc2',
    append = TRUE,
    grant = 'public_group',
    print = TRUE,
    from_schema = 'public',
    from_table = 'awapmaxave_qc',
    operation = NA,
    force = FALSE,
    where = "date = '2007-01-01'",
    group_by_dimensions = FALSE,
    having = NA)

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
