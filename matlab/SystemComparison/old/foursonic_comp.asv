function h = foursonic_comp

kais_plotting_setup;
close all;


cd C:\UBC_PC_Setup\Site_specific\4SonicExperiment

tv =[];
tv = [tv datenum(2004,6,24)+[74/96:1/48:98/96]];
%tv = tv([1:13 17:end]);
tv = [tv datenum(2004,6,25)+[64/96:1/48:96/96]];
tv = [tv datenum(2004,6,26)+[2/96:1/48:10/96]];
tv = [tv datenum(2004,6,26)+[70/96:1/48:96/96]];
tv = [tv datenum(2004,6,27)+[2/96:1/48:16/96]];
tv = [tv datenum(2004,6,27)+[69/96:1/48:96/96]];
tv = [tv datenum(2004,6,28)+[2/96:1/48:16/96]];
tv = [tv datenum(2004,6,28)+[72/96:1/48:(96+6)/96]];
tv = [tv datenum(2004,6,29)+[76/96:1/48:(96+16)/96]];

% Stats = yf_calc_module_main(tv);
% Stats(1).Configuration.pth_tv_exclude = Stats(1).Configuration.hhour_path;
% save \\ANNEX001\HFREQ_XSITE\Experiments\4SonicExperiment\met-data\hhour\foursonics Stats
x = load(fullfile(pwd,'..','met-data','hhour','foursonics.mat'));
Stats = x.Stats;
[dd,hhour_pth] = fr_get_local_path;
Stats(1).Configuration.pth_tv_exclude = '\\Fluxnet02\HFREQ_XSITE\Experiments\4SonicExperiment\met-data\hhour\';

dir_hist = get_stats_field(Stats,'Instrument(1).MiscVariables.WindDirection_Histogram');
imagesc(dir_hist(end-18:end,:)');
colorbar;

% XSITE vs GillR3-50 S/N 244
[tv_dum,h12] = fcrn_clean(Stats,{'Instrument(1)','Instrument(2)'},'foursonic',[],[],0);
fcrn_print_report(h12,'e:\');

% XSITE vs GillR3-50 S/N 295
[tv_dum,h13] = fcrn_clean(Stats,{'Instrument(1)','Instrument(3)'},'foursonic',[],[],0);
fcrn_print_report(h13,'e:\');

% XSITE vs CSAT3 - positioned farther away
ind = find(tv<datenum(2004,6,27,12,0,0));
[tv_dum,h14_pos1] = fcrn_clean(Stats(ind),{'Instrument(1)','Instrument(4)'},'foursonic',[],{'CSAT3_farther_away'},0);
fcrn_print_report(h14_pos1,'e:\');

% XSITE vs CSAT3 - positioned closer to the other two sonics
ind = find(tv>datenum(2004,6,27,12,0,0));
Stats(ind(1)).Configuration.pth_tv_exclude = Stats(1).Configuration.pth_tv_exclude;
[tv_dum,h14_pos2] = fcrn_clean(Stats(ind),{'Instrument(1)','Instrument(4)'},'foursonic',[],{'CSAT3_closer_in'},0);
fcrn_print_report(h14_pos2,'e:\');

% XSITE vs CSAT3 - all
[tv_dum,h14] = fcrn_clean(Stats,{'Instrument(1)','Instrument(4)'},'foursonic',[],[],0);
fcrn_print_report(h14,'e:\');

% XSITE vs GillR3-50 S/N 295 - with sample tube
ind = find(tv>datenum(2004,6,29,12,0,0));
Stats(ind(1)).Configuration.pth_tv_exclude = Stats(1).Configuration.pth_tv_exclude;
[tv_dum,h13] = fcrn_clean(Stats(ind),{'Instrument(1)','Instrument(3)'},'foursonic',[],{'XSITE_SAMPLET_295'},0);
fcrn_print_report(h13,'e:\');

% XSITE vs CSAT3 - with sample tube
ind = find(tv>datenum(2004,6,29,12,0,0));
Stats(ind(1)).Configuration.pth_tv_exclude = Stats(1).Configuration.pth_tv_exclude;
[tv_dum,h14_pos1] = fcrn_clean(Stats(ind),{'Instrument(1)','Instrument(4)'},'foursonic',[],{'XSITE_SAMPLET_CSAT'},0);
fcrn_print_report(h14_pos1,'e:\');
