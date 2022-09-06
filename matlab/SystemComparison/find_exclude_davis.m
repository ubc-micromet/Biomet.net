function find_exclude_davis

Stats_all = fcrn_load_data(datenum(2004,3,4:21),'XSITE');

T_air         = get_stats_field(Stats_all,'MiscVariables.Tair');
p_bar         = get_stats_field(Stats_all,'MiscVariables.BarometricP');
Rn            = 200.*sin([1:length(T_air)].*2*pi/48)+50;
WindDirection = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');

h = fcrn_plot_diagnostics(Stats_all,T_air,p_bar,Rn,WindDirection);

% Find calibration times:
[co2_min,tv] = get_stats_field(Stats_all,'Instrument(2).Min(1)');
[h2o_min,tv] = get_stats_field(Stats_all,'Instrument(2).Min(2)');

ind_cal_h2o = find(h2o_min < 5);
ind_cal = find(co2_min < 340);

% Find bad winddirection times:
wind_dir = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');

% Define bad sectors:
dir_min = 60;
dir_max = 140;

ind_dir = find(wind_dir < dir_min | wind_dir > dir_max);

% Check out wind direction influence
[dir_hist] = get_stats_field(Stats_all,'MiscVariables.WindDirHistogram');
n_out = sum(dir_hist(:,[1:10 15:36]),2);
ind_var_dir = find(n_out>1e3);
ind_beg = min(find(~isnan(n_out)));

ind_manual = [1:162 693 719 723 753 780]';

ind_exclude = unique([ind_cal; ind_cal_h2o; ind_dir; ind_manual]);

h = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});

h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});

return

figure
subplot(2,2,3);
	h= surf(dir_hist(ind_beg:end,:));
view(2)
set(h,'edgecolor','none','facecol','interp')
caxis([0 5000])

figure
plot(n_out(ind_beg:end))


ind_exclude = unique([ind_cal;ind_cal_h2o;ind_dir]);
h = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});

ind_exclude = unique([ind_cal;ind_cal_h2o;ind_dir;ind_manual]);
h = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});

ind_exclude = unique([ind_cal;ind_cal_h2o;ind_dir;ind_var_dir;ind_manual]);
h = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});

% Visual inspection of everything
h = fcrn_plot_report(Stats_all,[],{'XSITE_CP','XSITE_OP'});

% Visual inspection of manually excluded data
h = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});
ind_select = unique(sort([find_selected(h,Stats_all)]));

return
