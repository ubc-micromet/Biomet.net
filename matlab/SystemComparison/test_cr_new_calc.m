function test_cr_new_calc

x = load(fullfile(xsite_base_path,'BC_DF48','met-data','hhour','050421.hc.mat'));
stats = x.stats;

tv_main = stats.TimeVector;
co2_avg_main = squeeze(stats.AfterRot.AvgMinMax(1,7+4,:));
h2o_avg_main = squeeze(stats.AfterRot.AvgMinMax(1,8+4,:));
co2_std_main = squeeze(stats.AfterRot.AvgMinMax(4,7+4,:));
h2o_std_main = squeeze(stats.AfterRot.AvgMinMax(4,8+4,:));

u_avg_main = squeeze(stats.AfterRot.AvgMinMax(1,1,:));
v_avg_main = squeeze(stats.AfterRot.AvgMinMax(1,2,:));
u_std_main = squeeze(stats.AfterRot.AvgMinMax(4,1,:));
v_std_main = squeeze(stats.AfterRot.AvgMinMax(4,2,:));
w_std_main = squeeze(stats.AfterRot.AvgMinMax(4,3,:));
Ta_std_main = squeeze(stats.AfterRot.AvgMinMax(4,4,:));

fc_main = squeeze(stats.Fluxes.AvgDtr(:,5));
hs_main  = squeeze(stats.Fluxes.AvgDtr(:,2));
le_main = squeeze(stats.Fluxes.AvgDtr(:,1));
wT_main = squeeze(stats.AfterRot.Cov.AvgDtr(3,4,:));
wC_main = squeeze(stats.AfterRot.Cov.AvgDtr(3,7,:));
wH_main = squeeze(stats.AfterRot.Cov.AvgDtr(3,8,:));

load \\FLUXNET02\HFREQ_XSITE\Experiments\BC_DF48\met-data\hhour\050421.hCnew.mat

[co2_avg_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Avg(5)']);
[h2o_avg_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Avg(6)']);
[co2_std_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Std(5)']);
[h2o_std_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Std(6)']);

[u_avg_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Avg(1)']);
[u_std_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Std(1)']);
[w_std_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Std(3)']);
[Ta_std_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.Std(4)']);

[fc_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc']);
[hs_new,tv]  = get_stats_field(Stats,['MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs']);
[le_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L']);

[hist_new,tv] = get_stats_field(Stats,['MiscVariables.WindDirHistogram']);
%[wind_dir_new,tv] = get_stats_field(Stats,['Instrument(5).MiscVariables.WindDirection']);

[wT_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.AvgDtr.Cov(3,4)']);
[wC_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.AvgDtr.Cov(3,5)']);
[wH_new,tv] = get_stats_field(Stats,['MainEddy.Three_Rotations.AvgDtr.Cov(3,6)']);

[del,tv] = get_stats_field(Stats,['MainEddy.Delays.Calculated']);

ind = find(co2_avg_main > 1 & co2_std_main < 10);

figure('Name','Ta std regression');
plot_regression(Ta_std_main(ind),Ta_std_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','CO_2 std regression');
plot_regression(co2_std_main(ind),co2_std_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','H_2O std regression');
plot_regression(h2o_std_main(ind),h2o_std_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

% figure('Name','Wind speeds and directions');
% plot(tv_main,[u_avg_main],tv,u_avg_new,tv_clim,wind_speed_clim,tv_clim,wind_dir_clim./100);

figure('Name','CO_2 avg regression');
plot_regression(co2_avg_main(ind),co2_avg_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','H_2O avg regression');
plot_regression(h2o_avg_main(ind),h2o_avg_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','u avg regression');
plot_regression(u_avg_main(ind),u_avg_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','u std regression');
plot_regression(u_std_main(ind),u_std_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','w std regression');
plot_regression(w_std_main(ind),w_std_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','Fc regression');
plot_regression(fc_main(ind),fc_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','LE regression');
plot_regression(le_main(ind),le_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','Hs regression');
plot_regression(hs_main(ind),hs_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','wC regression');
plot_regression(wC_main(ind),wC_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','wH regression');
plot_regression(wH_main(ind),wH_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','wT regression');
plot_regression(wT_main(ind),wT_new(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

return
