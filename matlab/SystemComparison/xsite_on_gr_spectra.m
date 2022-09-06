function xsite_on_gr_spectra

%---------------------------------------------------------------------
% Comparison 
tv_exp = [datenum(2005,8,2):now];

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'ON_GR','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'ON_GR','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

tv    = get_stats_field(Stats_all,'TimeVector');
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

h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});