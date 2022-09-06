function [Stats_all,Stats1,Stats2] = fcrn_load_comparison_data(tv_dat,Setup1,Setup2)

arg_default('Setup2','C:\UBC_PC_Setup\Site_specific\XSITE');

%----------------------------------------------------
% Load 
%----------------------------------------------------
addpath(Setup1,'-begin');
Stats1 = fcrn_load_data(tv_dat,fr_current_siteid);
[dum,pth_tv_exclude] = fr_get_local_path;
rmpath(Setup1);

addpath(Setup2,'-begin');
Stats2 = fcrn_load_data(tv_dat,fr_current_siteid);
rmpath(Setup2);

Stats_all = fcrn_merge_stats(Stats2,Stats1);
Stats_all(1).Configuration.pth_tv_exclude = pth_tv_exclude;