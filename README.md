# Biomet.net

Below outlines the steps for installing Matlab on your local computer and then pointing it to biomet.net

# 1) Installing Matlab

* UBC has a free license for everyone and, if you have admin privileges on your PC, you can install it yourself. Otherwise talk to Zoran or to your IT person).

* The installation instructions can be found here: https://it.ubc.ca/services/desktop-print-services/software-licensing/matlab#getMATLAB
Find the paragraph on **Personally-Owned Devices** and go from there.

* Install Matlab with the following toolboxes only:

1. Signal Processing
2. Curve fitting
3. Statistics and Machine Learning
4. Optimization
5. Global Optimization
6. If you see something else that you may want to try go for it (Neural Networks,…) but having all the toolboxes installed is a waste of your disk space

NOTE: if you already have matlab you can install the toolboxes using the add on button instead (or use to add on button to add additional toolboxes down the line).

# 2) Setting-up biomet.net on your local computer

 * First clone Biomet.net to your to your `C:` drive (PC) or `~/Users/youruser` (mac). 
 * To clone a directory from the terminal:
 1. Make sure you are in the correct directory (for more information on how to change directories on your PC [see here](https://www.lifewire.com/change-directories-in-command-prompt-5185508) and on your mac [see here](https://appletoolbox.com/navigate-folders-using-the-mac-terminal/)).
 2. Clone the directory by following [these instructions](https://www.educative.io/answers/how-to-clone-a-git-repository-using-the-command-line).
 3. Clone the [UBC PC Setup repository](https://github.com/ubc-micromet/UBC_PC_Setup-template) and follow the instructions from the `README` file.
 4. Keep your `Biomet.net` code up to date by periodically by using `git pull` (Note: first make sure you are in the correct directory).

**NOTE**: Do NOT save any of your files into `Biomet.net` folder!

If you write any functions that you think the other group members could use, create a separate branch and have Zoran, Sara or June approve the files and review the pull request.

# 3) Creating a local copy of the database on your computer

* Once you have Biomet.net set up and followed all the instructions from the `README` file in the [UBC PC Setup repository](https://github.com/ubc-micromet/UBC_PC_Setup-template), you can create a local copy of the database for testing and analysis purposes.

* Zoran created an app that allows for easy copying of the database (it's called `setupLocalDataCleaning`). This app enables users to do local cleaning of database traces by copying the server database to you local machine. User can then work on the ini files, do the cleaning and check the results. Once everything is working, the user can (manually) copy the ini files and any functions from Derived_Variables to the main server and re-run the cleaning there to update the server database (**Note that this is done by sharing your files with Zoran who will then upload them to Vinimet**). The results on the server should now be the same as after the cleaning on the local computer.

* Steps for local cleaning (including editing of the ini files):

1) Create a folder for the data cleaning that you are about to do (or use an existing one if the folder already exists). Note that usually there would be one folder per site on your local computer. We suggest create the folder in a path such as `./user_name/Matlab/local_data_cleaning/site_name`. 

The biomet_database_default.m and localDataCleaning_ini.mat files will be stored in that folder. They will be created when the app runs the first time.

2) In Matlab, cd to that folder, then:

* Run `setupLocalDataCleaning` from the command line. 

* **Note**: You need to be logged into the VPN and connected to vinimet.  However, the application won't necessarily prompt you for the vinimet login.
 * If the application fails - try connecting to vinimet via your file manager first (e.g. \\vinimet.geog.ubc.ca\ubc_flux$) so you are prompted for the logon - then try again.

* Change the app settings if needed. The program always saves the settings after each successful run. Those settings become the defaults for the next app run. If the user starts the app while being in the same folder, the setup info saved during the previous run (file localDataCleaning_ini.mat) will be loaded with the default settings for the GUI.

* Here are the app settings you may need to change:<br />
    * Site: Enter your site name (e.g., DSM)<br />
    * Years: Enter the year of interest (eg. 2022)<br />
    * User work folder: This is the path to the folder you created in Step 1<br />
    * Database server location: Is these Database folder on vinimet (e.g., `/Volumes/Projects/Database`)<br />
    * Local copy of database: A folder where you'd like to keep a local copy of your database (e.g., `/Users/sara/localdatabase`)<br />

* Click on "Copy Database" and wait for the copy to finish. The program may stop and warn you if you are about to overwrite some newer files in your local database. **Read the prompts!**

* After the app closes, you'll have your own copy of the database and, as long as you stay in this folder, all the cleaning will be done on your local copy of the database (because biomet_database_default.m points to your local database).

**A Note on ini files**

* if you don't need to change ini files you, you can run the automated cleaning using `fr_automated_cleaning(years,sites,stages)` (e.g., fr_automated_cleaning(2021:2022,'DSM',1:2)

* If you do want to edit the ini file, copy the newest version of the ini files from `./Database/Calculation_Procedures/TraceAnalysis_ini/site_name` into your local folder - **the same one from which you ran setupLocalDataCleaning app (e.g., `./user_name/Matlab/local_data_cleaning/site_name`)**

* Edit and save ini files

* Now when running fr_automated_cleaning(), run `fr_automated_cleaning(years,site,[],'path to your edited ini file') (e.g., `fr_automated_cleaning(2021:2022,'DSM',1:2,[],'./user_name/Matlab/local_data_cleaning/site_name')`).

# 4) Plotting your data using R

1) Create an ini file for your site (under 'R/data_visualization/ini_files')

2) In your console, enter the following (note that you can also create an R script with the code below and run the R script):

file <- "ini_files/YOUNG_data_QCQA.R" # Specify the ini file of interest
args <-c("/Users/sara/Code/Biomet.net/R/", # Local path to Biomet.net
         "/Users/sara/Library/CloudStorage/OneDrive-UBC/UBC/Database") # Local path to your database
rmarkdown::run("/Users/sara/Code/Biomet.net/R/data_visualization/dashboard_data_QCQA_shiny.Rmd") # Run 'dashboard_data_QCQA_shiny.Rmd' and include your local path to the file.

