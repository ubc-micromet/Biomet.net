# Written to gap-fill FCH4 (and/or other fluxes or long gaps in fluxes)
# By Sara Knox March 2024, adapted from the code by Gavin McNicol & June Skeeter

# RF algorithm is trained ranger package in R (R Core Team, 2019; Wright & Ziegler, 2017) 

# Inputs 
# df <- input data frame with columns in this order:
# ["variable to be filled", c("predictor1", ... "predictorn"), "DateTime","DoY"]

# install required libraries
#install.packages('tidyverse') # for data wrangling 
#install.packages('caret') # for machine learning run and tuning
#install.packages('randomForest') # randomforest model
#install.packages('ranger')

RandomForestModel <- function(df,fill_name,log_file_path) {
  
  # load libraries
  library('tidyverse')
  library('ranger')
  library('caret')
  library('ggplot2')

  # This is a pretty hacked up approach assuming a specific order, should update to be more explicit
  var_dep <- colnames(df)[1]
  predictor_vars <- colnames(df[ , -which(names(df) %in% c(var_dep,"DateTime"))])

  # Truncate data set to remove all NA values at the start
  # Find full rows (non-NA predictors, excluding date based variables)
  pred_ix = which(rowSums(!is.na(df[predictor_vars]))==length(predictor_vars))

  # create subset of data excluding NAs at the end of the time series
  ML.df <- df[pred_ix, ] 
  
  # Create time variables & sine and cosine functions (carryover from previous version)
  # Would it be more appropriate to use a physically based function like solar declination?
  ML.df <- ML.df %>%
    mutate(sin_curve = sin((ML.df$DoY-1)/365*2*pi), # Sine function to represent the seasonal cycle
           cos_curve = cos((ML.df$DoY-1)/365*2*pi)) # cosine function to represent the seasonal cycle
  
  predictor_vars = c(predictor_vars,"sin_curve","cos_curve")

  # period when dep var is not missing
  obs_only <- ML.df[!is.na(ML.df[, 1]), ]
  
  # 75% of data used for model tuning/validation
  index <- createDataPartition(obs_only[, 1], p=0.75, list=F) 
  train_set <- obs_only[index,]
  test_set <- obs_only[-index,]
    
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
    verboseIter = FALSE, ## Set this to FALSE, verbose output is VERY VERBOSE and makes the output log very difficult to read
    returnData = FALSE,
  )
  
  ## train RF 
  RF <- train(
    as.formula(paste(var_dep, "~.")), 
    data = train_set[,c(var_dep,predictor_vars)],
    num.trees = 500, # start at 10xn_feat, maintain at 100 below 10 feat
    method = 'ranger',
    trControl = myControl,
    tuneGrid = tgrid,
    importance = 'permutation',  ## or 'impurity'
    metric = "MAE" ## or 'rmse',
  )
  
  ## A copy gets saved for each year
  ## This is a bit redundant, but current procedures could result in divergent models for different years
  ## So its important to do it this way, unless we will always be running the all years 
  ## Side note: we should consider ALWAYS training on the all years available
  save(RF,file = file.path(log_file_path,paste(var_dep,"RF_Model.RData",sep="_")))
  
  print(sprintf('RF Training for %s Complete, Normalized Variable Importance:',var_dep))
  
  print(varImp(RF))
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
  png(file.path(log_file_path,paste('RF',var_dep,"Varriable_Importance.png",sep="_")))
  plot(varImp(RF))
  dev.off()

  #generate rf predictions for test set
  test_set$rf <- predict(RF, test_set, na.action = na.pass)
  regrRF <- lm(test_set$rf ~ test_set[,var_dep]); 
  print(sprintf('Validation Statistics: %s',var_dep))
  print(summary(regrRF))
  
  p1 <- test_set  %>% ggplot(aes(x = !!sym(var_dep), y = rf)) + geom_abline(slope = 1, intercept = 0)+
    geom_point() + ggtitle("testset") + labs(x = var_dep)

    
  png(file.path(log_file_path,paste('RF',var_dep,"Test_Points.png",sep="_")))
  print(p1)
  dev.off()
    
  # ggsave(file.path(log_file_path,paste('RF',var_dep,"Test_Points.png",sep="_")))

  # browser()
  # p2 <- result %>% ggplot(aes_string('DateTime',var_dep)) + geom_point() + 
  #   theme_bw() + ylab(var_dep)


  p2 <- result %>% ggplot(aes_string('DateTime',names(result)[2])) + geom_point(color="red",alpha=0.5) +
    geom_point(aes_string('DateTime',var_dep),color="black")+
    theme_bw() + ylab(var_dep)

  png(file.path(log_file_path,paste('RF',var_dep,"Observed_vs_Modeled_TimeSeries.png",sep="_")))
  print(p2)
  dev.off()
    
  # ggsave(file.path(log_file_path,paste('RF',var_dep,"Observed_vs_Modeled_TimeSeries.png",sep="_")))

  # Output filled data (including 'var_Ustar_f_RF', 'var_Ustar_fall_RF' -> same naming convention as REddyProc)
  df.out <- data.frame(df[,1])
  # Make sure output data frame is the same length as the input data
  df.out[pred_ix, ] <- result[,3] #RF_filled
  names(df.out) <- paste(fill_name,sep="")
  df.out$RF_filled <- NA
  df.out$RF_filled[pred_ix] <- result[,2] #RF_model
  names(df.out)[2] <- paste(fill_name,"_all",sep="")  

  # Get all indicies before present timestamp
  BP <- which(df$DateTime<Sys.time())
  
  print(sprintf('RF Gap-Filling %s Complete, %i missing values remain in the time series',var_dep,sum(is.na(df.out[BP,1]))))
  print(sprintf('%i of those missing values are between the first and last complete set of predictors',sum(is.na(df.out[pred_ix[1]:pred_ix[length(pred_ix)],1]))))
  
  return(df.out)
  
}
