function xsite_on_tp_wind_confirmation

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

tv  = get_stats_field(Stats_all,'TimeVector');
doy = tv - datenum(2005,1,0);

[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','clean_tv'),8);;
wd = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','wind_direction_main'));;
ws = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','wind_speed_cup_main'));;
precip = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','precipitation'));;
Ta = read_bor(fullfile(pth_db,'2005','on_tp','clean','thirdstage','air_temperature_main'));;

[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));

wd = wd(ind_db);
ws = ws(ind_db);
precip = precip(ind_db);
Ta = Ta(ind_db);

wd_CSAT = get_stats_field(Stats_all,'Instrument(9).MiscVariables.WindDirection');
ws_CSAT = get_stats_field(Stats_all,'Instrument(9).MiscVariables.CupWindSpeed');
wd_GILL = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
ws_GILL = get_stats_field(Stats_all,'Instrument(1).MiscVariables.CupWindSpeed');
Ta_xsite = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.Avg(4)');
 
% figure('Name','Temperature comparison');
% plot(doy,[Ta Ta_xsite]);
% xlabel('DOY');
% ylabel('Ta');
% legend('Site','XSITE');

% Good sonic wind direction
% ind = find(wd_CSAT > 120 & wd_CSAT<240);

ind = find(ws_CSAT < 10 & ws_CSAT>1);

figure('Name','Relative wind speed diff vs direction');
subplot(3,1,1)
plot(wd_CSAT(ind),(ws(ind)-ws_CSAT(ind))./ws_CSAT(ind).*100,'.');
line([0 360],[0 0],'Color','k','LineStyle',':')
xlabel('Wind dir. CSAT');
ylabel('RMY-CSAT');
axis([0 360 -20 20])

subplot(3,1,2)
plot(wd_CSAT(ind),(ws_GILL(ind)-ws_CSAT(ind))./ws_CSAT(ind).*100,'.');
line([0 360],[0 0],'Color','k','LineStyle',':')
xlabel('Wind dir. CSAT');
ylabel('GILL-CSAT');
axis([0 360 -20 20])

subplot(3,1,3)
plot(wd_CSAT(ind),(ws_GILL(ind)-ws(ind))./ws_GILL(ind).*100,'.');
line([0 360],[0 0],'Color','k','LineStyle',':')
xlabel('Wind dir. CSAT');
ylabel('GILL-RMY');
axis([0 360 -20 20])

figure('Name','CSAT vs RMY wind direction');
plot_regression(wd,wd_CSAT);
xlabel('Wind dir. RMY');
ylabel('Wind dir. CSAT');

return

figure('Name','CSAT vs RMY wind speed');
plot_regression(ws(ind),ws_CSAT(ind));
xlabel('Wind speed RMY');
ylabel('Wind speed CSAT');

figure('Name','Wind speed diff vs direction - RMY');
plot(wd_CSAT(ind),(ws(ind)-ws_CSAT(ind)),'.');
xlabel('Wind dir. CSAT');
ylabel('Wind speed (RMY-CSAT)');

figure('Name','CSAT vs GILL wind speed');
plot_regression(ws_GILL(ind),ws_CSAT(ind));
xlabel('Wind speed GILL');
ylabel('Wind speed CSAT');

figure('Name','Wind speed diff vs direction - GILL');
plot(wd_CSAT(ind),ws_GILL(ind)-ws_CSAT(ind),'.');
xlabel('Wind dir. CSAT');
ylabel('Wind speed (GILL-CSAT)');

figure('Name','RMY vs GILL wind speed');
plot_regression(ws_GILL(ind),ws(ind));
xlabel('Wind speed GILL');
ylabel('Wind speed RMY');

figure('Name','Wind speed diff vs direction - GILL and RMY');
plot(wd_CSAT(ind),ws_GILL(ind)-ws(ind),'.');
xlabel('Wind dir. CSAT');
ylabel('Wind speed (GILL-RMY)');

figure('Name','Wind speed diff and precip');
subplot(2,1,1)
plot(doy(ind),precip(ind));
xlabel('DOY');
ylabel('precip');
subplot(2,1,2)
plot(doy(ind),ws_GILL(ind)-ws_CSAT(ind));
xlabel('DOY');
ylabel('Wind speed (GILL-CSAT)');

return


