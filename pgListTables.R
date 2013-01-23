pgListTables <- function(conn, schema, pattern = NA)
{
  tables <- dbGetQuery(conn, 'select   c.relname, nspname
                       FROM pg_catalog.pg_class c
                       LEFT JOIN pg_catalog.pg_namespace n 
                       ON n.oid = c.relnamespace
                       where c.relkind IN (\'r\',\'\') ')
  tables <- tables[grep(schema,tables$nspname),]
  if(!is.na(pattern)) tables <- tables[grep(pattern, tables$relname),]
  tables <- tables[order(tables$relname),]
  return(tables)
}
require(swishdbtools)
ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'ivan_hanigan')
pgListTables(conn=ch, schema='awap_grids', pattern='20120101')