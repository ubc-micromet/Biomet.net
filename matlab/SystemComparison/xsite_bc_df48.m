function xsite_bc_df48

%---------------------------------------------------------------------
% Diagnostics
% tv_exp = datenum(2005,4,21):floor(now);
tv_exp = datenum(2005,4,[21:24]);
cd(fullfile(xsite_base_path,'bc_df48','setup_xsite_home'));
% new_calc_and_save(tv_exp,'XSITE',1);

Stats_xsite = fcrn_load_data(tv_exp);
%Stats_xsite(1).Configuration.pth_tv_exclude = Stats_xsite(1).Configuration.hhour_path;
tv_xs = get_stats_field(Stats_xsite,'TimeVector');

%---------------------------------------------------------------------
% Read site met-data
h_diag = fcrn_plot_diagnostics(Stats_xsite);
%fcrn_print_report(h_diag,'e:\');

%---------------------------------------------------------------------
% Comparison XSITE vs MAIN SITE
% tv_exp = datenum(2005,4,21):floor(now);
tv_exp = datenum(2005,4,[21 24]);
cd(fullfile(xsite_base_path,'bc_df48','setup_xsite'));
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'bc_df48','setup'));
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,0/24);
i1 = 1;
while isempty(Stats_all(i1).Configuration)
    i1 = i1+1;
end
Stats_all(i1).Configuration.pth_tv_exclude = Stats_all(i1).Configuration.hhour_path;

fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',[],0,[20 20.8333]);

% Winddir to exclude
tv  = get_stats_field(Stats_all,'TimeVector');
wd  = get_stats_field(Stats_all,'Instrument(14).Avg(2)');
tv_exclude_man = tv(find(wd<250));
[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',tv_exclude_man,0,[20 20.8333]);
fcrn_print_report(h_rep,'e:\',textResults);

%---------------------------------------------------------------------
% Comparison before sonic exchange
tv_exp = datenum(2004,7,17:19);
cd D:\Experiments\QC_OBS\Setup_XSITe
Stats_xsite = fcrn_load_data(tv_exp);

cd D:\Experiments\QC_OBS\Setup
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Stats_all_bad_csat = fcrn_merge_stats(Stats_xsite,Stats_site,5/24);
Stats_all_bad_csat(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

% Winddir to exclude
tv  = get_stats_field(Stats_all_bad_csat,'TimeVector');
wd  = get_stats_field(Stats_all_bad_csat,'Instrument(1).MiscVariables.WindDirection');
AGC_main  = get_stats_field(Stats_all_bad_csat,'Instrument(end-1).MiscVariables.AGC_Max');
tv_exclude_bad_csat = tv(find(wd<90 | AGC_main>65));
[tv_exclude,h_bad_csat,varOut,textResults] = fcrn_clean(Stats_all_bad_csat,{'XSITE_CP','MainEddy'},'flux_comp',tv_exclude_bad_csat,1,[20 10]);
fcrn_print_report(h_bad_csat,'e:\',textResults);
