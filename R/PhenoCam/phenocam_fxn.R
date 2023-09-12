# ------------------------------------------------------------------
# PhenoCam Image Processing Functions
# Functions written for the analyses of PhenoCam Images 

# May 30, 2023 (Last Update: Aug. 16, 2023)
# Kelsey McGuire, Sarah Russell, Sara Knox
# UBC Micrometeorology Lab (ubc.micromet.github.io)
#
# Potential New Implementations:
#   - Create own fxn similar to structureFolder to sort images into
#     years and months pre-processing instead of doing it manually
#   - Edit Files into one specific datetime format instead of having it as a
#     fxn argument (noticed this fault when one sites images were named in diff.
#     formats)
# ------------------------------------------------------------------

EditFiles <- function(my_path) {
  # ------------------------------------------------------------------------ #
  # Arguments: 
  # - my_path [List[str]]: containing 4 folder paths associated with the phenopix 
  #   structureFolder() function (e.g., IMG (where all images are contained); 
  #   REF (Reference Image folder); ROI (where data from Ref. Image ROI is 
  #   stored as a .Rdata [List]); VI (data on Vegetation Indices is stored as a 
  #   .Rdata [List[ROI DataFrames]])
  #
  # Purpose: 
  # - Creates a list of the loose, unedited image files, detects, and changes 
  #   (if needed) the name of the image from its original format into the 
  #   defaulted format specified in VegInd/PhenoProcessing (to ensure 
  #   extractDateFilename() runs correctly).
  # 
  # Output:
  # - String confirming folders are corrected 
  # ------------------------------------------------------------------------ #
  img_path <- my_path$img
  old_files <- list.files(img_path, full.names = F)
  
  if (stringr::str_detect(old_files[1], '_')) {                
    new_files <- stringr::str_replace_all(old_files, "_", "-")
    file.copy(from = paste0(img_path, old_files), 
              to = paste0(img_path, new_files))
    file.remove(paste0(img_path, old_files))
  } 
  
  # when renaming photos originally had this issue, so placed in case it occurs again
  if (stringr::str_starts(old_files[1], ' ')) {                
    new_files <- stringr::str_replace_all(old_files, " ", "")
    file.copy(from = paste0(img_path, old_files), 
              to = paste0(img_path, new_files))
    file.remove(paste0(img_path, old_files))
  }
  
  # removes duplicates
  if (str_detect(old_files[1], " 1")) {
    file.remove(paste0(img_path, old_files))
  }
  
  print('files in proper format')
}

ROI <- function(my_path, UserRefImage, NROI = 1) { 
  # ------------------------------------------------------------------------ #
  # Arguments: 
  # - my_path [str]: See EditFiles() for description.
  # - UserRefImage [str]: An Image Path (full path not just name) for a 
  #   User Selected image that they wish to draw an ROI on.
  #      * Image should be in, and use the proper /REF folder, for all other 
  #        functions to work correctly
  #
  # Purpose: 
  # - Creates a list of the loose, unedited image files, detects, and changes 
  #   (if needed) the name of the image from its original format into the 
  #   defaulted format specified in VegInd/PhenoProcessing (to ensure 
  #   extractDateFilename() runs correctly).
  # - If UserRefImage is given, it will skip the above step, and assign the 
  #   reference image to subsequent analyses within the function.
  # - Once the Reference Image has been sorted out, the DrawMULTIROI() function 
  #   will run, where within the first month of each year's loop, an ROI will 
  #   be drawn, and that ROI will then be used overtop of all following 
  #   month's images.
  # 
  # Output:
  # - Nothing is returned directly, but within the /REF folder, there should be 
  #   one image, and the /ROI folder will then contain a [List] of roi 
  #   information within 'roi.data.Rdata', and an image outlining the boundaries 
  #   of the ROI.
  # ------------------------------------------------------------------------ #
  if (missing(UserRefImage)) {
    images <- list.files(my_path$img)
    for (img in images) {
      if (length(list.files(my_path$ref)) == 0) { 
        ref_img <- images[first(which(stringr::str_detect(images, '12')==TRUE))]
        ref_path <- paste("REF/", ref_img, sep = '')
        file.copy(from = paste0(my_path$img, ref_img), 
                  to = paste0(my_path$ref, ref_img))
      }
    }
    refimage <- paste0(my_path$ref, (list.files(my_path$ref)))
  } else {
    refimage <- UserRefImage # should we check it includes path name? 
  }
  
  roi_names <- list()
  
  for (i in 1:NROI) {
    
    number <- as.character(i)
    
    roi_names[i] <- paste0('roi', number) 
    
  }
  
  DrawMULTIROI(refimage, 
               my_path$roi, 
               nroi = NROI, 
               roi.names = roi_names,            
               file.type = '.jpg')
}

VegInd <- function(my_path, UserROI, pixels = 3, datecode = 'yyyy-mm-dd-HH-MM-SS') {
  # ------------------------------------------------------------------------ #
  # Arguments: 
  # - my_path: See EditFiles() for description.
  # - UserROI [str]: The desired ROI path as defined by the ROI function above
  #     * Needs User Input at the beginning of each years analysis if it is the 
  #       first run through for the analysis after a month (see what timeline we want).
  # - pixels [int]: How many pixels will be aggregated for the image analysis (default 
  #   is 3 (9 Pixel Grid)).
  # - datecode [str]: For the extractDateFilename() function within 
  #   extractVI(), need to specify the POSIX date time format, and change from
  #   default if found to be different. 
  #
  # Purpose: 
  # - Extracts the Vegetation Indices from the ROI for each image supplied 
  #   within the IMG folder, and will then calculate the half-hourly gcc
  # 
  # Output:
  # - A List of ROI dataframes 'roi.data.Rdata' (we specify 1 ROI currently, so 
  #   1 df), that contains information on green, red, blue reflectances, and 
  #   associated calculations. 
  # - A .csv file of the ROI dataframe for the specified wd at a daily
  #   interval along with a plot of mean daily GCC values over the month.
  # ------------------------------------------------------------------------ #
  
  extractVIs(my_path$img,
             UserROI,
             my_path$VI,
             date.code = datecode,
             npixels = pixels,
             file.type = '.jpg',           # include a parameter to change file type if not in .jpg format?
             ncores = 'all')
  
  load(paste0(my_path$VI, "VI.data.Rdata"))
  
  # find initial gcc for any processing
  VI.data$roi1$gcc <- VI.data$roi1$g.av/VI.data$roi1$bri.av
  VIs <- VI.data$roi1
  
  # bind together VIs if there is more than 1 ROI
  roi_names <- names(VI.data)
  
  if (length(roi_names) > 1) {
    for (i in 2:length(roi_names)) {
      # calculate half-hour gcc and ndvi
      VI.data[[i]]$gcc <- VI.data[[i]]$g.av/VI.data[[i]]$bri.av
      
      VIs <- rbind(VIs, VI.data[[i]])
    } 
  }
  # output plot
  # find daily average
  
  VI_plot <- VIs %>% group_by(date) %>% summarise(across(c(r.av, g.av, b.av, bri.av, 
                                                             gi.av, gei.av, ri.av, bi.av, gcc), mean))
  
  # Plot2: Daily GCC Mean Results
  title <- paste('GCC Daily Mean (',VI_plot$date[1],' ~ ',VI_plot$date[length(VI_plot$date)],')', sep = "")
  ggplot(VI_plot)+
    geom_point( aes(x = date, y = gcc),
                col = 'forestgreen')+
    geom_line( aes(x = date, y = gcc),
               col = 'forestgreen')+
    ggtitle(title)+
    ylab('GCC Average')
  ggsave(filename = paste0(my_path$VI, 'Daily_GCC.png', sep = ""),
         width = 8,
         height = 6)
  
  # monthly .csv - commented out bc want yearly csv as done in PhenoProcessing
  date <- as.character(VIs$date)[1]
  yearmonth <- substring(date, 1, 7)
  raw_outname <- paste(my_path$VI, 'raw_daily_VI_', yearmonth, '.csv', sep = '')
  outname <- stringr::str_replace_all(raw_outname, '-', '_')
  write.csv(VIs, outname)
}

FilterData <- function(my_path) {
  # ------------------------------------------------------------------------ #
  # Arguments: 
  # - my_path: See EditFiles() for description.
  #
  # Purpose: 
  # - Filter out unneccessary/poor data due to bad weather, low illumination, 
  #   dirty lenses, etc. that are explained more in-depth within the phenopix
  #   autoFilter() function
  # 
  # Output:
  # - A .csv file of the filtered data at a daily interval, where averages for
  #   the most common (rcc, gcc, bcc) indices are featured.
  # ------------------------------------------------------------------------ #
  
  # preview data
  load(paste0(my_path$VI, "VI.data.Rdata"))
  filtered_data <- autoFilter(VI.data$roi)
  
  # create csv
  date <- as.character(filtered_data$date)[1]
  yearmonth <- substring(date, 1, 7)
  raw_outname <- paste(my_path$VI, 'filtered_daily_VI_', yearmonth, '.csv', sep = '')
  outname <- stringr::str_replace_all(raw_outname, '-', '_')
  write.csv(filtered_data, outname)
}

PhenoProcessing <- function(wd, UserRefImage, NROI = 1, NumofPix = 3, datecode = 'yyyy-mm-dd-HH-MM-SS') { # include file type parameter? (see VegInd) 
  # ------------------------------------------------------------------------ #
  # Arguments: 
  # - wd [str]: Path for what working directory you want to be in - likely
  #   under the site name (e.g., ~/codes/phenocam/DSM)
  #      * Effective format would be to have the images/data preprocessing laid 
  #        out as Site > Year > Month > Images.
  # - UserRefImage [str]: See ROI() for detailed description.
  # - NumofPix [int]: See VegInd(pixels) for detailed description.
  # - datecode [str]: See VegInd(datecode) for detailed description.
  #
  # Purpose: 
  # - Contains all previously defined functions, along with some sorting and 
  #   folder editing lines to get the layout desired by each function, and to
  #   account for special cases in which an analysis, or function should be 
  #   skipped/altered.
  # 
  # Output:
  # - All previously outlined outputs, along with one final .csv file of daily 
  #   average for each respective year, containing all VI data.
  # ------------------------------------------------------------------------ #
  
  tic()
  year_folders <- list.dirs(wd, recursive = F)
  years <- list.dirs(wd, recursive = F, full.names = F) # used for naming later on in the function
  
  # enter into the loop containing the yearly info
  for (year in 1:length(year_folders)) {
    
    month_folders <- list.dirs(year_folders[year], full.names = T, recursive = F)
    months <- list.dirs(year_folders[year], full.names = F, recursive = F)
    VI_df <- data.frame() # dataframe containing all info from that year
    
    # enter into the loop containing the monthly info (typically just images at this point)
    for (month in 1:length(month_folders)) { 
      tic() # time how long each month takes to process
      
      if (length(list.files(month_folders[month])) != 0) { # makes sure that even if there are empty folders you can still process
        my_path <- structureFolder(month_folders[month], showWarnings = F) # set up folder structure within each respective month
        
        img_files <- as_tibble(list.files(month_folders[month], full.names = TRUE, pattern = ".jpg")) %>%
          cbind(as_tibble(list.files(month_folders[month], full.names = FALSE, pattern = ".jpg")))
        
        colnames(img_files) <- c("full_path", "img")
        
        path <- unlist(img_files$full_path) # path and image names
        img_name <- unlist(img_files$img) # just image name
        
        file.copy(from = path,
                  to   = paste(wd, "/",years[year], "/", months[month], "/IMG/", img_name, sep = ''),   # once these have split up move the images from the month folder
                  overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)  # into the IMG folder 
        
        if (length(list.files(month_folders[month])) > 4) {  # remove the files found in the month folder (but only if there are extra files beyond the 4 created by structure)
          file.remove(path)
        }
        
        # this statement sees if the current date matches the day that the files were last modified so that the same calculations aren't
        # performed over and over again yielding the same result, while taking up processing time
        # might be nice for the editing stage, but not needed so much for the actual final product?
        if (length(list.files(my_path$VI)) == 0) {
          # edit the file names into the compatable format for extractVIs within VegInd
          EditFiles(my_path) 
          
          # move an image (preferably one at noon) to REF, and draw the ROI
          if (month == 1) {
            if (length(list.files(my_path$roi)) == 0) {
              ROI(my_path, UserRefImage, NROI = NROI)
              UserROI <- my_path$roi
            } else {
              UserROI <- paste0(month_folders[1], '/ROI')
            }
          } else {
            UserROI <- paste0(month_folders[1], '/ROI')
          }
          
          VegInd(my_path, UserROI, datecode = datecode)
          
        } else {
          # calculate Vegetation Indices
          VI_file <- file.info(paste0(my_path$VI, 'VI.data.Rdata'))
          
          # finds what the current date is, and what date the VI.data was last modified (when VI data was last calculated)
          current_day <- as.Date(Sys.time())
          mod_day <- as.Date(VI_file$ctime)
          
          if ((current_day-mod_day) < 7) { 
            print('analysis already done for the week - skipped calculation')
          } else {
            UserROI <- paste0(month_folders[1], '/ROI')
            VegInd(my_path, UserROI, datecode = datecode)
          }
        }
        
        # get VegInd into a df
        load(paste(my_path$VI, "VI.data.Rdata", sep = ""))
        
        if (NROI > 1) {
          if (month == 1) {
            VI.data$roi1$gcc <- VI.data$roi1$g.av/VI.data$roi1$bri.av
            VIs <- VI.data$roi1
              for (i in 2:NROI) {
                # calculate half-hour gcc and ndvi
                VI.data[[i]]$gcc <- VI.data[[i]]$g.av/VI.data[[i]]$bri.av
                VIs <- rbind(VIs, VI.data[[i]])
              } 
            VI_df <- VIs
          } else {
            VI.data$roi1$gcc <- VI.data$roi1$g.av/VI.data$roi1$bri.av
            VIs <- VI.data$roi1
            for (i in 2:NROI) {
              # calculate half-hour gcc and ndvi
              VI.data[[i]]$gcc <- VI.data[[i]]$g.av/VI.data[[i]]$bri.av
              VIs <- rbind(VIs, VI.data[[i]])
            }
            VI_df <- rbind(VI_df, VIs)
          }
          
          # uncomment if wanting to get an average value across ROIs
          # VIs <- VIs %>% group_by(date) %>% summarise(across(colnames(VIs)[-1], mean)) 
                                                         
        } else {
          if (month == 1) {
            VI.data$roi1$gcc <- VI.data$roi1$g.av/VI.data$roi1$bri.av
            VI_df <- VI.data$roi1
          } else {
            VI.data$roi1$gcc <- VI.data$roi1$g.av/VI.data$roi1$bri.av
            VI_df <- rbind(VI_df, VI.data$roi1)
          }
        }
        toc()
      }
    }
    # write output .csv
    outname <- paste(wd, "/", years[year], '/unfiltered_VI_', years[year], '.csv', sep = '')
    write.csv(VI_df, outname)
    
    # output plot
    # find monthly average
    VI_df$month <- substring(VI_df$date, 6, 7)
    
    VI_plot <- VI_df %>% group_by(month) %>% summarise(across(c(r.av, g.av, b.av, bri.av, 
                                                                gi.av, gei.av, ri.av, bi.av, 
                                                                gcc), mean))
    
    # Plot2: Monthly GCC Mean Results
    title <- paste('GCC Monthly Mean in ', years[year], sep = "")
    ggplot(VI_plot)+
      geom_point( aes(x = month, y = gcc),
                  col = 'forestgreen')+
      geom_line( aes(x = month, y = gcc),
                 col = 'forestgreen')+
      ggtitle(title)+
      ylab('GCC Average')
    ggsave(filename = paste0(year_folders[year], '/Monthly_GCC.png', sep = ""),
           width = 8,
           height = 6)
    toc()
  }
  toc()
}