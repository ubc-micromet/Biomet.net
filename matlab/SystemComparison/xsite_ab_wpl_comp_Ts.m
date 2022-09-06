function xsite_ab_wpl_comp_Ts

T_prt = get_stats_field(Stats_all,'Instrument(9).Avg');
T_sonic_xs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Avg(4)');
T_sonic_pi = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Avg(4)');

figure
plot(T_prt,[T_sonic_pi,T_sonic_xs],'.')
figure
plot([T_sonic_pi,T_sonic_xs,T_prt])
