# Written to execute Stage Three clean
# By Sara Knox
# Aug 11, 2022

# Load function
source('D:/NZ/MATLAB/CurrentProjects/Micromet/R/database_functions/StageThree_REddyProc.R')
  
site <- 'DSM'
years <- 2021 # if using multiple years use c(year1,year2) 

# ZORAN, some of these inputs edited to better work with the biomet.net flow.     
db_ini <- "C:/Users/zoran/AppData/Local/Temp/local_database" # base path to find the files
db_out <- "C:/Users/zoran/AppData/Local/Temp/local_database" # base path where to save the files
ini_path <- 'D:/NZ/MATLAB/CurrentProjects/Micromet/R/database_functions/ini_files/' # specify base path to where the ini files are
fx_path <- "D:/NZ/MATLAB/CurrentProjects/Micromet/R/database_functions" # Specify path for loading functions

StageThree_REddyProc(site, years, db_ini, db_out, ini_path, fx_path)
