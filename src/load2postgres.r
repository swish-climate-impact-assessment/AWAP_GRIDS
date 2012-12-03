
###########################################################################
# newnode: load2postgres
require(delphe)
require(RODBC)
## try on postgres
args(load2postgres)
variablename <- 'minave'
load2postgres(inputfilepath=paste(variablename, '.csv', sep =''),
              schema = 'public', tablename = variablename, pk = 'stnum, date', header = TRUE,
printcopy = TRUE, sheetname = "Sheet1", withoids = FALSE,
pguser = "ivan_hanigan", db = "ewedb", ip = "115.146.84.135",
source_file = "STDIN", datecol = 'date', nrowscsv = 10000,
pgpath = c("psql"))
cat(
  paste('scp ',variablename,'.csv root@115.146.84.135:/home\n
cat sqlquery.txt "',variablename,'.csv" | psql -h 115.146.84.135 -U ivan_hanigan -d ewedb',sep='')
)
