# Written to gap fill and partition Ameriflux data
# By Sara Knox, Sarah Russell
# March 8, 2023

# Inputs
# data = data frame returned from Load_Ameriflux.R function
# site = site name or code (character)
# lat = site latitude (e.g. 49.088651)
# lon = site longitude (e.g. -122.894948)
# Ustar_scenario = full, fast, or none (character, required)
# TimeZoneHour = site timezone (e.g. -8)
# filepath = path to directory where csv and bin files should be saved (character)
# fill_RF_FCH4 = gapfill CH4? (TRUE/FALSE)
# years_RF = years for CH4 gap filling (defaults to all years)
# fx_path = path to Biomet.net directory (only needed for CH4 gap filling)

#______
Ameriflux_ReddyProc <- function(data, site, lat, lon, Ustar_scenario, TimeZoneHour, filepath, fill_RF_FCH4, years_RF, fx_path) {
  
      # Load libraries
      library("REddyProc")
      library("mlegp")
      require("dplyr")
      require("lubridate")
  
      # Output folder name for REddyProc and random forest output 
      level_REddyProc_Full <- 'REddyProc_RF_Full'
      level_REddyProc_Fast <- 'REddyProc_RF_Fast'
      
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
      
      # Vector of years
      yrs <- unique(EddyDataWithPosix$Year)
      
      # Create new data frame with only variables of interest, and rename columns
      vars_third_stage_REddyProc <- c('GPP_uStar_f','GPP_DT_uStar','NEE_uStar_orig','NEE_uStar_f','FC_uStar_orig','FC_uStar_f','LE_uStar_orig','LE_uStar_f','H_uStar_orig','H_uStar_f','FCH4_uStar_orig','FCH4_uStar_f','Reco_uStar','Reco_DT_uStar')
      vars_names_third_stage <- c('GPP_PI_F_NT','GPP_PI_F_DT','NEE','NEE_PI_F_MDS','FC','FC_PI_F_MDS','LE','LE_PI_F_MDS','H','H_PI_F_MDS','FCH4','FCH4_PI_F_MDS','Reco_PI_F_NT','Reco_PI_F_DT')
      data_third_stage <- FilledEddyData[, which(names(FilledEddyData) %in% vars_third_stage_REddyProc)]
      data_third_stage <- data_third_stage[, vars_third_stage_REddyProc]
      colnames(data_third_stage) <- vars_names_third_stage
      data_third_stage$datetime <- EddyDataWithPosix$DateTime
      
      # Create folder for csv file if it doesn't exist
      out_path <- paste0(filepath,"/REddyProc_Output")
      if (file.exists(out_path)){
        setwd(out_path)
      } else {
        dir.create(out_path)
        setwd(out_path)
      }
      
      # Save csv with variables of interest data
      if (length(yrs)==1) {
        write.csv(data_third_stage, paste0(site, yrs[1], ".csv"), row.names=FALSE)
      } else {
        write.csv(data_third_stage, paste0(site, first(yrs), "_", last(yrs), ".csv"), row.names=FALSE)
      }
      
      for (j in 1:length(yrs)) {
        
        # indices corresponding to year of interest
        ind_s <- first(which(EddyDataWithPosix$Year == yrs[j]))
        ind_e <- last(which(EddyDataWithPosix$Year == yrs[j]))
        ind <- seq(ind_s,ind_e)
        
        if (Ustar_scenario == 'full') { 
          
          out_path <- paste(filepath,"/REddyProc_Output/",as.character(yrs[j]),"/",site,"/",level_REddyProc_Full, sep = "")
          
          if (file.exists(out_path)){
            setwd(out_path)
          } else {
            dir.create(out_path, recursive = TRUE)
            setwd(out_path)
          }
          
          var_names <- colnames(FilledEddyData)
          for (i in 1:length(var_names)) {
            writeBin(as.numeric(FilledEddyData[ind,i]), var_names[i], size = 4)
          }
          
        } else if (Ustar_scenario == 'fast') { 
          out_path <- paste(filepath,"/REddyProc_Output/",as.character(yrs[j]),"/",site,"/",level_REddyProc_Fast, sep = "")
          
          if (file.exists(out_path)){
            setwd(out_path)
          } else {
            dir.create(out_path, recursive = TRUE)
            setwd(out_path)
          }
          
          var_names <- colnames(FilledEddyData)
          for (i in 1:length(var_names)) {
            writeBin(as.numeric(FilledEddyData[ind,i]), var_names[i], size = 4)
          }
        }
        
      }
      
    # Check if CH4 gap filling years specified
    if (missing(years_RF)) { years_RF <- yrs }
      
    predictors_FCH4 <- c("FCH4", "USTAR","NEE_PI_F_MDS","LE_PI_F_MDS","H_PI_F_MDS","Rg","Tair","Tsoil",
                           "rH","VPD","PA")
    plot_RF_results <- 0
    vars_third_stage_RF_FCH4 <- c('FCH4_PI_F_RF')

    # RF gap-filling for FCH4 (for now - add NEE, LE, H later)
    if (fill_RF_FCH4 == TRUE) {
      
      # Read function for RF gap-filling data
      sapply(list.files(pattern="RF_gf.R", path=paste0(fx_path, "/R/database_functions"), full.names=TRUE), source)
      
      # Loop through each year specified for the RF gap-filling and merge all years together
      data_RF <- data.frame()
      for (j in 1:length(years_RF)) {
        
        #Create index list for specified years
        ind_s <- first(which(EddyDataWithPosix$Year == years_RF[j]))
        ind_e <- last(which(EddyDataWithPosix$Year == years_RF[j]))
        ind <- seq(ind_s,ind_e)
        
        # Load stage three data
        data_RF.now <- bind_cols(data[ind,c(8,14)],data_third_stage[ind,c(4,8,10)],data[ind,c(9:13,15)],data_third_stage[ind, 15])
        data_RF <- dplyr::bind_rows(data_RF,data_RF.now)
        
      }
      
      # Apply gap-filling function
      datetime <- data_RF[,12]
      # Rename variables so that they work with RF_gf.R
      data_RF <- data_RF %>%
        rename(USTAR = Ustar,
               datetime = 12)
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