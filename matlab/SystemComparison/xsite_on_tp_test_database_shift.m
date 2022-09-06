function xsite_on_tp_test_database_shift

cd('c:\ubc_pc_setup\site_specific\');
tv_exp = datenum(2005,7,21:now);
Stats_xsite = fcrn_load_data(tv_exp);

tv_xsite = get_stats_field(Stats_xsite,'TimeVector');
Tc = get_stats_field(Stats_xsite,'Instrument(6).Avg(1:2)');

tv_exp = datenum(2005,7,21:now);
cd(fullfile(xsite_base_path,'ON_TP','Setup'));
Stats_site = fcrn_load_data(tv_exp);

tv_site = get_stats_field(Stats_site,'TimeVector');
Ts_site = get_stats_field(Stats_site,'Instrument(1).Avg(4)');
Ta_site = get_stats_field(Stats_site,'MiscVariables.Tair');

[pth_data,pth_hhour,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','ON_TP','clean\thirdstage','clean_tv'),8);
T_db  = read_bor(fullfile(pth_db,'2005','ON_TP','clean\thirdstage','air_temperature_main'));

ind = find(tv_db > datenum(2005,7,18) & tv_db < now);

plot(tv_site-datenum(2005,1,0),[Ts_site Ta_site], tv_db(ind)-4/24-datenum(2005,1,0),T_db(ind))

shift = 0;
[tv_dum,ind_xsite,ind_db] = intersect(tv_xsite,tv_db+shift);
ind = find(tv_db > datenum(2005,7,18) & tv_db < now);
plot(tv_db(ind)-datenum(2005,1,0),T_db(ind),tv_xsite-datenum(2005,1,0)+shift,Tc, tv_site-datenum(2005,1,0),[Ts_site Ta_site])

return