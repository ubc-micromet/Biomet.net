# # Figure for plotting Long-term trend or step change
# # By Sara Knox
# # November 7, 2022
# 
# # Input
# # data = dataframe with relevant variables
# # var_radiation = variables from net radiometer (e.g., c("SW_IN_1_1_1","PPFD_IN_1_1_1")).
# #                  note that SW_IN and PPFD_IN should always be listed as variables 1 and 2, respectively
#
# p_net <- plot_ly(data = data, x = ~datetime, y = as.formula(paste0("~",var_NETRAD)), type = 'scatter', mode = 'lines',name = var_NETRAD)%>%
#  layout(yaxis = list(title = yaxlabel[2])) %>%
#  toWebGL() 

# # Long-term trend or step change
# p.SW_IN<- ggplot() +
#   geom_point(data = data, aes(x = datetime, y = as.formula("SW_IN_1_1_1"),color = 'Grey',size = 0.1)
# 
# p.PPFD_IN <- ggplot() +
#   geom_point(data = data, aes(x = datetime, y = "PPFD_IN_1_1_1"),color = 'Grey',size = 0.1)
# 
# p <- grid.arrange(p.SW_IN, p.PPFD_IN, # Second row with 2 plots in 2 different columns
#              nrow = 2)                       # Number of rows
# 
# # Specify variables to keep
# data_keep_columns <- c("year","SW_IN_1_1_1", "PPFD_IN_1_1_1")
# 
# df_subset <- data[ ,colnames(data) %in% data_keep_columns]  # Extract columns from data
# df <- na.omit(df_subset) # renove NA values
# 
# data.by.year.R2 <- df %>%
#   group_by(year) %>%
#   dplyr::summarize(R2 = cor(SW_IN_1_1_1, PPFD_IN_1_1_1)^2)
# 
# data.by.year.slope <- df %>%
#   group_by(year) %>% # You can add here additional grouping variables if your real data set enables it
#   do(mod = lm(SW_IN_1_1_1 ~ PPFD_IN_1_1_1, data = .)) %>%
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