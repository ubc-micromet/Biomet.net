# This is our external R script for the analyses being called in the R markdown file

## @knitr LoadData

# Load path info
#args <-c("/Users/sara/Code/Biomet.net/R/",
#         "/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/Database")

# load all necessary functions
#fx_path <- paste0(args[1],'data_visualization',sep ="")
p <- sapply(list.files(pattern="*.R$", full.names=TRUE), source)

# Load functions from 'database_functions' folder - UPDATE AS TO NOT DUPLICATE
source(paste0(args[1],"data_visualization/read_database.R",sep = ""))

# Load data
opts_knit$set(root.dir = paste0(args[1],"data_visualization",sep = "")) # Specify directory

basepath <- args[2]
#basepath <- paste0(args[1],"data_visualization/Database",sep = "")
yrs <- c(2021:2022) # Make sure to include the most recent year
site <- "YOUNG"

# Specify variables of interest in Clean/SecondStage and Flux/clean
level <- c("Clean/SecondStage","Flux/clean")
vars <- c("WD_1_1_1","wind_dir","WS_1_1_1","wind_speed","USTAR","W_SIGMA",
          "ts","TA_1_1_1","RH_1_1_1","e","es",
          "SW_IN_1_1_1","SW_OUT_1_1_1","LW_IN_1_1_1","LW_OUT_1_1_1","NETRAD_1_1_1","PPFD_IN_1_1_1","PA_1_1_1",
          "P_RAIN_1_1_1","TS_1_1_1","TS_2_1_1","TS_3_1_1","NEE","FC","H","LE","FCH4")
tv_input <- "clean_tv"

export <- 0 # 1 to save a csv file of the data, 0 otherwise

# Create dataframe for years & variables of interest
# Path to function to load data
data1 <- read_database(basepath,yrs,site,level,vars,tv_input,export)

# Load traces just for plotting that aren't in Clean
level <- c("Flux")
vars_other <- c("air_temperature","air_t_mean","RH","air_pressure","air_p_mean","pitch",
                "mean_value_RSSI_LI_7200","rssi_77_mean","file_records","used_records","sonic_temperature")  
tv_input <- "Clean_tv"
data2 <- read_database(basepath,yrs,site,level,vars_other,tv_input,export)

# Merge dataframes loaded above
data <- merge(data1,data2, by=c("datetime"))

if (sum(which(vars %in% colnames(data) == FALSE)) > 0) {
  cat("variables: ", vars[which(vars %in% colnames(data) == FALSE)],"are not included in the dataframe", sep="\n")
}

# Make sure there are no duplicate column names & stop script if there are duplicate names
duplicate <- !duplicated(colnames(data))
ind_duplicate <- which(duplicate==FALSE)

if(length(ind_duplicate) > 0) {
  stop("Make sure to remove duplicate columns names in data dataframe")    
}

# Remove missing data (should be -9999)
data <- replace(data, data == -9999, NA)

# Specify end date if using current year - usually today's date
inde <- which(Sys.Date() == data$datetime)

if (!identical(inde, integer(0))) {
  data <- data[c(1:inde), ] # Remove NaN for dates beyond today's date
} else {
  data <- data[1:nrow(data)-1, ] # Remove the last data point so that the last data point doesn't start the following year.
}

# Create year & DOY column
data$year <- year(data$datetime)
data$DOY <- yday(data$datetime)

# Load third stage fluxes (this needs to be loaded separately so that we can distinguish between the Second and Third stage data)
level <- c("Clean/ThirdStage")
vars_other <- c("NEE","FC","H","LE","FCH4","NEE_PI_F_MDS",
                "FC_PI_F_MDS","H_PI_F_MDS","LE_PI_F_MDS","FCH4_PI_F_MDS","NETRAD_1_1_1")
tv_input <- "clean_tv"
data_thirdstage <- read_database(basepath,yrs,site,level,vars_other,tv_input,export)

# Remove missing data (should be -9999)
data_thirdstage <- replace(data_thirdstage, data_thirdstage == -9999, NA)

# Specify end date - usually today's date
inde <- which(Sys.Date() == data_thirdstage$datetime)

if (!identical(inde, integer(0))) {
  data_thirdstage <- data_thirdstage[c(1:inde), ] # Remove NaN for dates beyond today's date
} else {
  data_thirdstage <- data_thirdstage[1:nrow(data_thirdstage)-1, ] # Remove the last data point so that the last data point doesn't start the following year.
}

# Create year & DOY column
data_thirdstage$year <- year(data_thirdstage$datetime)
data_thirdstage$DOY <- yday(data_thirdstage$datetime)

# Now specify variables for standard plots

# Specify variables for sonic_plots.R
vars_WS <- c("WS_1_1_1") # Include sonic wind speed first
vars_WD <- c("WD_1_1_1")
vars_other_sonic <- c("USTAR","pitch") # include u* first
units_other_sonic <- c("m/s","degrees")
pitch_ind <- 2

wind_std <- "W_SIGMA"

# Specify variables for temp_RH_data_plotting.R

# Temperature variables
# Make sure that all temperature variables are in the same units (e.g., Celsius)
data$sonic_temperature_C <- data$sonic_temperature-273.15
data$air_t_mean_C <- data$air_t_mean-273.15
# Filter air_t_mean_C
data$air_t_mean_C[(data$air_t_mean_C>60 | data$air_t_mean_C< -60) & !is.na(data$air_t_mean_C)] <- NA
data$air_temperature_C <- data$air_temperature-273.15

# Now specify variables
vars_temp <- c("TA_1_1_1","sonic_temperature_C","air_t_mean_C","air_temperature_C") # Order should be HMP, sonic temperature, 7700 temperature, 7550 temperature

# RH variables
vars_RH <- c("RH_1_1_1","RH") # Order should be HMP then 7200 (CONFIRM SENSORS!)

# Radiation variables
vars_radiometer <- c("SW_IN_1_1_1","SW_OUT_1_1_1","LW_IN_1_1_1","LW_OUT_1_1_1") # note that SW_IN and SW_OUT should always be listed as variables 1 and 2, respectively
vars_NETRAD <- "NETRAD_1_1_1"
vars_PPFD <- c("PPFD_IN_1_1_1") #Note incoming PAR should always be listed first if outgoing PAR is also measured

# Calculate potential radiation
# define the standard meridian for DSM
Standard_meridian <- -90

# Define long/lat
long <- -100.534947
Lat <- 50.370433

# Calculate potential radiation
data$potential_radiation <- potential_rad_generalized(Standard_meridian,long,Lat,data$datetime,data$DOY)
data$potential_radiation[is.na(data$SW_IN_1_1_1)] <- NA
var_potential_rad <- "potential_radiation"

# Pressure variables
# Make sure that all pressure variables are in the same units (e.g., kPa)
data$air_pressure_kPa <- data$air_pressure/1000
data$air_p_mean_kPa <- data$air_p_mean/1000
data$PA_1_1_1_kPa <- data$air_p_mean/1000

vars_pressure <- c("PA_1_1_1_kPa","air_pressure_kPa","air_p_mean_kPa") # Biomet PA should always go first, followed by EC PA  

flux_vars <- c("NEE","FC","H","LE","FCH4") # List flux variables to plot (to compare Second and Third stages)
flux_vars_gf <- c("NEE_PI_F_MDS","FC_PI_F_MDS","H_PI_F_MDS","LE_PI_F_MDS","FCH4_PI_F_MDS") # List flux variables to plot (to compare Second and Third stages)

vars_flux_diag <- c("mean_value_RSSI_LI_7200","rssi_77_mean","file_records","used_records") # This list should be consistent across all sites and the order should be the same

vars_EBC_AE <- "NETRAD_1_1_1" # Include all terms for available energy. it should always include net radiation. Other terms to include if available are G, and other key storage terms.
