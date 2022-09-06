function h = fcrn_plot_diagnostics(tv_exp,SiteId)
% h = fcrn_plot_diagnostics(Stats_all,T_air,p_bar,Rn,WindDirection)
%
% Plot diagnostic variables

arg_default('tv_exp',floor([now-1 now]));
arg_default('SiteId',fr_current_siteid);

%----------------------------------------------------
% Load EC data
%----------------------------------------------------
if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,SiteId,'ubc_pc_setup\site_specific'));
end
Stats_xsite = fcrn_load_data(tv_exp);


cd(fullfile(xsite_base_path,SiteId,'Setup'));
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,4/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_all(1).Configuration.hhour_path;
tv = get_stats_field(Stats_all,'TimeVector');

%----------------------------------------------------
% Load site climate data
%----------------------------------------------------
[dum,dum,pth_db] = fr_get_local_path;
tv_db = read_bor(fullfile(pth_db,'2005',SiteId,'clean','thirdstage','clean_tv'),8);;
[tv_dum,ind_db,ind] = intersect(fr_round_hhour(tv_db),fr_round_hhour(tv));

try
    wd = read_bor(fullfile(pth_db,'2005',SiteId,'clean','thirdstage','wind_direction_main'),[],[],[],ind_db);;
catch
    wd = NaN.* ones(size(ind_db));
end
try
    Rn = read_bor(fullfile(pth_db,'2005',SiteId,'clean','thirdstage','radiation_net_main'),[],[],[],ind_db);;
catch
    Rn = NaN.* ones(size(ind_db));
end
try
    Ta = read_bor(fullfile(pth_db,'2005',SiteId,'clean','thirdstage','air_temperature_main'),[],[],[],ind_db);
catch
    Ta = NaN.* ones(size(ind_db));
end
try
    Pb = read_bor(fullfile(pth_db,'2005',SiteId,'clean','thirdstage','barometric_pressure_main'),[],[],[],ind_db);;
catch
    Pb = NaN.* ones(size(ind_db));
end
try
    r_h = read_bor(fullfile(pth_db,'2005',SiteId,'clean','thirdstage','relative_humidity_main'),[],[],[],ind_db);;
catch
    r_h = NaN.* ones(size(ind_db));
end

% Cleaning climate
ind = find(wd<-999);
wd(ind) = NaN;
ind = find(Rn<-999);
Rn(ind) = NaN;
ind = find(Ta<-999);
Ta(ind) = NaN;
ind = find(Pb<-999);
Pb(ind) = NaN;
ind = find(r_h<-999);
r_h(ind) = NaN;

plotting_setup

dv = datevec(tv(1));
doy = tv - datenum(dv(1),1,0);
doy_ticks = [floor(doy(1)):0.5:ceil(doy(end))];

%----------------------------------------------------
% Climate
%----------------------------------------------------
fsize_txorg = get(0,'DefaultTextFontSize');
fsize_axorg = get(0,'DefaultAxesFontSize'); 
set(0,'DefaultAxesFontSize',10) 
set(0,'DefaultTextFontSize',10);

h(1).name = 'Diagnostics_Climate';
h(1).hand = figure;
set(h(1).hand,'Name',h(1).name);
set(h(1).hand,'NumberTitle','off');


% Net Radiation
subplot('Position',subplot_position(5,1,1));
plot(doy,Rn);
subplot_label(gca,5,1,1,doy_ticks,yticks(Rn,200),2)
ylabel('Rn (W m^{-2})')

% Wind direction
subplot('Position',subplot_position(5,1,2));
plot(doy,wd);
subplot_label(gca,5,1,2,doy_ticks,0:60:360,2)
ylabel('Wind dir. (deg)')

% Relative humidity
subplot('Position',subplot_position(5,1,3));
plot(doy,r_h);
subplot_label(gca,5,1,3,doy_ticks,yticks(r_h,20),2)
ylabel('r_h (%)')

% Pressures
subplot('Position',subplot_position(5,1,4));
plot(doy,[Pb]);
subplot_label(gca,5,1,4,doy_ticks,yticks([Pb;Pb],20),2)
ylabel('XSITE p (kPa)')

% Temperatures
subplot('Position',subplot_position(5,1,5));
plot(doy,[Ta]);
subplot_label(gca,5,1,5,doy_ticks,yticks([Ta],5),2)
ylabel('XSITE T (^oC)')

zoom_together(gcf,'x','on')

%----------------------------------------------------
% Best temperature and pressure
%----------------------------------------------------
Tair_xsite = get_stats_field(Stats_all,'MiscVariables1.Tair');
Tair_site  = get_stats_field(Stats_all,'MiscVariables2.Tair');
p_xsite    = get_stats_field(Stats_all,'MiscVariables1.BarometricP');
p_site     = get_stats_field(Stats_all,'MiscVariables2.BarometricP');

h(2).name = 'Diagnostics_best_temperature_and_pressure';
h(2).hand = figure;
set(h(2).hand,'Name',h(2).name);
set(h(2).hand,'NumberTitle','off');

subplot('Position',subplot_position(2,1,1))
plot(doy,Tair_xsite,'o-',doy,Tair_site)
subplot_label(gca,2,1,1,doy_ticks,[10:10:30],1)

subplot('Position',subplot_position(2,1,2))
plot(doy,p_xsite,'o-',doy,p_site)
subplot_label(gca,2,1,1,doy_ticks,[90:100],1)
legend('XSITE','MainEddy')

%----------------------------------------------------
% Licor temperatures and pressures
%----------------------------------------------------
h(3).name = 'Diagnostics_bench_temperatures_and_pressures';
h(3).hand = figure;
set(h(3).hand,'Name',h(3).name);
set(h(3).hand,'NumberTitle','off');

c = Stats_all(1).Configuration2; % Main Eddy config
i = 0; numTb = [];
while isempty(numTb) & i<length(c.Instrument)
    i = i+1;
    numTb   = find(strcmp(c.Instrument(i).ChanNames,'Tbench'));
end
Tbench_site  = get_stats_field(Stats_all,['Instrument(' num2str(i+length(Stats_all(1).Configuration1.Instrument)) ').Avg(' num2str(numTb) ')']);
j = 0; numPb = [];
while isempty(numPb) & j<length(c.Instrument)
    j = j+1;
    numPb   = find(strcmp(c.Instrument(j).ChanNames,'Plicor'));
end
Plicor_site  = get_stats_field(Stats_all,['Instrument(' num2str(j+length(Stats_all(1).Configuration1.Instrument)) ').Avg(' num2str(numPb) ')']);

Tbench_xsite = get_stats_field(Stats_all,'Instrument(2).Avg(4)');
Plicor_xsite = get_stats_field(Stats_all,'Instrument(2).Avg(5)');

subplot('Position',subplot_position(2,1,1))
plot(doy,[Tbench_xsite Tbench_site Ta])
subplot_label(gca,2,1,1,doy_ticks,[10:10:50],1)
legend('XSITE','MainEddy','Air');

subplot('Position',subplot_position(2,1,2))
plot(doy,[Plicor_xsite Plicor_site Pb])
subplot_label(gca,2,1,1,doy_ticks,[70:10:100],1)


%----------------------------------------------------
% Individual system diagnostics
%----------------------------------------------------
h(3) = fcrn_plot_system_diagnostics(Stats_all,'XSITE_CP')
h(4) = fcrn_plot_system_diagnostics(Stats_all,'XSITE_OP')
h(5) = fcrn_plot_system_diagnostics(Stats_all,'MainEddy')
