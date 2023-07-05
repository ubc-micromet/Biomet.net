# phenocam functions

## When doing actual processing, define directories BEFORE the use of any functions

# editing file names to fit proper formatting
EditFiles <- function(my_path) {
  # move the downloaded images into their respective months, fxn renames files to be compatible with the 
  # extractDateFilename (within the extractVIs fxn later on) - once already done the else statement will print
  img_path <- my_path$img
  old_files <- list.files(img_path, full.names = T)
  for (x in old_files) {
    if (stringr::str_detect(x, '_')) {
      new_files <- stringr::str_replace_all(old_files, "_", "-")
      file.copy(from = old_files, to = new_files)
      file.remove(old_files)
    } 
  }
  print('files in proper format')
}

# draw in ROIs
ROI <- function(my_path) {
  img_path <- my_path$img
  images <- list.files(img_path)
  for (img in images) {
    # move one image (post-editing to ref folder)
    ref_path <- my_path$ref
    # 1st if - only move if there are no images in the folder
    if (length(list.files(ref_path)) == 0) { 
      # 2nd if - find only the image that is found at noon on the first day 
      # might be better to find if theres a way to detect and accept first OCCURRENCE of noon so we
      # don't need to depend so much on the day - worried atm that if we do just '-12-00-00' it will detect and move every occurrence
      if (stringr::str_ends(img, '01-12-00-00.jpg')) {
        image_name <- substring(img, 2)                
        ref_image <- paste(my_path$ref, image_name, sep = '')
        file.copy(from = img,
                  to   = ref_image,                         
                  overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
      } else if (stringr::str_ends(img, '28-12-00-00.jpg')) {
        image_name <- substring(img, 62)                  
        ref_image <- paste(my_path$ref, image_name, sep = '')
        file.copy(from = img,
                  to   = ref_image,                         
                  overwrite = TRUE, recursive = FALSE, copy.mode = TRUE) 
      }
    }
  }
  refimage <- list.files(my_path$ref, full.names = T)
  DrawMULTIROI(refimage, 
               my_path$roi, 
               nroi = 1, 
               roi.names = 'roi',            
               file.type = '.jpg')
  
  ## generate an ROI plot to check that the ROI are correct
  # PrintROI(refimage, my_path$roi, which = 'all', col = palette()) - commented out for time being
}

# calculate Vegetation Indicies from all photos within the folder (can quicken processing by changing
# the number of pixels being aggregated) - also calculates the half-hourly GCC and NDVI and outputs
# all VI's as csv
VegInd <- function(my_path, pixels = 3, datecode = 'yyyy-mm-dd-HH-MM-SS') {
  # extract VIs - adjust npixels to aggregate (2 for cluster of 4; 3 for cluster of 9) to cut down processing time
  tic()
  extractVIs(my_path$img,
             my_path$roi,
             my_path$VI,
             date.code = datecode,
             npixels = pixels,
             file.type = '.jpg',
             ncores = 'all')
  
  # Output Plot
  load(paste(my_path$VI,
             "VI.data.Rdata",
             sep = ""))
  imglist <- list.files(my_path$img)
  date <- VI.data$roi$date
  
  # calculate half-hour gcc and ndvi
  VI.data$roi$gcc <- VI.data$roi$g.av/VI.data$roi$bri.av
  gcc <- VI.data$roi$gcc
  # VI.data$roi$ndvi <- 0.086111 * exp(gcc*3.8496)
  toc()
  
  # monthly .csv - commented out bc want yearly csv as done in PhenoProcessing
  # images <- list.files(my_path$img)
  # yearmonth <- substr(images[1], 1, 7)
  # outname <- paste(my_path$VI, 'unfiltered_VI_Data_', yearmonth, '.csv', sep = '')
  # write.csv(VI.data$roi, outname)
}

PhenoProcessing <- function(wd, NumofPix = 3, datecode = 'yyyy-mm-dd-HH-MM-SS') {
  tic()
  year_folders <- list.files(wd, full.names = T)
  # enter into the loop containing the yearly info
  for (year in year_folders) {
    month_folders <- list.files(year, full.names = T) # list all folders (hopefully just months) within the year
    
    VI_df <- data.frame() # dataframe containing all info from that year
    
    # enter into the loop containing the monthly info (typically just images at this point)
    for (month in month_folders) {
      my_path <- structureFolder(month, showWarnings = F) # set up folder structure within each respective month
      
      # some code altered slightly from example given by stackoverflow user: glenn_in_boston
      img_files <- as_tibble(list.files(recursive = TRUE, full.names = TRUE, pattern = ".jpg")) %>% # brings in all files (with their paths)
        cbind(as_tibble(list.files(recursive = TRUE, full.names = FALSE, pattern = ".jpg")))        # brings in just the img name
      
      colnames(img_files) <- c("full_path", "img") # edit column names to make more clear
      
      path <- unlist(img_files$full_path) # split up the lists into the names with the path (e.g., 2023/01/2023-01-01...) and ...
      img_name <- unlist(img_files$img) # just the img name (2023-01-01...)
      
      file.copy(from = path,
                to   = paste("IMG/", img_name, sep = ''),                         # once these have split up move the images from the month folder
                overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)  # into the IMG folder 
      
      if (length(list.files(month)) > 4) {  # remove the files found in the month folder (but only if there are extra files beyond the 4 created by structure)
        file.remove(path)
      }
      
      # edit the file names into the compatable format for extractVIs within VegInd
      EditFiles(my_path) 
      
      # move an image (preferably one at noon) to REF, and draw the ROI (see if there's a way to reuse ROIs since this can reduce the amount of user interaction?)
      if (length(list.files(my_path$roi)) < 1) {
        ROI(my_path)
      }
      
      # calculate Vegetation Indices
      VegInd(my_path)
      
      # get VegInd into a df
      for (i in length(month_folders)) {
        load(paste(my_path$VI, "VI.data.Rdata", sep = ""))
        VI_data <- VI.data$roi
        if (i == 1) {
          VI_df <- VI_data
        } else {
          VI_df <- rbind(VI_df, VI_data)
        }
      }
    }
    # write output .csv 
    year <- list.files(wd)
    outname <- paste(my_path$VI, 'unfiltered_VI_Data_', year, '.csv', sep = '')
    write.csv(VI_df, outname)
  }
}
# HAVE TO EDIT THE FUNCTIONS BELOW MORE (ESPECIALLY Plots_CSVs)

# outputs all placed in this function (the plots on GI and other averages, as well as a CSV)
Plots_CSVs <- function(VI_dataframe, group_variable) {
  # Plot1: Hourly Results
  title <- paste('GI Half-Hourly Mean (',date[1],' ~ ',date[length(date)],')', sep = "")
  ggplot(VI_dataframe$roi)+
    geom_point( aes(x = date, y = gi.av))+
    geom_line( aes(x = date, y = gi.av))+
    ggtitle(title)+
    ylab('GI Average')
  ggsave(paste(my_path$VI, 'GI_Half-HourlyMean.png', sep = ""))
  
  # Plot2: Daily Mean Results
  GIavg <- VI_dataframe$roi%>%
    group_by(group_variable)%>%
    dplyr::summarise(Mean=mean(gi.av, na.rm = T))
  GIavg <- mutate(GIavg, 
                  date = as.Date(doy, origin = '2021-12-31')) # check if origin should be the same
  
  title <- paste('GI Daily Mean (',date[1],' ~ ',tail(date, n=1), ")", sep = "")
  ggplot(GIavg)+
    geom_point( aes(x = date, y = Mean))+
    geom_line( aes(x = date, y = Mean))+
    ggtitle(title)+
    ylab('GI Average')
  ggsave(paste(my_path$VI, 'GI_DailyMean.png', sep = ""))
  
  # Compute daily average
  DailyAvg <- VI.data$roi%>%
    group_by(doy)%>%
    summarise(across(where(is.numeric), ~ mean(.x, na.rm = T)))
  DailyAvg <- mutate(DailyAvg, date = as.Date(doy, origin = '2021-12-31'))
  DailyAvg <- DailyAvg[,c(18,1:17)]
  outname <- paste(my_path$VI, 'RCC_PhenoCam_EVI_daily_', format(Sys.time(), '%Y%m%d'), '.csv', sep = '')
  write.csv(as.matrix(DailyAvg), outname, row.names = F)
  
  # Create CSV containing all unfiltered results
}

# Filters through unneccessary data, and averages the daily GCC, RCC, BCC
FilterData <- function(VI_path) {
  # filter out unneccessary data (bad weather, low illumination, dirty lenses, etc.)
  ## preview data
  load(VI_path)
  filtered_data <- autoFilter(VI.data$roi)
  # warnings()
  print(filtered_data)
}