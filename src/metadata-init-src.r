
################################################################
# name:metadata-init-src

#   delphe <- connectDelphe('130.56.102.41','ivan_hanigan','delphe')

if(!require(RJDBC)) install.packages('RJDBC'); require(RJDBC)
drv <- JDBC("oracle.jdbc.driver.OracleDriver",
            '/u01/app/oracle/product/11.2.0/xe/jdbc/lib/ojdbc6.jar')
ch <- dbConnect(drv,"jdbc:oracle:thin:@130.56.102.54:1521","DDIINDEXDB","trojan9!")

idno <- 'AWAP_GRIDS'
if(!exists('s')){
s <- dbGetQuery(oracle, paste("select * from stdydscr where idno = '",idno,"'", sep = ''))
idno <- s$IDNO
}
t(s)
# newnode get tools
# rm(oracle)
if(!exists('oracle')) {source(dir('run',pattern = 'tools', full.names=T))}
