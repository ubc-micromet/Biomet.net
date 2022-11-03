# This is our external R script for the analyses being called in the R markdown file

## @knitr LoadData

# Load data
opts_knit$set(root.dir = "/Users/sara/Code/MLABcode/data_visualization") # Specify directory

basepath <- "/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/database"
yrs <- c(2021:2022)
site <- "DSM"
level <- c("Flux/clean","Met/clean")
vars <- c("WD_1_1_1","wind_dir","WS_1_1_1","wind_speed","USTAR","pitch","w_var",
          "ts","TA_1_1_1","air_temperature","air_t_mean","RH_1_1_1","RH","e","es","es",
          "SW_IN_1_1_1","SW_OUT_1_1_1","LW_IN_1_1_1","LW_OUT_1_1_1","NETRAD_1_1_1","PPFD_IN_1_1_1","PPFD_OUT_1_1_1",
          "air_pressure","air_p_mean","PA_1_1_1",
          "P_1_1_1","G_1_1_1","G_2_1_1","G_3_1_1",
          "TW_1_1_1","TS_1_1_1","TS_1_2_1","TS_1_3_1","TS_1_4_1",
          "TS_2_1_1","TS_2_2_1","TS_2_3_1","TS_2_4_1")
tv_input <- "clean_tv"

export <- 0 # 1 to save a csv file of the data, 0 otherwise

# Create dataframe for years & variables of interest
# Path to function to load data
source("/Users/sara/Code/MLABcode/database_functions/read_database.R")
data1 <- load.export.data(basepath,yrs,site,level,vars,tv_input,export)

# Load traces just for plotting that aren't in clean
basepath <- "/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/database" # Quite slow running through 
level <- c("Flux")
vars_other <- c("air_temperature","air_t_mean","RH","air_pressure")
tv_input <- "Clean_tv"
data2 <- load.export.data(basepath,yrs,site,level,vars_other,tv_input,export)

# Merge dataframes
data <- merge(data1,data2, by=c("datetime"))

if (sum(which(vars %in% colnames(df) == FALSE)) > 0) {
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

# Specify end date - usually today's date
inde <- which(Sys.Date() == data$datetime)
data <- data[c(1:inde), ]

# Create year & DOY column
data$year <- year(data$datetime)
data$DOY <- yday(data$datetime)

# # Remove empty columns for the end of the year (and start in some cases)
# ind <- !is.nan(data$year)
# data <- data[ind, ]

# Path to plotting functions
data_visualization_path <- "/Users/sara/Code/MLABcode/data_visualization"
p <- sapply(list.files(pattern="[.]R$", path=data_visualization_path, full.names=TRUE), source)

# Specify variables for sonic_plots.R
vars_WS <- c("wind_speed","WS_1_1_1") # Include sonic wind speed first
vars_WD <- c("wind_dir","WD_1_1_1")
vars_other_sonic <- c("USTAR","pitch") # include u* first
units_other_sonic <- c("m/s","degrees")
pitch_ind <- 2

# Specify other sonic variables
wind_variance <- "w_var" # If using all variances, make sure w_var is first

data$W_SIGMA <- sqrt(data$w_var)
wind_std <- "W_SIGMA"

# Specify variables for temp_RH_data_plotting.R

# Temperature variables
# Make sure that all temperature variables are in the same units (e.g., Celsius)
#data$sonic_temperature_C <- data$sonic_temperature-273.15
data$air_t_mean_C <- data$air_t_mean-273.15
# Filter air_t_mean_C
data$air_t_mean_C[(data$air_t_mean_C>60 | data$air_t_mean_C< -60) & !is.na(data$air_t_mean_C)] <- NA
data$air_temperature_C <- data$air_temperature-273.15

# Now specify variables
vars_temp <- c("TA_1_1_1","air_t_mean_C") # Order should be HMP, sonic temperature, 7700 temperature (NOTE - make sure to include sonic temperature!!) - c("AIR_TEMP_2M","sonic_temperature_C","air_t_mean_C")

# RH variables

# Now specify variables
vars_RH <- c("RH_1_1_1","RH") # Order should be HMP then 7200 (CONFIRM SENSORS!)

# Radiation variables
vars_radiometer <- c("SW_IN_1_1_1","SW_OUT_1_1_1","LW_IN_1_1_1","LW_OUT_1_1_1") # note that SW_IN and SW_OUT should always be listed as variables 1 and 2, respectively
vars_NETRAD <- "NETRAD_1_1_1"
vars_PPFD <- c("PPFD_IN_1_1_1","PPFD_OUT_1_1_1") #Note incoming PAR should always be listed first.

# Calculate potential radiation
# define the standard meridian for DSM
Standard_meridian <- -120

# Define long/lat
long <- -122.8942
Lat <- 49.0886

# Path to function to load data
source("/Users/sara/Code/MLABcode/data_visualization/potential_rad_generalized.R")

data$potential_radiation <- potential_rad(Standard_meridian,long,Lat,data$datetime,data$DOY)
data$potential_radiation[is.na(data$SW_IN_1_1_1)] <- NA
var_potential_rad <- "potential_radiation"

# Compute mean diurnal pattern for 15 day moving window
source("/Users/sara/Code/MLABcode/data_visualization/diurnal_composite_moving_window.R")
diurnal.composite <- diurnal.composite(data$datetime,data$potential_radiation,data$SW_IN_1_1_1,15,48)

diurnal.composite <- diurnal.composite[is.finite(diurnal.composite$potential_radiation), ]

# # Plot diurnal pattern with moving window
# source("/Users/sara/Code/MLABcode/diurnal_pattern_moving_window.R")
# diurnal.summary <- diurnal.summary(data$datetime, data$SHFP_1, 30, 48)
# diurnal.summary.composite <- diurnal.summary %>%
#   group_by(firstdate,HHMM) %>%
#   dplyr::summarize(var = median(var, na.rm = TRUE),
#                    HHMM = first(HHMM))
# diurnal.summary.composite$time <- as.POSIXct(as.character(diurnal.summary.composite$HHMM), format="%R", tz="UTC")
#
# p <- ggplot() +
#   geom_point(data = diurnal.summary, aes(x = time, y = var),color = 'Grey',size = 0.1) +
#   geom_line(data = diurnal.summary.composite, aes(x = time, y = var),color = 'Black') +
#   scale_x_datetime(breaks="6 hours", date_labels = "%R")
#
# p <- ggplotly(p+ facet_wrap(~as.factor(firstdate))) %>% toWebGL()
# p

# # Long-term trend or step change
# p.SW_IN<- ggplot() +
#   geom_point(data = data, aes(x = datetime, y = SHORTWAVE_IN),color = 'Grey',size = 0.1)
#
# p.PPFD_IN <- ggplot() +
#   geom_point(data = data, aes(x = datetime, y = INCOMING_PAR),color = 'Grey',size = 0.1)
#
# p <- grid.arrange(p.SW_IN, p.PPFD_IN, # Second row with 2 plots in 2 different columns
#              nrow = 2)                       # Number of rows
#
# # Specify variables to keep
# data_keep_columns <- c("year","SHORTWAVE_IN", "INCOMING_PAR")
#
# df_subset <- data[ ,colnames(data) %in% data_keep_columns]  # Extract columns from data
# df <- na.omit(df_subset) # renove NA values
#
# data.by.year.R2 <- df %>%
#   group_by(year) %>%
#   dplyr::summarize(R2 = cor(SHORTWAVE_IN, INCOMING_PAR)^2)
#
# data.by.year.slope <- df %>%
#   group_by(year) %>% # You can add here additional grouping variables if your real data set enables it
#   do(mod = lm(SHORTWAVE_IN ~ INCOMING_PAR, data = .)) %>%
#   mutate(slope = summary(mod)$coeff[2]) %>%
#   select(-mod)
#
# data.by.year <- merge(data.by.year.R2,data.by.year.slope,by="year")
#
# # Create plot of timeseries of R2 and slope
# multivariate_comparison_trend(data.by.year)
#
# # Plot data availability
# plot_datayear(data)

# Pressure variables
# Make sure that all pressure variables are in the same units (e.g., kPa)
data$air_pressure_kPa <- data$air_pressure/1000
data$air_p_mean_kPa <- data$air_p_mean/1000

#vars_pressure <- c("air_pressure_kPa","air_p_mean_kPa","PA_1_5M","PA_EC_AIR2_5M") # note that 

# Precip variables
precip <- "PRECIP"

# Soil heat flux
vars_G <- c("G_1_1_1","G_2_1_1","G_3_1_1")

# Volumetric water content
#vars_VWC <- "SVWC"

# Water and soil temperature variables - note go with decreasing height/depth from highest measurement
#vars_TS <- c("WATER_TEMP_3_5CM","WATER_TEMP_2_5CM","WATER_TEMP_3_5CM",
#                    "SOIL_TEMP_1_5CM","SOIL_TEMP_1_10CM","SOIL_TEMP_1_30CM","SOIL_TEMP_1_50CM",
#                    "SOIL_TEMP_2_5CM","SOIL_TEMP_2_10CM","SOIL_TEMP_2_30CM","SOIL_TEMP_2_50CM",
#                    "SOIL_TEMP_3_5CM","SOIL_TEMP_3_10CM","SOIL_TEMP_3_30CM","SOIL_TEMP_3_50CM") 

# Specify variables for Additional meteorological variables output
#var_other <- list(as.list(vars_G),as.list(vars_TS))
#yaxlabel_other <- c("G (W/m2)","Temperature (°C)")

var_other <- list(as.list(vars_G))
yaxlabel_other <- c("G (W/m2)")
