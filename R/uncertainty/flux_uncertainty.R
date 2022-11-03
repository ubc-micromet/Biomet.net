# Written to calculate uncertainty for fluxes for annual sums
# Based on 'Aggregating uncertainty to daily and annual values' (see: https://github.com/bgctw/REddyProc/blob/master/vignettes/aggUncertainty.md)
# By Sara Knox
# Aug 26, 2022

# NOTES:
# 1) Could create as a function
# 2) Generalize to loop over years
# 3) Add daytime partitioning

# Make sure to create ini file first

# Load required libraries
library("dplyr")
library("lubridate")
library("plotly")
# Run ini file first 

# Read function for loading data
p <- sapply(list.files(pattern="read_database.R", path=fx_path, full.names=TRUE), source)

# Loop through each year
df <- data.frame()
for (j in 1:length(yrs)) {
  
  # Create data frame for years & variables of interest to import into REddyProc
  df.now <- load.export.data(basepath,yrs[j],site,level_in,vars,tv_input,export)
  df <- dplyr::bind_rows(df,df.now)
}

# LOOP OVER YEARS
start_ind <- which(df$datetime==start_dates[1])+1 #+1 added to start at 30 min 
end_ind <- which(df$datetime==end_dates[1])
data <- df[c(start_ind:end_ind), ]

# NEE uncertainty

# Random error
# Considering correlations

# REddyProc flags filled data with poor gap-filling by a quality flag in NEE_<uStar>_fqc > 0 but still reports the fluxes. 
# For aggregation we recommend computing the mean including those gap-filled records, i.e. using NEE_<uStar>_f instead of NEE_orig. 
# However, for estimating the uncertainty of the aggregated value, the the gap-filled records should not contribute to the reduction of uncertainty due to more replicates.
# Hence, first we create a column 'NEE_orig_sd' similar to 'NEE_uStar_fsd' but where the estimated uncertainty is set to missing for the gap-filled records.
data <- data %>% 
  mutate(
    NEE_orig_sd = ifelse(
      is.finite(NEE_uStar_orig), NEE_uStar_fsd, NA), # NEE_orig_sd includes NEE_uStar_fsd only for measured values
    NEE_uStar_fgood = ifelse(
      NEE_uStar_fqc <= 1, is.finite(NEE_uStar_f), NA), # Only include filled values for the most reliable gap-filled observations. Note that is.finite() shouldn't be used here.
    resid = ifelse(NEE_uStar_fqc == 0, NEE_uStar_orig - NEE_uStar_fall, NA)) # quantify the error terms, i.e. model-data residuals (only using observations and exclude also
    # "good" gap-filled data)
# plot_ly(data = data, x = ~datetime, y = ~NEE_uStar_f, name = 'filled', type = 'scatter', mode = 'markers',marker = list(size = 3)) %>%
#   add_trace(data = data, x = ~datetime, y = ~NEE_uStar_orig, name = 'orig', mode = 'markers') %>% 
#   toWebGL()

# visualizing data
plot_ly(data = data, x = ~datetime, y = ~NEE_U2.5_orig, name = 'U2.5', type = 'scatter', mode = 'markers',marker = list(size = 3)) %>%
   add_trace(data = data, x = ~datetime, y =~NEE_uStar_orig, name = 'uStar', mode = 'markers') %>% 
   add_trace(data = data, x = ~datetime, y =~NEE_U97.5_orig, name = 'U97.5', mode = 'markers') %>% 
   toWebGL()

plot_ly(data = data, x = ~datetime, y = ~NEE_U2.5_fall, name = 'U2.5 fall', type = 'scatter', mode = 'markers',marker = list(size = 3)) %>%
  #add_trace(data = data, x = ~datetime, y =~NEE_U2.5_fall, name = 'U2.5 fall', mode = 'markers') %>% 
  #add_trace(data = data, x = ~datetime, y =~NEE_uStar_f, name = 'uStar fill', mode = 'markers') %>% 
  #add_trace(data = data, x = ~datetime, y =~NEE_uStar_fall, name = 'uStar fall', mode = 'markers') %>% 
  #add_trace(data = data, x = ~datetime, y =~NEE_U97.5_f, name = 'U97.5 fill', mode = 'markers') %>% 
  add_trace(data = data, x = ~datetime, y =~NEE_U97.5_fall, name = 'U97.5 fall', mode = 'markers') %>% 
  add_trace(data = data, x = ~datetime, y =~NEE_uStar_orig, name = 'uStar orig', mode = 'markers',marker = list(size = 5)) %>% 
  toWebGL()

autoCorr <- lognorm::computeEffectiveAutoCorr(data$resid)
nEff <- lognorm::computeEffectiveNumObs(data$resid, na.rm = TRUE)
c(nEff = nEff, nObs = sum(is.finite(data$resid))) 

# Note, how we used NEE_uStar_f for computing the mean, but NEE_orig_sd instead of NEE_uStar_fsd for computing the uncertainty.
resRand <- data %>% summarise(
  nRec = sum(is.finite(NEE_orig_sd))
  , NEEagg = mean(NEE_uStar_f, na.rm = TRUE)
  , varMean = sum(NEE_orig_sd^2, na.rm = TRUE) / nRec / (!!nEff - 1)
  , sdMean = sqrt(varMean) 
  , sdMeanApprox = mean(NEE_orig_sd, na.rm = TRUE) / sqrt(!!nEff - 1)
) %>% select(NEEagg, sdMean, sdMeanApprox)

# can also compute Daily aggregation -> but not done here.

# u* threshold uncertainty
ind <- which(grepl("NEE_U*", names(data)) & grepl("_f$", names(data)))
column_name <- names(data)[ind] 

#calculate column means of specific columns
NEEagg <- colMeans(data[ ,column_name], na.rm=T)

#compute uncertainty across aggregated values
sdNEEagg_ustar <- sd(NEEagg)

# Combined aggregated uncertainty

#Assuming that the uncertainty due to unknown u*threshold is independent from the random uncertainty, the variances add.
NEE_sdAnnual <- data.frame(
  sd_NEE_Rand = resRand$sdMean,
  sd_NEE_Ustar = sdNEEagg_ustar,
  sd_NEE_Comb = sqrt(resRand$sdMean^2 + sdNEEagg_ustar^2) 
)

data.mean_NEE_uStar_f <- data.frame(mean(data$NEE_uStar_f, na.rm = TRUE))
colnames(data.mean_NEE_uStar_f) <- 'mean_NEE_uStar_f'
NEE_sdAnnual <- cbind(data.mean_NEE_uStar_f,NEE_sdAnnual)

# GPP uncertainty (only u* for now) - Night time for now
# u* threshold uncertainty
ind <- which(grepl("GPP_U*", names(data)) & grepl("_f$", names(data)))
column_name <- names(data)[ind] 

#calculate column means of specific columns
GPPagg <- colMeans(data[ ,column_name], na.rm=T)

#compute uncertainty across aggregated values
sd_GPP_Ustar <- sd(GPPagg)
sd_GPP_Ustar <- data.frame(sd_GPP_Ustar)

# Reco uncertainty (only u* for now) - night time for now
# Rename column names to compute uncertainty
col_indx <- grep(pattern = '^Reco_U.*', names(data))
for (i in 1:length(col_indx)) {
  colnames(data)[col_indx[i]] <-
    paste(colnames(data)[col_indx[i]], "_f", sep = "")
}

ind <- which(grepl("Reco_U*", names(data)) & grepl("_f$", names(data)))
column_name <- names(data)[ind] 

#calculate column means of specific columns
Recoagg <- colMeans(data[ ,column_name], na.rm=T)

#compute uncertainty across aggregated values
sd_Reco_Ustar <- sd(Recoagg)
sd_Reco_Ustar <- data.frame(sd_Reco_Ustar)

# Create output data frame
mean_sdAnnual <- NEE_sdAnnual %>%
  mutate(mean_GPP_uStar_f = mean(data$GPP_uStar_f, na.rm = TRUE),
         sd_GPP_Ustar = sd_GPP_Ustar,
         mean_Reco_uStar_f = mean(data$Reco_uStar, na.rm = TRUE),
         sd_Reco_Ustar = sd_Reco_Ustar)
mean_sdAnnual

# Convert to annual sums
conv_gCO2 <- 1/(10^6)*44.01*60*60*24*length(data$NEE_uStar_f)/48 # Converts umol to mol, mol to gCO2, x seconds in a year
conv_gC <- 1/(10^6)*12.011*60*60*24*length(data$NEE_uStar_f)/48 # Converts umol to mol, mol to gCO2, x seconds in a year

# g CO2
mean_sdAnnual_gCO2 <- mean_sdAnnual*conv_gCO2
mean_sdAnnual_gCO2

# g C
mean_sdAnnual_gC <- mean_sdAnnual*conv_gC
mean_sdAnnual_gC
