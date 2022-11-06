# Written by Sara Knox
# Aug 11, 2022

# Revisions
#
# Nov 6, 2022 (Zoran)
#   - changed what yearsToProcess means. Now the value of 2 means that 2 years of data will be 
#     processed (yearIn and yearIn-1)
# Nov 1, 2022 (Zoran)
#   - removed hard-coded years, Ustar_scenario and others


# --------- These lines should not need editing ----------------------------------------------------
# Grab the arguments from Run_ThirdStage_REddyProc call

if(length(commandArgs(trailingOnly = TRUE))==0){
  cat("\nIn: DSM_ThirdStage_ini:\nNo input parameters!\nUsing whatever is in args variable \n")
} else {
  # otherwise use the third argument to pass the path
  args 		<- commandArgs(trailingOnly = TRUE)
}    

pathSetIni   		<- args[2]

# load input arguments from pathInputArgs file
source(pathSetIni)

# Specify range of years to process
stYear <- yrs-yearsToProcess+1
edYear <- yrs
years_REddyProc <- c(stYear, edYear) # Specify the number of years to use in REddyProc ustar filtering, gap-filling and partitioning (use all by default)
years_RF <- c(stYear, edYear) # Specify the number of years to use in RF gap-filling (use all by default)
#--------------------------------------------------------------------------------------------


#============================================================================================
# Edit the following lines for each site:

# Specify variables of interest
vars <- c("NEE","FC","LE","H","FCH4","SW_IN_1_1_1","TA_1_1_1","RH_1_1_1","VPD_1_1_1","USTAR") 

# Specify time vector name
tv_input <- "clean_tv"

# Specify site location
lat <- -12.8314 # Site latitude
long <- -69.2836 # Site longitude
TimeZoneHour <- -8 # time offset (in PST) from UTC 

export <- 0 # 1 to save a csv file of the data, 0 otherwise

# Specify variables only relevant variables for input into REddyProc 
col_order <- c("year","DOY","HHMM","NEE","FC","LE","H","FCH4","SW_IN_1_1_1","TA_1_1_1","RH_1_1_1","VPD_1_1_1","USTAR")

# Specify variable names in REddyProc
var_names<-c('Year','DoY','Hour','NEE','FC','LE','H','FCH4','Rg','Tair','rH','VPD','Ustar')

#Note that units should be the following:
#UNITS<-list('-','-','-','umol_m-2_s-1','umol_m-2_s-1','Wm-2','Wm-2','nmol_m-2_s-1','Wm-2','degC','%','hPa','ms-1')

# Define variables to save in third stage
vars_third_stage_REddyProc <- c('GPP_uStar_f','GPP_DT_uStar','NEE_uStar_orig','NEE_uStar_f','FC_uStar_orig','FC_uStar_f','LE_uStar_orig','LE_uStar_f','H_uStar_orig','H_uStar_f','FCH4_uStar_orig','FCH4_uStar_f','Reco_uStar','Reco_DT_uStar')
vars_names_third_stage <- c('GPP_PI_F_NT','GPP_PI_F_DT','NEE','NEE_PI_F_MDS','FC','FC_PI_F_MDS','LE','LE_PI_F_MDS','H','H_PI_F_MDS','FCH4','FCH4_PI_F_MDS','Reco_PI_F_NT','Reco_PI_F_DT')

# Random Forest gap-filling
# Gap-filling FCH4 
fill_RF_FCH4 <- 1 # 0 (no) or 1 (yes) to fill FCH4 and long gaps with RF from Kim et al., 2019 GCB 
level_RF_FCH4 <- "clean/ThirdStage" # which folder you are loading variables from for RF gap-filling (not this should typically remain unchanged unless there's a specific reason to load data from another folder)

# variable we need for FCH4 gap-filling (if implementing)
# df includes FCH4 and predictor variables.
# FCH4 should be quality controlled. Other variables should be fully gap-filled (maybe gap-fill long gaps for CO2 fluxes first!! ADD LATER)
predictors_FCH4 <- c("FCH4", "USTAR","NEE_PI_F_MDS","LE_PI_F_MDS","H_PI_F_MDS","SW_IN_1_1_1","TA_1_1_1","TS_1",
                "RH_1_1_1","VPD_1_1_1","PA_1_1_1")
plot_RF_results <- 0
vars_third_stage_RF_FCH4 <- c('FCH4_PI_F_RF')

# Gap-filling long gaps with RF (add later!!)

# Variables to copy from Second to Third stage- see second stage ini file for variable description
# CHECK WHY 'COND_WATER_1_1_1' isn't working anymore
copy_vars <- c('clean_tv','TA_1_1_1','TA_1_2_1','RH_1_1_1','RH_1_2_1','VPD_1_1_1','PA_1_1_1','P_1_1_1','WS_1_1_1','WD_1_1_1',
               'wind_speed','wind_dir','DO_1_1_1','DOperc_1_1_1','WTD_1_1_1','ORP_1_1_1',
               'pH_1_1_1','TW_1_1_1','CO2','H2O','CH4','SW_IN_1_1_1','SW_OUT_1_1_1','LW_IN_1_1_1','LW_OUT_1_1_1',
               'NETRAD_1_1_1','ALB_1_1_1','PPFD_IN_1_1_1','PPFD_OUT_1_1_1','PPFD_IN_2_1_1','PPFD_DIF_1_1_1',
               'PRI_1_1_1','NDVI_1_1_1','TS_1','TS_2','TS_3','TS_4','G_1','USTAR','SLE','SH','SCH4','SC',
               'TKE','L','U_SIGMA','V_SIGMA','W_SIGMA','TAU','zdL')

# Add R functions to for: 'aerodynamic_resistance_momentum', 'aerodynamic_resistance_scalar','surface_conductance','specific_humidity'
