tv_exp = datenum(2005,8,2):now;

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

wd_xsite = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection')
chi = get_stats_field(Stats_all,'Instrument(2).Avg(2)');
Ta = get_stats_field(Stats_all,'MiscVariables.Tair');
Pb = get_stats_field(Stats_all,'MiscVariables.BarometricP');
r_h_xsite = (chi_xsite.*Pb)./sat_vp(Ta);

[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','clean_tv'),8);;
wd = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','wind_direction_main'));;
precip = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','precipitation'));;
r_h = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','relative_humidity_main'));;

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));

