
################################################################
# name:pgListTables
pgListTables <- function(conn, schema, pattern = NA)
{
  tables <- dbGetQuery(conn, "select   c.relname, nspname
                       FROM pg_catalog.pg_class c
                       LEFT JOIN pg_catalog.pg_namespace n
                       ON n.oid = c.relnamespace
                       where c.relkind IN ('r','','v') ")
  tables <- tables[grep(schema,tables$nspname),]
  if(!is.na(pattern)) tables <- tables[grep(pattern, tables$relname),]
  tables <- tables[order(tables$relname),]
  return(tables)
}
