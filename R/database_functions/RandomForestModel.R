# Written to gap-fill FCH4 (and/or other fluxes or long gaps in fluxes)
# By Sara Knox, adapted from the code by Kim et al., 2019 
# https://github.com/yeonukkim/EC_FCH4_gapfilling/blob/master/rf_run_for_public.R
# Aug 11, 2022

# Updated June Skeeter March 2019
# Adjustments to line with streamline third stage procedures

# Inputs 
# df <- input data frame with columns in this order:
# ["variable to be filled", c("predictor1", ... "predictorn"), "DateTime","DoY"]

# install required libraries
#install.packages('tidyverse') # for data wrangling 
#install.packages('caret') # for machine learning run and tuning
#install.packages('randomForest') # randomforest model

RandomForestModel <- function(df,fill_name,plot_results=0) {
  
  # load libraries
  library(tidyverse)
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
  
  # # Apply gap-filling function
  # predictor_vars <- c(predictor_vars,"c","s") # Add sine and cosine to predictor list
  
  # period when dep var is not missing
  obs_only <- ML.df[!is.na(ML.df[, 1]), ]
  
  # 75% of data used for model tuning/validation
  index <- createDataPartition(obs_only[, 1], p=0.75, list=F) 
  train_set <- obs_only[index,]
  test_set <- obs_only[-index,]
  
  ############### Random forest run
  
  #### option 1. random forest model with mtry tuning - IF USING THIS OPTION, NEED TO UPDATE THE CODE (this is the original code from Kim et al. 2019)
  # tgrid <- data.frame(mtry = c(3,6,9,12))
  # #Add parallel processing for the fast processing if you want to
  # library(parallel)
  # library(doParallel)
  # cluster <- makeCluster(6)
  # registerDoParallel(cluster)
  # RF_FCH4 <- train(FCH4 ~ ., data = train_set[,predictors],
  # 								 method = "rf",
  # 								 preProcess = c("medianImpute"),                #impute missing met data with median
  # 								 trControl=trainControl(method = "repeatedcv",   #three-fold cross-validation for model parameters 3 times
  # 								 											number = 3,                #other option: "cv" without repetition
  # 								 											repeats = 3),
  # 								 tuneGrid = tgrid,
  # 								 na.action = na.pass,
  # 								 allowParallel=TRUE, # This requires parallel packages. Otherwise you can choose FALSE.
  # 								 ntree=400, # can generate more trees
  # 								 importance = TRUE)
  # RF_FCH4$bestTune
  # RF_FCH4$results
  
  #### option 2. random forest model without tuning. 
  # (when mtry value is already tunned or using squre root of the number of predictor)

  var_dep <- colnames(df)[1]
  predictor_vars <- colnames(df[ , -which(names(df) %in% c("DateTime","DoY"))])

  RF <- train(as.formula(paste(var_dep, "~.")), train_set[,predictor_vars],
              method = "rf",
              preProcess = c("medianImpute"),  # impute missing met data with median (but it will not be applied since we used gap-filled predictors)
              trControl = trainControl(method = "none"),
              tuneGrid=data.frame(mtry=9), # use known mtry value.
              na.action = na.pass,
              allowParallel=FALSE,
              ntree=400, # can generate more trees
              importance = TRUE)
  
  ############### Results
  
  # whole dataset
  result <- subset(ML.df,select = var_dep)
  
  result$RF_model <- predict(RF, ML.df, na.action = na.pass); # RF model
  result$RF_filled <- ifelse(is.na(result[,var_dep]),result$RF_model,result[,var_dep]) # gap-filled column (true value when it is, gap-filled value when missing)
  result$RF_residual <- ifelse(is.na(result[,var_dep]),NA,result$RF_model - result[,var_dep]) # residual (model - obs). can be used for random uncertainty analysis
  # Rename variable names base on the dependant variable
  names(result)[2:4] <- c(paste(fill_name,'_RF_model',sep=""),paste(fill_name,'_RF_filled',sep=""),paste(fill_name,'_RF_residual',sep=""))
  
  result$DateTime <- ML.df$DateTime

  if (plot_results == 1) {
    # variable importance
    plot(varImp(RF, scale = FALSE), main="variable importance")
    
    #generate rf predictions for testset
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
  names(df.out) <- paste(fill_name,'_f_RF',sep="")
  df.out$RF_filled <- NA
  df.out$RF_filled[ind_start:ind_end] <- result[,2] #RF_model
  names(df.out)[2] <- paste(fill_name,'_fall_RF',sep="")  
  return(df.out)
}