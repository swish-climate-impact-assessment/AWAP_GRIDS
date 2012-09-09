
newnode(dsc='R-init', clearpage = F, ttype='report', nosectionheading = T,
 o = 'R-init',append = F,end_doc = F,
 notes='Initialize the project workspace',echoCode = FALSE,
 code=NA)

newnode(dsc='go', clearpage = F, ttype='report', nosectionheading = T,
 o = 'go',i='R-init',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='tools', clearpage = F, ttype='report', nosectionheading = T,
 i=c('go', 'vars', 'get_data_range', 'read.asciigrid2','grid2csv'),
 o = 'tools',append = T,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='variable names', clearpage = F, ttype='report', nosectionheading = T,
 o = 'vars',
 notes='
 At the BoM website the urls for our files can be like the following combinations:
 rain                http://www.bom.gov.au/web03/ncc/www/awap/   rainfall/totals/daily/    grid/0.05/history/nat/2010120120101201.grid.Z
 tmax                http://www.bom.gov.au/web03/ncc/www/awap/   temperature/maxave/daily/ grid/0.05/history/nat/2012020620120206.grid.Z
 tmin                http://www.bom.gov.au/web03/ncc/www/awap/   temperature/minave/daily/ grid/0.05/history/nat/2012020620120206.grid.Z
 vapour pressure 9am http://www.bom.gov.au/web03/ncc/www/awap/   vprp/vprph09/daily/       grid/0.05/history/nat/2012020620120206.grid.Z
 vapour pressure 3pm http://www.bom.gov.au/web03/ncc/www/awap/   vprp/vprph15/daily/       grid/0.05/history/nat/2012020620120206.grid.Z
 solar               http://www.bom.gov.au/web03/ncc/www/awap/   solar/solarave/daily/     grid/0.05/history/nat/2012020720120207.grid.Z
 NDVI                http://reg.bom.gov.au/web03/ncc/www/awap/   ndvi/ndviave/month/       grid/history/nat/2012010120120131.grid.Z
 ',echoCode = FALSE,
 code=NA)

newnode(dsc='get data range', clearpage = F, ttype='report', nosectionheading = T,
 o = c('get_data_range'),i='get_data',
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='read.asciigrid2', clearpage = F, ttype='report', nosectionheading = T,
 o = c('read.asciigrid2'),
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='grid2csv', clearpage = F, ttype='report', nosectionheading = T,
 o = 'grid2csv',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='download', clearpage = F, ttype='report', nosectionheading = T,
 o = 'data/{year}/{month}', i=c('tools', 'foundMissings'),
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='uncompress-newnode', clearpage = F, ttype='report', nosectionheading = T,
 i='data/{year}/{month}', o = c('grids','csvs'),append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='check', clearpage = F, ttype='report', nosectionheading = T,
 i='grids', o = 'fig1.jpg',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='loadCsv2delphe test', clearpage = F, ttype='transformations', nosectionheading = T,
 i='csvs',o = 'test. too slow',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='loadCsv2delpheUsingCOPY-newnode', clearpage = F, ttype='transformations', nosectionheading = T,
 i ='csvs', o = c('awap_grids.vprph_master','check4duplicates','check4missings'),append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA, TASK = '
**** TODO NEED TO REMOVE GRID POLYGONS
 ')

newnode(dsc='check4duplicates', clearpage = F, ttype='transformations', nosectionheading = T,
 i = 'check4duplicates',
 o='response by bom',
 append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='check4missings', clearpage = F, ttype='transformations', nosectionheading = T,
 i = 'check4missings',
 o='foundMissings',
 append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='checkAstation-newnode', clearpage = F, ttype='transformations', nosectionheading = T,
 o = c('fig2.jpg','checkAstation'),i='awap_grids.vprph_master',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='function to extract timeseries', clearpage = F, ttype='transformations', nosectionheading = T,
 i = 'awap_grids.vprph_master', o = 'function to extract timeseries',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='test function', clearpage = F, ttype='transformations', nosectionheading = T,
 i='function to extract timeseries', o = 'test function',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='publish function', clearpage = F, ttype='transformations', nosectionheading = T,
 i = 'test function', o = c('to NCEPH PostGIS wiki','to ivanstools','metadata'),append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA)

newnode(dsc='Archives', clearpage = F, ttype='transformations', nosectionheading = T,
 i='metadata',o = 'Archives',append = T,end_doc = F,
 notes='',echoCode = FALSE,
 code=NA,
 TASK=NA)

newnode(dsc = 'The end', clearpage = F, ttype = 'transformations', nosectionheading = T,
dontshow = T,
append = T,,
document='sweave',
end_doc = T)
# now run 
#oldwd <- getwd()
#setwd('reports')
#Sweave('AWAP_GRIDS_transformations_doc.Rnw')
#setwd(oldwd)
