
################################################################
# name:check_dbsize
 require(ProjectTemplate)
  load.project()

  require(swishdbtools)
  p <- getPassword(remote=T)
  ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user=
                         'gislibrary', p = p)
  sql_subset(ch, x = 'dbsize', limit = -1, eval = TRUE)
