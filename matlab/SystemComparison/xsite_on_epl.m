function xsite_ab_wpl

%---------------------------------------------------------------------
% Diagnostics
tv_exp = datenum(2004,7,9:15);
cd D:\Experiments\ON_EPL\Setup_XSITE
% new_calc_and_save(tv_exp,'XSITE',1);

Stats_xsite = fcrn_load_data(tv_exp);
Stats_xsite(1).Configuration.pth_tv_exclude = Stats_xsite(1).Configuration.hhour_path;
tv_xs = get_stats_field(Stats_xsite,'TimeVector');

%---------------------------------------------------------------------
% Read site met-data
h_diag = fcrn_plot_diagnostics(Stats_xsite);
fcrn_print_report(h_diag,'e:\');
% h_diag = fcrn_plot_diagnostics_site(Stats_xsite);
% fcrn_print_report(h_diag,'e:\');
%---------------------------------------------------------------------
% OP - CP
tv_exp = datenum(2004,7,9:15);
cd D:\Experiments\ON_EPL\Setup_XSITe
Stats_xsite(1).Configuration.pth_tv_exclude = Stats_xsite(1).Configuration.hhour_path;
% new_calc_and_save(tv_exp,'XSITE',1);

tv = get_stats_field(Stats_xsite,'TimeVector');
wd = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');
tv_exclude_man_cpop = tv(find((wd>60 & wd<120) | (tv>datenum(2004,1,193) & tv<datenum(2004,1,193.7))));
% We are not throwing out wind direction at this point because both, open
% and closed path get screwed up the same way when the wind blows through
% the tower and the same screwed up w is used to calc fluxes.
% [tv_ex,h_cpop] = fcrn_clean(Stats_xsite,{'XSITE_CP','XSITE_OP'},'report_cpop',tv_exclude_man_cpop,1);
[tv_ex,h_cpop,varOut,textResults] = fcrn_clean(Stats_xsite,{'XSITE_CP','XSITE_OP'},'report_cpop');
fcrn_print_report(h_cpop,'e:\',textResults);

%---------------------------------------------------------------------
% Comparison XSITE vs MAIN SITE
tv_exp = datenum(2004,7,9:15);
cd D:\Experiments\ON_EPL\Setup_XSITe
Stats_xsite = fcrn_load_data(tv_exp);

cd D:\Experiments\ON_EPL\Setup
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,5/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

% Winddir to exclude
tv  = get_stats_field(Stats_all,'TimeVector');
wd  = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
ust = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Ustar');
%tv_exclude_man = tv(find((wd>60 & wd<120) | (wd > 150 & wd < 210) | (tv>datenum(2004,1,193) & tv<datenum(2004,1,193.7))| ust<0.07));
%tv_exclude_man = tv(find((wd>60 & wd<120) | (wd > 150 & wd < 210) | (tv>datenum(2004,1,193) & tv<datenum(2004,1,193.7))));
tv_exclude_man = tv(find((wd>80 & wd<180)| (tv>datenum(2004,1,193) & tv<datenum(2004,1,193.7))));
[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_var',tv_exclude_man,1);
fcrn_print_report(h_rep,'e:\',textResults);

%---------------------------------------------------------------------
% Comparison cov max / fixed samples
tv_exp = datenum(2004,7,9:14);
cd D:\Experiments\ON_EPL\Setup
Stats_site = fcrn_load_data(tv_exp);

cd D:\Experiments\ON_EPL\Setup_cov_max
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_cov_max = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_site,Stats_cov_max);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

[tv_exclude,h_rep] = fcrn_clean(Stats_all,{'MainEddy','MainEddy_cov_max'},'report_var');
fcrn_print_report(h_rep,'e:\');
