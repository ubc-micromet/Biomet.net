function xsite_on_tp_time_shift

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'ON_TP','Setup_XSITE'));
end
tv_exp = datenum(2005,7,21:now);
Stats_xsite = fcrn_load_data(tv_exp);

tv_exp = datenum(2005,7,21:now);
cd(fullfile(xsite_base_path,'ON_TP','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);
Stats_all_noshift = fcrn_merge_stats(Stats_xsite,Stats_site,0/24);

tv = get_stats_field(Stats_all,'TimeVector');
T_x = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Avg(4)');
T_s = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Avg(4)');

tv_noshift = get_stats_field(Stats_all_noshift,'TimeVector');
T_x_noshift = get_stats_field(Stats_all_noshift,'XSITE_CP.Three_Rotations.Avg(4)');
T_s_noshift = get_stats_field(Stats_all_noshift,'MainEddy.Three_Rotations.Avg(4)');

plot(tv-datenum(2005,1,0),[T_x,T_s],tv_noshift-datenum(2005,1,0),[T_x_noshift,T_s_noshift])