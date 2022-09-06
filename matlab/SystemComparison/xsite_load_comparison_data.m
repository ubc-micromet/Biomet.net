function [Stats_all,Stats_xsite,Stats_new] = xsite_load_comparison_data(tv_dat,SiteId)

%----------------------------------------------------
% Load new data
%----------------------------------------------------
pth_old = pwd;

cd(['C:\UBC_PC_Setup\Site_specific\' SiteId]);
Stats_new = fcrn_load_data(tv_dat,fr_current_siteid)

cd C:\UBC_PC_Setup\Site_specific\xsite
Stats_xsite = fcrn_load_data(tv_dat,'xsite')

cd(pth_old);

Stats_all = fcrn_merge_stats(Stats_new,Stats_xsite)
