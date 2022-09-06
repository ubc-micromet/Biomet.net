%----------------------------------------------------
% Load new data
%----------------------------------------------------
cd C:\UBC_PC_Setup\Site_specific\BS_new_eddy

% new_calc_and_save(datenum(2004,4,30),'bs')
tv_dat = datenum(2004,5,13);

Stats_new = fcrn_load_data(tv_dat,'bs')

cd C:\UBC_PC_Setup\Site_specific\xsite

Stats_xsite = fcrn_load_data(tv_dat,'xsite')

Stats_all = fcrn_merge_stats(Stats_new,Stats_xsite)

% Correct the density effect by using the same Tair for both systems:
UBC_Biomet_Constants;

% Calculate correct total air density
[Ta,tv] = get_stats_field(Stats_all,'Instrument(6).Avg');
tv = fr_round_hhour(tv);
Pb = get_stats_field(Stats_all,'Instrument(2).Avg');
rho = (Pb.*1000)./((Ta+ZeroK).*R); % mol m^-3

% Calculate XSITE total air density
Ta_xsite = get_stats_field(Stats_all,'Instrument(11).Avg');
Pb_xsite = get_stats_field(Stats_all,'Instrument(10).Avg');
rho_xsite = (Pb_xsite.*1000)./((Ta_xsite+ZeroK).*R); % mol m^-3

% Correction factor
c = rho./rho_xsite;

% Extract fluxes to be corrected
H  = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Stats_cor = set_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs',Hs .* c);

h = fcrn_plot_report(Stats_all,[13 34],{'XSITE_CP','MainEddy'});
h = fcrn_plot_report(Stats_cor,[13 34],{'XSITE_CP','MainEddy'});

Tsys = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Avg(4)');
Ts = get_stats_field(Stats_all,'Instrument(5).Avg(4)');
Ts_xsite = get_stats_field(Stats_all,'Instrument(7).Avg(4)');

% Read good temperature
pth = biomet_path(2004,'bs','clean\secondstage');
Tm = read_bor([pth 'air_temperature_main']);
clean_tv = fr_round_hhour(read_bor([pth 'clean_tv'],8));

[tv_dum,ind_tv,ind_clean] = intersect(tv,clean_tv);
Tm = Tm(ind_clean);

figure
plot([Tm,Ta,Ta_xsite])

figure
plot(Tm,Ta,'bo',Tm,Ta_xsite,'go',[-2 12],[-2 12],'k:')

