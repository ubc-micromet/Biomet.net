function [t,x] = FAIP_UBC_FARM_pl(ind, year, SiteID, select, fig_num_inc,pause_flag) %#ok<INUSL>
% HP_pl - plotting program for UBC Farm Site--
%   
%   Created 20161003 by Hughie Jones
%
%

% Revisions


if ind(1) > datenum(0,4,15) & ind(1) < datenum(0,10,1); %#ok<AND2>
    WINTER_TEMP_OFFSET = 0;
else
    WINTER_TEMP_OFFSET = 5;
end

colordef none
if nargin < 5
    pause_flag = 0;
end
if nargin < 4
    fig_num_inc = 1;
end
if nargin < 3
    select = 0; %#ok<NASGU>
end
if nargin < 2 | isempty(year) %#ok<OR2>
    year = datevec(now);                    % if parameter "year" not given
    year = year(1);                         % assume current year
end
if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 8/24;                                 %changed from 8/24 (Nov16 2010)
% GMTshift = 1/3;                                  
pthClim = biomet_path(year,SiteID,'cl');         % get the climate data path
% pthEC   = biomet_path(year,SiteID,'fl');         % get the eddy data path
% pthSoil = biomet_path(year,SiteID,'Climate\Soil'); %#ok<NOPRT> % get the climate\soil data path
% %pthEC   = fullfile(pthEC,'Above_Canopy');
% pthFl   = biomet_path(year,SiteID,'Flux_Logger'); 

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

% currentDate = datenum(year,1,ind(1));
% c = fr_get_init(SiteID,currentDate);
% IRGAnum = c.System(1).Instrument(2);
% SONICnum = c.System(1).Instrument(1);

%----------------------------------------------------------
% Battery Voltage
%----------------------------------------------------------
trace_name  = [SiteID '-Battery voltage'];

   trace_path  = str2mat(fullfile(pthClim,'batt_volt_Avg'),fullfile(pthClim,'batt_volt_Max'),fullfile(pthClim,'batt_volt_Min'),...
       fullfile(pthClim,'battVolt_2_Avg'),fullfile(pthClim,'battVolt_2_Max'),fullfile(pthClim,'battVolt_2_Min'));
   trace_legend= str2mat('CLIM_1 BattVolt_{Avg}','CLIM_1 BattVolt_{Max}','CLIM_1 BattVolt_{Min}',...
       'CLIM_2 BattVolt_{Avg}','CLIM_2 BattVolt_{Max}','CLIM_2 BattVolt_{Min}');

trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Battery Charge Current
%----------------------------------------------------------
trace_name  = [SiteID '-Battery Charge Current'];

   trace_path  = str2mat(fullfile(pthClim,'Batt_cur_2_Avg'),fullfile(pthClim,'Batt_cur_2_Max'),fullfile(pthClim,'Batt_cur_2_Min'));
   trace_legend= str2mat('Current_{Avg}','Current_{Max}','Current_{Min}');

trace_units = '(A)';
y_axis      = [-10 0];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Relative Humidity
%----------------------------------------------------------
trace_name  = [SiteID '-WXT relative humidity'];

   trace_path  = str2mat(fullfile(pthClim,'RelHumidity_Avg'),fullfile(pthClim,'RelHumidity_Max'),fullfile(pthClim,'RelHumidity_Min'));
   trace_legend= str2mat('RH_{Avg}','RH_{Max}','RH_{Min}');

trace_units = '(%)';
y_axis      = [0 100];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = [SiteID '-WXT barometric pressure'];

   trace_path  = str2mat(fullfile(pthClim,'AirPressure_Avg'),fullfile(pthClim,'AirPressure_Max'),fullfile(pthClim,'AirPressure_Min'));
   trace_legend= str2mat('Pressure_{Avg}','Pressure_{Max}','Pressure_{Min}');

trace_units = '(hPa)';
y_axis      = [0 1010];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% PrecipitationTotalRain
%----------------------------------------------------------
trace_name  = [SiteID '-WXT Precipitation'];

   trace_path  = str2mat(fullfile(pthClim,'TotalRain'),fullfile(pthClim,'Rain_Tot'),fullfile(pthClim,'Hamount_Tot'),fullfile(pthClim,'Ramount_Tot'));
   trace_legend= str2mat('Tipping Bucket','Tipping Bucket','WXT','WXT');

trace_units = '(mm)';
y_axis      = [0 1010];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Precipitation
%----------------------------------------------------------
trace_name  = [SiteID '-WXT Wind speed'];

   trace_path  = str2mat(fullfile(pthClim,'WindSpd_Avg'),fullfile(pthClim,'WindSpd_Max'),...
       fullfile(pthClim,'WindSpd_Min'),fullfile(pthClim,'u_wind_Avg'),fullfile(pthClim,'v_wind_Avg'),...
       fullfile(pthClim,'w_wind_Avg'));
   trace_legend= str2mat('WXT Wind speed_{Avg}','WXT Wind speed_{Max}','WXT Wind speed_{Min}',...
       'RMY_{U Avg}','RMY_{V Avg}','RMY_{W Avg}');

trace_units = '(m s^{-1})';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Mulch Surface Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Mulch surface temperature'];

   trace_path  = str2mat(fullfile(pthClim,'AirTemp_Avg'),fullfile(pthClim,'TC_CR5000_4_Avg'),...
                      fullfile(pthClim,'TC_AM25T_1_Avg'),...  
                      fullfile(pthClim,'TC_AM25T_7_Avg'),...
                      fullfile(pthClim,'TC_CR5000_2_Avg'));
   trace_legend = str2mat('Air temperature','Control mulch temp','Perf mulch temp','6-mil poly mulch temp','TMX 6-mil poly mulch temp');


trace_units = '(\circC)';
y_axis      = [0 70]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Air temperature'];

   trace_path  = str2mat(fullfile(pthClim,'AirTemp_Avg'),fullfile(pthClim,'TC_CR5000_3_Avg'),...
                      fullfile(pthClim,'TC_CR5000_6_Avg'),...  
                      fullfile(pthClim,'TC_CR5000_5_Avg'),...
                      fullfile(pthClim,'TC_CR5000_1_Avg'));
   trace_legend = str2mat('Air temp','Control air temp','Perf air temp','6-mil poly air temp','TMX 6-mil poly air temp');


trace_units = '(\circC)';
y_axis      = [0 70]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cover Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Cover temperature'];

   trace_path  = str2mat(fullfile(pthClim,'AirTemp_Avg'),fullfile(pthClim,'TC_AM25T_4_Avg'),...
                      fullfile(pthClim,'TC_AM25T_6_Avg'),...  
                      fullfile(pthClim,'TC_AM25T_5_Avg'),...
                      fullfile(pthClim,'TC_AM25T_2_Avg'),fullfile(pthClim,'TC_AM25T_3_Avg'));
   trace_legend = str2mat('Air temp','Perf cover temp','6-mil poly cover temp','TMX 6-mil poly cover temp',...
       'Unkown #2','Unkown #3');


trace_units = '(\circC)';
y_axis      = [0 70]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
trace_name  = [SiteID '-Soil Heat Flux'];

   trace_path  = str2mat(fullfile(pthClim,'SHF_RAW_4_Avg'),fullfile(pthClim,'SHF_RAW_8_Avg'),fullfile(pthClim,'SHF_RAW_2_Avg'),...
       fullfile(pthClim,'SHF_RAW_6_Avg'),fullfile(pthClim,'SHF_RAW_1_Avg'),fullfile(pthClim,'SHF_RAW_5_Avg'),...
       fullfile(pthClim,'SHF_RAW_3_Avg'),fullfile(pthClim,'SHF_RAW_7_Avg'));
   trace_legend= str2mat('Control #1','Control #2','6-mil poly #1','6-mil poly #2','Perforated poly #1','Perforated poly #2',...
   'Thermax #1','Thermax #2');

trace_units = 'mV';
y_axis      = [-10 30];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Net radiation (CNR1 sn:)Rn_1_Avg
%----------------------------------------------------------
trace_name  = [SiteID '-4 radiation components (CNR-1 #1) uncorrected'];

   trace_path  = str2mat(fullfile(pthClim,'Rn_1_Avg'),fullfile(pthClim,'short_up_1_Avg'),fullfile(pthClim,'short_dn_1_Avg'),...
       fullfile(pthClim,'long_up_corr_1_Avg'),fullfile(pthClim,'long_dn_corr_1_Avg'),...
       fullfile(pthClim,'long_up_1_Avg'),fullfile(pthClim,'long_dn_1_Avg'));
   trace_legend= str2mat('Net radiation', 'Shortwave downwelling','Shortwave upwelling',...
       'Longwave downwelling corrected','Longwave upwelling corrected',...
        'Longwave downwelling uncorrected','Longwave upwelling uncorrected');

trace_units = 'W m^{-2}';
y_axis      = [-200 800];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Net radiation (CNR1 sn:)cnr1_rad_1_Rn_1_Avg
%----------------------------------------------------------
trace_name  = [SiteID '-R_n and 4 radiation components (CNR-1 #1) corrected'];

   trace_path  = str2mat(fullfile(pthClim,'cnr1_rad_1_Rn_1_Avg'),fullfile(pthClim,'CNR1_su_1_Avg'),fullfile(pthClim,'CNR1_sd_1_Avg'),...
       fullfile(pthClim,'cnr1_rad_1_lu_corr_1_Avg'),fullfile(pthClim,'cnr1_rad_1_ld_corr_1_Avg'),...
        fullfile(pthClim,'CNR1_lu_1_Avg'),fullfile(pthClim,'CNR1_ld_1_Avg'));
   trace_legend= str2mat('Net radiation','Shortwave downwelling','Shortwave upwelling',...
       'Longwave downwelling corrected','Longwave upwelling corrected',...
        'Longwave downwelling uncorrected','Longwave upwelling uncorrected');

trace_units = 'W m^{-2}';
y_axis      = [-200 800];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Net radiation (CNR1 sn:)long_dn_corr_1_Avg
%----------------------------------------------------------
trace_name  = [SiteID '-R_n and 4 radiation components (CNR-1 #2) '];

   trace_path  = str2mat(fullfile(pthClim,'Rn_2_Avg'),fullfile(pthClim,'short_up_2_Avg'),fullfile(pthClim,'short_dn_2_Avg'),...
        fullfile(pthClim,'long_up_corr_2_Avg'),fullfile(pthClim,'long_dn_corr_2_Avg'),...
       fullfile(pthClim,'long_up_2_Avg'),fullfile(pthClim,'long_dn_2_Avg'));
   trace_legend= str2mat('Net radiation','Shortwave downwelling','Shortwave upwelling',...
       'Longwave downwelling corrected','Longwave upwelling corrected',...
        'Longwave downwelling uncorrected','Longwave upwelling uncorrected');
    
trace_units = 'W m^{-2}';
y_axis      = [-200 800];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end




% 
% %----------------------------------------------------------
% % Logger Temp
% %----------------------------------------------------------
% trace_name  = [SiteID '-Logger temperature'];
% if strcmp(SiteID,'HP09')
%    trace_path  = str2mat(fullfile(pthClim,'RefT_MPLX_AVG'),fullfile(pthFl,'ref_temp_Avg'));
%    trace_legend= str2mat('MUX','Eddy Logger');
% elseif strcmp(SiteID,'HP11')
%     trace_path  = str2mat(fullfile(pthFl,'ref_temp_Avg'));
%     trace_legend= str2mat('Eddy Logger');
% end
% trace_units = '(\circC)';
% y_axis      = [0 50]-WINTER_TEMP_OFFSET;
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 1],[0 0]);
% if pause_flag == 1;pause;end
% 
% ----------------------------------------------------------
% % Sonic wind speed logger
% %----------------------------------------------------------
% trace_name  = [SiteID '-CSAT wind vector components'];
% trace_path  = str2mat(fullfile(pthFl,'u_wind_Avg'),fullfile(pthFl,'v_wind_Avg'),fullfile(pthFl,'w_wind_Avg'));
% trace_legend= str2mat('u wind','v wind','w wind');
% trace_units = '(m s^{-1})';
% y_axis      = [-10 10];
% fig_num = fig_num + fig_num_inc;
% x_CSAT = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% %-----------------------------------
% % Net radiation
% %-----------------------------------
% 
% if strcmp(SiteID,'HP09')
%  trace_name  = 'HP09-Net radiation above canopy';
%  trace_path  = str2mat(fullfile(pthClim,'Net_Radn_AVG'));
% elseif strcmp(SiteID,'HP11')
%  trace_name  = 'HP11-Net radiation above canopy';
%  trace_path  = str2mat(fullfile(pthClim,'Rn_Avg'));
% end
% trace_legend = str2mat('Net Avg');
% trace_units = '(W m^{-2})';
% y_axis      = [-200 1400];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% %-----------------------------------
% % Net radiation SW and LW
% %-----------------------------------
% 
% if strcmp(SiteID,'HP09')
%  trace_name  = 'HP09-Radiation above canopy';
%  trace_path  = str2mat(fullfile(pthClim,'SW_DW_AVG'),fullfile(pthClim,'SW_UW_AVG'),fullfile(pthClim,'LW_DW_AVG'),fullfile(pthClim,'LW_UW_AVG'));
% elseif strcmp(SiteID,'HP11')
%  trace_name  = 'HP11-Radiation above canopy';
%  trace_path  = str2mat(fullfile(pthClim,'short_dn_Avg'),fullfile(pthClim,'short_up_Avg'),fullfile(pthClim,'long_dn_Avg'),fullfile(pthClim,'long_up_Avg'));
% end
% trace_legend = str2mat('swu Avg','swd Avg','lwu Avg','lwd Avg');
% trace_units = '(W m^{-2})';
% y_axis      = [-200 2000];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end
% 
% %---------------------------------
% % Corrected Radiation above Canopy
% %----------------------------------
% 
% if strcmp(SiteID,'HP11')
% T_CNR4 = read_bor(fullfile(pthClim,'cnr4_T_C_Avg'));
% LongWaveOffset =(5.67E-8*(273.15+T_CNR4).^4);
% 
% S_upper_AVG = read_bor(fullfile(pthClim,'short_up_Avg'));
% S_lower_AVG = read_bor(fullfile(pthClim,'short_dn_Avg'));
% lwu = read_bor(fullfile(pthClim,'long_dn_Avg'));
% lwd = read_bor(fullfile(pthClim,'long_up_Avg'));
% trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
% trace_units = '(W m^{-2})';
% y_axis      = [-200 1400];
% L_upper_AVG = lwd + LongWaveOffset;
% L_lower_AVG = lwu + LongWaveOffset;
% Net_cnr4_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
% trace_path = [S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr4_calc];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end
% end
% 
% %----------------------------------------------------------
% % Barometric Pressure
% %----------------------------------------------------------
% trace_name  = [SiteID '-Barometric pressure'];
% %trace_path  = str2mat(fullfile(pthEC,'MiscVariables.BarometricP'),fullfile(pthFl,'Irga_P_Avg'));
% trace_path  = str2mat(fullfile(pthFl,'Irga_P_Avg'),fullfile(pthFl,'Irga_P_Min'),fullfile(pthFl,'Irga_P_Max'));
% trace_legend= str2mat('Avg','Min','Max');
% trace_units = '(kPa)';
% y_axis      = [30 110];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% %----------------------------------------------------------
% % Wind speed (RM Young)
% %----------------------------------------------------------
% % trace_name  = 'Climate: Wind Speed Averages (RM Young)';
% % trace_path  = str2mat(fullfile(pthClim,'WS_ms_S_WVT'));
% % trace_legend = str2mat('CSAT','RMYoung (avg)');
% % trace_units = '(m/s)';
% % y_axis      = [0 10];
% % fig_num = fig_num + fig_num_inc;
% % x_RMYoung = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% % clf
% % x = plt_msig( [sqrt(sum(x_CSAT'.^2))' x_RMYoung], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% % if pause_flag == 1;pause;end
% 
% 
% % ----------------------------------------------------------
% % Precipitation 
% % ----------------------------------------------------------
% trace_name  = [SiteID '-Rainfall'];
% if strcmp(SiteID,'HP11')
%     trace_path  = str2mat(fullfile(pthClim,'Rain_Tot'));
%     trace_legend= str2mat('Rain_Hhour');
% elseif strcmp(SiteID,'HP09')
%     trace_path = str2mat(fullfile(pthSoil,'Rain_Tot'));
%     trace_legend = str2mat('Rain_Hhour');
% end
% trace_units = '(mm)';
% y_axis      = [-1 5];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% 
% if pause_flag == 1;pause;end
% 
% % ----------------------------------------------------------
% % Cumulative Precipitation
% % ----------------------------------------------------------
% trace_name  = [SiteID '-Cumlative Rainfall'];
% if strcmp(SiteID,'HP11')
%     trace_path  = str2mat(fullfile(pthClim,'TotalRain'));
%     trace_legend= str2mat('Cumulative Rain');
% elseif strcmp(SiteID,'HP09')
%     trace_path = str2mat(fullfile(pthSoil,'TotalRain'));
%     trace_legend = str2mat('Cumulative Rain');
% end
% trace_units = '(mm)';
% y_axis      = [-10 400];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% 
% if pause_flag == 1;pause;end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %----------------------------------------------------------
% % Sonic wind speed
% %----------------------------------------------------------
% trace_name  = [SiteID '-Wind Speed'];
% wspd2d = sqrt(u.^2 + v.^2);
% if strcmp(SiteID,'HP11')
%   wspd_Gill_Avg = read_bor(fullfile(pthClim,'WindSpeed_Avg'));
%   wspd_Gill_Max = read_bor(fullfile(pthClim,'WindSpeed_Max'));
%   wspd_Gill_Min = read_bor(fullfile(pthClim,'WindSpeed_Min'));
%   trace_legend= str2mat('CSAT3','Gill Avg','Gill Max','Gill Min');
%   trace_units = '(m/s)';
%   y_axis      = [0 10];
%   fig_num = fig_num + fig_num_inc;
%   x = plt_msig( [wspd2d(ind) wspd_Gill_Avg(ind) wspd_Gill_Max(ind) wspd_Gill_Min(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% elseif strcmp(SiteID,'HP09')
%     trace_legend= str2mat('CSAT3');
%     trace_units = '(m/s)';
%     y_axis      = [0 10];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( [wspd2d(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% end
% 
% if pause_flag == 1;pause;end
% 
% %----------------------------------------------------------
% % Sonic wind direction
% %----------------------------------------------------------
% trace_name  = [SiteID '-Wind direction'];
% wdir   = FR_Sonic_wind_direction([u'; v'],'CSAT3');
% if strcmp(SiteID,'HP11')
%   wdir_Gill  = read_bor(fullfile(pthClim,'WindDir_Avg'));
%   trace_legend= str2mat('CSAT3','Gill WindSonic');
%   trace_units = '(^o)';
%   y_axis      = [-10 400];
%   fig_num = fig_num + fig_num_inc;
%   x = plt_msig( [wdir(ind)' wdir_Gill(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% elseif strcmp(SiteID,'HP09')
%     trace_legend= str2mat('CSAT3');
%     trace_units = '(^o)';
%     y_axis      = [-10 400];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( [wdir(ind)' ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% end
% 
% if pause_flag == 1;pause;end
% 
% 
% 
% 
% %----------------------------------------------------------
% % Soil Temperature Profile
% %----------------------------------------------------------
% 
% if strcmp(SiteID,'HP11')
% 
%     trace_name  = [SiteID '-Soil temperature profile'];
% trace_path  = str2mat(fullfile(pthClim,'SoilT_3cm_Avg'),fullfile(pthClim,'SoilT_15cm_Avg'),...
%                       fullfile(pthClim,'SoilT_30cm_Avg'),fullfile(pthClim,'SoilT_60cm_Avg'),...
%                       fullfile(pthClim,'SoilT_100cm_Avg'));
% trace_legend= str2mat('soilT_{3cm}','soillT_{15cm}','soilT_{30cm}','soilT_{60cm}','soilT_{100cm}');
% trace_units = '(\circC)';
% y_axis      = [-20 40];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 
% 
% if pause_flag == 1;pause;end
% 
% end
% 
% %----------------------------------------------------------
% % Soil Heat Flux
% %----------------------------------------------------------
% trace_name  = [SiteID '-Soil heat flux'];
% 
% if strcmp(SiteID,'HP09')
%   trace_path  = str2mat(fullfile(pthClim,'SHF_1_AVG'),fullfile(pthClim,'SHF_2_AVG'),...
%                       fullfile(pthClim,'SHF_3_AVG'),fullfile(pthClim,'SHF_4_AVG'),fullfile(pthClim,'SHF_5_AVG'));
%   trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}','sheat_{5}');
% elseif strcmp(SiteID,'HP11')
%  trace_path  = str2mat(fullfile(pthClim,'SoilHeat_1_Avg'),fullfile(pthClim,'SoilHeat_2_Avg'),...
%                       fullfile(pthClim,'SoilHeat_3_Avg'),fullfile(pthClim,'SoilHeat_4_Avg'));
%  trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}');
% end
% 
% trace_units = '(W m^{-2})';
% y_axis      = [-50 250];
% fig_num = fig_num + fig_num_inc;
% 
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 
% 
% if pause_flag == 1;pause;end
% 
% %-----------------------------------
% % Soil Tc's for SHF correction
% %-----------------------------------
% if strcmp(SiteID,'HP09')
% trace_name  = 'HP09-Soil temperature at 3 cm for SHF correction';
% 
% trace_path  = str2mat(fullfile(pthClim,'TC_3cm_1_AVG'),fullfile(pthClim,'TC_3cm_2_AVG'));
% trace_legend = str2mat('Rep 1','Rep 2');
% 
% trace_units = '(W m^{-2})';
% y_axis      = [0 35 ] -  WINTER_TEMP_OFFSET;
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end
% end
% 
% %----------------------------------------------------------
% % Soil Moisture Profile
% %----------------------------------------------------------
% 
% if strcmp(SiteID,'HP11')
%     trace_name  = [SiteID '-Soil Moisture profile'];
%     trace_path  = str2mat(fullfile(pthClim,'CS616_percent1'),fullfile(pthClim,'CS616_percent2'),...
%                       fullfile(pthClim,'CS616_percent3'),fullfile(pthClim,'CS616_percent4'),...
%                       fullfile(pthClim,'CS616_percent5'));
%     trace_legend= str2mat('VWC_{3cm}','VWC_{10cm}','VWC_{20cm}','VWC_{50cm}','VWC_{80cm}');
% trace_units = '(%)';
% y_axis      = [0 1];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 
% 
% if pause_flag == 1;pause;end
% 
% end
% 
% if strcmp(SiteID,'HP09')
%     trace_name  = [SiteID '-Soil Moisture profile'];
%     trace_path  = str2mat(fullfile(pthSoil,'VWCm_4_Avg'),fullfile(pthSoil,'VWCm_3_Avg'),fullfile(pthSoil,'VWCm_2_Avg'),fullfile(pthSoil,'VWCm_Avg'));
%     trace_legend= str2mat('VWC_{5cm}','VWC_{20cm}','VWC_{50cm}','VWC_{80cm}');
% trace_units = '(%)';
% y_axis      = [0 100];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 
% 
% if pause_flag == 1;pause;end
% 
% end
% 
% 
% %----------------------------------------------------------
% % PAR
% %----------------------------------------------------------
% 
% trace_name  = [SiteID '-PAR above canopy'];
% if strcmp(SiteID,'HP09')
%   trace_path  = str2mat(fullfile(pthClim,'PAR_dn_AVG'),fullfile(pthClim,'PAR_up_AVG'));
%   trace_legend= str2mat('PAR_{uw}','PAR_{dw}');
% elseif strcmp(SiteID,'HP11')
%  trace_path  = str2mat(fullfile(pthClim,'Par_DownWell_Avg'),fullfile(pthClim,'Par_UpWell_Avg'));
%   trace_legend= str2mat('PAR_{uw}','PAR_{dw}');
% end
% 
% trace_units = '(\mumol photons m^{-2} s^{-1})';
% y_axis      = [-5 2500];
% fig_num = fig_num + fig_num_inc;
% % if SiteID == 'MPB1'
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% 



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



function set_figure_name(SiteID)
     title_string = get(get(gca,'title'),'string');
     set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'number','off')
