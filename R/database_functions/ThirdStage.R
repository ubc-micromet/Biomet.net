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

ThirdStage_REddyProc <- function(data_in) {
    
    # Rearrange data frame and only keep relevant variables for input into REddyProc
    data_REddyProc <- data_in[ , c(unlist(config$REddyProc$vars_in),"DateTime","Year","DoY","Hour")]
    # Rename column names to variable names in REddyProc
    colnames(data_REddyProc)<-c(names(config$REddyProc$vars_in),"DateTime","Year","DoY","Hour")

    # Old code had hardcoded storage calculations here
    # Consensus on storage fluxes? Should be calculated in stage 2?

    # Run REddyProc
    # Following "https://cran.r-project.org/web/packages/REddyProc/vignettes/useCase.html" This is more up to date than the Wutzler et al. paper
    # NOTE: skipped loading in txt file since alread have data in data frame
    # Initalize R5 reference class sEddyProc for post-processing of eddy data
    # with the variables needed for post-processing later
    EProc <- sEddyProc$new(
      config$Metadata$siteID,
      data_REddyProc,
      c(names(config$REddyProc$vars_in),'Year','DoY','Hour')) 
      
    EProc$sSetLocationInfo(LatDeg = config$Metadata$lat, 
                          LongDeg = config$Metadata$long,
                          TimeZoneHour = config$Metadata$TimeZoneHour)

    if (config$REddyProc$Ustar_filtering$run_defaults){
      EProc$sEstimateUstarScenarios()
    } else {
       EProc$sEstimateUstarScenarios( 
        nSample = config$REddyProc$Ustar_filtering$samples,
        probs = seq(
          config$REddyProc$Ustar_filtering$min,
          config$REddyProc$Ustar_filtering$max,
          length.out = config$REddyProc$Ustar_filtering$steps)
          )
    }
    
    # Simple MDS for non-Ustar dependent variables
    MDS_basic <- unlist(strsplit(config$REddyProc$MDSGapFill$basic, ","))
    MDS_basic <- (MDS_basic[MDS_basic %in% names(config$REddyProc$vars_in)])
    for (i in 1:length(MDS_basic)){
      EProc$sMDSGapFill(MDS_basic[i])
    }

    # MDS for Ustar dependent variables
    MDS_Ustar <- unlist(strsplit(config$REddyProc$MDSGapFill$UStarScens, ","))
    MDS_Ustar <- (MDS_Ustar[MDS_Ustar %in% names(config$REddyProc$vars_in)])
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

    FilledEddyData = dplyr::bind_cols(
      data_in,FilledEddyData
      )
    return(FilledEddyData)
}

RF_GapFilling <- function(data_in){
    
    # Read function for RF gap-filling data
    p <- sapply(list.files(pattern="RandomForestModel.R", path=config$fx_path, full.names=TRUE), source)

    fill_names <- names(config$RF_GapFilling)
    if (!is.null(fill_names)){
        for (i in 1:length(fill_names)){
            var_dep <- unlist(config$RF_GapFilling[[fill_names[i]]]$var_dep)
            predictors <- unlist(strsplit(config$RF_GapFilling[[fill_names[i]]]$Predictors, split = ","))
            vars_in <- c(var_dep,predictors,"DateTime","DoY")
            gap_filled <- RandomForestModel(
                data_in[,vars_in],fill_names[i])
            data_out = dplyr::bind_cols(
                data_in,gap_filled
                )
        }
        return(data_out)
    }else {
       return(data_in)
    }
    
}

write_traces <- function(data){
    yrs <- config$yrs 
    siteID <- config$Metadata$siteID
    level_in <- config$Database$Paths$SecondStage
    level_out <- config$Database$Paths$ThirdStage
    tv_input <- config$Database$datenum$filename
    db_root <- config$Database$db_root

    for (j in 1:length(yrs)){
        # Create new directory, or clear existing directory
        out_path <- file.path(db_root,as.character(yrs[j]),siteID,level_out) 
        dir.create(out_path, showWarnings = FALSE)
        unlink(file.path(out_path,'*'))

        # Copy tv from stage 2 to 3 ... maybe not as "safe" as recalculating it from timestamp?
        file.copy(
        file.path(db_root,as.character(yrs[j]),siteID,level_in,tv_input),
        file.path(db_root,as.character(yrs[j]),siteID,level_out,tv_input))
        
        ind_s <- which(data$Year == yrs[j] & data$DoY == 1 & data$Hour == 0.5)
        ind_e <- which(data$Year == yrs[j]+1 & data$DoY == 1 & data$Hour == 0)
        ind <- seq(ind_s,ind_e)

        # Dumping everything by default into stage 3
        # Can parse down later as desired
        cols_out <- colnames(data)
        cols_out <- cols_out[! cols_out %in% c("DateTime","Year","DoY","Hour")]
        setwd(out_path)
        for (i in 1:length(cols_out)){
        writeBin(as.numeric(data[ind,i]), cols_out[i], size = 4)
        }
    }
  
}

start.time <- Sys.time()


config <- configure() # Load configuration file

input_data <- read_traces() # Read Stage 2 Data

FilledEddyData <- ThirdStage_REddyProc(input_data) # Run REddyProc

FilledEddyData <- RF_GapFilling(FilledEddyData)

write_traces(FilledEddyData) # Write Stage 3 Data

end.time <- Sys.time()
print('Stage 3 Complete, total run time:')
print(end.time - start.time)