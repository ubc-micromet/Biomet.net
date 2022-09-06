function xsite_on_tp_tc_comparison

tv_exp = datenum(2005,7,21:now);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'ON_TP','ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);


cd(fullfile(xsite_base_path,'ON_TP','Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;

% Comparing straight standard deviations (using avg detrend)
std_Ta_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std(4)');
std_Ts_xsite = get_stats_field(Stats_all,'Instrument(1).Std(4)');
std_Tc_xsite  = get_stats_field(Stats_all,'Instrument(6).Std([1 2])');
std_Ta       = get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std(4)');

std_h2o     = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Std(6)');
min_h2o     = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Min(6)');

ind = find(min_h2o>1);

figure('Name','std_Ta_xsite(ind),std_Tc_xsite(ind,1)');
plot_regression(std_Ta_xsite(ind),std_Tc_xsite(ind,1),[],[],'ortho');

ind = find(std_Ta < 1.1);

figure('Name','std_Ta(ind),std_Tc_xsite(ind,1)');
plot_regression(std_Ta(ind),std_Tc_xsite(ind,1),[],[],'ortho');

ind = find(std_Ta < 1.1 & min_h2o>1);

figure('Name','std_Ta(ind),std_Ta_xsite(ind,1)');
plot_regression(std_Ta(ind),std_Ta_xsite(ind,1),[],[],'ortho');

% Comparing standard deviations after linear detrend
ind = find(std_Ta < 1.1 & min_h2o>1);

std_Ta_xsite_ld = sqrt(get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.LinDtr.Cov(4,4)'));
std_Ta_ld       = sqrt(get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Cov(4,4)'));

figure('Name','std_Ta_ld(ind),std_Ta_xsite_ld(ind,1)');
plot_regression(std_Ta_ld(ind),std_Ta_xsite_ld(ind,1),[],[],'ortho');

Hs_xsite = (get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs'));
Hs       = (get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs'));
Hs_xsite_ld = (get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.LinDtr.Fluxes.Hs'));
Hs_ld       = (get_stats_field(Stats_all,'MainEddy.Three_Rotations.LinDtr.Fluxes.Hs'));

figure('Name','Hs(ind),Hs_xsite(ind)');
plot_regression(Hs(ind),Hs_xsite(ind),[],[],'ortho');

figure('Name','Hs_ld(ind),Hs_xsite_ld(ind)');
plot_regression(Hs_ld(ind),Hs_xsite_ld(ind),[],[],'ortho');

return

