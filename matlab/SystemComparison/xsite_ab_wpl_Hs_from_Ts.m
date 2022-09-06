function xsite_ab_wpl_Hs_from_Ts

cd C:\UBC_PC_Setup\Site_specific\XSITE_Hs_from_Ts
%new_calc_and_save(datenum(2004,6,16:19));
Stats_xsite = fcrn_load_data(datenum(2004,6,16:19));

cd C:\UBC_PC_Setup\Site_specific\AB-WPL_Hs_from_Ts
%new_calc_and_save(datenum(2004,6,16:19));
Stats_ab_wpl = fcrn_load_data(datenum(2004,6,16:19));

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_ab_wpl,7/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_ab_wpl(1).Configuration.hhour_path;

[tv_exclude,h_rep] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_var');
%fcrn_print_report(h_rep,'e:\');

% Check out covariances
figure
Hs_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Cov(3,4)');
Hs_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.LinDtr.Cov(3,4)');
plot_regression(Hs_xs,Hs_pi)
xlabel('cov(w,T_s) - XSITE (K m s^{-1})')
ylabel('cov(w,T_s) - AB-WPL (K m s^{-1})')

%print -deps e:\cov_Ts
return