# Written to gap-fill FCH4 (and/or other fluxes or long gaps in fluxes)
# By Sara Knox March 2024, adapted from the code by Gavin McNicol & June Skeeter

# RF algorithm is trained ranger package in R (R Core Team, 2019; Wright & Ziegler, 2017) 

RandomForestModel <- function(df,fill_name,plot_results=0,fill_tag='_RF_f') {
  
  # load libraries
  library(tidyverse)
  library(ranger)
  library(caret)
  
  # Truncate data set to remove all NA values at the start
  # Find first non-NA data point
  data_first <- sapply(df, function(x) x[min(which(!is.na(x)))])
  
  # See what index that corresponds too
  ind_first <- rep(NA, length(data_first))
  for (i in 1:length(data_first)) {
    ind_first[i] <- head(which(df[,i] == data_first[[i]]),n=1)
  }
  
  # Why is this in here?
  # # Find last first-NaN data point but exclude USTAR
  # ind_USTAR <- which(vars_reorder == 'USTAR')
  ind_start <- min(ind_first)
  
  # Truncate data set to remove future time steps
  # Find last non-NA data point
  data_last <- sapply(df, function(x) x[max(which(!is.na(x)))])
  
  # See what index that corresponds too
  ind_last <- rep(NA, length(data_last))
  for (i in 1:length(data_last)) {
    ind_last[i] <- tail(which(df[,i] == data_last[[i]]),n=1)
  }
  
  # Find last non-NaN data point
  ind_end <- max(ind_last)
  
  # create subset of data excluding NAs at the end of the time series
  ML.df <- df[ind_start:ind_end, ] 
  
  # Would it be more appropriate to use a physically based function like solar declination?
  # Create time variables & sine and cosine functions
  df <- df[ind_start:ind_end, ]
  ML.df <- ML.df %>%
    mutate(s = sin((df$DoY-1)/365*2*pi), # Sine function to represent the seasonal cycle
           c = cos((df$DoY-1)/365*2*pi)) # cosine function to represent the seasonal cycle
  
  # period when dep var is not missing
  obs_only <- ML.df[!is.na(ML.df[, 1]), ]
  
  # 75% of data used for model tuning/validation
  index <- createDataPartition(obs_only[, 1], p=0.75, list=F) 
  train_set <- obs_only[index,]
  test_set <- obs_only[-index,]
  
  var_dep <- colnames(df)[1]
  predictor_vars <- colnames(df[ , -which(names(df) %in% c("DateTime","DoY"))])
  
  ## Create tune-grid (all combinations of hyper-parameters)
  tgrid <- expand.grid(
    mtry = c(1:length(predictor_vars)-1), # since mtry can not be larger than number of variables in data, could add parameter in function for step so doesn't default increment by 1
    splitrule = "variance", 
    min.node.size = c(5, 50, 100)
  )
  
  ## Create trainControl object (other)
  myControl <- trainControl(
    method = "cv",
    allowParallel = TRUE,
    verboseIter = TRUE,  
    returnData = FALSE,
  )
  
  ## train RF 
  RF <- train(
    as.formula(paste(var_dep, "~.")), 
    data = train_set[,predictor_vars],
    num.trees = 500, # start at 10xn_feat, maintain at 100 below 10 feat
    method = 'ranger',
    trControl = myControl,
    tuneGrid = tgrid,
    importance = 'permutation',  ## or 'impurity'
    metric = "MAE" ## or 'rmse'
  )
  
  ############### Results
  # whole dataset
  result <- subset(ML.df,select = var_dep)
  
  result$RF_model <- predict(RF, ML.df, na.action = na.pass); # RF model
  result$RF_filled <- ifelse(is.na(result[,var_dep]),result$RF_model,result[,var_dep]) # gap-filled column (true value when it is, gap-filled value when missing)
  result$RF_residual <- ifelse(is.na(result[,var_dep]),NA,result$RF_model - result[,var_dep]) # residual (model - obs). can be used for random uncertainty analysis
  # Rename variable names base on the dependant variable
  names(result)[2:4] <- c(paste(fill_name,'_RF_model',sep=""),paste(fill_name,'_RF_filled',sep=""),paste(fill_name,'_RF_residual',sep=""))
  
  result$DateTime <- ML.df$DateTime
  
  # Do we want to add more statistic of model fit/results?
  
  if (plot_results == 1) {
    # variable importance
    plot(varImp(RF, scale = FALSE), main="variable importance")
    
    #generate rf predictions for test set
    test_set$rf <- predict(RF, test_set, na.action = na.pass)
    regrRF <- lm(test_set$rf ~ test_set[,var_dep]); 
    print(summary(regrRF))
    test_set  %>% ggplot(aes_string(x=var_dep, y='rf')) + geom_abline(slope = 1, intercept = 0)+
      geom_point() + geom_smooth(method = "lm") + ggtitle("testset") + labs(x = var_dep)
    
    result %>% ggplot(aes_string('DateTime',var_dep)) + geom_point() + 
      theme_bw() + ylab(var_dep)
    result %>% ggplot(aes_string('DateTime',names(result)[2])) + geom_point(color="red",alpha=0.5) +
      geom_point(aes_string('DateTime',var_dep),color="black")+
      theme_bw() + ylab(var_dep)
    
    # whole data comparison
    ggplot(result, aes_string(x = var_dep, y =names(result)[2])) + geom_abline(slope = 1, intercept = 0)+
      geom_point() + geom_smooth(method = "lm") + ggtitle("whole dataset")
    regrRF_whole <- lm(result[,2] ~ result[,1]);
    print(summary(regrRF_whole))
  }
  
  # Output filled data (including 'var_Ustar_f_RF', 'var_Ustar_fall_RF' -> same naming convention as REddyProc)
  df.out <- data.frame(df[,1]) 
  # Make sure output data frame is the same length as the input data
  df.out[ind_start:ind_end, ] <- result[,3] #RF_filled
  names(df.out) <- paste(fill_name,fill_tag,sep="")
  df.out$RF_filled <- NA
  df.out$RF_filled[ind_start:ind_end] <- result[,2] #RF_model
  names(df.out)[2] <- paste(fill_name,fill_tag,"all",sep="")  
  return(df.out)
  
}
