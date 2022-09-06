function xsite_on_gr_site_calc_comparison(Stats_all,tv_exclude);

% Load data from database
[dum,dum,pth_db] = fr_get_local_path;
tv_db      = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','clean_tv'),8);;
Hs_site    = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','h_main'));;
Htc_site   = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','h_tc_main'));;
LE_site    = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','le_main'));;
Fc_site    = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','fc_main'));;
ustar_site = read_bor(fullfile(pth_db,'2005','on_gr','clean','thirdstage','ustar_main'));;

Fc_site = Fc_site./0.044;

Hs_site(Hs_site == 0) = NaN;

tv = get_stats_field(Stats_all,'TimeVector');

Hs_xsite    = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_main     = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
LE_main     = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
Fc_main     = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
ustar_main  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');

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

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));

tv_exclude = tv(find(LE_site(ind_db) == 0 ...
    | abs(Fc_site(ind_db))>20 | abs(Fc_main)>20 ...
    | LE_site(ind_db)<-10 | LE_main < -10 ));

[tv_dum,ind_ex] = intersect(tv,tv_exclude);

ind_in = setdiff(1:length(tv),ind_ex);



figure('Name','Flux calculation regression');
subplot(2,2,1);
plot_regression(Hs_main(ind_in),Hs_site(ind_db(ind_in)),[],[],'ortho');
xlabel('Hs Main'); ylabel('Hs site calc');

subplot(2,2,2);
plot_regression(LE_main(ind_in),LE_site(ind_db(ind_in)),[],[],'ortho');
xlabel('LE Main'); ylabel('LE site calc');

subplot(2,2,3);
plot_regression(Fc_main(ind_in),Fc_site(ind_db(ind_in)),[],[],'ortho');
xlabel('Fc Main'); ylabel('Fc site calc');

subplot(2,2,4);
plot_regression(ustar_main(ind_in),ustar_site(ind_db(ind_in)),[],[],'ortho');
xlabel('u* Main'); ylabel('u* site calc');

return

figure('Name','wT from sonic regressions');
plot_regression(cov_wT_xsite(ind_in),cov_wT_main(ind_in),[],[],'ortho');
xlabel('wT XSITE'); ylabel('wT Main');

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
