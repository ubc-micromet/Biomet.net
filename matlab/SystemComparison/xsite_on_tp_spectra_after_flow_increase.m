function xsite_on_tp_spectra_after_flow_increase

%---------------------------------------------------------------------
% Comparison 
% tv_exp = datenum(2005,7,21:now);
tv_exp = datenum(2005,7,27:29);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'ON_TP','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'ON_TP','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

tv    = get_stats_field(Stats_all,'TimeVector');
Hs_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
Fc_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
Fc_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
LE_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
LE_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
CO2_min = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Min(5)');

ind_include = find( Hs_xs > 100 & Hs_pi > 100 ...
    & Fc_xs > -20 & Fc_xs < -5  ...
    & Fc_pi > -20 & Fc_pi < -5  ...
    & LE_xs > 200 & LE_pi > 200 );

ind_exclude = find(tv<datenum(2005,7,27,18,0,0)+4/24 | Fc_pi>-6 | Fc_xs>-6 | isnan(Fc_pi));
ind_include = setdiff(1:length(Hs_xs),ind_exclude);

figure
plot(tv-datenum(2005,1,0),[Fc_pi Fc_xs],tv(ind_exclude)-datenum(2005,1,0),[Fc_pi(ind_exclude)],'ro')


h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','MainEddy'});