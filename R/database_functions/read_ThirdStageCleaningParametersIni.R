#
# This script reads siteID_ThirdStageCleaningParamenters.ini file
# that contains all the setup parameters for siteID's cleaning.
# The ini file is usually created by Matlab function runThirdStageCleaningREddyProc().

args 		<- commandArgs(trailingOnly = TRUE)
filePth 		<- args[2]
dataIn <- read.csv(filePth,header = FALSE,skip=5)

for(i in 1:length(dataIn$V1) ){
  if(dataIn$V3[i]=="s"){
    assign(dataIn$V1[i],dataIn$V2[i])
  } else {
    assign(dataIn$V1[i],as.numeric(dataIn$V2[i]))
  }
}



