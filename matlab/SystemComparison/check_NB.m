Stats_all = fcrn_load_data(datenum(2003,8,10:33),'NB');

Fc = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc'));
LE = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L'));
Hs = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs'));
ustar = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar'));
[Hs_complex,tv] = get_stats_field(Stats_all,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');

co2 = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.Avg(5)'));
h2o = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.Avg(6)'));
T_std = real(get_stats_field(Stats_all,'MainEddy.Three_Rotations.Std(4)'));
delay_co2 = real(get_stats_field(Stats_all,'MainEddy.Delays.Calculated(1)'));
delay_h2o = real(get_stats_field(Stats_all,'MainEddy.Delays.Calculated(2)'));

doy = tv - datenum(2003,1,0);

ind_exclude = find(T_std > 5 | co2<300 | co2>450);

Fc(ind_exclude) = NaN;
LE(ind_exclude) = NaN;
Hs(ind_exclude) = NaN;
co2(ind_exclude) = NaN;
h2o(ind_exclude) = NaN;
delay_co2(ind_exclude) = NaN;
delay_h2o(ind_exclude) = NaN;

figure
subplot('Position',subplot_position(2,1,1));
hist(delay_co2,-5:5)
subplot_label(gca,2,1,1,-6:6,0:50:300,1);

subplot('Position',subplot_position(2,1,2));
hist(delay_co2,-5:5)
subplot_label(gca,2,1,2,[-6:6],[0:50:300],1);

figure
subplot('Position',subplot_position(2,1,1));
plot(doy,co2,'g')
subplot_label(gca,2,1,1,[221:246],[300:25:425],1);

subplot('Position',subplot_position(2,1,2));
plot(doy,h2o,'b')
subplot_label(gca,2,1,2,[221:246],[0:10:30],1);

figure

subplot('Position',subplot_position(2,1,1));
plot(doy,Fc,'g')
subplot_label(gca,2,1,1,[221:246],[-40:10:25],1);

subplot('Position',subplot_position(2,1,2));
plot(doy,LE,'b',doy,Hs,'r')
subplot_label(gca,2,1,2,[221:246],[-100:100:400],1);

figure
ind = find(LE<20);
plot(ustar(ind),Fc(ind),'o')

fPsd = get_stats_field(Stats_all,'MainEddy.Spectra.fPsd(:,5)');
f = get_stats_field(Stats_all,'MainEddy.Spectra.Flog');
P_norm = get_stats_field(Stats_all,'MainEddy.Spectra.Psd_norm(5)');
fP_n = fPsd./(P_norm * ones(1,100));

ind = 20:28; % Midday for one day

figure
loglog(mean(f(ind,:)),mean(fP_n(ind,:)),'.')
