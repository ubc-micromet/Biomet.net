function [t,x] = FAIP_MC_pl(ind, year, SiteID, select, fig_num_inc,pause_flag) %#ok<INUSL>
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

   trace_path  = str2mat(fullfile(pthClim,'BattV_Avg'),fullfile(pthClim,'BattV_Max'),...
       fullfile(pthClim,'BattV_Min'));
   trace_legend= str2mat('CLIM_1 BattVolt_{Avg}','CLIM_1 BattVolt_{Max}','CLIM_1 BattVolt_{Min}');

trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Relative Humidity
%----------------------------------------------------------
trace_name  = [SiteID '-WXT relative humidity (2 m)'];

   trace_path  = str2mat(fullfile(pthClim,'RelHumidity_Avg'),fullfile(pthClim,'HoneyW_RH_Tcorr_1_Avg'),...
       fullfile(pthClim,'HoneyW_RH_Tcorr_2_Avg'),fullfile(pthClim,'HoneyW_RH_Tcorr_3_Avg'));
   trace_legend= str2mat('RH_{Avg} (2m)','RH Super 4','RH 6-mil poly','RH Thermax');

trace_units = '(%)';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = [SiteID '-WXT barometric pressure (2 m)'];

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
trace_name  = [SiteID '-WXT Precipitation (2 m)'];

   trace_path  = str2mat(fullfile(pthClim,'TotalRain'),fullfile(pthClim,'Rain_Tot'));
   trace_legend= str2mat('Tipping Bucket','Tipping Bucket','WXT');

trace_units = '(mm)';
y_axis      = [0 1010];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Precipitation
%----------------------------------------------------------
trace_name  = [SiteID '-WXT Wind speed (2 m)'];

   trace_path  = str2mat(fullfile(pthClim,'WindSpd_Avg'),fullfile(pthClim,'WindSpd_Max'),...
       fullfile(pthClim,'WindSpd_Min'));
   trace_legend= str2mat('WXT Wind speed_{Avg}','WXT Wind speed_{Max}','WXT Wind speed_{Min}');

trace_units = '(m s^{-1})';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Mulch Surface Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Surface temperature'];

   trace_path  = str2mat(fullfile(pthClim,'CTT_C_1_Avg'),fullfile(pthClim,'CTT_C_2_Avg'),...
                      fullfile(pthClim,'CTT_C_3_Avg'));
   trace_legend = str2mat('Thermax','6-mil Poly','control (outside tunnel)');


trace_units = '(\circC)';
y_axis      = [-10 70]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Air temperature'];

   trace_path  = str2mat(fullfile(pthClim,'Air_temp_HH_1'),fullfile(pthClim,'Air_temp_HH_2'),...
                      fullfile(pthClim,'Air_temp_HH_3'),fullfile(pthClim,'Air_temp_HH_4'),...  
                      fullfile(pthClim,'Air_temp_HH_5'),fullfile(pthClim,'Air_temp_HH_6'),...
                      fullfile(pthClim,'Air_temp_HH_7'),fullfile(pthClim,'Air_temp_HH_8'),...
                      fullfile(pthClim,'Air_temp_HH_9'),fullfile(pthClim,'AirTemp_Avg'));
   trace_legend = str2mat('Tunnel temp #1','Tunnel temp #2','Tunnel temp #3','Tunnel temp #4',...
       'Tunnel temp #5','Tunnel temp #6','Tunnel temp #7','Tunnel temp #8','Tunnel temp #9',...
       'Air temp');


trace_units = '(\circC)';
y_axis      = [-10 70]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Soil temperature (5 cm)'];

   trace_path  = str2mat(fullfile(pthClim,'P_Avg1_2'),fullfile(pthClim,'P_Avg6_2'),...
                      fullfile(pthClim,'P_Avg9_2'),fullfile(pthClim,'P_Avg5_2'),...  
                      fullfile(pthClim,'P_Avg7_2'),fullfile(pthClim,'P_Avg8_2'),...
                      fullfile(pthClim,'P_Avg3_2'),fullfile(pthClim,'P_Avg2_2'),...
                      fullfile(pthClim,'P_Avg4_2'),fullfile(pthClim,'P_Avg10_2'),...
                      fullfile(pthClim,'P_Avg11_2'),fullfile(pthClim,'P_Avg12_2'));
   trace_legend = str2mat('6-mil Poly #1','6-mil Poly #2','6-mil Poly #3','Super4 #1'...
       ,'Super4 #2','Super4 #3','Thermax #1','Thermax #2','Thermax #3', 'Control #1',...
       'Control #2','Control #2');


trace_units = '(\circC)';
y_axis      = [-10 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Soil moisture (5 cm)'];

   trace_path  = str2mat(fullfile(pthClim,'P_Avg1_1'),fullfile(pthClim,'P_Avg6_1'),...
                      fullfile(pthClim,'P_Avg9_1'),fullfile(pthClim,'P_Avg5_1'),...  
                      fullfile(pthClim,'P_Avg7_1'),fullfile(pthClim,'P_Avg8_1'),...
                      fullfile(pthClim,'P_Avg3_1'),fullfile(pthClim,'P_Avg2_1'),...
                      fullfile(pthClim,'P_Avg4_1'),fullfile(pthClim,'P_Avg10_1'),...
                      fullfile(pthClim,'P_Avg11_1'),fullfile(pthClim,'P_Avg12_1'));
   trace_legend = str2mat('6-mil Poly #1','6-mil Poly #2','6-mil Poly #3','Super4 #1'...
       ,'Super4 #2','Super4 #3','Thermax #1','Thermax #2','Thermax #3', 'Control #1',...
       'Control #2','Control #2');


trace_units = '(\circC)';
y_axis      = [0 100]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temp
%----------------------------------------------------------
trace_name  = [SiteID '-PPFD (2 m)'];

   trace_path  = str2mat(fullfile(pthClim,'PAR1'),fullfile(pthClim,'PAR2'));
   trace_legend = str2mat('PPFD #1','PPFD #2');


trace_units = '(\circC)';
y_axis      = [0 2000];
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
