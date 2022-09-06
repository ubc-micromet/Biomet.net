Stats_all = fcrn_load_data(datenum(2004,3,4:21),'XSITE');

% ind_exclude = unique([ind_cal ind_cal_h2o ind_dir ind_var_dir ind_manual]);



[Csd] = get_stats_field(Stats_all(10),'XSITE_CP.Spectra.Csd(:,5)');
