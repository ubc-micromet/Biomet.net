function xsite_on_epl_spectra

%---------------------------------------------------------------------
% Comparison 
tv_exp = datenum(2004,7,9:12);

cd D:\Experiments\ON_EPL\Setup_XSITE
Stats_xsite = fcrn_load_data(tv_exp);

cd D:\Experiments\ON_EPL\Setup
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,5/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;


Hs_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
Fc_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
Fc_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
LE_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
LE_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');

ind_include = find( Hs_xs > 100 & Hs_pi > 100 ...
    & Fc_xs > -20 & Fc_xs < -5  ...
    & Fc_pi > -20 & Fc_pi < -5  ...
    & LE_xs > 200 & LE_pi > 200 );
ind_exclude = setdiff(1:length(Hs_xs),ind_include);

h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','MainEddy'});