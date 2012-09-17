# tools for loading data to postgres
# Joseph Guillame and Ivan Hanigan 
# original by Joe 24/3/2009

# modifications
# 5/1/2010
# ihanigan
# generalise a bit more, add optional primary key, improve handling of dates 

# TO DO:
## set the vacuum automatically when printcopy=F 

# load_newtable_to_postgres = Convert to csv and load to postgres
# pk as either column names as they appear at the end or column indices

# inspired from 
#odbc_dsn="pg"
#require(RODBC)
#con<-odbcConnect(odbc_dsn,"postgres","test",case="postgresql")
#sqlSave(con,data[0,],test=TRUE,verbose=TRUE)
#close(con)

# source file could be
#source_file=paste("E'", csvfilename,"'",sep="")
	
if (!require(RODBC)) install.packages('RODBC')	
require(RODBC) # for getSqlTypeInfo
# if (!file.exists('C:/pgutils/psql.exe')) {
# dir.create('c:/pgutils') 
# download.file("http://alliance.anu.edu.au/access/content/group/4e0f55f1-b540-456a-000a-24730b59fccb/pgutils.zip","c:/pgutils/pgutils.zip",mode="wb")
# unzip("c:/pgutils/pgutils.zip",exdir="C:/pgutils")
# }
# not working
print('please download http://alliance.anu.edu.au/access/content/group/4e0f55f1-b540-456a-000a-24730b59fccb/pgutils.zip')

load2postgres<-function(inputfilepath,schema,tablename,pk=NULL,header=TRUE,printcopy=TRUE,sheetname="Sheet1",withoids=FALSE,pguser="username",db='databasename',ip='ipaddress',source_file="STDIN",datecol=NULL,nrowscsv=10000,pgpath=c('c:\\pgutils\\psql')){

	table=paste(schema,".",tablename,sep="")

	ext<-substr(inputfilepath,nchar(inputfilepath)-2,nchar(inputfilepath))
	#print(ext)

	if (ext=="dbf"){
		require(foreign)
		data<-read.dbf(inputfilepath,as.is=TRUE)
		csvfilename=sub(".dbf",".csv",basename(inputfilepath))
		csvfilename=paste(getwd(),csvfilename,sep="/")
		write.csv(data,csvfilename,row.names=FALSE,na="")
	}
	else if (ext=="csv" || ext=="txt"){
		#or from csv originally
		csvfilename<-inputfilepath
		data<-read.csv(csvfilename,stringsAsFactors=FALSE,header=header,strip.white=TRUE,nrows=nrowscsv)
		names(data)<-gsub("\\.","_",names(data))
		names(data)<-gsub("_+","_",names(data))
	}
	else if (ext=="xls"){
		odbcf<-odbcConnectExcel(inputfilepath)
		data<-sqlFetch(odbcf,sheetname,as.is=TRUE)
		csvfilename=sub(".xls",".csv",basename(inputfilepath))
		csvfilename=paste(getwd(),csvfilename,sep="/")
		write.csv(data,csvfilename,row.names=FALSE,na="")
	}
	else print("Unknown extension")

	names(data)<-tolower(names(data))

	if (length(pk)>0) {
		if (class(pk) %in% c("integer","numeric")) pk=paste(names(data)[pk],collapse=",")
		}
	
	datatypes<-getSqlTypeInfo("PostgreSQL")
	datatypes["numeric"]<-"numeric"

	csvfilename=gsub("\\\\","\\\\\\\\",csvfilename)

	text=""
	text=paste(text,"CREATE TABLE ",table," (",sep="")
	columnnames<-names(data)

#################################################################################

	if (length(pk)>0) { 
		for (n in columnnames) {
		if (length(grep(n, datecol))>0) {
			text=paste(text,"\"",n,"\" date,\n",sep="")
			} else {
			#print(class(data[[n]]))
			if (is.null(class(data[[n]]))) cat("Missing datatype:",class(data[[n]]),"\n")
			text=paste(text,"\"",n,"\" ",datatypes[[class(data[[n]])]],",\n",sep="")
			}
		}
	text=paste(text,"CONSTRAINT \"",table,"_pkey\" PRIMARY KEY (",pk,")\n",sep="")
	}	
	
	if (length(pk)==0) { 
		for (n in columnnames[1:(length(columnnames)-1)]) {
			if (length(grep(n, datecol))>0) {
			text=paste(text,"\"",n,"\" date,\n",sep="")
			} else {
			#print(class(data[[n]]))
			if (is.null(class(data[[n]]))) cat("Missing datatype:",class(data[[n]]),"\n")
			text=paste(text,"\"",n,"\" ",datatypes[[class(data[[n]])]],",\n",sep="")
			}
		}
		
		n=columnnames[length(columnnames)]
		text=paste(text,"\"",n,"\" ",datatypes[[class(data[[n]])]],sep="")
		#\"
	}

###############################################################################
	if (withoids) text=paste(text,") WITH (OIDS=TRUE);\n",sep="")
	else text=paste(text,") WITH (OIDS=FALSE);\n",sep="")
	text=paste(text,"ALTER TABLE ",table," OWNER TO ",pguser,";\n",sep="")
	
	

	
	if (source_file=="STDIN") {
	if (header) text=paste(text,"COPY ",table," FROM ",source_file," CSV HEADER;\n",sep="")
	else text=paste(text,"COPY ",table," FROM ",source_file," CSV;\n",sep="")
	
	sink("sqlquery.txt")
	cat(text)
	sink()

	
			
	if (printcopy){
			
		cat(paste('ok the CREATE TABLE and COPY statements have been constructed for this file and is in "sqlquery.txt", have a look and see if it is correct\nif it is ok and you have not set your password to be remembered in pgAdmin then paste this into a cmd prompt\n\n type sqlquery.txt \"',csvfilename,'\" | \"',pgpath,'\" -h ',ip,' -U ',pguser,' -d ',db,'\n\n\notherwise you can run this directly from R\n\n system(\"type sqlquery.txt \\"',csvfilename,'\\" | \"',pgpath,'\" -h ',ip,' -U ',pguser,' -d ',db,'\")',sep=''),'\n')

cat(paste("\n\nnow you probably should vaccuum the table\nVACUUM ANALYZE ",table,";\n",sep=""))			
	} else {
sink('go.bat')
cat(paste('type sqlquery.txt \"',csvfilename,'\" | \"',pgpath,'\" -h ',ip,' -U ',pguser,' -d ',db,'',sep=''))
sink()
shell('go.bat')
file.remove('go.bat')
}	
	

}
	
}



## joes orig (slightly moded by ivan)
load_newtable_to_postgres<-function(inputfilepath,schema,tablename,pk=NULL,header=TRUE,printcopy=TRUE,sheetname="Sheet1",withoids=FALSE,pguser="username",db='databasename',ip='ipaddress',source_file="STDIN",datecol=NULL){

	table=paste(schema,".",tablename,sep="")

	ext<-substr(inputfilepath,nchar(inputfilepath)-2,nchar(inputfilepath))
	#print(ext)

	if (ext=="dbf"){
		require(foreign)
		data<-read.dbf(inputfilepath,as.is=TRUE)
		csvfilename=sub(".dbf",".csv",basename(inputfilepath))
		csvfilename=paste(getwd(),csvfilename,sep="/")
		write.csv(data,csvfilename,row.names=FALSE,na="")
	}
	else if (ext=="csv" || ext=="txt"){
		#or from csv originally
		csvfilename<-inputfilepath
		data<-read.csv(csvfilename,stringsAsFactors=FALSE,header=header,strip.white=TRUE,)
		names(data)<-gsub("\\.","_",names(data))
		names(data)<-gsub("_+","_",names(data))
	}
	else if (ext=="xls"){
		odbcf<-odbcConnectExcel(inputfilepath)
		data<-sqlFetch(odbcf,sheetname,as.is=TRUE)
		csvfilename=sub(".xls",".csv",basename(inputfilepath))
		csvfilename=paste(getwd(),csvfilename,sep="/")
		write.csv(data,csvfilename,row.names=FALSE,na="")
	}
	else print("Unknown extension")

	names(data)<-tolower(names(data))

	if (length(pk)>0) {
		if (class(pk) %in% c("integer","numeric")) pk=paste(names(data)[pk],collapse=",")
		}
	
	datatypes<-getSqlTypeInfo("PostgreSQL")
	datatypes["numeric"]<-"numeric"

	csvfilename=gsub("\\\\","\\\\\\\\",csvfilename)

	text=""
	text=paste(text,"CREATE TABLE ",table," (",sep="")
	columnnames<-names(data)

#################################################################################

	if (length(pk)>0) { 
		for (n in columnnames) {
		if (length(grep(n, datecol))>0) {
			text=paste(text,"\"",n,"\" date,\n",sep="")
			} else {
			#print(class(data[[n]]))
			if (is.null(class(data[[n]]))) cat("Missing datatype:",class(data[[n]]),"\n")
			text=paste(text,"\"",n,"\" ",datatypes[[class(data[[n]])]],",\n",sep="")
			}
		}
	text=paste(text,"CONSTRAINT \"",table,"_pkey\" PRIMARY KEY (",pk,")\n",sep="")
	}	
	
	if (length(pk)==0) { 
		for (n in columnnames[1:(length(columnnames)-1)]) {
			if (length(grep(n, datecol))>0) {
			text=paste(text,"\"",n,"\" date,\n",sep="")
			} else {
			#print(class(data[[n]]))
			if (is.null(class(data[[n]]))) cat("Missing datatype:",class(data[[n]]),"\n")
			text=paste(text,"\"",n,"\" ",datatypes[[class(data[[n]])]],",\n",sep="")
			}
		}
		
		n=columnnames[length(columnnames)]
		text=paste(text,"\"",n,"\" ",datatypes[[class(data[[n]])]],sep="")
		#\"
	}

###############################################################################
	if (withoids) text=paste(text,") WITH (OIDS=TRUE);\n",sep="")
	else text=paste(text,") WITH (OIDS=FALSE);\n",sep="")
	text=paste(text,"ALTER TABLE ",table," OWNER TO ",pguser,";\n",sep="")
	
	

	
	if (source_file=="STDIN") {
	if (header) text=paste(text,"COPY ",table," FROM ",source_file," CSV HEADER;\n",sep="")
	else text=paste(text,"COPY ",table," FROM ",source_file," CSV;\n",sep="")
	
	sink("sqlquery.txt")
	cat(text)
	sink()

	
			
	if (printcopy){
			
		cat(paste('ok the CREATE TABLE and COPY statements have been constructed for this file and is in "sqlquery.txt", have a look and see if it is correct\nif it is ok and you have not set your password to be remembered in pgAdmin then paste this into a cmd prompt\n\ntype sqlquery.txt \"',csvfilename,'\" | \"C:\\Program Files\\PostgreSQL\\8.3\\bin\\psql\" -h ',ip,' -U ',pguser,' -d ',db,'\n\n\notherwise you can run this directly from R\n\nshell(\"type sqlquery.txt \\"',csvfilename,'\\" | \\"C:\\\\Program Files\\\\PostgreSQL\\\\8.3\\\\bin\\\\psql\\" -h ',ip,' -U ',pguser,' -d ',db,'\")',sep=''),'\n')

cat(paste("\n\nnow you probably should vaccuum the table\nVACUUM ANALYZE ",table,";\n",sep=""))			
	} else {
sink('go.bat')
cat(paste('type sqlquery.txt \"',csvfilename,'\" | \"C:\\Program Files\\PostgreSQL\\8.3\\bin\\psql\" -h ',ip,' -U ',pguser,' -d ',db,'',sep=''))
sink()
shell('go.bat')
file.remove('go.bat')
}	
	

}
	
}


############
# new_gisview
new_gisview<-function(viewname,gis,data,gis_key,data_key){
cat(paste("CREATE OR REPLACE VIEW public.",viewname," AS
SELECT * FROM ",data,"
INNER JOIN ",gis,"
ON ",gis,".",gis_key," = ",data,".",data_key,";\n",sep=""))
}

####################
points_to_geom_query<-function(schema,tablename,col_lat,col_long){
	table=sprintf("%s.%s",schema,tablename)

	cat(sprintf(
	"SELECT AddGeometryColumn('%s', '%s', 'the_geom', 4283, 'POINT', 2);\n",
	schema,tablename))

	cat(sprintf(
	"ALTER TABLE %s ADD CONSTRAINT geometry_valid_check CHECK (isvalid(the_geom));\n" ,
	table))

	cat(sprintf("
	UPDATE %s
	SET the_geom=GeomFromText(
		'POINT('||
		%s ||
		' '||
		%s ||')'
		,4283);\n",table,col_long,col_lat))
}


##########
# function to load shp to postgres
shp2pgis=function(rootdir=getwd(),infile,d='postgis',u='postgres',host='localhost',srid=4283,schema='public', pgpath=c('c:\\pgutils')){
	# NOTE THERE IS ANOTHER VERSION ON THE WIKI WITH SOME EXTRA INDEX STUFF
	oldwd=getwd()
	setwd(rootdir)

	sink(paste(rootdir,"doshp.bat",sep="/"))
	cat(paste("\"",pgpath,"\\shp2pgsql\" -D %1.shp -s ",srid," ",schema,".%1 > %1.sql",sep=""),"\n")
	cat(paste("\"",pgpath,"\\psql\"  -d ",d," -U ",u," -W -h ",host," -f %1.sql",sep=""),"\n")
	sink()

	shell(paste("doshp.bat ",infile,sep=""))
	file.remove("doshp.bat")
	file.remove(paste(infile,".sql",sep=""))

	ch=odbcConnect(d) # double check you connect to the correct database

	sqlQuery(ch,paste("CREATE INDEX \"",infile,"_gist\" ON ",schema,".",infile," USING gist(the_geom);
	ALTER TABLE ",schema,".",infile," CLUSTER ON \"",infile,"_gist\";",sep=""))

	sqlQuery(ch,paste("VACUUM ANALYZE ",infile,";",sep=""))


	if (srid!=4283){	             
		sqlQuery(ch,
			sprintf("SELECT AddGeometryColumn('%s','%s','gda94_geom',4283,'MULTIPOLYGON',2);
			ALTER TABLE %s.\"%s\" DROP CONSTRAINT enforce_geotype_gda94_geom;
			UPDATE %s.\"%s\" SET gda94_geom=ST_Transform(the_geom,4283);",
			tolower(schema),tolower(infile),tolower(schema),tolower(infile),tolower(schema),tolower(infile))
			)                     
			}
	close(ch)					        
	setwd(oldwd)		
}

# JUST PRINT

shp2pgisBAT=function(infile,d='postgis',u='postgres',host='localhost',srid=4283,schema='public',
 pgutils = 'C:\\pgutils\\'){
	cat(paste("\"",pgutils,"shp2pgsql\" -s ",srid," -D %1.shp ",schema,".%1 > %1.sql",sep=""),"\n")
	cat(paste("\"",pgutils,"psql\"  -d ",d," -U ",u," -W -h ",host," -f %1.sql",sep=""),"\n")
	cat('make doshp.bat\n\n')
	cat(paste("doshp.bat ",infile,sep=""))
    cat(paste("\n\nCREATE INDEX idx_",infile,"_the_geom ON ",schema,".",infile," USING gist(the_geom);\n",sep=""))
    cat(paste("VACUUM ANALYZE ",schema,".",infile,";\n",sep=""))
    
	cat(paste("CREATE INDEX \"",infile,"_gist\"
  	ON ",schema,".",infile,"
  	USING gist
  	(the_geom);
	ALTER TABLE ",schema,".",infile," CLUSTER ON \"",infile,"_gist\";\n",sep=""))

		
	if (srid!=4283){	             
		cat(
		sprintf("SELECT AddGeometryColumn('%s','%s','gda94_geom',4283,'MULTIPOLYGON',2);
		ALTER TABLE %s.\"%s\" DROP CONSTRAINT enforce_geotype_gda94_geom;
		UPDATE %s.\"%s\" SET gda94_geom=ST_Transform(the_geom,4283);",
		tolower(schema),tolower(infile),tolower(schema),tolower(infile),tolower(schema),tolower(infile))
		)                     
	}

	
	}
	
#############
# add metadata
# add_study=function(idno,titl,sourcename,abstract='',restrctn='unrestricted',copyright='no copyright',host='weather'){
			# hst=odbcConnect(host)
      
      # sqlQuery(hst,
			# #cat(
			# paste("insert into metadata_stdydscr (idno,titl,authenty,abstract,restrctn,copyright) values (
			# '",idno,"','",titl,"','",sourcename,"','",abstract,"','",restrctn,"','",copyright,"');",sep="")
			# )
      # close(hst)
      # }
      
# filei is the name of the 'schema.table' to add descs to
# descriptions is a list

# TODO: messages regarding descriptions for each column ('more variables than descriptions' etc)


# add_file_metadata=function(stdy,filei,filelocn,descriptions=NA,tablecomment='',host='weather'){

      # hst=odbcConnect(host)
      # sqlQuery(hst,sprintf("insert into metadata_filedscr (idno,filename,filelocation,filedscr) values ('%s','%s','%s','%s')",stdy,filei,filelocn,tablecomment))
      
      # fileid=sqlQuery(hst,sprintf("select fileid from metadata_filedscr where filename like '%s'",filei))
        # labls=names(sqlQuery(ch,sprintf("select * from %s limit 1",filei)))

        # if(is.na(descriptions)){
            # chooseToEnterWithoutDesc=parse(prompt=paste("do you want to enter labls without desc: "))
                # if(chooseToEnterWithoutDesc[[1]]=='y'){       
                    # print("Ok you can enter the descriptions for these later:")
                    # print(as.matrix(c(labls))) 
                    # #descriptions=parse(prompt=paste("enter descriptions for the ",length(labls)," variables (no spaces): "),n=length(labls))
                    # #dsc=data.frame(ncol=2)   
# #                    for(i in 1:length(labls)){
# #                        dsc=rbind(dsc,c(as.character(labls[i]),as.character(descriptions[[i]])))
# #                    }
# #                    dsc=dsc[-c(1),]
# #                    rm(descriptions)
                    # dsc=rep(NA,length(labls))
                    # variables=as.data.frame(cbind(rep(as.numeric(fileid),length(labls)),labls,dsc)  )
                    # names(variables)=c("fileid","labl","notes")
                # variables$fileid=as.numeric(as.character(variables$fileid))                   
                    # sqlSave(ch,variables)
                    # sqlQuery(ch,"insert into metadata_datadscr (fileid,labl,notes) select fileid,labl,notes from variables")
                    # sqlQuery(ch,'drop table variables')

                                                # } else {break}
              # }
       
        # ########################################                                                               
        # ## if descriptions are supplied
        # variables=as.data.frame(cbind(rep(as.numeric(fileid),length(labls)),labls,as.character(descriptions))  )
    # # if not enough descriptions show the list of varnames
    # if(length(labls)!= length(descriptions)) {
                # print('different number of descriptions to labels')
                # break
                # }
               
    # names(variables)=c("fileid","labl","notes")
    # variables$fileid=as.numeric(as.character(variables$fileid))
    # print(variables)
       
        # sqlSave(ch,variables)
        # sqlQuery(ch,"insert into metadata_datadscr (fileid,labl,notes) select fileid,labl,notes from variables")
        # sqlQuery(ch,'drop table variables')


        # sqlQuery(ch,paste("COMMENT ON TABLE ",filei," IS '",tablecomment,"';",sep=""))

        # for(i in 1:nrow(variables)){
                # sqlQuery(ch,paste("COMMENT ON COLUMN ",filei,".",variables[i,2]," IS '",gsub("'","",variables[i,3]),"';",sep=""))
                # }
        # close(hst)
# }

# grant access
grant_access=function(tablename,grant_u,access='SELECT'){
cat(
paste("grant ",access," on ",tablename," to ",grant_u,sep="")
)
}

# grant_access=function(tablename,grant_u,access='SELECT',host='weather'){
			# hst=odbcConnect(host)
      
      # sqlQuery(hst,
			# #cat(
			# paste("grant ",access," on ",tablename," to ",grant_u,sep="")
			# )
      # close(hst)
      # }
      
	

