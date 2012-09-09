
newnode(dsc='metadata-init', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'metadata-init',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

 source('~/My Dropbox/tools/transformations.r')

 source('~/My Dropbox/tools/df2ddi/df2ddi.r')
 delphe <- connectDelphe('130.56.102.41','ivan_hanigan','delphe')  
 oracle <- connectOracle(hostip='150.203.74.97',user='ivan') 
 idno <- 'AWAP_GRIDS'
 if(!exists('s')){
   s <- dbGetQuery(oracle, paste("select * from stdydscr where idno = '",idno,"'", sep = ''))
 idno <- s$IDNO
 }
 t(s) 
# newnode get tools
# rm(oracle)
if(!exists('oracle')) {source(dir('run',pattern = 'tools', full.names=T))}

newnode(dsc='insert study id', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'insert study id',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)
 
 dir.create('metadata')
 
 write.table(s,'metadata/stdydscr.csv',sep=',',row.names=F)

newnode(dsc='include data desc for file1', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'include data desc for file1',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)
 
 # newnode abs data
 t(fileDscr[2,])
 df <-  dbGetQuery(delphe, 'select * from awap_grids.vprph_master limit 1') 
 d <- add_datadscr(data_frame = df, fileid = 3130, ask=T)
 write.table(d,'metadata/datadscr.csv',sep=',',row.names=F)

newnode(dsc='include data desc for file2', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'include data desc for file2',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

 f$PRODDATEDOCFILE <- NA
 f$PRODUCERDOCFILE <- NA
 f$DESTROYED <- 0
 f <- f[,c('FILEID','IDNO','FILENAME','FILETYPE','PROCSTAT','SPECPERMFILE','DATEARCHIVED','DATEDESTROY','FILEDSCR','FILELOCATION','NOTES','REQID','PUBLISHDDI','BACKUPVALID','DATEBACKUPVALID','CHECKED','BACKUPLOCATION','PRODDATEDOCFILE','PRODUCERDOCFILE','DESTROYED')]

 # datadscr
 df <- dbGetQuery(delphe, ' select * from awap_grids.awap_grid_05_stns limit 1')
 d <- add_datadscr(data_frame = df, fileid = 1, ask=T) # might not be correct but will update on insert to oracle
 d
 

 write.table(f,'metadata/filedscr.csv',sep=',',row.names=F, col.names=F, append=T)
 write.table(d,'metadata/datadscr.csv',sep=',',row.names=F, col.names=F, append=T)

newnode(dsc='add metadata for the files', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'add metadata for the files',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

 # newnode file1 the final document
 #f <- add_filedscr(fileid = 1, idno = s$IDNO, ask=T)
 #f$FILELOCATION <- 'I:/My Dropbox/projects/1.302 Biomass/Biomass Smoke Project/JAWMA_fire_events'

newnode(dsc='add metadata for files to oracle', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'add metadata for files to oracle',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)
 
 f<-read.table('metadata/filedscr.csv',as.is=T,sep=',',header=T)
 f2 <- as.data.frame(matrix(nrow = 0, ncol=ncol(f)))
 for(i in 1:nrow(f)){
 f2 <- rbind(f2,as.data.frame(t(unlist(ifelse(is.na(f[i,]),'',f[i,])  ))))
 }
 names(f2) <- names(f)
 f2 
 replaceDDI <- F
 if(replaceDDI == T) { dbSendUpdate(oracle, sprintf("delete from filedscr where idno = '%s'",idno))}
 extant <- dbGetQuery(oracle, sprintf("select * from filedscr where idno = '%s'",idno))
 
 if(nrow(extant) == 0){
  dbWriteTable(oracle, 'NUFILES', f2)
  dbSendUpdate(oracle,
  'insert into ivan.filedscr (IDNO, FILENAME, FILETYPE, PROCSTAT, SPECPERMFILE, DATEARCHIVED, DATEDESTROY, FILEDSCR, NOTES, REQID, PUBLISHDDI, BACKUPVALID, DATEBACKUPVALID, CHECKED, BACKUPLOCATION, FILEID, FILELOCATION)
  select IDNO, FILENAME, FILETYPE, PROCSTAT, SPECPERMFILE, to_date(DATEARCHIVED), DATEDESTROY, FILEDSCR, NOTES, REQID, PUBLISHDDI, BACKUPVALID, to_date(DATEBACKUPVALID), CHECKED, BACKUPLOCATION, FILEID, FILELOCATION from nufiles
  ')
  dbSendUpdate(oracle,'
  drop table nufiles
  ')

  } else {
 
  for(i in 1:nrow(f2)){
   #i <- 1
   print(f2$FILENAME[i])
   if(length(grep(f2$FILENAME[i], extant$FILENAME)) != 0) {next}
   dbWriteTable(oracle, 'NUFILES', f2[i,])
   dbSendUpdate(oracle,
   'insert into ivan.filedscr (IDNO, FILENAME, FILETYPE, PROCSTAT, SPECPERMFILE, DATEARCHIVED, DATEDESTROY, FILEDSCR, NOTES, REQID, PUBLISHDDI, BACKUPVALID, DATEBACKUPVALID, CHECKED, BACKUPLOCATION, FILEID, FILELOCATION)
   select IDNO, FILENAME, FILETYPE, PROCSTAT, SPECPERMFILE, to_date(DATEARCHIVED), DATEDESTROY, FILEDSCR, NOTES, REQID, PUBLISHDDI, BACKUPVALID, to_date(DATEBACKUPVALID), CHECKED, BACKUPLOCATION, FILEID, FILELOCATION from nufiles
   ')
   dbSendUpdate(oracle,'
   drop table nufiles
   ')
   }
  }

newnode(dsc='add metadata for data to oracle', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'add metadata for data to oracle',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)
 
 
 
 # NOW NEED TO IDENTIFY ID NUMBERS
 dbGetQuery(oracle,paste(
  "
  SELECT IDNO, min(FILEID), max(FILEID) FROM FILEDSCR 
  WHERE IDNO = '",idno,"'
  group by idno
  ", sep='')
  )

 # FILEIDS ARE 
# minfileid <- 3122
# maxfileid <- 3122
# fileids <- seq(minfileid,maxfileid)

 datarows <- read.csv('metadata/datadscr.csv')
 # need to edit this as I made that fileid up above
 names(table(datarows$FILEID))
 datarows[datarows$FILEID == 1,'FILEID']  <- 3137
 fileids <- names(table(datarows$FILEID))
for(i in 1:length(names(table(datarows$FILEID)))){
  # i <- 1
  rows <- names(table(datarows$FILEID))[i]
  fid<-fileids[i]
  cat(paste('insert into ivan.datadscr (',
  paste(names(read.csv(dir('metadata',full.names=T)[grep('datadscr.csv',dir('metadata',full.names=T))])),sep='',collapse=', '),
  ')
  
  select ',
  gsub('FILEID',fid,paste(names(datarows),sep='',collapse=', ')),
  ' from nudata
  WHERE FILEID = ',rows,'
  ',
  sep='')
  )
  }


 
 # upload the data table
 nudata <- read.csv('metadata/datadscr.csv')
 nudata
 dbWriteTable(oracle,'NUDATA', nudata)
 
 dbSendUpdate(oracle,
 'insert into ivan.datadscr (LABL, NOTES, SPECPERMVAR, FILEID)
  
  select LABL, NOTES, SPECPERMVAR, 3130 from nudata
  WHERE FILEID = 3130

 ')
 dbSendUpdate(oracle,
 'insert into ivan.datadscr (LABL, NOTES, SPECPERMVAR, FILEID)
  
  select LABL, NOTES, SPECPERMVAR, 3137 from nudata
  WHERE FILEID = 1

 ')
 dbSendUpdate(oracle,
 'drop table nudata
 ')

newnode(dsc='oracle2xml-makeTex', clearpage = F, ttype='transformations', nosectionheading = T,
 o = 'oracle2xml-makeTex',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)
 
 setwd('~/My Dropbox/projects/0.3 Catalogue/')
 
 # run I:/My Dropbox/projects/0.3 Catalogue/oracle2xml-makeTex.r 
 setwd(dbx)

  doc <- dir(file.path('I:/My Dropbox/projects/0.3 Catalogue/publishddi',idno,'reports'), pattern = '\\.tex')
  file.copy(file.path('I:/My Dropbox/projects/0.3 Catalogue/publishddi',idno,'reports',doc), file.path('metadata',gsub('_doc','_metadata',doc)), overwrite = T) 
  # edits = find and replace \subsection with \textbf , remove header and end, paste into keynote, keynode output

newnode(dsc='create catalogue and ddi xmls', clearpage = F, ttype='transformations', nosectionheading = T,
o = 'create catalogue and ddi xmls',append = T,end_doc = F,
notes='',echoCode = FALSE,
code=NA)

setwd('I:/My Dropbox/projects/0.3 Catalogue/')
setwd(dbx)
