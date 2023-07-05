library('phenopix')
library('raster')
library('ggplot2')
library('dplyr')
source('~/Desktop/codes/phenocam/scripts/phenocam_fxn.R')
# devtools::install_github("collectivemedia/tictoc")
library('tictoc')

# main function currently
wd <- '~/Desktop/codes/phenocam/DSM'
PhenoProcessing(wd)