# Written to execute Stage Three clean
# By Sara Knox
# Aug 11, 2022
# 
# Last modification: Oct 28, 2022 (Zoran)
#
# Example (it should be entered as one line if a Win CMD prompt) : 
#   "C:\Program Files\R\R-4.2.1\bin\Rscript.exe" "C:\Biomet.net\R\database_functions\Run_REddyProc_ThirdStage.R" DSM 2022 "p:\database" "C:\Biomet.net\R\database_functions"  2> "p:\database\Calculation_procedures\TraceAnalysis_ini\DSM\log\DSM_ThirdStageCleaning.log" 1>&2

# 
#	
#


# Revisions
#
# Nov 1, 2022 (Zoran)
#   - Added Ustar_scenario and yearsToProcess to input arguments of StageThree_REddyProc.
# Oct 27, 2022 (Zoran)
#   - converted it into a script that can be called by Matlab 



args 		<- commandArgs(trailingOnly = TRUE)
site 		<- args[1]
years 	<- as.numeric(args[2])
Ustar_scenario 	<- args[3]              # either fast or full
yearsToProcess <- as.numeric(args[4])   # How many years to process for gap filling (years-yearsToProcess to years)
do_REddyProc <- as.numeric(args[5])     # 1 = yes to do ustar filtering, gap-filling and partitioning using REddyProc, 0 = no
db_root 	<- args[6]								    # Path to database (p:/database)
fx_path 	<- args[7] 								    # Path for R/database_functions functions




db_ini <- db_root # base path to find the files
db_out <- db_root # base path where to save the files
ini_path <- paste(db_root,"Calculation_Procedures","TraceAnalysis_ini",site,"/",sep="/") # specify base path to where the ini files are

# Load function
source(file.path(fx_path,'StageThree_REddyProc.R'))

# Call third stage processing
StageThree_REddyProc(site, years, db_ini, db_out, ini_path, fx_path,Ustar_scenario,yearsToProcess,do_REddyProc)
cat("=============================================================================\n")
cat(" Warnings\n")
cat("=============================================================================\n")
warnings()
cat("=============================================================================\n\n")






#==========================
# Old comments (still useful)
#
# input parameters
# site <- 'DSM'
# years <- 2022 # if using multiple years use c(year1,year2) 

# ----------- could be made generic ---------------
# define main paths
#db_root <- "p:/database"
#fx_path <- "C:/Ubc_flux/R/database_functions"   # Specify path for loading functions

# ZORAN, some of these inputs edited to better work with the biomet.net flow.     

