function [h_cpme,h_cpop,h_opme] = xsite_davis_comp_csi(tv_dat,ind_manual)
% xsite_bs_comp(tv_dat,ind_manual)
%
% tv_dat = datenum(2004,5,[14:19]);

if ~exist('ind_manual')
    ind_manual = []';
end

%----------------------------------------------------
% Load new data
%----------------------------------------------------
cd \\PAOA001\SITES\XSITE\Experiments\Davis\CSI;

% new_calc_and_save(datenum(2004,4,30),'bs')

Stats_new = fcrn_load_data(tv_dat,'csi')

cd C:\UBC_PC_Setup\Site_specific\xsite

Stats_xsite = fcrn_load_data(tv_dat,'xsite')

Stats_all = fcrn_merge_stats(Stats_new,Stats_xsite,-8/24)

%----------------------------------------------------
% Plot diagnostics
%----------------------------------------------------

% Find broken records
[N_CP,tv] = get_stats_field(Stats_all,'XSITE_CP.MiscVariables.NumOfSamples');
[N_OP,tv] = get_stats_field(Stats_all,'XSITE_OP.MiscVariables.NumOfSamples');
[N_EC,tv] = get_stats_field(Stats_all,'CSIEddyCP.MiscVariables.NumOfSamples');
tv = fr_round_hhour(tv);

T_air         = get_stats_field(Stats_all,'MiscVariables.Tair');
p_bar         = get_stats_field(Stats_all,'MiscVariables.BarometricP');
Rn            = 200.*sin([1:length(T_air)].*2*pi/48)+50;
WindDirection = get_stats_field(Stats_all,'Instrument(7).MiscVariables.WindDirection');

h1 = fcrn_plot_diagnostics(Stats_all,T_air,p_bar,Rn,WindDirection);

ind_n = find(N_CP<3.5e4 | N_OP<3.5e4 | N_EC<3.5e4/2 | isnan(N_CP.*N_EC));

% Find calibration times:
[co2_min,tv] = get_stats_field(Stats_all,'Instrument(8).Min(1)');
[h2o_min,tv] = get_stats_field(Stats_all,'Instrument(8).Min(2)');
[co2_min_csi,tv] = get_stats_field(Stats_all,'Instrument(3).Min(1)');

ind_cal_h2o = find(h2o_min < 1);
ind_cal = find(co2_min < 340 |co2_min_csi<340);

% Find bad winddirection times:
wind_dir = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');

% Find crazy fluxes
[Fc_EC,tv] = get_stats_field(Stats_all,'CSIEddyCP.Three_Rotations.AvgDtr.Fluxes.Fc');
[Fc_CP,tv] = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
[LE_EC,tv] = get_stats_field(Stats_all,'CSIEddyCP.Three_Rotations.AvgDtr.Fluxes.LE_L');
[LE_CP,tv] = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
[Us_EC,tv] = get_stats_field(Stats_all,'CSIEddyCP.Three_Rotations.AvgDtr.Fluxes.Ustar');
[Us_CP,tv] = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Ustar');
ind_flux = find(Fc_EC < -30 | Fc_EC > 15 | ...
                Fc_CP < -30 | Fc_CP > 15 | ...
                LE_EC < -50 | LE_EC > 1000 | ...
                LE_CP < -50 | LE_CP > 1000 | ...
                Us_EC < 0.1 | Us_EC > 15 | ...
                Us_CP < 0.1 | Us_CP > 15);
ind_flux=[];
% Define bad sectors:
dir_min = 5;
dir_max = 355;

ind_dir = find(wind_dir < dir_min | wind_dir > dir_max);
ind_dir = [];
ind_time = find((tv > datenum(2004,1,0)+130.3 & tv < datenum(2004,1,0)+131.1) | ...
                (tv > datenum(2004,1,0)+133 & tv < datenum(2004,1,0)+133.3)); 
ind_time = [];
ind_exclude = unique([ind_n; ind_cal; ind_cal_h2o; ind_dir; ind_manual ; ind_flux;ind_time]);

h_cpme = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','CSIEddyCP'})
h_cpop = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'})
h_opme = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_OP','CSIEddyCP'})

return