function Stats_all = xsite_on_gr_exclude_wind_dir

tv_exp = datenum(2005,8,2:9);
if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'on_gr','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'on_gr','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;
tv = get_stats_field(Stats_all,'TimeVector');

[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','clean_tv'),8);;
wd = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','wind_direction_main'));;
precip = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','precipitation'));;

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));
AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
wd_xsite = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
wd_hist = get_stats_field(Stats_all,'MiscVariables.WindDirHistogram');

Hs_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
co2_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Min(5)');
co2_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Min(5)');

ind_good = find( sum(wd_hist(:,[1:9 29:end]),2)>30000 ...
    & co2_xsite>10 & co2_main>10 ...
    & precip(ind_db)==0 ...
    & AGC_xsite<=60);

ind_good_night = find( sum(wd_hist(:,[1:9 29:end]),2)>30000 ...
    & co2_xsite>10 & co2_main>10 ...
    & precip(ind_db)==0 ...
    & AGC_xsite<=60 ...
    & Hs_xsite < 0);

ind_bad = find( sum(wd_hist(:,[22:28]),2)>30000 ...
    & co2_xsite>10 & co2_main>10 ...
    & precip(ind_db)==0 ...
    & AGC_xsite<=60);

ind_bad_night = find( sum(wd_hist(:,[25:28]),2)>30000 ...
    & co2_xsite>10 & co2_main>10 ...
    & precip(ind_db)==0 ...
    & AGC_xsite<=60 ...
    & Hs_xsite < 0);

figure('Name','Hs regression');

subplot(2,2,1)
plot_regression(Hs_xsite(ind_good),Hs_main(ind_good),[],[],'ortho');
title('290 to 90 deg - all data')

subplot(2,2,2)
plot_regression(Hs_xsite(ind_bad),Hs_main(ind_bad),[],[],'ortho');
title('220 to 289 deg - all data')

subplot(2,2,3)
plot_regression(Hs_xsite(ind_good_night),Hs_main(ind_good_night),[],[],'ortho');
title('290 to 90 deg - Hs<0')

subplot(2,2,4)
plot_regression(Hs_xsite(ind_bad_night),Hs_main(ind_bad_night),[],[],'ortho');
title('250 to 289 deg - all data')

axes('Visible','off')
text(0.5,-0.1,'Hs XSITE','HorizontalA','center')
text(-0.1,0.5,'Hs Main','HorizontalA','center','Rotation',90)

figure('Name','Flux regressions - 290 to 90 deg - all data')
four_panel_flux(Stats_all(ind_good));

figure('Name','Flux regressions - 220 to 289 deg - all data')
four_panel_flux(Stats_all(ind_bad));

figure('Name','Flux regressions - 290 to 90 deg - Hs<0')
four_panel_flux(Stats_all(ind_good_night));

figure('Name','Flux regressions - 250 to 289 deg - all data')
four_panel_flux(Stats_all(ind_bad_night));

return

function four_panel_flux(Stats_all)

Hs_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
LE_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L');
LE_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
Fc_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
Fc_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
us_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Ustar');
us_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');

subplot(2,2,1)
plot_regression(Hs_xsite,Hs_main,[],[],'ortho');
xlabel('Hs XSITE (W m^{-2})')
ylabel('Hs Main (W m^{-2})')

subplot(2,2,2)
plot_regression(LE_xsite,LE_main,[],[],'ortho');
xlabel('LE XSITE (W m^{-2})')
ylabel('LE Main (W m^{-2})')

subplot(2,2,3)
plot_regression(Fc_xsite,Fc_main,[],[],'ortho');
xlabel('Fc XSITE (\mumol m^{-2} s^{-1})')
ylabel('Fc Main (\mumol m^{-2} s^{-1})')

subplot(2,2,4)
plot_regression(us_xsite,us_main,[],[],'ortho');
xlabel('Ustar XSITE (m/s)')
ylabel('Ustar Main (m/s)')

