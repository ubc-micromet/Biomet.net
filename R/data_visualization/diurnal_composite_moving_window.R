# Script for calculating composite of diurnal patterns over a fixed moving window
# By Sara Knox
# June 27, 2022

# Input
# datetime = date in format e.g., "2019-12-12 08:00:00 UTC"
# potential_radiation = potential radiation calculated using the function potential_rad.R
# SW_IN = incoming shortwave radiation
# PAR_IN = incoming PAR !!ADD!!
# width = width of moving windows in days
# ts = timestep (i.e., 48 half hour observations per day)

# Loop through data frame to create mean diurnal patter for a 15 day moving average
diurnal.composite <- function(datetime,potential_radiation,SW_IN,width,ts){
  
  # Find index of first midnight time point
  istart <- first(which(hour(datetime) == 0 & minute(datetime) == 0))
  iend <- last(which(hour(datetime) == 23 & minute(datetime) == 30))
  
  df <- data.frame(datetime, potential_radiation, SW_IN)
  
  # Create new data frame starting from midnight and ending at 11:30pm
  df2 <- df[istart:iend, ]
  
  # Specify number of windows to loop through
  nwindows <- floor(nrow(df2)/width/ts)
  
  #setup empty dataframe
  diurnal.composite <- data.frame(matrix(ncol=4, nrow=0)) # CHANGE ncol to 5 once PAR_IN is added!!
  colnames(diurnal.composite)<- c("HHMM","potential_radiation","SW_IN","date")
  
  for (i in 1:nwindows){
    
    if (i == 1) {
      data.diurnal <- df2[1:(width*ts), ] %>%
        mutate(year = year(datetime),
               month = month(datetime),
               day = day(datetime),
               jday = yday(datetime),
               hour = hour(datetime),
               minute = minute(datetime),
               HHMM = format(as.POSIXct(datetime), format = "%H:%M")) %>%  # Create hour and minute variable (HHMM)
        group_by(HHMM) %>%
        dplyr::summarize(potential_radiation = max(potential_radiation, na.rm = TRUE),
                         SW_IN = max(SW_IN, na.rm = TRUE),
                         date = median(datetime))
      
      # Create a column for the same date for a given window (for plotting purposes)
      data.diurnal$firstdate <- last(format(as.POSIXct(data.diurnal$date ,format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d'))
      
      # Append to dataframe
      diurnal.composite <- rbind(diurnal.composite,data.diurnal)
      
    } else {
      data.diurnal <- df2[((i-1)*width*ts+1):(i*width*ts), ] %>%
        mutate(year = year(datetime),
               month = month(datetime),
               day = day(datetime),
               jday = yday(datetime),
               hour = hour(datetime),
               minute = minute(datetime),
               HHMM = format(as.POSIXct(datetime), format = "%H:%M")) %>%  # Create hour and minute variable (HHMM)
        group_by(HHMM) %>%
        dplyr::summarize(potential_radiation = max(potential_radiation, na.rm = TRUE),
                         SW_IN = max(SW_IN, na.rm = TRUE),
                         date = median(datetime))
      
      # Create a column for the same date for a given window (for plotting purposes)
      data.diurnal$firstdate <- last(format(as.POSIXct(data.diurnal$date ,format='%Y-%m-%d %H:%M:%S'),format='%Y-%m-%d'))
      
      # Append to dataframe
      diurnal.composite <- rbind(diurnal.composite,data.diurnal)
    }
  }
  
  # Find points where SW_IN > potential radiation
  diurnal.composite$exceeds <- diurnal.composite$SW_IN
  diurnal.composite$exceeds[which(diurnal.composite$SW_IN < diurnal.composite$potential_radiation)] <- NA
  
  # Create new time variable for plotting purposes
  diurnal.composite$time <- as.POSIXct(as.character(diurnal.composite$HHMM), format="%R", tz="UTC")
  
  return(diurnal.composite)
}

