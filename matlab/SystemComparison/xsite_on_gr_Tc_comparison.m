function xsite_on_gr_Tc_comparison(Stats_all,tv_exclude);

tv = get_stats_field(Stats_all,'TimeVector');

Hs_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');

Htc1_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Htc1');
Htc2_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Htc2');
Htc1_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Htc1');

stdTs_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std(4)');
stdTs_main = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std(4)');
stdTc1_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std(7)');
stdTc2_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std(8)');
stdTc1_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std(7)');

cov_wT_xsite = get_stats_field(Stats_all,'Instrument(1).Cov(3,4)');
cov_wT_main = get_stats_field(Stats_all,'Instrument(10).Cov(3,4)');

[tv_dum,ind_ex] = intersect(tv,tv_exclude);
ind_in = setdiff(1:length(tv),ind_ex);

figure('Name','H regressions');
subplot(2,2,1)
plot_regression(Hs_xsite(ind_in),Hs_main(ind_in),[],[],'ortho');
xlabel('Hs XSITE'); ylabel('Hs Main');

subplot(2,2,2)
plot_regression(Hs_xsite(ind_in),Htc1_main(ind_in),[],[],'ortho');
xlabel('Hs XSITE'); ylabel('HTc Main');

subplot(2,2,3)
plot_regression(Hs_xsite(ind_in),Htc1_xsite(ind_in),[],[],'ortho');
xlabel('Hs XSITE'); ylabel('HTc1 XSITE');

subplot(2,2,4)
plot_regression(Hs_xsite(ind_in),Htc2_xsite(ind_in),[],[],'ortho');
xlabel('Hs XSITE'); ylabel('HTc2 XSITE');

figure('Name','wT from sonic regressions');
plot_regression(cov_wT_xsite(ind_in),cov_wT_main(ind_in),[],[],'ortho');

return

figure('Name','sigma T regressions');
subplot(2,2,1)
plot_regression(stdTs_xsite(ind_in),stdTs_main(ind_in));
subplot(2,2,2)
plot_regression(stdTs_xsite(ind_in),stdTc1_main(ind_in));
subplot(2,2,3)
plot_regression(stdTs_xsite(ind_in),stdTc1_xsite(ind_in));
subplot(2,2,4)
plot_regression(stdTs_xsite(ind_in),stdTc2_xsite(ind_in));
