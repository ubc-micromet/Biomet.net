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

