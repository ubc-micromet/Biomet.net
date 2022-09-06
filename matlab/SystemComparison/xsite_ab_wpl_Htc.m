function xsite_ab_wpl_Htc

%---------------------------------------------------------------------
% 
tv_exp = datenum(2004,6,16:20);

cd C:\UBC_PC_Setup\Site_specific
Stats_xsite = fcrn_load_data(tv_exp);

cd C:\UBC_PC_Setup\Site_specific\XSITE_sonic_cal
Stats_xsite_cal = fcrn_load_data(tv_exp);

cd C:\UBC_PC_Setup\Site_specific\AB-WPL
Stats_ab_wpl = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_ab_wpl,7/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_ab_wpl(1).Configuration.hhour_path;

Stats_cal = fcrn_merge_stats(Stats_xsite_cal,Stats_ab_wpl,7/24);
Stats_cal(1).Configuration.pth_tv_exclude = Stats_ab_wpl(1).Configuration.hhour_path;

Hs  = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_cal  = get_stats_field(Stats_cal,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Htc = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Htc1');
Htp = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');

Ts_var = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.LinDtr.Cov(4,4)');
Ts_cal = get_stats_field(Stats_cal,'XSITE_CP.Three_Rotations.LinDtr.Cov(4,4)');
Tc_var = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.LinDtr.Cov(7,7)');
Tp_var = get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Cov(4,4)');
Tc_var(find(Tc_var>10)) = NaN;

figure
plot_regression(Hs,Htc,[],[],'ortho')

figure
plot_regression(Hs,Htp,[],[],'ortho')

figure
plot_regression(Ts_var,Tc_var,[],[],'ortho')

figure
plot_regression(Tp_var,Tc_var,[],[],'ortho')