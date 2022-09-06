function xsite_BC_DF48

%---------------------------------------------------------------------
% Manually load and compare concetrations
x1 = load(fullfile(xsite_base_path,'BC_DF48','met-data','hhour','050421s.hc.mat'));
x2 = load(fullfile(xsite_base_path,'BC_DF48','met-data','hhour','050422s.hc.mat'));
x3 = load(fullfile(xsite_base_path,'BC_DF48','met-data','hhour','050423s.hc.mat'));
stats1 = x1.stats;
stats2 = x2.stats;
stats3 = x3.stats;

stats.AfterRot.AvgMinMax = shiftdim([shiftdim(stats1.AfterRot.AvgMinMax,2); shiftdim(stats2.AfterRot.AvgMinMax,2); shiftdim(stats3.AfterRot.AvgMinMax,2)],1);
stats.Fluxes.AvgDtr = [stats1.Fluxes.AvgDtr; stats2.Fluxes.AvgDtr; stats3.Fluxes.AvgDtr];
stats.TimeVector = [stats1.TimeVector; stats2.TimeVector; stats3.TimeVector];

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
h_main  = squeeze(stats.Fluxes.AvgDtr(:,2));
le_main = squeeze(stats.Fluxes.AvgDtr(:,1));
le_main = squeeze(stats.Fluxes.AvgDtr(:,1));

%wT_main = squeeze(stats.AfterRot.Cov.AvgDtr(3,4,:));
%wC_main = squeeze(stats.AfterRot.Cov.AvgDtr(3,7,:));
%wH_main = squeeze(stats.AfterRot.Cov.AvgDtr(3,8,:));

tv_exp = datenum(2005,4,21):floor(now);
cd(fullfile(xsite_base_path,'BC_DF48','Setup_XSITE'));
%load D:\kai_data\Projects_data\XSITE\Experiments\BC_DF48\met-data\hhour\050421s.hXSITE.mat;
%Stats_xsite = Stats;
Stats_xsite = fcrn_load_data(tv_exp);
[co2_avg_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Avg(5)']);
[h2o_avg_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Avg(6)']);
[co2_std_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Std(5)']);
[h2o_std_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Std(6)']);

[u_avg_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Avg(1)']);
[u_avg_inst,tv] = get_stats_field(Stats_xsite,['Instrument(1).MiscVariables.CupWindSpeed']);

[u_std_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Std(1)']);
[w_std_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Std(3)']);
[Ta_std_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.Std(4)']);

[fc_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc']);
[h_xsite,tv]  = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs']);
[le_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.AvgDtr.Fluxes.LE_L']);

[hist_xsite,tv] = get_stats_field(Stats_xsite,['MiscVariables.WindDirHistogram']);
[wind_dir_xsite,tv] = get_stats_field(Stats_xsite,['Instrument(1).MiscVariables.WindDirection']);
 
[wT_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.AvgDtr.Cov(3,4)']);
[wC_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.AvgDtr.Cov(3,5)']);
[wH_xsite,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Three_Rotations.AvgDtr.Cov(3,6)']);

[del,tv] = get_stats_field(Stats_xsite,['XSITE_CP.Delays.Calculated']);

% Site Climate data:
[tv_clim,climateData] = fr_read_csi(fullfile(xsite_base_path,'BC_DF48','met-data','csi_net','fr_clim1*'),tv,[23,28,53,77,78]);
wind_speed_clim = climateData(:,1);
wind_dir_clim   = climateData(:,2);
pbar_clim       = climateData(:,3);
Ta_clim         = climateData(:,4);
Rh_clim         = climateData(:,5);

[junk,ind_main,ind_clim] = intersect(tv_main,tv_clim);


ind = find(u_avg_main(ind_main)>0.5);
figure('Name','Error on wind direction');
plot(wind_dir_clim(ind_clim(ind)),(u_avg_main(ind_main(ind)) - wind_speed_clim(ind_clim(ind)))./u_avg_main(ind_main(ind)),'ro');

ind = find(co2_avg_main ~= 0 & abs(co2_avg_main-co2_avg_xsite)<2 & wind_dir_xsite<200);
ind = find(wind_dir_clim(ind_clim)>250 & wind_dir_clim(ind_clim)<350 & u_avg_main(ind_main)~= 0);
ind = ind_main(ind);
ind = find(wind_dir_clim(ind_clim)>250 & wind_dir_clim(ind_clim)<350 & u_avg_main(ind_main)~= 0);
ind_clim = ind_clim(ind);

figure('Name','Ta std regression');
plot_regression(Ta_std_main(ind),Ta_std_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','CO_2 std regression');
plot_regression(co2_std_main(ind),co2_std_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','H_2O std regression');
plot_regression(h2o_std_main(ind),h2o_std_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

% figure('Name','Wind speeds and directions');
% plot(tv_main,[u_avg_main],tv,u_avg_xsite,tv_clim,wind_speed_clim,tv_clim,wind_dir_clim./100);

figure('Name','Wind directions');
plot(tv(ind)-8/24,wind_dir_xsite(ind),tv_clim-8/24,wind_dir_clim);
%datevec('x');

figure('Name','CO_2 avg regression');
plot_regression(co2_avg_main(ind),co2_avg_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','H_2O avg regression');
plot_regression(h2o_avg_main(ind),h2o_avg_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','u avg regression');
plot_regression(u_avg_main(ind),u_avg_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','u std regression');
plot_regression(u_std_main(ind),u_std_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','w std regression');
plot_regression(w_std_main(ind),w_std_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','Fc regression');
plot_regression(fc_main(ind),fc_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','LE regression');
plot_regression(le_main(ind),le_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

figure('Name','Hs regression');
plot_regression(h_main(ind),h_xsite(ind),[],[],'ortho');
xlabel('Main'),ylabel('XSITE');

return

