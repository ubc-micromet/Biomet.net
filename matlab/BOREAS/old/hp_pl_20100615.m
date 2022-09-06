function [t,x] = HP_pl(ind, year, SiteID, select, fig_num_inc,pause_flag)
% HP_pl - plotting program for Alberta Hybrid Poplar sites--
%       -created from MPB_pl
%
%
%

% Revisions
%   
% June 15, 2010
%   -vaisala GMM traces renamed without the "_AVG".

if ind(1) > datenum(0,4,15) & ind(1) < datenum(0,10,15);
    WINTER_TEMP_OFFSET = 0;
else
    WINTER_TEMP_OFFSET = 30;
end

colordef none
if nargin < 5
    pause_flag = 0;
end
if nargin < 4
    fig_num_inc = 1;
end
if nargin < 3
    select = 0;
end
if nargin < 2 | isempty(year)
    year = datevec(now);                    % if parameter "year" not given
    year = year(1);                         % assume current year
end
if nargin < 1 
    error 'Too few imput parameters!'
end


GMTshift = 1/3;                                  % offset to convert GMT to CST
pthClim = biomet_path(year,SiteID,'cl');         % get the climate data path
pthEC   = biomet_path(year,SiteID,'fl');         % get the eddy data path
%pthEC   = fullfile(pthEC,'Above_Canopy');
pthFl   = biomet_path(year,SiteID,'Flux_Logger'); 

%pthCtrl = [];

axis1 = [340 400];
axis2 = [-10 5];
axis3 = [-50 250];
axis4 = [-50 250];    

st = min(ind);                                   % first day of measurements
ed = max(ind)+1;                                 % last day of measurements (approx.)
ind = st:ed;

tv=read_bor(fullfile(pthClim,'clean_tv'),8);             % get decimal time from the data base
t = tv - tv(1) + 1 - GMTshift;                  % convert time to decimal DOY local time
t_all = t;                                          % save time trace for later
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;
%whitebg('w'); 

%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Air Temperature';
trace_path  = str2mat(fullfile(pthFl,'Eddy_TC_Avg'),fullfile(pthFl,'Tsonic_Avg'));
trace_legend= str2mat('Eddy_{Tc}','Sonic_{Tc}');
trace_units = '(Deg C)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Battery Voltage';
trace_path  = str2mat(fullfile(pthClim,'BattV_AVG'),fullfile(pthFl,'batt_volt_Avg'));
trace_legend= str2mat('CLIM BattVolt_{Avg}','EC logger BattVolt_{Avg}');
trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

% %----------------------------------------------------------
% % Battery Current
% %----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Battery Current';
% trace_path  = str2mat(fullfile(pthClim,'BattCurrent_Avg'),fullfile(pthClim,'BattCurrent_Min'),fullfile(pthClim,'BattCurrent_Max'),...
%                 fullfile(pthClim,'LowPowerMode_Avg'),fullfile(pthClim,'LI7500Power_Avg'));
% trace_legend= str2mat('BattCurrent_{Avg}','BattCurrent_{Min}','BattCurrent_{Max}','LowPowerMode(-5=off)','LI7500Power(-5=off)');
% trace_units = '(A)';
% y_axis      = [-10 20];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1],[0 0 0 (4.9) (5)] );
% if pause_flag == 1;pause;end

% %----------------------------------------------------------
% % Battery Current Cumulative
% %----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Cumulative Battery Current';
% trace_legend= str2mat('BattCurrent_{Avg}');
% trace_units = '(Ah)';
% y_axis      = []; %y_axis      = [-100 100];
% ax = axis;
% ax = ax(1:2);
% [x1,tx_new] = read_sig(trace_path(1,:), ind,year, t,0);
% fig_num = fig_num + fig_num_inc;
% indBadData =  find(x1==-999 | x1 > 36);
% indGoodData = find(x1~=-999 & x1 <= 36);
% x1(indBadData) = interp1(indGoodData,x1(indGoodData),indBadData);
% indCharging = find(x1>0);
% x1(indCharging) = x1(indCharging)*0.85;  % use 90 percent efficiency in charging
% x1 = x1* 30/60;                         % convert from Amps to AmpHours
% plt_sig1( tx_new, [cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Temperature
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Battery Temperature';
% trace_path  = str2mat(fullfile(pthClim,'BattBoxTemp_Avg'));
% trace_legend= str2mat('BattBoxTemp');
% trace_units = '(Deg C)';
% y_axis      = [-5 50];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Temperature';
trace_path  = str2mat(fullfile(pthClim,'RefT_C_AVG'),fullfile(pthFl,'ref_temp_Avg'));
trace_legend= str2mat('Clim Logger','Eddy Logger');
trace_units = '(Deg C)';
y_axis      = [0 50]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 1],[273.15 0]);
if pause_flag == 1;pause;end


% %----------------------------------------------------------
% % Phone Status
% %----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Phone Diagnostics';
% if SiteID== 'MPB3'
%     trace_path  = str2mat(fullfile(pthClim,'PhonePower_Avg'));
%     trace_legend= str2mat('Phone Schedule');
%     y_axis      = [0 5];
% else
%     trace_path  = str2mat(fullfile(pthClim,'PhoneStatus_Avg'));
%     trace_legend= str2mat('Phone ON\OFF');
%     y_axis      = [0 50]-WINTER_TEMP_OFFSET;
% end
% 
% trace_units = '1=ON';
% %y_axis      = [0 50]-WINTER_TEMP_OFFSET;
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% IRGA Diagnostic
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: IRGA diag';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_4'),fullfile(pthFl,'Idiag_Avg'));
% trace_legend= str2mat('Idiag','Idiag logger');
trace_name  = 'Climate/Diagnostics: IRGA diag';
trace_path  = str2mat(fullfile(pthFl,'Idiag_Avg'));
trace_legend= str2mat('Idiag logger');
trace_units = '';
y_axis      = [240 260];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% CO2 
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: CO2';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_1'),fullfile(pthEC,'Instrument_5.Min_1'),fullfile(pthEC,'Instrument_5.Max_1')...
%     ,fullfile(pthFl,'CO2_Avg'));
%trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}','CO2_{Avg
%Logger}');
trace_name  = 'Climate/Diagnostics: CO2';
trace_path  = str2mat(fullfile(pthFl,'CO2_Avg'));
trace_legend= str2mat('CO2_{AvgLogger}');
trace_units = '(mmol m^{-2} s^{-1})';
y_axis      = [-5 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% H2O
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: H2O';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_2'),fullfile(pthEC,'Instrument_5.Min_2'),fullfile(pthEC,'Instrument_5.Max_2')...
%     ,fullfile(pthFl,'H2O_Avg'));
% trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H2O_{Max}','H2O_{Avg logger}');
trace_path  = str2mat(fullfile(pthFl,'H2O_Avg'));
trace_legend= str2mat('H2O_{Avg logger}');
trace_units = '(mmol m^{-2} s^{-1})';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Sonic Diagnostic
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Sonic diag';
%trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_9'),fullfile(pthFl,'Sdiag_Avg'));
trace_path  = str2mat(fullfile(pthFl,'Sdiag_Avg'));
%trace_legend= str2mat('Sdiag','Sdiag logger');
trace_legend= str2mat('Sdiag logger');
trace_units = '';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind speed logger
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: CSAT Wind Speed Logger';
trace_path  = str2mat(fullfile(pthFl,'u_wind_Avg'),fullfile(pthFl,'v_wind_Avg'),fullfile(pthFl,'w_wind_Avg'));
trace_legend= str2mat('u wind','v wind','w wind');
trace_units = '(^o)';
y_axis      = [-10 10];
fig_num = fig_num + fig_num_inc;
x_CSAT = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
% trace_name  = 'Climate: Wind Speed Averages (RM Young)';
% trace_path  = str2mat(fullfile(pthClim,'WS_ms_S_WVT'));
% trace_legend = str2mat('CSAT','RMYoung (avg)');
% trace_units = '(m/s)';
% y_axis      = [0 10];
% fig_num = fig_num + fig_num_inc;
% x_RMYoung = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% clf
% x = plt_msig( [sqrt(sum(x_CSAT'.^2))' x_RMYoung], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end


%----------------------------------------------------------
% Precipitation - needs a multiplier
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Rainfall';
% trace_path  = str2mat(fullfile(pthClim,'RainFall_Tot'));
% trace_legend= str2mat('Rainfall_{tot}');
% trace_units = '(mm)';
% y_axis      = [0 4];
% fig_num = fig_num + fig_num_inc;
% if SiteID== 'MPB1' | SiteID== 'MPB3';
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% else
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[2.54]);
% end
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative Precipitation
%----------------------------------------------------------
% indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
% tx = t_all(indx);                                           % the beginning of the year
% 
% trace_name  = 'Climate: Cumulative Rain';
% y_axis      = [];
% ax = [st ed];
% [x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
% 
% if SiteID== 'MPB2';
%    x1 = x1*2.54;
% else
%    x1 = x1*1;   
% end
% fig_num = fig_num + fig_num_inc;
% 
% plt_sig1( tx_new, [cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
% if pause_flag == 1;pause;end


%------------------------------------------
if select == 1 %diagnostics only
    if pause_flag ~= 1;
        childn = get(0,'children');
        childn = sort(childn);
        N = length(childn);
        for i=childn(:)';
            if i < 200 
                figure(i);
%                if i ~= childn(N-1)
                    pause;
%                end
            end
        end
    end
    return
end

%----------------------------------------------------------
% HMP Temp
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: HMP Temperature';
% trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthFl,'HMP_T_Min'),fullfile(pthClim,'HMP_T_Max'));
% trace_legend= str2mat('HMPTemp_{Avg}','HMPTemp_{Min}','HMPTemp_{Max}');
% trace_units = '(Deg C)';
% y_axis      = [0 40]-WINTER_TEMP_OFFSET;
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% HMP RH
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: HMP Relative Humidity';
% trace_path  = str2mat(fullfile(pthClim,'HMP_RH_Avg'),fullfile(pthClim,'HMP_RH_Min'),fullfile(pthClim,'HMP_RH_Max'));
% trace_legend= str2mat('HMP_RH_{Avg}','HMP_RH_{Min}','HMP_RH_{Max}');
% trace_units = '(%)';
% y_axis      = [0 100];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Barometric Pressure';
%trace_path  = str2mat(fullfile(pthEC,'MiscVariables.BarometricP'),fullfile(pthFl,'Irga_P_Avg'));
trace_path  = str2mat(fullfile(pthFl,'Irga_P_Avg'));
trace_legend= str2mat('Pressure logger');
trace_units = '(kPa)';
y_axis      = [30 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil moisture
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Soil water content';
% if SiteID == 'MPB3'
%     trace_path  = str2mat(fullfile(pthClim,'H2Opercent_3cm_Avg'),fullfile(pthClim,'H2Opercent_20cm_Avg'),fullfile(pthClim,'H2Opercent_50cm_Avg'),...
%                           fullfile(pthClim,'H2Opercent_100cm_Avg') );
%     trace_legend= str2mat('H2O%_{3cm}','H2O%_{20cm}','H2O%_{50cm}','H2O%_{100cm}');
% else
%     trace_path  = str2mat(fullfile(pthClim,'H2Opercent_Avg1'),fullfile(pthClim,'H2Opercent_Avg2'),fullfile(pthClim,'H2Opercent_Avg3'));
%     trace_legend= str2mat('H2O%_{1}','H2O%_{2}','H2O%_{3}');
% end
% 
% trace_units = '(%)';
% 
% if SiteID == 'MPB1' | SiteID == 'MPB3';
%    y_axis      = [0 1];
% else
%    y_axis      = [0 600];   
% end
% 
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp vs. Surface Temp
%----------------------------------------------------------
% if SiteID=='MPB3'
%     trace_name  = 'Climate/Diagnostics: Air Temp vs. Surface Temp (IR Thermometer)';
%     trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthClim,'Surf_Soil_temp_Avg'));
%     trace_legend= str2mat('HMPTemp_{Avg}','Apogee SI-111');
%     trace_units = '(Deg C)';
%     y_axis      = [0 40]-WINTER_TEMP_OFFSET;
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%     if pause_flag == 1;pause;end
% end
%----------------------------------------------------------
% Soil temperature
%----------------------------------------------------------
% if year == 2006;
% 
% trace_name  = 'Climate/Diagnostics: Soil temperature';
% % trace_path  = str2mat(fullfile(pthClim,'soil_temperature_Avg'),fullfile(pthClim,'soil_tempera_Avg1'),fullfile(pthClim,'soil_tempera_Avg2'),fullfile(pthClim,'soil_tempera_Avg3'),fullfile(pthClim,'soil_tempera_Avg4'),fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),fullfile(pthClim,'Soil_temp_Avg3'),fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'),fullfile(pthClim,'Soil_temp_Avg6'));
% % trace_legend= str2mat('T_{s}','T_{s1}','T_{s2}','T_{s3}','T_{s4}','Ts_{1}','Ts_{2}','Ts_{3}','Ts{4}','Ts{5}','Ts{6}');
% 
% trace_path  = str2mat(fullfile(pthClim,'soil_temperature_Avg'),fullfile(pthClim,'soil_tempera_Avg1'),...
%               fullfile(pthClim,'soil_tempera_Avg2'),fullfile(pthClim,'soil_tempera_Avg3'),fullfile(pthClim,'soil_tempera_Avg4'));
% trace_legend= str2mat('T_{sx}','T_{s20}','T_{s10}','T_{s2}','T_{s50}');
% trace_units = '(\circC)';
% y_axis      = [-15 30];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% else
% trace_name  = 'Climate/Diagnostics: Soil temperature';
% % trace_path  = str2mat(fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),...
% %                fullfile(pthClim,'Soil_temp_Avg3'),fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'),fullfile(pthClim,'Soil_temp_Avg6'));
% % trace_legend= str2mat('Ts_{20}','Ts_{10}','Ts_{2}','Ts{50}','Ts{5}','Ts{6}');
% if SiteID=='MPB3'
%     trace_path  = str2mat(fullfile(pthClim,'Soil_temp_3cm_Avg'),fullfile(pthClim,'Soil_temp_10cm_Avg'),...
%               fullfile(pthClim,'Soil_temp_20cm_Avg'),fullfile(pthClim,'Soil_temp_50cm_Avg'),fullfile(pthClim,'Soil_temp_100cm_Avg'));
%     trace_legend= str2mat('T_{s3}','T_{s10}','T_{s20}','T_{s50}','T_{s100}');
% else
%    trace_path  = str2mat(fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),fullfile(pthClim,'Soil_temp_Avg3'),...
%                       fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'));
%    if SiteID == 'MPB1';
%       trace_legend= str2mat('Ts_{50}','Ts_{5}','Ts_{10}','Ts{20}','');
%    else              
%       trace_legend= str2mat('Ts_{2}','Ts_{5}','Ts_{10}','Ts{30}','Ts{50}');
%    end
% end
% trace_units = '(\circC)';
% y_axis      = [-15 30];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% end


%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = 'Covariances: CO2*w';
trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov5'));
trace_legend= str2mat('wco2_cov_{Avg}');
trace_units = '';
y_axis      = [-0.05 0.05];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = 'Covariances: H2O*w';
trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov9'));
trace_legend= str2mat('wh2o_cov_{Avg}');
trace_units = '';
y_axis      = [-0.5 5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = 'Covariances: w*T';
trace_path  = str2mat(fullfile(pthFl,'Tc_Temp_cov_Cov4'),fullfile(pthFl,'Tsonic_cov_Cov4'));
trace_legend= str2mat('wTceddy_cov_{Avg}','wTsonic_cov_{Avg}');
trace_units = '';
y_axis      = [-0.05 0.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% CO2 Flux
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: CO2 Flux';
trace_path  = str2mat(fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.Fc']));
trace_legend= str2mat('Fc_{Avg}');
trace_units = '(\mumol CO_{2} m^{-2})';
y_axis      = [-10 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind direction
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Wind Direction';
trace_path  = str2mat(fullfile(pthEC,'Instrument_2.MiscVariables.WindDirection'));
trace_legend= str2mat('Wind Dir');
trace_units = '(^o)';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
% trace_name  = 'Climate: Wind Direction (RM Young)';
% trace_path  = str2mat(fullfile(pthClim,'WindDir_D1_WVT'),fullfile(pthClim,'WindDir_SD1_WVT'));
% trace_legend = str2mat('wdir 25m','wdir stdev 25m');
% trace_units = '(^o)';
% y_axis      = [0 360];
% fig_num = fig_num + fig_num_inc;
% if SiteID=='MPB3'
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% else
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% end
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Soil Heat flux';

trace_path  = str2mat(fullfile(pthClim,'SHF_1_AVG'),fullfile(pthClim,'SHF_2_AVG'),...
                      fullfile(pthClim,'SHF_3_AVG'),fullfile(pthClim,'SHF_4_AVG'),fullfile(pthClim,'SHF_5_AVG'));
trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}','sheat_{5}');

trace_units = '(Watts m^{-2} s^{-1})';
y_axis      = [-200 200];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 

if pause_flag == 1;pause;end

%-----------------------------------
% Soil Tc's for SHF correction
%-----------------------------------
trace_name  = 'Soil Temperature at 3 cm for SHF correction';

trace_path  = str2mat(fullfile(pthClim,'TC_3cm_1_AVG'),fullfile(pthClim,'TC_3cm_2_AVG'));
trace_legend = str2mat('Rep 1','Rep 2');

trace_units = '(W/m^2)';
y_axis      = [0 35 ];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Soil Tc's for SHF correction
%-----------------------------------
trace_name  = 'Vaisala soil CO2';

% June 15, 2010
%trace_path  = str2mat(fullfile(pthClim,'GMM_0cm_AVG'),fullfile(pthClim,'GMM_5cm_AVG'),fullfile(pthClim,'GMM_15cm_AVG'),...
%                     fullfile(pthClim,'GMM_30cm_AVG'),fullfile(pthClim,'GMM_50cm_AVG')); %
                      
trace_path  = str2mat(fullfile(pthClim,'GMM_0cm'),fullfile(pthClim,'GMM_5cm'),fullfile(pthClim,'GMM_15cm'),...
                      fullfile(pthClim,'GMM_30cm'),fullfile(pthClim,'GMM_50cm'));                      
trace_legend = str2mat('0 cm','5 cm','15 cm','30 cm','50 cm');

trace_units = 'ppm_v';
y_axis      = [0 12000 ];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
%----------------------------------------------------------
% PAR
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: PAR';

trace_path  = str2mat(fullfile(pthClim,'PAR_dn_AVG'),fullfile(pthClim,'PAR_up_AVG'));
trace_legend= str2mat('PAR_{uw}','PAR_{dw}');

trace_units = '(\mumol m^{-2} s^{-1})';
y_axis      = [-5 2500];
fig_num = fig_num + fig_num_inc;
% if SiteID == 'MPB1'
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Net radiation
%-----------------------------------
trace_name  = 'Net-Radiation Above Canopy';
trace_path  = str2mat(fullfile(pthClim,'Net_Radn_AVG'));
trace_legend = str2mat('Net Avg');
trace_units = '(W/m^2)';
y_axis      = [-200 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation SW and LW
%-----------------------------------
trace_name  = 'Radiation Above Canopy';

trace_path  = str2mat(fullfile(pthClim,'SW_DW_AVG'),fullfile(pthClim,'SW_UW_AVG'),fullfile(pthClim,'LW_DW_AVG'),fullfile(pthClim,'LW_UW_AVG'));
trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg');

trace_units = '(W/m^2)';
y_axis      = [-200 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% SW comparison: CNR1 and Dave's Eppley
%-----------------------------------
% if SiteID == 'MPB3'
%     trace_name  = 'SW comparison: CNR1 and Dave''s Eppley';
%     trace_path  = str2mat(fullfile(pthClim,'swu_3m_Avg'),fullfile(pthClim,'swu_Avg'));
%     trace_legend = str2mat('Eppley swu 3m','CNR1 swu 30m');
%     trace_units = '(W/m^2)';
%     y_axis      = [-10 50];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[110.1 1],[0 0]);
%     if pause_flag == 1;pause;end
% end

% %-----------------------------------
% % Snow Tc
% %-----------------------------------
% % if SiteID=='MPB3'
% %     trace_name  = 'Snow Thermocouple';
% %     trace_path  = str2mat(fullfile(pthClim,'Snow_tc_Avg'),fullfile(pthClim,'Snow_tc_Max'),fullfile(pthClim,'Snow_tc_Min'));
% %     trace_legend = str2mat('Tc Avg','Tc Max','Tc Min');
% %     trace_units = '(^oC)';
% %     y_axis      = [-20 20];
% %     fig_num = fig_num + fig_num_inc;
% %     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% %     if pause_flag == 1;pause;end
% % end
% 
% %-----------------------------------
% % Snow Depth
% %-----------------------------------
% if SiteID=='MPB3'
%     trace_name  = 'Snow Depth';
%     trace_path  = str2mat(fullfile(pthClim,'SnowDepth_Avg'),fullfile(pthClim,'SnowDepth_Max'),fullfile(pthClim,'SnowDepth_Min'));
%     trace_legend = str2mat('Snowdepth Avg','Snowdepth Max','Snowdepth Min');
%     trace_units = '(m)';
%     y_axis      = [0 5];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-3.6 -3.6 -3.6] );
%     if pause_flag == 1;pause;end
% end
%colordef white
if pause_flag ~= 1;
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=childn(:)';
        if i < 200 
            figure(i);
%            if i ~= childn(N-1)
                pause;
%            end
        end
    end
end



