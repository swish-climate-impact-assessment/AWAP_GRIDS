
# fills a variable in a table for missing combinations of variable1 ... variableN
# returns filled table
# 'variableName' to be filled
# 'fillValue' for filled variable 
# 'variable1' values for category variable 1, where names(variable1) is the name of variable1
# variable2, ...,  variableN - values and names of category variable 2 ... N
FillCategoryTimeSeries<-function(tableIn, variableName, fillValue, variable1, ...)
{
  argumentNames <- c(deparse(substitute(variable1)), sapply(substitute(list(...))[-1], deparse))
  argumentNames <- paste(collapse = ", ", argumentNames)
  
  categoryExpression <- paste(sep = "", "t1.", names(variable1) ," = t2.", names(variable1))
  otherVariables <- list(...)
  for(variableIndex in 1:length(otherVariables)) 
  {
    variable <- otherVariables[[variableIndex]]
    categoryExpression <- paste(sep="", categoryExpression, "\r\n", " and ", "t1.", names(variable), " = t2.", names(variable))
  }
  
  tableName <- deparse(substitute(tableIn))
  case <- paste(sep = "", "case when ", variableName, " is null then ", fillValue, " else ", variableName, " end")
  joinExpression <- paste(sep = "", "(select * from ", argumentNames,") ", "\r\n", "t1 left join ", tableName, " t2 on ", "\r\n", categoryExpression)
  sql <- paste(sep = "", "select t1.*, ", "\r\n", case, "\r\n", " as ", variableName, " from ", "\r\n", joinExpression)
  
  tableOut <-  sqldf(sql, drv = 'SQLite')
  
  return(tableOut)
}

# # Example use FillCategoryTimeSeries
# # FillTest.csv is a file containing incomplete values for table with columns factorA, factorB, and value
# 
# sparseTable <- read.csv("FillTest.csv") 
# 
# variable1 = as.data.frame(toupper(letters[1:4]))
# names(variable1) <- 'factorA'
# 
# variable2 =  as.data.frame(c(1:3))
# names(variable2) <- 'factorB'
# 
# filledTable = FillCategoryTimeSeries(tableIn, "value", -1, variable1, variable2)
# 

