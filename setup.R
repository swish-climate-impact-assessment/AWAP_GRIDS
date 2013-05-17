update.packages(checkBuilt=TRUE, ask = F)

install.packages("reshape")

install.packages("ggplot2")


install.packages("lubridate")

install.packages("fgui")

install.packages("raster")

install.packages("rgdal")


install.packages("devtools")
require(devtools)
install_github("swishdbtools", "swish-climate-impact-assessment")
install_github("awaptools", "swish-climate-impact-assessment")
