function xsite_ab_wpl_sonic_cal

%---------------------------------------------------------------------
% Recalculation
cd C:\UBC_PC_Setup\Site_specific\XSITE_sonic_cal

% tv_exp = datenum(2004,6,[16 17 18 20]);
% tv_exp = datenum(2004,6,[19]);
%new_calc_and_save(tv_exp);

tv_exp = datenum(2004,6,[16:20]);

Stats_xsite = fcrn_load_data(tv_exp);

%---------------------------------------------------------------------
% Comparison 

cd C:\UBC_PC_Setup\Site_specific\AB-WPL
% new_calc_and_save(datenum(2004,6,16:20),'AB_WPL',1);
Stats_ab_wpl = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_ab_wpl,7/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_ab_wpl(1).Configuration.hhour_path;

[tv_exclude,h_rep] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_var');
%fcrn_print_report(h_rep,'e:\')