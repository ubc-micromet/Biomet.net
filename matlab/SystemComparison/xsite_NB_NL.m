function Stats_all = xsite_NB_NL

% tv_exp = datenum(2005,8,23):floor(now);
tv_exp = datenum(2005,9,1):floor(now);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'NB_NL','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'NB_NL','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;
tv = get_stats_field(Stats_all,'TimeVector');

% h_diag = fcrn_plot_diagnostics(tv_exp,'NB_NL');

% fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',[],1,[20 10]);

AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
wd_xsite = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
wd_hist = get_stats_field(Stats_all,'MiscVariables.WindDirHistogram');

tv_exclude_man = tv( find( sum(wd_hist(:,19:37),2)<30000 ...
    | AGC_xsite>60));
fcrn_auto_clean(Stats_all,{'XSITE_CP','MainEddy'},tv_exclude_man);
[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',tv_exclude_man,1,[20 10]);

return

tv_exclude_man = tv(AGC_xsite>60);
fcrn_auto_clean(Stats_all,{'XSITE_CP','XSITE_OP'},tv_exclude);
[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','XSITE_OP'},'report_cpop',tv_exclude_man,1,[20 20]);

return
