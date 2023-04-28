# Written to execute Stage Three clean
# By Sara Knox
# Aug 11, 2022
# 
# Last modification: Nov 6, 2022 (Zoran)
#
# Example (it should be entered as one line if a Win CMD prompt) : 
#   "C:\Program Files\R\R-4.2.1\bin\Rscript.exe" "C:/Biomet.net/R/database_functions/Run_ThirdStage_REddyProc.R" "C:/Biomet.net/R/database_functions" "p:\database\Calculation_Procedures\TraceAnalysis_ini\DSM\log\DSM_setThirdStageCleaningParameters.R"  2> "p:/database/Calculation_Procedures/TraceAnalysis_ini/DSM/log/DSM_ThirdStageCleaning.log" 1>&2
# Calling it from R-Studio:
#   args <- c("C:/Biomet.net/R/database_functions", "p:/database/Calculation_procedures/TraceAnalysis_ini/DSM/log/DSM_setThirdStageCleaningParameters.R")
#   source("C:/Biomet.net/R/database_functions/Run_ThirdStage_REddyProc.R")


# Revisions
#
# Nov 6, 2022 (Zoran)
#   - All input parameters for REddyProc now come via an R script. 
#     The path to this script is in:pathSetIni (the second argument to the function call)
# Nov 2, 2022 (Zoran)
#   - changed to work with most of input arguments being passed 
#     via siteID_ThirdStageCleaningParamenters.ini. This file is usualy created
#     by Matlab function runThirdStageCleaningREddyProc().
# Nov 1, 2022 (Zoran)
#   - Added Ustar_scenario and yearsToProcess to input arguments of StageThree_REddyProc.
# Oct 27, 2022 (Zoran)
#   - converted it into a script that can be called by Matlab 


if(length(commandArgs(trailingOnly = TRUE))==0){
    cat("\nIn: Run_ThirdStage_REddyProc:\nNo input parameters!\nUsing whatever is in args variable \n")
} else {
    # otherwise set args to commandArgs()
    args 		<- commandArgs(trailingOnly = TRUE)
}    

pathSetIni   		<- args[2]

# load input arguments from pathInputArgs file
source(pathSetIni)

# Load function
source(file.path(fx_path,'ThirdStage_REddyProc_testZ.R'))

# Call third stage processing
ThirdStage_REddyProc_testZ(pathSetIni)

cat("=============================================================================\n")
cat(" Warnings\n")
cat("=============================================================================\n")
warnings()
cat("=============================================================================\n\n")
cat("End of Run_ThirdStageREddyProc run.\n\n")




