function compare_YF_OR(WHEN);
% Graphically compares climate data from YF (blue lines) and OR (red lines). WHEN
% should be 1+ years, e.g. 2004:2005 (default) or 2005. OR data exists only from
% DOY 142 in 2004 onward.

% Admin
arg_default('WHEN',2004:2005);
close all;

% Load OR traces [raw names]
% HMP45C
HMP_AirT_AVG = read_db(WHEN,'OR','\climate\or1','HMP_AirT_AVG');
HMP_RH_AVG   = read_db(WHEN,'OR','\climate\or1','HMP_RH_AVG');
%  RM Young Anemometer
WindDir_AVG  = read_db(WHEN,'OR','\climate\or1','WindDir_AVG');
WindSpd_AVG  = read_db(WHEN,'OR','\climate\or1','WindSpd_AVG');
% Li-cor Pyranometer
Solar_AVG    = read_db(WHEN,'OR','\climate\or1','Solar_AVG');
% Soil thermocouple profile
Soil_Tmp1_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp1_AVG');Soil_Tmp1_AVG = quick_clean(Soil_Tmp1_AVG);
Soil_Tmp2_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp2_AVG');Soil_Tmp2_AVG = quick_clean(Soil_Tmp2_AVG);
Soil_Tmp3_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp3_AVG');Soil_Tmp3_AVG = quick_clean(Soil_Tmp3_AVG);
Soil_Tmp4_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp4_AVG');Soil_Tmp4_AVG = quick_clean(Soil_Tmp4_AVG);
Soil_Tmp5_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp5_AVG');Soil_Tmp5_AVG = quick_clean(Soil_Tmp5_AVG);
Soil_Tmp6_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp6_AVG');Soil_Tmp6_AVG = quick_clean(Soil_Tmp6_AVG);
Soil_Tmp7_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp7_AVG');Soil_Tmp7_AVG = quick_clean(Soil_Tmp7_AVG);
Soil_Tmp8_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp8_AVG');Soil_Tmp8_AVG = quick_clean(Soil_Tmp8_AVG);
Soil_Tmp9_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Tmp9_AVG');Soil_Tmp9_AVG = quick_clean(Soil_Tmp9_AVG);
SoilTmp10_AVG   = read_db(WHEN,'OR','\climate\or1','SoilTmp10_AVG');SoilTmp10_AVG = quick_clean(SoilTmp10_AVG);
% Soil temperature averages by depth and renamed
soil_temperature_2cm_or   = Soil_Tmp1_AVG;
soil_temperature_5cm_or   = Soil_Tmp6_AVG;
soil_temperature_10cm_or  = nanmean([Soil_Tmp2_AVG,Soil_Tmp7_AVG]')';
soil_temperature_20cm_or  = nanmean([Soil_Tmp3_AVG,Soil_Tmp8_AVG]')';
soil_temperature_50cm_or  = nanmean([Soil_Tmp4_AVG,Soil_Tmp9_AVG]')';
soil_temperature_100cm_or = nanmean([Soil_Tmp5_AVG,SoilTmp10_AVG]')';
% % Soil moisture profile
% Soil_Mst1_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Mst1_AVG');
% Soil_Mst2_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Mst2_AVG');
% Soil_Mst3_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Mst3_AVG');
% Soil_Mst4_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Mst4_AVG');
% Soil_Mst5_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Mst5_AVG');
% Soil_Mst6_AVG   = read_db(WHEN,'OR','\climate\or1','Soil_Mst6_AVG');

% Load YF traces [first stage names]
% HMP45C
[air_temperature_hmp_12m, tv] = read_db(WHEN,'YF','\climate\clean','air_temperature_hmp_12m');
relative_humidity_hmp_12m = read_db(WHEN,'YF','\climate\clean','relative_humidity_hmp_12m');
%  RM Young Anemometer
wind_speed_12m = read_db(WHEN,'YF','\climate\clean','wind_speed_12m');
wind_direction_weighted_12m = read_db(WHEN,'YF','\climate\clean','wind_direction_weighted_12m');
% Li-cor Pyranometer
radiation_shortwave_downwell2_licor_18m = read_db(WHEN,'YF','\climate\clean','radiation_shortwave_downwell2_licor_18m');
% Soil thermocouple profile
soil_temperature1_2cm  = read_db(WHEN,'YF','\climate\clean','soil_temperature1_2cm');
soil_temperature2_2cm  = read_db(WHEN,'YF','\climate\clean','soil_temperature2_2cm');
soil_temperature_5cm   = read_db(WHEN,'YF','\climate\clean','soil_temperature_5cm');
soil_temperature_10cm  = read_db(WHEN,'YF','\climate\clean','soil_temperature_10cm');
soil_temperature_20cm  = read_db(WHEN,'YF','\climate\clean','soil_temperature_20cm');
soil_temperature_50cm  = read_db(WHEN,'YF','\climate\clean','soil_temperature_50cm');
soil_temperature_100cm = read_db(WHEN,'YF','\climate\clean','soil_temperature_100cm');
% Soil temperature averages by depth
soil_temperature_2cm  = nanmean([soil_temperature1_2cm,soil_temperature2_2cm]')';
% % Soil moisture profile
% soil_moisture_3cm_5cm    = read_db(WHEN,'YF','\climate\clean','soil_moisture_3cm_5cm');
% soil_moisture_10cm_15cm  = read_db(WHEN,'YF','\climate\clean','soil_moisture_10cm_15cm');
% soil_moisture_35cm_50cm  = read_db(WHEN,'YF','\climate\clean','soil_moisture_35cm_50cm');
% soil_moisture_70cm_95cm  = read_db(WHEN,'YF','\climate\clean','soil_moisture_70cm_95cm');
% soil_moisture2_3cm_5cm   = read_db(WHEN,'YF','\climate\clean','soil_moisture2_3cm_5cm');
% soil_moisture2_10cm_15cm = read_db(WHEN,'YF','\climate\clean','soil_moisture2_10cm_15cm');
% % Soil temperature averages by depth
% soil_moisture_3cm_5cm   = nanmean([soil_moisture_3cm_5cm,soil_moisture2_3cm_5cm]')';
% soil_moisture_10cm_15cm = nanmean([soil_moisture_10cm_15cm,soil_moisture2_10cm_15cm]')';

% OR sensor calibration [needs replacement at some point...]
[slope,intercept] = OR_CR_calibrate;
Solar_AVG = slope.*Solar_AVG+intercept;
gpr = read_db(WHEN,'YF','\clean\thirdstage','global_radiation_main');
ind_night = find(gpr<=0);
ind_bad = find(Solar_AVG<0);
Solar_AVG(ind_night)=0;
Solar_AVG(ind_bad)=0;

% Get x-axis limits
current = datevec(now);
current = current(1);
if sum(ismember(WHEN,2004)) == 1
    x_left = datenum(2004,1,142); % after this date all sensors at OR up and working
else
    x_left = tv(1);
end
if sum(ismember(WHEN,current)) == 1
    x_right = now-21; % 3 week delay with data dumping
else
    x_right = tv(end);
end

% Draw figures
figure;
plot(tv,HMP_AirT_AVG,'r-');
hold on;
plot(tv,air_temperature_hmp_12m,'b-');
xlabel('Month');
ylabel('T_{air}');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Air temperature [HMP]');

figure;
subplot('position',subplot_position(2,1,1));
plot(tv,WindDir_AVG,'r-');
set(gca,'XLim',[x_left x_right]);
set(gca,'XTickLabel','');
set(gca,'YLim',[1 360]);
ylabel('Wind direction');
title('Wind direction [RM Young]');
subplot('position',subplot_position(2,1,2));
plot(tv,wind_direction_weighted_12m,'b-');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
set(gca,'YLim',[1 360]);
ylabel('Wind direction');
xlabel('Month');

figure;
subplot('position',subplot_position(2,1,1));
plot(tv,WindSpd_AVG,'r-');
set(gca,'XLim',[x_left x_right]);
set(gca,'XTickLabel','');
set(gca,'YLim',[0 7.67]);
ylabel('Wind speed');
title('Wind speed [RM Young]');
subplot('position',subplot_position(2,1,2));
plot(tv,wind_speed_12m,'b-');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
set(gca,'YLim',[0 7.67]);
ylabel('Wind speed');
xlabel('Month');

figure;
plot(tv,Solar_AVG,'r-');
hold on;
plot(tv,radiation_shortwave_downwell2_licor_18m,'b-');
xlabel('Month');
ylabel('Downwelling shortwave radiation');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Downwelling shortwave radiation [Li-cor Pyranometer]');

figure;
plot(tv,soil_temperature_2cm_or,'r-');
hold on;
plot(tv,soil_temperature_2cm,'b-');
xlabel('Month');
ylabel('T_{soil} 2cm');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Soil temperature at 2 cm');

figure;
plot(tv,soil_temperature_5cm_or,'r-');
hold on;
plot(tv,soil_temperature_5cm,'b-');
xlabel('Month');
ylabel('T_{soil} 5cm');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Soil temperature at 5 cm');

figure;
plot(tv,soil_temperature_10cm_or,'r-');
hold on;
plot(tv,soil_temperature_10cm,'b-');
xlabel('Month');
ylabel('T_{soil} 10cm');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Soil temperature at 10 cm');

figure;
plot(tv,soil_temperature_20cm_or,'r-');
hold on;
plot(tv,soil_temperature_20cm,'b-');
xlabel('Month');
ylabel('T_{soil} 20cm');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Soil temperature at 20 cm');

figure;
plot(tv,soil_temperature_50cm_or,'r-');
hold on;
plot(tv,soil_temperature_50cm,'b-');
xlabel('Month');
ylabel('T_{soil} 50cm');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Soil temperature at 50 cm');

figure;
plot(tv,soil_temperature_100cm_or,'r-');
hold on;
plot(tv,soil_temperature_100cm,'b-');
xlabel('Month');
ylabel('T_{soil} 100cm');
set(gca,'XLim',[x_left x_right]);
datetick('x','m','keeplimits');
title('Soil temperature at 100 cm');

function TRACE=quick_clean(TRACE);
ind_bad = find(TRACE<-50);
TRACE(ind_bad)=NaN;