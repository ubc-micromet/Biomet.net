function [t,x] = MPB_pl(ind, year, SiteID, select, fig_num_inc,pause_flag)

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

%----------------------------------------------------------
% HMP Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: HMP Temperature';
trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthClim,'HMP_T_Min'),fullfile(pthClim,'HMP_T_Max'));
trace_legend= str2mat('HMPTemp__{Avg}','HMPTemp_{Min}','HMPTemp_{Max}');
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
trace_path  = str2mat(fullfile(pthClim,'H2Opercent_Avg1'),fullfile(pthClim,'H2Opercent_Avg2'),fullfile(pthClim,'H2Opercent_Avg3'));
trace_legend= str2mat('H2O%_{1}','H2O%_{2}','H2O%_{3}');
trace_units = '(%)';

if SiteID == 'MPB1';
y_axis      = [0 1];
else
y_axis      = [0 600];   
end

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Precipitation - needs a multiplier
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Rainfall';
trace_path  = str2mat(fullfile(pthClim,'RainFall_Tot'));
trace_legend= str2mat('Rainfall_tot');
trace_units = '(mm)';
y_axis      = [0 4];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative Precipitation
%----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'Climate: Cumulative Rain';
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
trace_path  = str2mat(fullfile(pthClim,'Soil_temp_Avg1'),fullfile(pthClim,'Soil_temp_Avg2'),fullfile(pthClim,'Soil_temp_Avg3'),...
                      fullfile(pthClim,'Soil_temp_Avg4'),fullfile(pthClim,'Soil_temp_Avg5'));
               if SiteID == 'MPB1';
                   trace_legend= str2mat('Ts_{50}','Ts_{5}','Ts_{10}','Ts{20}','');
               else              
                   trace_legend= str2mat('Ts_{2}','Ts_{5}','Ts_{10}','Ts{30}','Ts{50}');
               end
trace_units = '(\circC)';
y_axis      = [-15 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% Logger Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Temperature';
trace_path  = str2mat(fullfile(pthClim,'LoggerRefTemp_Avg'),fullfile(pthClim,'LoggerRefTemp_Min'),...
              fullfile(pthClim,'LoggerRefTemp_Max'));
trace_legend= str2mat('LoggerRefTemp_{Avg}','LoggerRefTemp_{Min}','LoggerRefTemp_{Max}');
trace_units = '(\circC)';
y_axis      = [0 50]-WINTER_TEMP_OFFSET;
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
% Logger Current
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Current';
trace_path  = str2mat(fullfile(pthClim,'BattCurrent_Avg'),fullfile(pthClim,'BattCurrent_Min'),fullfile(pthClim,'BattCurrent_Max'));
trace_legend= str2mat('BattCurrent_{Avg}','BattCurrent_{Min}','BattCurrent_{Max}');
trace_units = '(V)';
y_axis      = [-10 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Barometric Pressure';
trace_path  = str2mat(fullfile(pthEC,'MiscVariables.BarometricP'));
trace_legend= str2mat('Pressure');
trace_units = '(Kpa)';
y_axis      = [30 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% CO2 
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: CO2';
trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_1'),fullfile(pthEC,'Instrument_5.Min_1'),fullfile(pthEC,'Instrument_5.Max_1'));
trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}');
trace_units = '(\mumol CO_{2} m^{-3})';
y_axis      = [-5 40];
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
% H2O
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: H2O';
trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_2'),fullfile(pthEC,'Instrument_5.Min_2'),fullfile(pthEC,'Instrument_5.Max_2'));
trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H2O_{Max}');
trace_units = '(H2O)';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind direction
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: H2O';
trace_path  = str2mat(fullfile(pthEC,'Instrument_2.MiscVariables.WindDirection'));
trace_legend= str2mat('H2O_{Avg}');
trace_units = '(^o)';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% IRGA Diagnostic
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Idiag';
trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_4'));
trace_legend= str2mat('Idiag');
trace_units = '';
y_axis      = [240 260];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Sonic Diagnostic
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Sdiag';
trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_9'));
trace_legend= str2mat('Sdiag');
trace_units = '';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Sheat_flux';
if SiteID == 'MPB1';
trace_path  = str2mat(fullfile(pthClim,'Sheat_flux_Avg1'),fullfile(pthClim,'Sheat_flux_Avg2')...
    ,fullfile(pthClim,'Sheat_flux_Avg3'),fullfile(pthClim,'Sheat_flux_Avg4'));
trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}');
else
trace_path  = str2mat(fullfile(pthClim,'Sheat_flux_Avg1'),fullfile(pthClim,'Sheat_flux_Avg2'),fullfile(pthClim,'Sheat_flux_Avg3'));
trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}');   
end
trace_units = '(Watts m^{-2} s^{-1})';
y_axis      = [-200 200];
fig_num = fig_num + fig_num_inc;
if SiteID == 'MPB1';
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 1 1 1 1]);
else
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1 -1]);  
end
if pause_flag == 1;pause;end


%----------------------------------------------------------
% PAR
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: PAR';
if SiteID == 'MPB1'
trace_path  = str2mat(fullfile(pthClim,'Quantum_Avg'),fullfile(pthClim,'Quantum_Avg1'),fullfile(pthClim,'Quantum_Avg2'),...
              fullfile(pthClim,'Quantum_Avg3'));
trace_legend= str2mat('Quantum_{Avg}','Quantum_{Avg1}','Quantum_{Avg2}','Quantum_{Avg3}');
else
trace_path  = str2mat(fullfile(pthClim,'Quantum_Avg1'),fullfile(pthClim,'Quantum_Avg2'),fullfile(pthClim,'Quantum_Avg3'));
trace_legend= str2mat('Quantum_{Avg1}','Quantum_{Avg2}','Quantum_{Avg3}');    
end
trace_units = '(\mumol CO_{2} m^{-2})';
y_axis      = [-5 2500];
fig_num = fig_num + fig_num_inc;
if SiteID == 'MPB1'
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Speed Averages (RM Young)';
trace_path  = str2mat(fullfile(pthClim,'WS_ms_S_WVT'));
trace_legend = str2mat('WS (avg)');
trace_units = '(m/s)';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Direction (RM Young)';
trace_path  = str2mat(fullfile(pthClim,'WindDir_SD1_WVT'),fullfile(pthClim,'WindDir_D1_WVT'));
trace_legend = str2mat('25m','25m');
trace_units = '(^o)';
y_axis      = [0 360];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation
%-----------------------------------
trace_name  = 'Net-Radiation Above Canopy';
trace_path  = str2mat(fullfile(pthClim,'CNR_net_Avg'),fullfile(pthClim,'CNR_net_Max'),fullfile(pthClim,'CNR_net_Min'));
trace_legend = str2mat('Net_Avg','Net_Max','Net_Min');
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation
%-----------------------------------
trace_name  = 'Radiation Above Canopy';
if SiteID == 'MPB2'
trace_path  = str2mat(fullfile(pthClim,'swd_Avg'),fullfile(pthClim,'swu_Avg'),fullfile(pthClim,'lwd_Avg'),fullfile(pthClim,'lwu_Avg'));
trace_legend = str2mat('swu_Avg','swd_Avg','lwd_Avg','lwu_Avg');
else
trace_path  = str2mat(fullfile(pthClim,'swd_Avg'),fullfile(pthClim,'swu_Avg'),fullfile(pthClim,'lwd_Avg'),fullfile(pthClim,'lwu_Avg'));
trace_legend = str2mat('S upper_Avg','S lower_Avg','L upper_Avg','L lower_Avg');
% lwd_Avg = -lwd_Avg;
% lwu_Avg = -lwu_Avg;
end
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
if SiteID == 'MPB1'
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 -1 -1]);
else
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
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



end