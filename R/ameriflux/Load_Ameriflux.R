# Written to load in and format Ameriflux data for REddyPro NEE gap filling and partitioning
# By Sarah Russell, Sara Knox
# March 8, 2023

# INPUTS
# filepath = path to raw Ameriflux csv file, including filename (character)
# co2_var = NEE variable (default "CO2")
# fc_var = FC variable (default "FC")
# le_var = latent heat flux variable (default "LE")
# h_var = sensible heat flux variable (default "H")
# ch4_var = methane flux variable (default "FCH4", if no CH4 then "none")
# rg_var = incoming shortwave variable (default "SW_IN")
# tair_var = air temp variable (default "TA")
# tsoil_var = soil temp variable (default "TS")
# rh_var = relative humidity variable (default "RH")
# vpd_var = vapor pressure deficit variable (default "VPD")
# ustar_var = Ustar variable (default "USTAR")

# NOTES
# Delete rows above column header in Ameriflux file before running
# Change TIMESTAMP_START to TIMESTAMP, depending on the file

Load_Ameriflux <- function(filepath, co2_var, fc_var, le_var, h_var, ch4_var, rg_var, tair_var, tsoil_var, rh_var, vpd_var, ustar_var) {
  
  # Load libraries
  library("REddyProc")
  require("dplyr")
  require("lubridate")
  
  # Load raw Ameriflux file and separate TIMESTAMP variable
  data <- read.csv(filepath) %>%
    mutate(Year = substr(TIMESTAMP_START, 1, 4),
           Month = substr(TIMESTAMP_START, 5, 6),
           Day = substr(TIMESTAMP_START, 7, 8),
           Hour = substr(TIMESTAMP_START, 9, 10),
           Minute = substr(TIMESTAMP_START, 11, 12),
           Datetime = as.POSIXct(strptime(paste(Year, 
                                                Month, 
                                                Day, 
                                                paste(Hour, Minute, sep=":")), 
                                          format="%Y %m %d %H:%M")),
           DoY = yday(Datetime))
  
  # Create Hour as fractional hour (e.g., 13, 13.5, 14)
  min <- data$Minute
  min[which(min == 30)] <- 0.5
  data$Hour <- as.numeric(data$Hour)+as.numeric(min)
  
  # Function to supply default parameters if variable names not specified
  varnames <- function(x,y){
    if(missing(y)) {return(x)} else {return(y)}
  }
  
  # Check variable names and supply default if not specified
  co2_var <- varnames("CO2", co2_var)
  fc_var <- varnames("FC", fc_var)
  le_var <- varnames("LE", le_var)
  h_var <- varnames("H", h_var)
  rg_var <- varnames("SW_IN", rg_var)
  tair_var <- varnames("TA", tair_var)
  tsoil_var <- varnames("TS", tsoil_var)
  rh_var <- varnames("RH", rh_var)
  vpd_var <- varnames("VPD", vpd_var)
  ustar_var <- varnames("USTAR", ustar_var)
  
  # Rename variables
  data <- data %>%
    rename(NEE = co2_var,
           FC = fc_var,
           LE = le_var,
           H = h_var,
           Rg = rg_var,
           Tair = tair_var,
           Tsoil = tsoil_var,
           rH = rh_var,
           Ustar = ustar_var)
  
  # Check if VPD is in the raw Ameriflux file
  if (vpd_var %in% colnames(data)) {
    
    # Rename variables for post-processing
    data <- data %>%
      rename(VPD = vpd_var)
    
  } else {
    # Calculate VPD
    data$VPD <- fCalcVPDfromRHandTair(data$rH, data$Tair)
    
    # Remove calculated VPD if either RH or Tair are missing
    data$VPD[which(data$rH == -9999 | data$Tair == -9999)] <- NA
    
  }
  
  if (ch4_var=="none") { 
    
    #Select variables for post-processing, not including CH4
    data <- data %>%
      select(Year, DoY, Hour, NEE, FC, LE, H, Rg, Tair, Tsoil, rH, VPD, Ustar)
    
  } else {
    
    # Check CH4 variable name and supply default if not specified
    ch4_var <- varnames("FCH4", ch4_var)
    
    #Select variables for post-processing, including CH4
    data <- data %>%
      rename(FCH4 = ch4_var) %>%
      select(Year, DoY, Hour, NEE, FC, LE, H, FCH4, Rg, Tair, Tsoil, rH, VPD, Ustar)
    
  }
  
  # Transform missing values into NA
  data <- as.data.frame(sapply(data, function(x) replace(x, x==-9999, NA))) %>%
    #mutate all variables to numeric
    mutate_all(as.numeric)
  
  return(data)
  
}
