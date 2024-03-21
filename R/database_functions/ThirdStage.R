# Written by June Skeeter (March 2024)
# Intended to streamline third stage processing

## Need to add:
# Clear third stage folder before running
# copy clean_tv directly from second stage
# output procedures

# Load libraries
library("yaml")
library("REddyProc")
library("rlist")
require("dplyr")
require("lubridate")
require("data.table")

configure <- function(filename){
    config <- yaml.load_file(filename)
    # Read function for loading data
    p <- sapply(list.files(pattern="read_database.R", path=config$Database$fx_path, full.names=TRUE), source)
    # Read function for RF gap-filling data
    p <- sapply(list.files(pattern="RandomForestModel.R", path=config$Database$fx_path, full.names=TRUE), source)

    return(config)
}

read_traces <- function(config,yrs){
    siteID <- config$Metadata$siteID
    db_root <- config$Database$db_root
    data <- data.frame()

    # Copy files from second stage to third stage, takes everything by default
    # Can change behavior later if needed
    level_in <- config$Database$level_in
    for (j in 1:length(yrs)) {
        in_path <- file.path(db_root,as.character(yrs[j]),siteID,level_in)
        copy_vars <- list.files(in_path)
        copy_vars <- copy_vars[! copy_vars %in% c(config$Metadata$tv_input)]
        data.now <- read_database(db_root,yrs[j],siteID,level_in,copy_vars,config$Database$tv_input,0)
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

ThirdStage_REddyProc <- function(config,data_in) {
    
    # Rearrange data frame and only keep relevant variables for input into REddyProc
    data_REddyProc <- data_in[ , c(unlist(config$REddyProc$vars_in),"DateTime","Year","DoY","Hour")]
    # Rename column names to variable names in REddyProc
    colnames(data_REddyProc)<-c(names(config$REddyProc$vars_in),"DateTime","Year","DoY","Hour")

    # Old code had hardcoded storage calculations here.  Consensus on storage fluxes?

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

RF_GapFilling <- function(config,data_in){
    fill_names <- names(config$RF_GapFilling)
    if (!is.null(fill_names)){
        for (i in 1:length(fill)){
            var_dep <- unlist(config$RF_GapFilling[[fill_names[i]]]$var_dep)
            predictors <- unlist(strsplit(config$RF_GapFilling[[fill_names[i]]]$Predictors, split = ","))
            vars_in <- c(var_dep,predictors,"DateTime","DoY")
            gap_filled <- RandomForestModel(
                data_in[,vars_in],fill_names[i])
            FilledEddyData = dplyr::bind_cols(
                data_in,gap_filled
                )
        }
        return(FilledEddyData)
    }else {
       return(data_in)
    }
    
}

write_traces <- function(config,data){
    yrs <- sort(unique(data$Year)) 
    siteID <- config$Metadata$siteID
    level_in <- config$Database$level_in
    level_out <- config$Database$level_out
    tv_input <- config$Database$tv_input
    db_root <- config$Database$db_root

    for (j in 1:(length(yrs)-1)){
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

# Define run (some of this e.g., root, can be defined from a global ini file)
root <- "C:/Database/Calculation_Procedures/TraceAnalysis_ini"
siteID <- "BBS"
StartYear <- 2023
EndYear <- 2024
fn <- sprintf('%s_ThirdStage.yml',siteID)
config_file <- file.path(root,siteID,fn)
args <- c(config_file,StartYear,EndYear)

yrs <- c(args[2]:args[length(args)])

config <- configure(args[1]) # Load configuration file

input_data <- read_traces(config,yrs) # Read Stage 2 Data

FilledEddyData <- ThirdStage_REddyProc(config,input_data) # Run REddyProc

FilledEddyData <- RF_GapFilling(config,FilledEddyData)

write_traces(config,FilledEddyData) # Write Stage 3 Data

end.time <- Sys.time()
print('Stage 3 Complete, total run time:')
print(end.time - start.time)

# args <- c("C:/Database/Calculation_Procedures/TraceAnalysis_ini/BBS/BBS_ThirdStage.ini",2023,2024)
# source("C:/Biomet.net/R/database_functions/ThirdStage.R")
