# Written to execute Stage Three clean
# By Sara Knox
# Aug 11, 2022
# 
# Last modification: Nov 2, 2022 (Zoran)
#
# Example (it should be entered as one line if a Win CMD prompt) : 
#   "C:\Program Files\R\R-4.2.1\bin\Rscript.exe" "C:\Biomet.net\R\database_functions\Run_ThirdStage_REddyProc.R" "C:\Biomet.net\R\database_functions" "E:\Junk\database\Calculation_procedures\TraceAnalysis_ini\DSM\log\DSM_ThirdStageCleaningParameters.ini"  2> "E:\Junk\database\Calculation_procedures\TraceAnalysis_ini\DSM\log\DSM_ThirdStageCleaning.log" 1>&2



# Revisions
#
# Nov 2, 2022 (Zoran)
#   - changed to work with most of input arguments being passed 
#     via siteID_ThirdStageCleaningParamenters.ini. This file is usualy created
#     by Matlab function runThirdStageCleaningREddyProc().
# Nov 1, 2022 (Zoran)
#   - Added Ustar_scenario and yearsToProcess to input arguments of StageThree_REddyProc.
# Oct 27, 2022 (Zoran)
#   - converted it into a script that can be called by Matlab 



args 		<- commandArgs(trailingOnly = TRUE)
pathBiometR   		<- args[1]
pathInputArgs 		<- args[2]


# load input arguments from pathInputArgs file
source(paste(pathBiometR,"read_ThirdStageCleaningParametersIni.R",sep="/"))

# Load function
source(file.path(fx_path,'ThirdStage_REddyProc.R'))

# Call third stage processing
# ThirdStage_REddyProc(site, years, db_ini, db_out, ini_path, fx_path,Ustar_scenario,yearsToProcess,do_REddyProc)
ThirdStage_REddyProc(pathBiometR,pathInputArgs)
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

