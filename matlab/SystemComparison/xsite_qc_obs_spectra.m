function xsite_qc_obs_spectra

%---------------------------------------------------------------------
% Comparison 
tv_exp = datenum(2004,7,20:23);

cd D:\Experiments\QC_OBS\Setup_XSITE
Stats_xsite = fcrn_load_data(tv_exp);

cd D:\Experiments\QC_OBS\Setup
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,5/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

tv  = get_stats_field(Stats_all,'TimeVector');
wd  = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
ust = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Ustar');
AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
AGC_main  = get_stats_field(Stats_all,'Instrument(end).MiscVariables.AGC_Max');
CSAT_diag_max  = get_stats_field(Stats_all,'Instrument(end-2).Max(end)');
%tv_exclude_man = tv(find((wd>60 & wd<120) | (wd > 150 & wd < 210) | (tv>datenum(2004,1,193) & tv<datenum(2004,1,193.7))| ust<0.07));
%tv_exclude_man = tv(find((wd>60 & wd<120) | (wd > 150 & wd < 210) | (tv>datenum(2004,1,193) & tv<datenum(2004,1,193.7))));
ind_exclude = find(wd<90 | tv<datenum(2004,7,20.5) | AGC_xsite>60 | AGC_main>65 | CSAT_diag_max > 63);


Hs_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
Fc_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
Fc_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
LE_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
LE_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');

ind_include = find( Hs_xs > 100 & Hs_pi > 100 ...
    & Fc_xs > -15 & Fc_xs < -5  ...
    & Fc_pi > -15 & Fc_pi < -5  ...
    & LE_xs > 100 & LE_pi > 100 );

% Get the 10 'best' flux hhours
best_flux = Fc_xs .* -20 + Hs_xs + LE_xs;

% [dum,ind_s] = sort(best_flux(ind_include));

% ind_exclude = unique([setdiff(1:length(Hs_xs),ind_include(ind_s(end-9:end)))]);
ind_exclude = unique([setdiff(1:length(Hs_xs),ind_include) ind_include(14)]);

h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','MainEddy'});
fcrn_print_report(h,'e:\');

return

tv_exp = datenum(2004,7,17:19);

cd D:\Experiments\QC_OBS\Setup_XSITE
Stats_xsite = fcrn_load_data(tv_exp);





%---------------------------------------------------------------------
% Comparison 
tv_exp = datenum(2004,7,20:22);

cd D:\Experiments\QC_OBS\Setup_XSITE
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Fc_xs = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
LE_xs = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');

%ind_include = find( Fc_xs >5 & Fc_xs<11);
ind_include = find( Fc_xs <-5 & Fc_xs>-11);

ind_exclude = setdiff(1:length(Fc_xs),ind_include);

h = fcrn_plot_spectra(Stats_xsite,ind_exclude,{'XSITE_CP','XSITE_OP'});