# variables/paths to edit to run 'flux_shiny_app.R'

# Specify the path to your database
main_dir <- "/Users/saraknox/Code/local_data_cleaning/Projects/uqam-site/Database"

# Path for met/flux variables to display
basepath <- main_dir
level <- c("Clean/ThirdStage","Met") #Update to third stage
tv_input <- "clean_tv" # MAKE SURE tv is in folder

# Path to csv file with units
UnitCSVFilePath <- '/Users/saraknox/Code/flux_shiny_plots/flux_variables.csv'

# path to shiny app
arg <- '/Users/saraknox/Code/flux_shiny_plots/'

# provide names for incoming shortwave radiation and incoming PPDF
var_rad <- c('SW_IN_Avg', 'PPFD_IN_Avg') 

# path and file name of site coordinates
coordinatesXLSXFilePath <- '/Users/saraknox/Code/flux_shiny_plots/ini files/site_coordinates_UQAM.xlsx'
