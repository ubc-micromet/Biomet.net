function [t,x] = MPB_pl(ind, year, SiteID, select, fig_num_inc,pause_flag)
% MPB_pl - plotting program for MPB sites
%
%
%

% Revisions
% April 19, 2011 (Nick)
%   -CO2 and H2O rotated fluxes changed to 'THREE' from 'TWO' to reflect
%       HF data rotation.
%April 5, 2011 (Amanda)
%   - replaced bad logger net radiation trace with calculated net
%   - put Sonic and RMYoung Wind direction on same graph
% Feb 21, 2011
%   -reduced size of rotation matrixes to ind rather than one whole year!
%   Jan 19, 2011 (Zoran)
%       - Fixed plotting of MPB3 BattBoxTemp
%   Jan 12, 2010 (Amanda)
%  - added try-catch statement for missing hf data
%   Dec 16, 2010
%   -typo fixed in function call to apply_WPL_correction; c_v was passed by
%   error instead of H_w (Nick)
%
%    August 1, 2010 (Amanda)
%  - added WPL rotated and unrotated CO2 and H2O flux
%  - edited units and titles of plots

%   Dec, 4, 2007 (Zoran)
%       - added cumulative Ahours
%       - added cup wind speed for CSAT and RMYoung on the same plot
%  

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
pthEC   = fullfile(pthEC,'Above_Canopy');
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
trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthFl,'Eddy_Tc_Avg'),fullfile(pthFl,'Tsonic_Avg'));
trace_legend= str2mat('HMPTemp_{Avg}','Eddy_{Tc}','Sonic_{Tc}');
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Battery Voltage';
trace_path  = str2mat(fullfile(pthClim,'BattVolt_Avg'),fullfile(pthClim,'BattVolt_Min'),fullfile(pthClim,'BattVolt_Max'));
trace_legend= str2mat('BattVolt_{Avg}','BattVolt_{Min}','BattVolt_{Max}');
trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Current
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Battery Current';
trace_path  = str2mat(fullfile(pthClim,'BattCurrent_Avg'),fullfile(pthClim,'BattCurrent_Min'),fullfile(pthClim,'BattCurrent_Max'),...
                fullfile(pthClim,'LowPowerMode_Avg'),fullfile(pthClim,'LI7500Power_Avg'));
trace_legend= str2mat('BattCurrent_{Avg}','BattCurrent_{Min}','BattCurrent_{Max}','LowPowerMode on','LowPowerMode(-5=off)');
trace_units = '(A)';
y_axis      = [-10 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1],[0 0 0 (4.9) (5)] );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Current Cumulative
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Cumulative Battery Current';
trace_legend= str2mat('BattCurrent_{Avg}');
trace_units = '(Ah)';
y_axis      = []; %y_axis      = [-100 100];
ax = axis;
ax = ax(1:2);
[x1,tx_new] = read_sig(trace_path(1,:), ind,year, t,0);
fig_num = fig_num + fig_num_inc;
indBadData =  find(x1==-999 | x1 > 36);
indGoodData = find(x1~=-999 & x1 <= 36);
x1(indBadData) = interp1(indGoodData,x1(indGoodData),indBadData);
indCharging = find(x1>0);
x1(indCharging) = x1(indCharging)*0.85;  % use 90 percent efficiency in charging
x1 = x1* 30/60;                         % convert from Amps to AmpHours
plt_sig1( tx_new, [cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Temperature
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Battery Temperature';
if SiteID== 'MPB3'
    trace_path  = str2mat(fullfile(pthClim,'BattBoxTemp_Avg'));
    trace_legend= [];    
else
    trace_path  = str2mat(fullfile(pthClim,'BattBoxTemp_Avg'),fullfile(pthClim,'BattHeatTemp_Avg'),...
                  fullfile(pthClim,'HeaterPower_Avg'));
    trace_legend= str2mat('BattBoxTemp','BattHeatTemp','Heater ON\OFF');              
end

trace_units = '(\circC)';
y_axis      = [-5 50];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Temperature';
trace_path  = str2mat(fullfile(pthClim,'LoggerRefTemp_Avg'),fullfile(pthFl,'ref_temp_Avg'),...
              fullfile(pthClim,'AM25T_RefT_Avg'),fullfile(pthClim,'HMP_T_Avg'));
trace_legend= str2mat('Clim Logger','Eddy Logger','AM25T','HMP');
trace_units = '(\circC)';
y_axis      = [0 50]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Phone Status
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Phone Diagnostics';
if SiteID== 'MPB3'
    trace_path  = str2mat(fullfile(pthClim,'PhonePower_Avg'));
    trace_legend= str2mat('Phone Schedule');
    y_axis      = [0 5];
else
    trace_path  = str2mat(fullfile(pthClim,'PhoneStatus_Avg'));
    trace_legend= str2mat('Phone ON\OFF');
    y_axis      = [0 50]-WINTER_TEMP_OFFSET;
end

trace_units = '1=ON';
%y_axis      = [0 50]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% IRGA Diagnostic
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: IRGA diag';
trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_4'),fullfile(pthFl,'Idiag_Avg'));
trace_legend= str2mat('Idiag','Idiag logger');
trace_units = '';
y_axis      = [240 260];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% CO2 density
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: CO2 density';
trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_1'),fullfile(pthEC,'Instrument_5.Min_1'),fullfile(pthEC,'Instrument_5.Max_1')...
    ,fullfile(pthFl,'CO2_Avg'));
trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}','CO2_{Avg Logger}');
trace_units = '(mmol CO_{2} m^{-3})';
y_axis      = [-5 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% H2O density
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Water vapour density';
trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_2'),fullfile(pthEC,'Instrument_5.Min_2'),fullfile(pthEC,'Instrument_5.Max_2')...
    ,fullfile(pthFl,'H2O_Avg'));
trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H2O_{Max}','H2O_{Avg logger}');
trace_units = '(mmol H_{2}O m^{-3})';
y_axis      = [0 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Sonic Diagnostic
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Sonic diag';
trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_9'),fullfile(pthFl,'Sdiag_Avg'));
trace_legend= str2mat('Sdiag','Sdiag logger');
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
trace_units = '(m s^{-1})';
y_axis      = [-10 10];
fig_num = fig_num + fig_num_inc;
x_CSAT = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Speed Averages (RM Young)';
trace_path  = str2mat(fullfile(pthClim,'WS_ms_S_WVT'));
trace_legend = str2mat('CSAT','RMYoung (avg)');
trace_units = '(m s^{-1})';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x_RMYoung = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
clf
x = plt_msig( [sqrt(sum(x_CSAT'.^2))' x_RMYoung], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Precipitation - needs a multiplier
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Rainfall';
trace_path  = str2mat(fullfile(pthClim,'RainFall_Tot'));
trace_legend= str2mat('Rainfall_{tot}');
trace_units = '(mm halfhour^{-1})';
y_axis      = [0 4];
fig_num = fig_num + fig_num_inc;
if SiteID== 'MPB1' | SiteID== 'MPB3';
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[2.54]);
end
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative Precipitation
%----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'Climate: Cumulative Rain';
trace_units = '(mm)';
y_axis      = [];
ax = [st ed];
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);

if SiteID== 'MPB2';
   x1 = x1*2.54;
else
   x1 = x1*1;   
end
fig_num = fig_num + fig_num_inc;

plt_sig1( tx_new, [cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% CNR1 temperature
%----------------------------------------------------------
trace_name  = 'CNR1 temperature';
T_CNR1 = read_bor(fullfile(pthClim,'cnr1_Temp_avg'));
T_HMP = read_bor(fullfile(pthClim,'HMP_T_Avg'));
trace_path  = [T_CNR1 T_HMP];
trace_legend = str2mat('CNR1_{PRT}','T_{HMP}');
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Net radiation SW and LW
%-----------------------------------
trace_name  = 'Radiation Above Canopy';
LongWaveOffset =(5.67E-8*(273.15+T_CNR1).^4);
%Net_cnr1_AVG = read_bor(fullfile(pthClim,'CNR_net_avg'));
S_upper_AVG = read_bor(fullfile(pthClim,'swd_Avg'));
S_lower_AVG = read_bor(fullfile(pthClim,'swu_Avg'));
lwu = read_bor(fullfile(pthClim,'lwu_Avg'));
lwd = read_bor(fullfile(pthClim,'lwd_Avg'));
trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
trace_units = '(W m^{-2})';
y_axis      = [-200 1400];

if SiteID == 'MPB1'
    L_upper_AVG = lwd + LongWaveOffset;
    L_lower_AVG = lwu + LongWaveOffset;
elseif SiteID == 'MPB2'
    %reverse up and down and change signs
    L_upper_AVG = -lwu + LongWaveOffset;
    L_lower_AVG = -lwd + LongWaveOffset;
    % reverse up and down
    S_upper_AVG = read_bor(fullfile(pthClim,'swu_Avg'));
    S_lower_AVG = read_bor(fullfile(pthClim,'swd_Avg'));
else
    L_upper_AVG = lwd + LongWaveOffset;
    L_lower_AVG = lwu + LongWaveOffset;
end
Net_cnr1_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
trace_path = [S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr1_calc];

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Barometric Pressure';
trace_path  = str2mat(fullfile(pthEC,'MiscVariables.BarometricP'),fullfile(pthFl,'Irga_P_Avg'));
trace_legend= str2mat('Pressure','Pressure logger');
trace_units = '(kPa)';
y_axis      = [30 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end























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
trace_name  = 'Climate/Diagnostics: HMP Temperature';
trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthFl,'HMP_T_Min'),fullfile(pthClim,'HMP_T_Max'));
trace_legend= str2mat('HMPTemp_{Avg}','HMPTemp_{Min}','HMPTemp_{Max}');
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% HMP RH
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: HMP Relative Humidity';
trace_path  = str2mat(fullfile(pthClim,'HMP_RH_Avg'),fullfile(pthClim,'HMP_RH_Min'),fullfile(pthClim,'HMP_RH_Max'));
trace_legend= str2mat('HMP_RH_{Avg}','HMP_RH_{Min}','HMP_RH_{Max}');
trace_units = '(%)';
y_axis      = [0 100];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil moisture
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Soil water content';
if SiteID == 'MPB3'
    trace_path  = str2mat(fullfile(pthClim,'H2Opercent_3cm_Avg'),fullfile(pthClim,'H2Opercent_20cm_Avg'),fullfile(pthClim,'H2Opercent_50cm_Avg'),...
                          fullfile(pthClim,'H2Opercent_100cm_Avg') );
    trace_legend= str2mat('H2O%_{3cm}','H2O%_{20cm}','H2O%_{50cm}','H2O%_{100cm}');
else
    trace_path  = str2mat(fullfile(pthClim,'H2Opercent_Avg1'),fullfile(pthClim,'H2Opercent_Avg2'),fullfile(pthClim,'H2Opercent_Avg3'));
    trace_legend= str2mat('H2O%_{1}','H2O%_{2}','H2O%_{3}');
end

trace_units = '(m^{3} m^{-3})';

if SiteID == 'MPB1' | SiteID == 'MPB3';
   y_axis      = [0 1];
else
   y_axis      = [0 600];   
end

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp vs. Surface Temp
%----------------------------------------------------------
if SiteID=='MPB3'
    trace_name  = 'Climate/Diagnostics: Air Temp vs. Surface Temp (IR Thermometer)';
    trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthClim,'Surf_Soil_temp_Avg'));
    trace_legend= str2mat('HMPTemp_{Avg}','Apogee SI-111');
    trace_units = '(\circC)';
    y_axis      = [0 40]-WINTER_TEMP_OFFSET;
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end
%----------------------------------------------------------
% Soil temperature
%----------------------------------------------------------
if year == 2006;

trace_name  = 'Climate/Diagnostics: Soil temperature';
% trace_path  = str2mat(fullfile(pthClim,'soil_temperature_Avg'),fullfile(pthClim,'soil_tempera_Avg1'),fullfile(pthClim,'soil_tempera_Avg2'),fullfile(pthClim,'soil_tempera_Avg3'),fullfile(pthClim,'soil_tempera_Avg4'),fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),fullfile(pthClim,'Soil_temp_Avg3'),fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'),fullfile(pthClim,'Soil_temp_Avg6'));
% trace_legend= str2mat('T_{s}','T_{s1}','T_{s2}','T_{s3}','T_{s4}','Ts_{1}','Ts_{2}','Ts_{3}','Ts{4}','Ts{5}','Ts{6}');

trace_path  = str2mat(fullfile(pthClim,'soil_temperature_Avg'),fullfile(pthClim,'soil_tempera_Avg1'),...
              fullfile(pthClim,'soil_tempera_Avg2'),fullfile(pthClim,'soil_tempera_Avg3'),fullfile(pthClim,'soil_tempera_Avg4'));
trace_legend= str2mat('T_{sx}','T_{s20}','T_{s10}','T_{s2}','T_{s50}');
trace_units = '(\circC)';
y_axis      = [-15 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
else
trace_name  = 'Climate/Diagnostics: Soil temperature';
% trace_path  = str2mat(fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),...
%                fullfile(pthClim,'Soil_temp_Avg3'),fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'),fullfile(pthClim,'Soil_temp_Avg6'));
% trace_legend= str2mat('Ts_{20}','Ts_{10}','Ts_{2}','Ts{50}','Ts{5}','Ts{6}');
if SiteID=='MPB3'
    trace_path  = str2mat(fullfile(pthClim,'Soil_temp_3cm_Avg'),fullfile(pthClim,'Soil_temp_10cm_Avg'),...
              fullfile(pthClim,'Soil_temp_20cm_Avg'),fullfile(pthClim,'Soil_temp_50cm_Avg'),fullfile(pthClim,'Soil_temp_100cm_Avg'));
    trace_legend= str2mat('T_{s3}','T_{s10}','T_{s20}','T_{s50}','T_{s100}');
else
   trace_path  = str2mat(fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),fullfile(pthClim,'Soil_temp_Avg3'),...
                      fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'));
   if SiteID == 'MPB1';
      trace_legend= str2mat('Ts_{50}','Ts_{5}','Ts_{10}','Ts{20}','');
   else              
      trace_legend= str2mat('Ts_{2}','Ts_{5}','Ts_{10}','Ts{30}','Ts{50}');
   end
end
trace_units = '(\circC)';
y_axis      = [-15 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end

% added covs and Fc Nick and Amanda June 15, 2010.
%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = 'Covariances: w*CO2 (raw)';
trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov5'));
trace_legend= str2mat('wco2_cov_{Avg}');
trace_units = '(mmol CO_{2} m^{-2} s^{-1})';
y_axis      = [-0.05 0.05];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = 'Covariances: w*H2O (raw)';
trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov9'));
trace_legend= str2mat('wh2o_cov_{Avg}');
trace_units = '(mmol H_{2}O m^{-2} s^{-1})';
y_axis      = [-0.5 5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = 'Covariances: w*T (kinematic)';
trace_path  = str2mat(fullfile(pthFl,'Tc_Temp_cov_Cov4'),fullfile(pthFl,'Tsonic_cov_Cov4'));
trace_legend= str2mat('wTceddy_cov_{Avg}','wTsonic_cov_{Avg}');
trace_units = '(\circC m s^{-1})';
y_axis      = [-0.05 0.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% add prelim Fc calculation (link to Amanda's function)
% %----------------------------------------------------------
% trace_name  = 'Fc unrotated, WPL-corrected';
% trace_legend= str2mat('Fc_{raw}');
% trace_units = '(\mumol m^{-2} s^{-1})';
% 
% [Fc,E] = WPLcorrection(SiteID,year);
% 
% fig_num = fig_num + fig_num_inc;
% 
% y_axis      = [-15 20];
% x = plt_msig( Fc, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% 
% if pause_flag == 1;pause;end



%----------------------------------------------------------
%  CO2 Flux (from high frequency data, WPL rotated and unrotated from raw
%  covariances)
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: CO2 Flux'; 

%load mean wind vector
u = read_bor(fullfile(pthFl, 'u_wind_Avg'));
v = read_bor(fullfile(pthFl, 'v_wind_Avg'));
w = read_bor(fullfile(pthFl, 'w_wind_Avg'));

meansIn = [u v w];

% load raw covariances 

% c, H, u, v, w
c_c = read_bor(fullfile(pthFl, 'CO2_cov_Cov1'));
pthFl = biomet_path(year,SiteID,'Flux_Logger'); 
c_H = read_bor(fullfile(pthFl,'CO2_cov_Cov2'));
c_u = read_bor(fullfile(pthFl,'CO2_cov_Cov3'));
c_v = read_bor(fullfile(pthFl,'CO2_cov_Cov4')); 
c_w = read_bor(fullfile(pthFl,'CO2_cov_Cov5'));   
H_H = read_bor(fullfile(pthFl,'CO2_cov_Cov6')); 
H_u = read_bor(fullfile(pthFl,'CO2_cov_Cov7'));
H_v = read_bor(fullfile(pthFl,'CO2_cov_Cov8'));
H_w = read_bor(fullfile(pthFl,'CO2_cov_Cov9'));
u_u = read_bor(fullfile(pthFl,'CO2_cov_Cov10'));
u_v = read_bor(fullfile(pthFl,'CO2_cov_Cov11'));
u_w = read_bor(fullfile(pthFl,'CO2_cov_Cov12'));
v_v = read_bor(fullfile(pthFl,'CO2_cov_Cov13'));
v_w = read_bor(fullfile(pthFl,'CO2_cov_Cov14'));
w_w = read_bor(fullfile(pthFl,'CO2_cov_Cov15'));

% % Tsonic, u, v, w
T_T = read_bor(fullfile(pthFl,'Tsonic_cov_Cov1'));
T_u = read_bor(fullfile(pthFl,'Tsonic_cov_Cov2'));
T_v = read_bor(fullfile(pthFl,'Tsonic_cov_Cov3'));
T_w = read_bor(fullfile(pthFl,'Tsonic_cov_Cov4'));

cc = read_bor(fullfile(pthFl,'CO2_Avg'));              % cc is molar CO2 density (mmol/m3)
cv = read_bor(fullfile(pthFl,'H2O_Avg'));              % cv is molar water vapour density (mmol/m3)
T = read_bor(fullfile(pthFl,'Tsonic_avg'));   % load T and P
P = read_bor(fullfile(pthFl,'Irga_P_Avg'));

% rotation of raw covariances
C1 = [u_u  u_v  v_v  u_w  v_w  w_w  c_u  c_v  c_w  c_c  H_u  H_v  H_w  c_H  H_H ];
C2 = [u_u  u_v  v_v  u_w  v_w  w_w  T_u  T_v  T_w  T_T];


[wT_rot, wH_rot, wc_rot] = rotate_cov_matrices(meansIn(ind,:), C1(ind,:), C2(ind,:), T_w(ind));

% WPL for rotated and unrotated covariances
[Fc_wpl, E_wpl] = apply_WPL_correction(c_w(ind), H_w(ind), T_w(ind), cc(ind), cv(ind), T(ind), P(ind));  %unrotated, fixed typo Dec 16, 2010 (Nick)
[Fc_rot, E_rot] = apply_WPL_correction(wc_rot, wH_rot, wT_rot, cc(ind), cv(ind), T(ind), P(ind));  %rotated


trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
y_axis      = [-10 15];
fig_num = fig_num + fig_num_inc;

% prevent graph from closing if trace is missing (Amanda, Jan 2011)
try
    Fc_hf = read_bor(fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.Fc']));
    trace_legend= str2mat('CO_{2} 3 rotations (high freq)', 'CO_{2} WPL 3 rotations (raw)', 'CO_{2} WPL unrotated (raw)');
    x = plt_msig( [Fc_hf(ind) Fc_rot Fc_wpl],ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

catch
    FCfnstr = fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.Fc']);
    disp(['Could not load ' FCfnstr ]);
    disp(lasterr);
    trace_legend= str2mat('CO_{2} WPL 3 rotations (raw)', 'CO_{2} WPL unrotated (raw)');
    x = plt_msig( [Fc_rot Fc_wpl], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end

if pause_flag == 1;pause;end

%----------------------------------------------------------
% add  prelim H20 flux WPL calculation (link to Amanda's function)
%----------------------------------------------------------
trace_name  = 'H20 flux WPL-corrected';
trace_legend= str2mat('H_{2}O WPL 3 rotations (raw)', 'H_{2}O WPL unrotated (raw)');
trace_units = '(mmol m^{-2} s^{-1})';

fig_num = fig_num + fig_num_inc;
y_axis      = [-1 5];
x = plt_msig( [E_rot E_wpl], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

if pause_flag == 1;pause;end


%----------------------------------------------------------
% Sonic wind direction
%----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Wind Direction';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_2.MiscVariables.WindDirection'));
% trace_legend= str2mat('Wind Dir');
% trace_units = '(^o)';
% y_axis      = [-10 700];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Direction';
trace_path  = str2mat(fullfile(pthEC,'Instrument_2.MiscVariables.WindDirection'), fullfile(pthClim,'WindDir_D1_WVT'),fullfile(pthClim,'WindDir_SD1_WVT'));
trace_legend = str2mat('Wind dir (Sonic)', 'wdir 25m (Rm Young)','wdir stdev 25m (Rm Young)');
trace_units = '(^o)';
y_axis      = [0 360];
fig_num = fig_num + fig_num_inc;
if SiteID=='MPB3'
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Soil Heat flux';
if SiteID == 'MPB1';
trace_path  = str2mat(fullfile(pthClim,'Sheat_flux_Avg1'),fullfile(pthClim,'Sheat_flux_Avg2')...
    ,fullfile(pthClim,'Sheat_flux_Avg3'),fullfile(pthClim,'Sheat_flux_Avg4'));
trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}');
else
trace_path  = str2mat(fullfile(pthClim,'Sheat_flux_Avg1'),fullfile(pthClim,'Sheat_flux_Avg2'),fullfile(pthClim,'Sheat_flux_Avg3'));
trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}');   
end
trace_units = '(W m^{-2})';
y_axis      = [-200 200];
fig_num = fig_num + fig_num_inc;
if SiteID == 'MPB1';
   x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 1 1 1 1]);
elseif SiteID == 'MPB2'
   x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 1 -1]);  
else
   x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1]); 
end
if pause_flag == 1;pause;end


%----------------------------------------------------------
% PAR
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: PAR';
if SiteID == 'MPB1'
% trace_path  = str2mat(fullfile(pthClim,'Quantum_Avg'),fullfile(pthClim,'Quantum_Avg1'),fullfile(pthClim,'Quantum_Avg2'),...
%               fullfile(pthClim,'Quantum_Avg3'));
trace_path  = str2mat(fullfile(pthClim,'Quantum_Avg1'),fullfile(pthClim,'Quantum_Avg2'),fullfile(pthClim,'Quantum_Avg3'),...
               fullfile(pthClim,'Quantum_Avg3'));
trace_legend= str2mat('Quantum_{Avg}','Quantum_{Avg1}','Quantum_{Avg2}','Quantum_{Avg3}');
elseif SiteID == 'MPB2'
  trace_path  = str2mat(fullfile(pthClim,'Quantum_Avg1'),fullfile(pthClim,'Quantum_Avg2'),fullfile(pthClim,'Quantum_Avg3'));
  trace_legend= str2mat('Quantum_{Avg1}','Quantum_{Avg2}','Quantum_{Avg3}');    
else
  trace_path  = str2mat(fullfile(pthClim,'PAR_up_30m_Avg'),fullfile(pthClim,'PAR_down_30m_Avg'),fullfile(pthClim,'PAR_up_3m_Avg'));
  trace_legend= str2mat('PAR_{dw 30m}','PAR_{uw 30m}','PAR_{dw 3m}');
end
trace_units = '(\mumol photons m^{-2} s^{-1})';
y_axis      = [-5 2500];
fig_num = fig_num + fig_num_inc;
% if SiteID == 'MPB1'
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Net radiation - net radiation is calculated in view sites and is NOT the trace from logger! (Amanda, April 2011)
%-----------------------------------
trace_name  = 'Net-Radiation Above Canopy';
%trace_path  = str2mat(fullfile(pthClim,'CNR_net_Avg'),fullfile(pthClim,'CNR_net_Max'),fullfile(pthClim,'CNR_net_Min'));
%trace_legend = str2mat('Net Avg','Net Max','Net Min');
trace_legend = str2mat('Net Avg');
trace_units = '(W m^{-2})';
y_axis      = [-200 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( Net_cnr1_calc, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% SW comparison: CNR1 and Dave's Eppley
%-----------------------------------
if SiteID == 'MPB3'
    trace_name  = 'SW comparison: CNR1 and Dave''s Eppley';
    trace_path  = str2mat(fullfile(pthClim,'swu_3m_Avg'),fullfile(pthClim,'swu_Avg'));
    trace_legend = str2mat('Eppley swu 3m','CNR1 swu 30m');
    trace_units = '(W m^{-2})';
    y_axis      = [-10 150];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[110.1 1],[0 0]);
    if pause_flag == 1;pause;end
end

%-----------------------------------
% Snow Tc
%-----------------------------------
% if SiteID=='MPB3'
%     trace_name  = 'Snow Thermocouple';
%     trace_path  = str2mat(fullfile(pthClim,'Snow_tc_Avg'),fullfile(pthClim,'Snow_tc_Max'),fullfile(pthClim,'Snow_tc_Min'));
%     trace_legend = str2mat('Tc Avg','Tc Max','Tc Min');
%     trace_units = '(^oC)';
%     y_axis      = [-20 20];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%     if pause_flag == 1;pause;end
% end

%-----------------------------------
% Snow Depth
%-----------------------------------
if SiteID=='MPB3'
    trace_name  = 'Snow Depth';
    trace_path  = str2mat(fullfile(pthClim,'SnowDepth_Avg'),fullfile(pthClim,'SnowDepth_Max'),fullfile(pthClim,'SnowDepth_Min'));
    trace_legend = str2mat('Snowdepth Avg','Snowdepth Max','Snowdepth Min');
    trace_units = '(m)';
    y_axis      = [0 5];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-3.6 -3.6 -3.6] );
    if pause_flag == 1;pause;end
end
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



