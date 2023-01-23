# Figure for plotting flux diagnostics
# By Sara Knox
# Jan 22, 2023

# Input
# data = dataframe with relevant variables
# var_WS = wind speed variables (e.g., from sonic and cup anemometer - make sure sonic data is first)
# var_WD = wind direction variables (e.g., from sonic and cup anemometer)
# var = other sonic variables of interest (e.g., c("u_","pitch") - make sure u* is first)
# unit = units for variables defined in var (e.g., c("m/s","degrees"))
# pitch_ind = index for pitch (e.g., 2)
flux_diagnostic_plots <- function(data,vars_flux_diag){
  
  df <- data[,c("datetime",vars_flux_diag)]
  df[,vars_flux_diag[3]] <- df[,vars_flux_diag[3]]*60000 # Convert flow rate to L/min
  
  plots <- plot.new()
  
  # signal strengths
  yaxlabel <- "Signal strength"
  SS_plot <- plotly_loop(df,vars_flux_diag[1:2],yaxlabel)
  
  plots[[1]] <- SS_plot
  
  # flow rate
  yaxlabel <- "Flow rate (L/m)"
  FR_plot <- plot_ly(df, x = ~datetime, y = as.formula(paste0("~", vars_flux_diag[3]))) %>%
    add_lines(name = vars_flux_diag[3])%>% 
    layout(yaxis = list(title = vars_flux_diag[3],range = c(-1,20)))%>%
    toWebGL()
  
  plots[[2]] <- FR_plot
  
  # signal strengths
  yaxlabel <- "number of records"
  Rec_plot <- plotly_loop(df,vars_flux_diag[4:5],yaxlabel)
  
  plots[[3]] <- Rec_plot
  
  p <- subplot(plots, nrows = length(plots), shareX = TRUE, titleX = FALSE,titleY = TRUE)%>% layout(legend = list(orientation = 'h'))
  return(p)
}