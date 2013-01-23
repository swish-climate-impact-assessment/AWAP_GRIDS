require(ProjectTemplate)
load.project()

# All the potentially messy data cleanup
ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user= 'ivan_hanigan')
rpgsqlList(conn, schema, pattern){
  
#   dbSendQuery(ch, 'SET search_path =awap_grids, pg_catalog')
#  
#   # dbSendQuery(ch,'SET search_path =abs_census06, pg_catalog;')
#   tbls <- dbListTables(ch)
# head(tbls)
# tbls <- dbGetQuery(ch, 'SELECT n.nspname as \"Schema\",
# c.relname as \"Name\",
#                   CASE c.relkind WHEN \'r\' THEN \'table\' WHEN \'v\' THEN \'view\' WHEN \'i\' THEN
#                   \'index\' WHEN \'S\' THEN \'sequence\' WHEN \'s\' THEN \'special\' END as \"Type\",
#                   u.usename as \"Owner\"
#                   FROM pg_catalog.pg_class c
#                   LEFT JOIN pg_catalog.pg_user u ON u.usesysid = c.relowner
#                   LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
#                   WHERE n.nspname NOT IN (\'pg_catalog\', \'pg_toast\')
#                   AND pg_catalog.pg_table_is_visible(c.oid)
#                   ORDER BY 1,2;') 
#   head(tbls)
#   #c.relname 
tables <- dbGetQuery(ch, 'select   c.relname, nspname
                       FROM pg_catalog.pg_class c
                       LEFT JOIN pg_catalog.pg_namespace n 
                       ON n.oid = c.relnamespace
                       where c.relkind IN (\'r\',\'\') ')
  #                     WHERE c.relkind IN (\'r\',\'\') AND n.nspname NOT IN (\'pg_catalog\', \'pg_toast\')
  #                     AND pg_catalog.pg_table_is_visible(c.oid);')
  #tables <- as.character(tables[[1]])
  str(tables)
  tables <- tables[grep('awap_grids',tables$nspname),]
  tables <- tables[order(tables$relname),]
  head(tables)
  tail(tables)  
#dbSendQuery(ch, 'SET search_path =public, pg_catalog')
  
}