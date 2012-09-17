
library(RODBC)
#############
# add metadata
add_study=function(idno,titl,sourcename,distrbtr,abstract='',notes='NCEPH Unrestricted',restrctn='',datakind='OTHER',host='oracle',run=F){
if(run==F){
#hst=odbcConnect(host)

#sqlQuery(hst,
cat(
paste("insert into stdydscr (idno,titl,authenty,abstract,distrbtr,notes,restrctn,datakind) 
values ('",idno,"','",titl,"','",sourcename,"','",abstract,"','",distrbtr,"','",notes,"','",restrctn,"','",datakind,"');",sep="")
)
#close(hst)
} else {
hst=odbcConnect(host)

sqlQuery(hst,
#cat(
paste("insert into stdydscr (idno,titl,authenty,abstract,distrbtr,notes,restrctn,datakind) 
values ('",idno,"','",titl,"','",sourcename,"','",abstract,"','",distrbtr,"','",notes,"','",restrctn,"','",datakind,"');",sep="")
)
close(hst)
}

}

# filei is the name of the 'schema.table' to add descs to
# descriptions is a list

# TODO: messages regarding descriptions for each column ('more variables than descriptions' etc)


add_file_metadata=function(stdy,filei,filelocn,descriptions=NA,tablecomment='' ,host='weather',filetype='Raw data', run=F){  
if(run==F){
	#hst=odbcConnect(host)
	#sqlQuery(hst,
	cat(
	sprintf("insert into filedscr (idno,filename,filelocation,notes,filetype) 
	values ('%s','%s','%s','%s','%s');",stdy,filei,filelocn,tablecomment,filetype)
	)

	#fileid=sqlQuery(hst,
	cat('\n-- fileid\n\n')
	cat(
	sprintf("select fileid 
	from filedscr 
	where filename like '%s';",filei)
	)



	#labls=names(sqlQuery(hst,
	cat(
	sprintf("\n--labls\n\nselect * from %s limit 1;",filelocn)
	)
} else {
	hst2=odbcConnect('oracle')
	sqlQuery(hst2,
	#cat(
	sprintf("insert into filedscr (idno,filename,filelocation,notes,filetype) 
	values ('%s','%s','%s','%s','%s');",stdy,filei,filelocn,tablecomment,filetype)
	)
	close(hst2)
}

}

# find out the fileid number and labls.

add_data_descriptions=function(fileid=NA ,filei, filelocn, descriptions=NA,host='bio',run=F){

if(is.na(fileid)){
hst2=odbcConnect('oracle')
fileid=sqlQuery(hst2,
#cat('\n-- fileid\n\n')
#cat(
sprintf("select fileid 
from filedscr 
where filename like '%s';",filei)
,as.is=T)
close(hst2) 
}


hst=odbcConnect(host)
labls=names(sqlQuery(hst,
#cat(
sprintf("select * from %s limit 1;",filelocn)
))

if(run==F){
  if(is.na(descriptions)){
  
  cat(
  paste("insert into datadscr (fileid,labl,notes) values (",fileid,",'",labls,"','');",collapse='\n',sep="")
  )
  
  } else {
  
  cat(
  paste("insert into datadscr (fileid,labl,notes) values (",fileid,",'",labls,"','",descriptions,"');",collapse='\n',sep="")
  )
  
  }
} else {
hst2=odbcConnect('oracle')
 if(is.na(descriptions)){

	for(lab in labls){
		sqlQuery(hst2,
		# cat(
		paste("insert into datadscr (fileid,labl,notes) 
		values (",fileid,",'",lab,"','');",collapse='\n',sep="")
		)
		}
		
} else {
  #sqlQuery(hst2,
  cat(
  paste("insert into datadscr (fileid,labl,notes) values (",fileid,",'",labls,"','",descriptions,"');",collapse='\n',sep="")
  )
  
  }
close(hst2)  
}
 
}

#
#
#
#
#
#
#        if(is.na(descriptions)){
#            chooseToEnterWithoutDesc=parse(prompt=paste("do you want to enter labls without desc: "))
#                if(chooseToEnterWithoutDesc[[1]]=='y'){       
#                    print("Ok you can enter the descriptions for these later:")
#                    print(as.matrix(c(labls))) 
#                    #descriptions=parse(prompt=paste("enter descriptions for the ",length(labls)," variables (no spaces): "),n=length(labls))
#                    #dsc=data.frame(ncol=2)   
##                    for(i in 1:length(labls)){
##                        dsc=rbind(dsc,c(as.character(labls[i]),as.character(descriptions[[i]])))
##                    }
##                    dsc=dsc[-c(1),]
##                    rm(descriptions)
#                    dsc=rep(NA,length(labls))
#                    variables=as.data.frame(cbind(rep(as.numeric(fileid),length(labls)),labls,dsc)  )
#                    names(variables)=c("fileid","labl","notes")
#                variables$fileid=as.numeric(as.character(variables$fileid))                   
#                    sqlSave(hst,variables)
#                    sqlQuery(hst,"insert into metadata_datadscr (fileid,labl,notes) select fileid,labl,notes from variables")
#                    sqlQuery(hst,'drop table variables')
#
#                                                } else {break}
#              }
#       
#        ########################################                                                               
#        ## if descriptions are supplied
#        variables=as.data.frame(cbind(rep(as.numeric(fileid),length(labls)),labls,as.character(descriptions))  )
#    # if not enough descriptions show the list of varnames
#    if(length(labls)!= length(descriptions)) {
#                print('different number of descriptions to labels')
#                break
#                }
#               
#    names(variables)=c("fileid","labl","notes")
#    variables$fileid=as.numeric(as.character(variables$fileid))
#    print(variables)
#       
#        sqlSave(hst,variables)
#        sqlQuery(hst,"insert into metadata_datadscr (fileid,labl,notes) select fileid,labl,notes from variables")
#        sqlQuery(hst,'drop table variables')
#
#
#        sqlQuery(hst,paste("COMMENT ON TABLE ",filei," IS '",tablecomment,"';",sep=""))
#
#        for(i in 1:nrow(variables)){
#                sqlQuery(hst,paste("COMMENT ON COLUMN ",filei,".",variables[i,2]," IS '",gsub("'","",variables[i,3]),"';",sep=""))
#                }
#        close(hst)
#}

# grant access
grant_access=function(tablename,grant_u,access='SELECT',host='weather'){
			hst=odbcConnect(host)
      
      sqlQuery(hst,
			#cat(
			paste("grant ",access," on ",tablename," to ",grant_u,sep="")
			)
      close(hst)
      }
      
	