function Stats_all = xsite_on_gr_SN703

tv_exp = datenum(2005,8,7:9);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'on_gr','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'on_gr','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;
tv = get_stats_field(Stats_all,'TimeVector');

[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','clean_tv'),8);;
wd = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','wind_direction_main'));;
precip = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','precipitation'));;

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));
AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
wd_xsite = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');

tv_exclude_man = tv( find(tv<datenum(2005,8,7,19,0,0)...
    | (wd_xsite<220 & wd_xsite>90)...
    | precip(ind_db)>0 ...
    | AGC_xsite>60));

[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_Std_AvgDtr',tv_exclude_man,1,[20 20]);
pause

xsite_on_gr_Tc_comparison(Stats_all,tv_exclude);
pause

[tv_exclude,h_rep,varOut,textResults] = fcrn_clean(Stats_all,{'XSITE_CP','MainEddy'},'report_H_AvgDtr',tv_exclude_man,0,[20 20]);
pause
return
