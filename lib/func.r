
# Project: AWAP_GRIDS
# Author: ivanhanigan
# Maintainer: Who to complain to <ivan.hanigan@gmail.com>

# Functions for the project
if (!require(plyr)) install.packages('plyr', repos='http://cran.csiro.au'); require(plyr)     
if(!require(swishdbtools)) print('Please download the swishdbtools package and install it.')
# for instance 
# install.packages("~/tools/swishdbtools_1.0_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source");
require(swishdbtools)
