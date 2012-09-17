connect2postgres <- function(hostip,db,user, p=NA, pgutils = 'i:/dropbox/tools/pgutils'){
if(is.na(p)){
pwd=readline("enter password (! it will be shown, use ctrl-L to clear the console after): ")
} else {
pwd <- p
}
if (!require(RJDBC)) install.packages('RJDBC'); require(RJDBC)

# This downloads the JDBC driver to your selected directory if needed
# older postgresql-8.4-701.jdbc4.jar

if (!file.exists(file.path(pgutils,'postgresql-9.1-901.jdbc4.jar'))) {
dir.create(pgutils,recursive =T)
download.file("http://jdbc.postgresql.org/download/postgresql-9.1-901.jdbc4.jar",file.path(pgutils,'postgresql-9.1-901.jdbc4.jar'),mode="wb")
}

# connect
pgsql <- JDBC( "org.postgresql.Driver", file.path(pgutils,"postgresql-9.1-901.jdbc4.jar"))
con <- dbConnect(pgsql, paste("jdbc:postgresql://",hostip,"/",db,sep=""), user = user, password = pwd)
rm(pwd)
return(con)
}
