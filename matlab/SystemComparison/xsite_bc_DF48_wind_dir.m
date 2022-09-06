function xsite_bc_df48_wind_dir

tv_exp = datenum(2005,4,21):floor(now);

cd(fullfile(xsite_base_path,'bc_df48','setup_xsite_home'));
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'bc_df48','setup'));
Stats_main = fcrn_load_data(tv_exp);

wd_xsite = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');
wd_main  = get_stats_field(Stats_main,'Instrument(5).MiscVariables.WindDirection');
wd_clim  = get_stats_field(Stats_main,'Instrument(6).Avg(2)');

figure;
plot([wd_main,-1.*wd_clim+360,wd_xsite])
legend('Main','Climate','XSITE')