function xsite_nb_nl_spectra

%---------------------------------------------------------------------
% Comparison 
tv_exp = [datenum(2005,9,1):now];

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'NB_NL','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'NB_NL','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);

tv    = get_stats_field(Stats_all,'TimeVector');
Hs_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
Fc_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
Fc_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
LE_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
LE_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');

AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
wd_xsite = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
wd_hist = get_stats_field(Stats_all,'MiscVariables.WindDirHistogram');

ind_exclude_man = find( sum(wd_hist(:,19:37),2)<30000 ...
    | AGC_xsite>60 ...
    | Hs_xs < 100 | Hs_pi < 100 ...
    | LE_xs < 100 | LE_pi < 100 ...
    | Fc_xs > -5  | Fc_pi > -5 ...
    );

tv_exclude = fcrn_auto_clean(Stats_all,{'XSITE_CP','XSITE_OP'},tv(ind_exclude_man));
[tv_dum,ind_exclude] = intersect(tv,tv_exclude);

h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','MainEddy'});

h = fcrn_plot_spectra(Stats_all,ind_exclude,{'XSITE_CP','XSITE_OP'});