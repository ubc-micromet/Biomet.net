# Written to gap fill and partition Ameriflux data
# By Sarah Russell, Sara Knox
# March 8, 2023

# Inputs
# data = dataframe returned from Load_Ameriflux.R function
# site = site name or code (character)
# lat = site latitude (e.g. 49.088651)
# lon = site longitude (e.g. -122.894948)
# Ustar_scenario = full, fast, or none (character, required)
# TimeZoneHour = 
#______
filepath = "~/Documents/PhD_Thesis/Chapter1/Site_Data/DSM/CA-DSM_HH_202101010000_202201010000.csv"
data <- Load_Ameriflux(filepath)


Ameriflux_ReddyProc <- function(data, site, lat, lon, Ustar_scenario, TimeZoneHour) {
  
      # Load libraries
      library("REddyProc")
      library("mlegp")
      require("dplyr")
      require("lubridate")
  
      # Output folder name for REddyProc and random forest output 
      level_REddyProc_Full <- 'ThirdStage_REddyProc_RF_Full'
      level_REddyProc_Fast <- 'ThirdStage_REddyProc_RF_Fast'
  
      # Folder where stage three variables should be save
      level_out <- "Clean/ThirdStage"
      
      # Following "https://cran.r-project.org/web/packages/REddyProc/vignettes/useCase.html" This is more up to date than the Wutzler et al. paper
      
      #+++ Add time stamp in POSIX time format
      EddyDataWithPosix <- fConvertTimeToPosix(data, 'YDH', Year = 'Year',Day = 'DoY', Hour = 'Hour') 
      
      #+++ Initalize R5 reference class sEddyProc for post-processing of eddy data
      #+++ with the variables needed for post-processing later
      EProc <- sEddyProc$new(site, EddyDataWithPosix, c('NEE','FC','LE','H','FCH4','Rg','Tair','VPD', 'Ustar')) 
      
      # Here we only use three ustar scenarios - for full uncertainty estimates, use the UNCERTAINTY SCRIPT (or full vs. fast run - as an option in ini)
      if (Ustar_scenario == 'full') { 
        nScen <- 39
        EProc$sEstimateUstarScenarios( 
          nSample = nScen*4, probs = seq(0.025,0.975,length.out = nScen) )
        uStarSuffixes <- colnames(EProc$sGetUstarScenarios())[-1]
        uStarSuffixes
        
      } else if (Ustar_scenario == 'fast') { 
        EProc$sEstimateUstarScenarios(
          nSample = 100L, probs = c(0.05, 0.5, 0.95))
        EProc$sGetEstimatedUstarThresholdDistribution()
      }
      
      # The subsequent post processing steps will be repeated using the four u∗ threshold scenarios (non-resampled and three quantiles of the bootstrapped distribution).
      #EProc$sGetUstarScenarios() -> print output if needed
      #EProc$sPlotNEEVersusUStarForSeason() -> save plot if needed
      
      # Gap-filling
      EProc$sMDSGapFillUStarScens('NEE')
      EProc$sMDSGapFillUStarScens('FC')
      EProc$sMDSGapFillUStarScens('LE')
      EProc$sMDSGapFillUStarScens('H')
      EProc$sMDSGapFillUStarScens('FCH4')
      
      # "_f" denotes the filled value and "_fsd" the estimated standard deviation of its uncertainty.
      # grep("NEE_.*_f$",names(EProc$sExportResults()), value = TRUE) -> print output if needed
      # grep("NEE_.*_fsd$",names(EProc$sExportResults()), value = TRUE) -> print output if needed
      # EProc$sPlotFingerprintY('NEE_U50_f', Year = 2022) -> view plot if needed
      
      # Partitioning
      EProc$sSetLocationInfo(LatDeg = lat, LongDeg = lon, TimeZoneHour = TimeZoneHour)
      EProc$sMDSGapFill('Tair', FillAll = FALSE,  minNWarnRunLength = NA)
      EProc$sMDSGapFill('VPD', FillAll = FALSE,  minNWarnRunLength = NA)
      #EProc$sFillVPDFromDew() # fill longer gaps still present in VPD_f
      EProc$sMDSGapFill('Rg', FillAll = FALSE,  minNWarnRunLength = NA)
      
      # Nighttime
      EProc$sMRFluxPartitionUStarScens()
      # EProc$sPlotFingerprintY('GPP_U50_f', Year = 2022)  # -> view plot if needed
      
      # Daytime
      EProc$sGLFluxPartitionUStarScens()
      #EProc$sPlotFingerprintY('GPP_DT_U50', Year = 2022)
      # grep("GPP|Reco",names(EProc$sExportResults()), value = TRUE)
      
      # Create data frame for REddyProc output
      FilledEddyData <- EProc$sExportResults()
      
      # Delete uStar dulplicate columns since they are output for each gap-filled variables
      vars_remove <- c(colnames(FilledEddyData)[grepl('\\Thres.', names(FilledEddyData))],
                       colnames(FilledEddyData)[grepl('\\_fqc.', names(FilledEddyData))])
      FilledEddyData <- FilledEddyData[, -which(names(FilledEddyData) %in% vars_remove)]
      
      yrs <- unique(EddyDataWithPosix$Year)
      
      # Save data
      # Loop through each year and save each year individually
      for (j in 1:length(yrs)) {
        
        # indices corresponding to year of interest
        ind_s <- first(which(EddyDataWithPosix$Year == yrs[j]))
        ind_e <- last(which(EddyDataWithPosix$Year == yrs[j]))
        
        ind <- seq(ind_s,ind_e)
        
        # create new data frame with only variables of interest, and rename columns
        data_third_stage <- FilledEddyData[, which(names(FilledEddyData) %in% vars_third_stage_REddyProc)]
        data_third_stage <- data_third_stage[, vars_third_stage_REddyProc]
        colnames(data_third_stage) <- vars_names_third_stage
        
        for (i in 1:length(vars_names_third_stage)) {
          writeBin(as.numeric(data_third_stage[ind,i]), vars_names_third_stage[i], size = 4)
        }
      }

    
    # RF gap-filling for FCH4 (for now - add NEE, LE, H later)
    if (fill_RF_FCH4 == 1) {
      # Read function for RF gap-filling data
      p <- sapply(list.files(pattern="RF_gf.R", path=fx_path, full.names=TRUE), source)
      
      data_RF <- data.frame()
      # Loop through each year specified for the RF gap-filling and merge all years together
      for (j in 1:length(years_RF)) {
        
        # Load stage three data
        data_RF.now <- read_database(db_ini,years_RF[j],site,level_RF_FCH4,predictors_FCH4,tv_input,export)
        data_RF <- dplyr::bind_rows(data_RF,data_RF.now)
      }
      
      # Apply gap-filling function
      datetime <- data_RF$datetime
      gap_filled_FCH4 <- RF_gf(data_RF,predictors_FCH4[1],predictors_FCH4,plot_RF_results,datetime)
      
      # Save data for the years of interest (i.e., not years_RF). Note years_RF is used to allow us to years additional years for RF gap-filling
      # Loop through each year and save each year individually
      for (j in 1:length(yrs)) {
        
        # indices corresponding to year of interest
        ind_s <- which(year(gap_filled_FCH4$DateTime) == yrs[j] & yday(gap_filled_FCH4$DateTime) == 1 & hour(gap_filled_FCH4$DateTime) == 0 & minute(gap_filled_FCH4$DateTime) == 30)
        ind_e <- which(year(gap_filled_FCH4$DateTime) == yrs[j]+1 & yday(gap_filled_FCH4$DateTime) == 1 & hour(gap_filled_FCH4$DateTime) == 0 & minute(gap_filled_FCH4$DateTime) == 0)
        
        ind <- seq(ind_s,ind_e)
        
        # First save all RF output under REddyProc_RF
        
        if (Ustar_scenario == 'full') { 
          
          out_path <- paste(db_out,"/",as.character(yrs[j]),"/",site,"/",level_REddyProc_Full, sep = "")
          
          if (file.exists(out_path)){
            setwd(out_path)
          } else {
            dir.create(out_path)
            setwd(out_path)
          }
          
          var_names <- colnames(gap_filled_FCH4)
          for (i in 1:length(var_names)) {
            writeBin(as.numeric(gap_filled_FCH4[ind,i]), var_names[i], size = 4)
          }
          
        } else if (Ustar_scenario == 'fast') { 
          
          out_path <- paste(db_out,"/",as.character(yrs[j]),"/",site,"/",level_REddyProc_Fast, sep = "")
          
          if (file.exists(out_path)){
            setwd(out_path)
          } else {
            dir.create(out_path)
            setwd(out_path)
          }
          
          var_names <- colnames(gap_filled_FCH4)
          for (i in 1:length(var_names)) {
            writeBin(as.numeric(gap_filled_FCH4[ind,i]), var_names[i], size = 4)
          }
        }
        
        # Output variables to stage three
        out_path <- paste(db_out,"/",as.character(yrs[j]),"/",site,"/",level_out, sep = "")
        
        if (file.exists(out_path)){
          setwd(out_path)
        } else {
          dir.create(out_path)
          setwd(out_path)
        }
        
        # Save only RF filled FCH4 flux
        writeBin(as.numeric(gap_filled_FCH4[ind,1]), vars_third_stage_RF_FCH4, size = 4)
        
        # Copy over clean_tv to REddyProc_RF
        # set wd to third stage
        out_path <- paste(db_out,"/",as.character(yrs[j]),"/",site,"/",level_out, sep = "")
        
        if (file.exists(out_path)){
          setwd(out_path)
        } else {
          dir.create(out_path)
          setwd(out_path)
        }
        
      }
    }
  }