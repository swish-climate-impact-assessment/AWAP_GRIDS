
################################################################
# name:check_dbsize
 require(ProjectTemplate)
  load.project()

  require(swishdbtools)
  ch <- connect2postgres(h = '115.146.84.135', db = 'ewedb', user=
                         'gislibrary', p = 'gislibrary')
  sqlquery_select(ch, from_table = 'dbsize', limit = -1, eval = TRUE)
