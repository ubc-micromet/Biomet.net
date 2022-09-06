%----------------------------------------------------
% Load new data
%----------------------------------------------------
cd D:\Sites\XSITE\Site_specific

Stats_xsite = fcrn_load_data(datenum(2004,4,30:41),'xsite')

%----------------------------------------------------
% Plot diagnostics
%----------------------------------------------------
T_air         = get_stats_field(Stats_xsite,'MiscVariables.Tair');
p_bar         = get_stats_field(Stats_xsite,'MiscVariables.BarometricP');
Rn            = 200.*sin([1:length(T_air)].*2*pi/48)+50;
WindDirection = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');

h = fcrn_plot_diagnostics(Stats_xsite,T_air,p_bar,Rn,WindDirection);

% Find broken records
[N_CP,tv] = get_stats_field(Stats_xsite,'XSITE_CP.MiscVariables.NumOfSamples');
[N_OP,tv] = get_stats_field(Stats_xsite,'XSITE_OP.MiscVariables.NumOfSamples');

ind_n = find(N_CP<3.5e4 | N_OP<3.5e4 | isnan(N_CP));

% Find calibration times:
[co2_min,tv] = get_stats_field(Stats_xsite,'Instrument(2).Min(1)');
[h2o_min,tv] = get_stats_field(Stats_xsite,'Instrument(2).Min(2)');

ind_cal_h2o = find(h2o_min < 1);
ind_cal = find(co2_min < 340);

% Find calibration times:
[co2_std,tv] = get_stats_field(Stats_xsite,'XSITE_OP.Three_Rotations.Std(5)');
[h2o_std,tv] = get_stats_field(Stats_xsite,'XSITE_OP.Three_Rotations.Std(6)');
ind_std = find(co2_std > 10 | h2o_std > 0.4);

% Find time after first fix:
%ind_tv = find(tv < datenum(2004,5,6)+6/24);
ind_tv = [];

% Find bad winddirection times:
wind_dir = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');

% Define bad sectors:
dir_min = 0;
dir_max = 360;

ind_dir = find(wind_dir < dir_min | wind_dir > dir_max);

ind_manual = []';

ind_exclude = unique([ind_n; ind_cal; ind_cal_h2o; ind_dir; ind_manual; ind_tv; ind_std]);

h = fcrn_plot_report(Stats_xsite,ind_exclude,{'XSITE_CP','XSITE_OP'})

h = fcrn_plot_spectra(Stats_xsite,[13],{'XSITE_CP','XSITE_OP'})
