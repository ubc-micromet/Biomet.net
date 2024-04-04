# Written by June Skeeter (March 2024)
# Intended to streamline third stage processing
# Input Arguments:

# Required:
# siteID (e.g., BB)
# startYear (first year to run, e.g., 2022)
# Optional: 
# lastYear years run will be: c(startYear:lastYear)


# Example call from command line (assumes R is added to your PATH variable)
# Rscript --vanilla C:/Biomet.net/R/database_functions/ThirdStage.R BBS 2023 2024

# Example call from R terminal
# args <- c("BBS",2023,2024)
# source("C:/Biomet.net/R/database_functions/ThirdStage.R")

# # Install on first run
# install.packages(c('rs','yaml','rlist','dplyr','lubridate','data.table','tidyverse','caret'))

# Load libraries
library('fs')
library("yaml")
library("REddyProc")
library("rlist")
require("dplyr")
require("lubridate")
require("data.table")

configure <- function(siteID){
  # Get path of current script & arguments
  # Procedures differ if called via command line or via source()
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  needle <- "--file="
  match <- grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript
    args <- commandArgs(trailingOnly = TRUE)
    fx_path<- path_dir(normalizePath(sub(needle, "", cmdArgs[match])))
  } else {
    # 'source'd via R console
    fx_path<- path_dir(normalizePath(sys.frames()[[1]]$ofile))
  }
  
  siteID <- args[1]
  yrs <- c(args[2]:args[length(args)])
  
  # Read function to get db_root variable
  sapply(list.files(pattern="db_root.R", path=fx_path, full.names=TRUE), source)
  
  # Read a the global database configuration
  filename <- file.path(db_root,'Calculation_Procedures/TraceAnalysis_ini/_config.yml')
  dbase_config = yaml.load_file(filename)
  
  # Read a the site specific configuration
  fn <- sprintf('%s_ThirdStage.yml',siteID)
  filename <- file.path(db_root,'Calculation_Procedures/TraceAnalysis_ini',siteID,fn)
  config <- yaml.load_file(filename)
  
  # merge the config files
  config <- c(dbase_config,config)
  
  # Add the relevant paths
  config$Database$db_root <- db_root
  config$fx_path <- fx_path
  config$yrs <- yrs
  return(config)
}

read_traces <- function(){
  # Read function for loading data
  sapply(list.files(pattern="read_database.R", path=config$fx_path, full.names=TRUE), source)
  
  siteID <- config$Metadata$siteID
  yrs <- config$yrs
  db_root <- config$Database$db_root
  data <- data.frame()
  
  # Copy files from second stage to third stage, takes everything by default
  # Can change behavior later if needed
  level_in <- config$Database$Paths$SecondStage
  tv_input <- config$Database$Timestamp$name
  for (j in 1:length(yrs)) {
    in_path <- file.path(db_root,as.character(yrs[j]),siteID,level_in)
    copy_vars <- list.files(in_path)
    copy_vars <- copy_vars[! copy_vars %in% c(config$Metadata$tv_input)]
    data.now <- read_database(db_root,yrs[j],siteID,level_in,copy_vars,tv_input,0)
    data <- dplyr::bind_rows(data,data.now)
  }
  # Create time variables
  data <- data %>%
    mutate(Year = year(datetime),
           DoY = yday(datetime),
           hour = hour(datetime),
           minute = minute(datetime))
  
  # Create hour as fractional hour (e.g., 13, 13.5, 14)
  data$Hour <- data$hour+data$minute/60
  
  # REddyProc expects a specific naming convention
  names(data)[names(data) == 'datetime'] <- 'DateTime'
  #Transforming missing values into NA:
  data[is.na(data)]<-NA
  return(data)
}

storage_correction <- function(data_in){
  Storage_Terms <- config$Processing$ThirdStage$Storage_Terms
  terms <- names(Storage_Terms)
  for (term in terms){
    flux <- names(Storage_Terms[[term]])
    storage <- names(Storage_Terms[[term]])
    if (flux %in% colnames(data_in)) {
      data_in[[term]] <- data_in[[flux]]+data_in[[storage]]
    }else{
      print(sprintf('%s Not present in Second Stage, excluding from storage correction',flux))
    }
  }
  return(data_in)
}

ThirdStage_REddyProc <- function(data_in) {
  
  # Subset just the config info relevant to REddyProc
  REddyConfig <- config$Processing$ThirdStage$REddyProc
  
  # Limit to only variables present in data_in (e.g., exclude FCH4 if not present)
  REddyConfig$vars_in <- lapply(REddyConfig$vars_in, function(x) if (x %in% colnames(data_in)){x})
  skip <- names(REddyConfig$vars_in[REddyConfig$vars_in=='NULL']) 
  for (var in skip){
    print(sprintf('%s Not present, REddyProc will not process',var))
  }
  REddyConfig$vars_in <- REddyConfig$vars_in[!REddyConfig$vars_in=='NULL']
  
  # Rearrange data frame and only keep relevant variables for input into REddyProc
  data_REddyProc <- data_in[ , c(unlist(REddyConfig$vars_in),"DateTime","Year","DoY","Hour")]
  # Rename column names to variable names in REddyProc
  colnames(data_REddyProc)<-c(names(REddyConfig$vars_in),"DateTime","Year","DoY","Hour")
  
  # Run REddyProc
  # Following "https://cran.r-project.org/web/packages/REddyProc/vignettes/useCase.html" This is more up to date than the Wutzler et al. paper
  # NOTE: skipped loading in txt file since alread have data in data frame
  # Initalize R5 reference class sEddyProc for post-processing of eddy data
  # with the variables needed for post-processing later
  EProc <- sEddyProc$new(
    config$Metadata$siteID,
    data_REddyProc,
    c(names(REddyConfig$vars_in),'Year','DoY','Hour')) 
  
  EProc$sSetLocationInfo(LatDeg = config$Metadata$lat, 
                         LongDeg = config$Metadata$long,
                         TimeZoneHour = config$Metadata$TimeZoneHour)
  
  if (REddyConfig$Ustar_filtering$run_defaults){
    EProc$sEstimateUstarScenarios()
  } else {
    UstFull <- REddyConfig$Ustar_filtering$full_uncertainty
    EProc$sEstimateUstarScenarios( 
      nSample = UstFull$samples,
      probs = seq(
        UstFull$min,
        UstFull$max,
        length.out = UstFull$steps)
    )
  }
  
  # Simple MDS for non-Ustar dependent variables
  MDS_basic <- unlist(strsplit(REddyConfig$MDSGapFill$basic, ","))
  MDS_basic <- (MDS_basic[MDS_basic %in% names(REddyConfig$vars_in)])
  for (i in 1:length(MDS_basic)){
    EProc$sMDSGapFill(MDS_basic[i])
  }
  
  # MDS for Ustar dependent variables
  MDS_Ustar <- unlist(strsplit(REddyConfig$MDSGapFill$UStarScens, ","))
  MDS_Ustar <- (MDS_Ustar[MDS_Ustar %in% names(REddyConfig$vars_in)])
  for (i in 1:length(MDS_Ustar)){
    EProc$sMDSGapFillUStarScens(MDS_Ustar[i])
  }
  
  # Nighttime (MR) and Daytime (GL)
  EProc$sMRFluxPartitionUStarScens()
  EProc$sGLFluxPartitionUStarScens()
  
  # Create data frame for REddyProc output
  FilledEddyData <- EProc$sExportResults()
  
  # Delete uStar dulplicate columns since they are output for each gap-filled variables
  vars_remove <- c(colnames(FilledEddyData)[grepl('\\Thres.', names(FilledEddyData))],
                   colnames(FilledEddyData)[grepl('\\_fqc.', names(FilledEddyData))])
  FilledEddyData <- FilledEddyData[, -which(names(FilledEddyData) %in% vars_remove)]
  
  # Revert to original input name (but maintain ReddyProc modifications that follow first underscore)
  for (i in 1:length(REddyConfig$vars_in)){
    rep <- paste(as.character(names(REddyConfig$vars_in[i])),"_",sep="")
    sub <- paste(as.character(REddyConfig$vars_in[i]),"_",sep="")
    uNames <- lapply(colnames(FilledEddyData), function(x) if (startsWith(x,rep)) {sub(rep,sub,x)} else {x})
    colnames(FilledEddyData) <- uNames
  }
  
  
  FilledEddyData = dplyr::bind_cols(
    data_in,FilledEddyData
  )
  
  return(FilledEddyData)
}

RF_GapFilling <- function(data){
  
  RFConfig <- config$Processing$ThirdStage$RF_GapFilling
  
  # Read function for RF gap-filling data
  p <- sapply(list.files(pattern="RandomForestModelTest.R", path=config$fx_path, full.names=TRUE), source)
  
  # Check if dependent variable is available and run RF gap filling if it is
  for (fill_name in names(RFConfig)){
    if (RFConfig[[fill_name]]$var_dep %in% colnames(data)){
      var_dep <- unlist(RFConfig[[fill_name]]$var_dep)
      predictors <- unlist(strsplit(RFConfig[[fill_name]]$Predictors, split = ","))
      vars_in <- c(var_dep,predictors,"DateTime","DoY")
      gap_filled <- RandomForestModel(
        data[,vars_in],fill_name)
      data = dplyr::bind_cols(data,gap_filled)
    }else{
      print(sprintf('%s Not present, RandomForest will not process',RFConfig[[i]]$var_dep))
    }
  }
  return(data)
}

write_traces <- function(data){
  yrs <- config$yrs 
  siteID <- config$Metadata$siteID
  level_in <- config$Database$Paths$SecondStage
  # Set intermediary output depending on ustar scenario
  # Different output path for default vs advanced
  # This could create some ambiguity as to the source of final data
  if (config$Processing$ThirdStage$REddyProc$Ustar_filtering$run_defaults){
    level_out <- config$Database$Paths$ThirdStage_Default
  } else {
    level_out <- config$Database$Paths$ThirdStage_Advanced
  }
  level_out_final <- config$Database$Paths$ThirdStage
  copy_out_final <- config$Processing$ThirdStage$Final_Outputs
  tv_input <- config$Database$datenum$filename
  db_root <- config$Database$db_root
  
  for (j in 1:length(yrs)){
    # Create new directory, or clear existing directory (both intermediate and final)
    dpath <- file.path(db_root,as.character(yrs[j]),siteID) 
    
    dir.create(file.path(dpath,level_out_final), showWarnings = FALSE)
    unlink(file.path(dpath,level_out_final,'*'))
    
    dir.create(file.path(dpath,level_out), showWarnings = FALSE)
    unlink(file.path(dpath,level_out,'*'))
    
    # Copy tv from stage 2 to 3 (intermediate and final) ... maybe not as "safe" as recalculating it from timestamp?
    file.copy(
      file.path(dpath,level_in,tv_input),
      file.path(dpath,level_out,tv_input))
    
    file.copy(
      file.path(dpath,level_in,tv_input),
      file.path(dpath,level_out_final,tv_input))
    
    ind_s <- which(data$Year == yrs[j] & data$DoY == 1 & data$Hour == 0.5)
    ind_e <- which(data$Year == yrs[j]+1 & data$DoY == 1 & data$Hour == 0)
    ind <- seq(ind_s,ind_e)
    
    # Dumping everything by default into stage 3
    # Can parse down later as desired
    cols_out <- colnames(data)
    cols_out <- cols_out[! cols_out %in% c("DateTime","Year","DoY","Hour")]
    setwd(file.path(dpath,level_out))
    for (i in 1:length(cols_out)){
      writeBin(as.numeric(data[ind,i]), cols_out[i], size = 4)
    }
    
    # Copy/rename final outputs
    for (name in names(copy_out_final)){
      if (file.exists(file.path(dpath,level_out,copy_out_final[name]))){
        file.copy(
          file.path(dpath,level_out,copy_out_final[name]),
          file.path(dpath,level_out_final,name)
        )
      }else{
        print(sprintf('%s was not created, cannot copy to final output for %i',copy_out_final[name],yrs[j]))
      }            
    }
    # Save the config in the output folder
    write_yaml(
      config$Processing, 
      file.path(dpath,level_out_final,'ProcessingSettings.yml'),
      fileEncoding = "UTF-8")
  } 
}

start.time <- Sys.time()


config <- configure() # Load configuration file

input_data <- read_traces() # Read Stage 2 Data

input_data <- storage_correction(input_data)

FilledEddyData <- ThirdStage_REddyProc(input_data) # Run REddyProc

FilledEddyData <- RF_GapFilling(FilledEddyData) # Run RF model

write_traces(FilledEddyData) # Write Stage 3 Data

end.time <- Sys.time()
print('Stage 3 Complete, total run time:')
print(end.time - start.time)
