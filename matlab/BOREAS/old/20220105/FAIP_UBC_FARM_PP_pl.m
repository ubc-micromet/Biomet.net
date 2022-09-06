function [t,x] = FAIP_UBC_FARM_PP_pl(ind, year, SiteID, select, fig_num_inc,pause_flag) %#ok<INUSL>
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
pthClim = biomet_path(year,SiteID,'cl');  
pthSS = biomet_path(year,SiteID,'Clean\SecondStage');  % get the climate data path
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
y_axis      = [0 1100];
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

   trace_path  = str2mat(fullfile(pthSS,'air_temperature_main'),fullfile(pthSS,'Ta_BM_PP_10cm'),...
                      fullfile(pthSS,'Ta_HDP_PP_10cm'),...  
                      fullfile(pthSS,'Ta_HDP_EMP_10cm'),...
                      fullfile(pthSS,'Ta_TMX_PP_10cm'),...
                      fullfile(pthSS,'Ta_BM_PP_50cm'),...
                      fullfile(pthSS,'Ta_HDP_PP_50cm'),...  
                      fullfile(pthSS,'Ta_HDP_EMP_50cm'),...
                      fullfile(pthSS,'Ta_TMX_PP_50cm'));
   trace_legend = str2mat('Air temp', ' T_a Control PP (10 cm)', ' T_a HDP PP (10 cm)', ' T_a HDP empty (10 cm)', ' T_a TMX PP (10 cm)',...
   ' T_a Control PP (50 cm)', ' T_a HDP PP (50 cm)', ' T_a HDP empty (50 cm)', ' T_a TMX PP (50 cm)');


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
