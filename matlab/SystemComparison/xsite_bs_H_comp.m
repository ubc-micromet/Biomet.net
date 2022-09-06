function h = xsite_bs_H_comp(Stats_all,tv_exclude,ind_org,ind_bef,ind_sw1,ind_sw2)
% Comparison of Sonic vs. Tc heat fluxes 

[Hs,tv] = get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Fluxes.Hs');
Hscp    = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.LinDtr.Fluxes.Hs');
Htc1    = get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Fluxes.Htc1');
Htc2    = get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Fluxes.Htc2');

[tv_dum,ind] = intersect(tv,tv_exclude);

Hs(ind)   = NaN;
Hscp(ind) = NaN;
ind_tc = find((Hs>10 & Htc1<5) | Htc1<-200);
Htc1([ind; ind_tc]) = NaN;
ind_tc = find((Hs>10 & Htc2<5) | Htc2<-200);
Htc2([ind; ind_tc]) = NaN;

h(1).name = 'H_comp_Site_vs_Tc1';
h(1).hand = figure;
set(h(1).hand,'Name',h(1).name);
set(h(1).hand,'NumberTitle','off');
set(gcf,'DefaultTextFontSize');

subplot(2,2,1)
plot_regression(Hs(ind_org),Htc1(ind_org));
title('Setup1a')

subplot(2,2,2)
plot_regression(Hs(ind_bef),Htc1(ind_bef));
title('Setup1b')

subplot(2,2,3)
plot_regression(Hs(ind_sw1),Htc1(ind_sw1));
title('Setup2')

subplot(2,2,4)
plot_regression(Hs(ind_sw2),Htc1(ind_sw2));
title('Setup3')

h(2).name = 'H_comp_Site_vs_Tc2';
h(2).hand = figure;
set(h(2).hand,'Name',h(2).name);
set(h(2).hand,'NumberTitle','off');
set(gcf,'DefaultTextFontSize');

subplot(2,2,1)
plot_regression(Hs(ind_org),Htc2(ind_org));
title('Setup1a')

subplot(2,2,2)
plot_regression(Hs(ind_bef),Htc2(ind_bef));
title('Setup1b')

subplot(2,2,3)
plot_regression(Hs(ind_sw1),Htc2(ind_sw1));
title('Setup2')

subplot(2,2,4)
plot_regression(Hs(ind_sw2),Htc2(ind_sw2));
title('Setup3')

h(3).name = 'H_comp_Site_vs_XSITE';
h(3).hand = figure;
set(h(3).hand,'Name',h(3).name);
set(h(3).hand,'NumberTitle','off');
set(gcf,'DefaultTextFontSize');

subplot(2,2,1)
plot_regression(Hs(ind_org),Hscp(ind_org));
title('Setup1a')

subplot(2,2,2)
plot_regression(Hs(ind_bef),Hscp(ind_bef));
title('Setup1b')

subplot(2,2,3)
plot_regression(Hs(ind_sw1),Hscp(ind_sw1));
title('Setup2')

subplot(2,2,4)
plot_regression(Hs(ind_sw2),Hscp(ind_sw2));
title('Setup3')

return