function [h_cpme,h_cpop,h_opme,ind_exclude] = xsite_bs_comp(tv_dat,ind_manual)
% xsite_bs_comp(tv_dat,ind_manual)
%
% tv_dat = datenum(2004,5,[14:19]);
% [h_cpme,h_cpop,h_opme] = xsite_bs_comp(tv_dat,ind_manual);

close all

lowUs = 0;

dir_min = 0;
dir_max = 360;


if ~exist('ind_manual')
    ind_manual = [7 38:52 70:77 233 259   260   264:272 8     9    15    ...
                    66    67    78   155   202   203   238   256 158   246   257   258]';
end

%----------------------------------------------------
% Load new data
%----------------------------------------------------
[Stats_all,Stats_xsite,Stats_new] = xsite_load_comparison_data(tv_dat,'bs_new_eddy');

%----------------------------------------------------
% Plot diagnostics
%----------------------------------------------------

% Find broken records
[N_CP,tv] = get_stats_field(Stats_xsite,'XSITE_CP.MiscVariables.NumOfSamples');
[N_OP,tv] = get_stats_field(Stats_xsite,'XSITE_OP.MiscVariables.NumOfSamples');
[N_EC,tv] = get_stats_field(Stats_new,'MainEddy.MiscVariables.NumOfSamples');
tv = fr_round_hhour(tv);

T_air         = get_stats_field(Stats_xsite,'MiscVariables.Tair');
p_bar         = get_stats_field(Stats_xsite,'MiscVariables.BarometricP');
Rn            = 200.*sin([1:length(T_air)].*2*pi/48)+50;
WindDirection = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');
%WindDirection = read_bor(fullfile(biomet_path(2004,'bs','clean\secondstage\'),'wind_direction_main'));
%WindDirection_tv = fr_round_hhour(read_bor(fullfile(biomet_path(2004,'bs','clean\secondstage\'),'clean_tv'),8));
%[junk,ind_tv,ind_dir]=intersect(tv,WindDirection_tv);
%WindDirection = WindDirection(ind_dir);

h1 = fcrn_plot_diagnostics(Stats_xsite,T_air,p_bar,Rn,WindDirection);

ind_n = find(N_CP<3.5e4 | N_OP<3.5e4 | N_EC<3.5e4 | isnan(N_CP.*N_EC));

% Find calibration times:
[co2_min,tv] = get_stats_field(Stats_xsite,'Instrument(2).Min(1)');
[h2o_min,tv] = get_stats_field(Stats_xsite,'Instrument(2).Min(2)');

ind_cal_h2o = find(h2o_min < 1);
ind_cal = find(co2_min < 340);

% Find bad winddirection times:
wind_dir = get_stats_field(Stats_xsite,'Instrument(1).MiscVariables.WindDirection');

% Find crazy fluxes
[Fc_EC,tv] = get_stats_field(Stats_new,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
[Fc_CP,tv] = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
[LE_EC,tv] = get_stats_field(Stats_new,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
[LE_CP,tv] = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
[Us_EC,tv] = get_stats_field(Stats_new,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');
[Us_CP,tv] = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Ustar');
ind_flux = find(Fc_EC < -50 | Fc_EC > 30 | ...
                Fc_CP < -50 | Fc_CP > 30 | ...
                LE_EC < -200 | LE_EC > 1000 | ...
                LE_CP < -200 | LE_CP > 1000 | ...
                Us_EC < lowUs | Us_EC > 15 | ...
                Us_CP < lowUs | Us_CP > 15);
%ind_flux=[];
% Define bad sectors:
ind_dir = find(wind_dir < dir_min | wind_dir > dir_max);
%ind_select = tv(sort([find_selected(h_cpme,Stats_all)]))';
ind_time = find((tv > datenum(2004,1,0)+130.3 & tv < datenum(2004,1,0)+131.1) | ...
                (tv > datenum(2004,1,0)+133 & tv < datenum(2004,1,0)+133.3)); 

ind_exclude = unique([ind_n; ind_cal; ind_cal_h2o; ind_dir; ind_manual ; ind_flux;ind_time]);

h_cpme = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','MainEddy'})
h_cpop = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'})
h_opme = fcrn_plot_report(Stats_all,ind_exclude,{'XSITE_OP','MainEddy'})

ind_addman = unique([find_selected(h_cpme,Stats_all)])';

return

ind_spec = find(Fc_EC >-1 | LE_EC<30 | Us_EC < 0.1);
h_s = fcrn_plot_spectra(Stats_all,unique([ind_exclude;ind_spec]),{'XSITE_CP','MainEddy'})
