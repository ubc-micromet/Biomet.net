%% Example of data plotting for Voigt 2023 paper
% Tested with Matlab 2020b in Windows 10. 
% File paths will not work for MacOS. Edit them as needed.

% First change Matlab's current folder to point to where the Matlab repository
% has been cloned to (type in the folder for Voigt2023_CH4_uptake code
cd c:/
%%
load .\data\met-data\hhour\20190803_recalcs_UdeM.mat
%%
UdeM_show_one_run(dataStruct,2,10,'exp_L')