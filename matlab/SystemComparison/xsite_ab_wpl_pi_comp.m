function xsite_on_epl_pi_comp

%---------------------------------------------------------------------
% Comparison of calcs
x = load('D:\Experiments\ON_EPL\met-data\hhour\040630.hMB.mat');
Stats_mb = x.Stats;
tv_pi  = get_stats_field(Stats_mb,'TimeVector');% - 7/24;
H_pi   = get_stats_field(Stats_mb,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
LE_pi  = get_stats_field(Stats_mb,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
Fc_pi  = get_stats_field(Stats_mb,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
Ust_pi = get_stats_field(Stats_mb,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');

cd D:\Experiments\ON_EPL\Setup
Stats_on_epl = fcrn_load_data(datenum(2004,6,30));
tv  = get_stats_field(Stats_on_epl,'TimeVector');% - 7/24;
H   = get_stats_field(Stats_on_epl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
LE  = get_stats_field(Stats_on_epl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
Fc  = get_stats_field(Stats_on_epl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
Ust = get_stats_field(Stats_on_epl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');

[tv_all,ind_pi,ind] = intersect(fr_round_hhour(tv_pi),fr_round_hhour(tv));

figure
plot([H(ind),H_pi(ind_pi)])
figure
plot([LE(ind),LE_pi(ind_pi)])
figure
plot([Fc(ind),Fc_pi(ind_pi)])

figure
plot_regression(H(ind),H_pi(ind_pi))


return

