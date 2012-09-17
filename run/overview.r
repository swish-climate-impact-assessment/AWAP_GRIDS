
dbx <- 'I:/My Dropbox/data/AWAP_GRIDS'
source('~/my dropbox/tools/transformations.r')
 rootdir <- getwd()
 wd <- '~/AWAP_GRIDS' # I? or maybe actually want to use c drive for large data downloads on work PC?
 # source(dir('run',pattern = 'tools', full.names=T))
 # file.remove(dir('run',full.names=T))
 #file.copy(file.path(dbxwd,'overview.r'), file.path(wd,'overview.r'), overwrite=T)
 setwd(wd)
 dir()
 dir.create('run')

print('helloworld2')
