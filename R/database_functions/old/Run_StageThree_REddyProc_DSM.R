# Written to execute Stage Three clean
# By Sara Knox
# Aug 11, 2022

# input parameters
site <- 'DSM'
years <- 2022 # if using multiple years use c(year1,year2) 

# ----------- could be made generic ---------------
# define main paths
db_root <- "p:/database"
fx_path <- "C:/Ubc_flux/R/database_functions"   # Specify path for loading functions

# ZORAN, some of these inputs edited to better work with the biomet.net flow.     

db_ini <- db_root # base path to find the files
db_out <- db_root # base path where to save the files
ini_path <- paste(db_root,"Calculation_Procedures","TraceAnalysis_ini",site,"/",sep="/") # specify base path to where the ini files are

# Load function
source(file.path(fx_path,'StageThree_REddyProc.R'))

StageThree_REddyProc(site, years, db_ini, db_out, ini_path, fx_path)
