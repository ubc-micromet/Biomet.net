function [t,x] = yf_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = yf_pl(ind, year, select, fig_num_inc)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
% (c) Elyn Humphreys         File created:   Sept 6, 2001      
%                            Last modification:  Jul 13, 2010
% (c) Nesic Zoran           
%

% Revisions:
% July 13, 2010 (Zoran)
%   - added inverter current plot and the system power plot
% Nov 24, 2005 - Add sample tube temperature plot
% Feb 1, 2002 - isolated diagnostic info in this program

if ind(1) > datenum(0,4,15) & ind(1) < datenum(0,10,15);
    WINTER_TEMP_OFFSET = 0;
else
    WINTER_TEMP_OFFSET = 15;
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

GMTshift = 8/24;                                    % offset to convert GMT to PST
[pth] = biomet_path(year,'YF','cl');                % get the climate data path
axis1 = [340 400];
axis2 = [-10 5];
axis3 = [-50 250];
axis4 = [-50 250];


% Find logger ini files
ini_climMain = fr_get_logger_ini('yf',year,[],'yf_clim_60');   % main climate-logger array
ini_clim2    = fr_get_logger_ini('yf',year,[],'yf_clim_61');   % secondary climate-logger array

ini_climMain = rmfield(ini_climMain,'LoggerName');
ini_clim2    = rmfield(ini_clim2,'LoggerName');

st = min(ind);                                        % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

fileName = fr_logger_to_db_fileName(ini_climMain, '_dt', pth);
t=read_bor(fileName);                               % get decimal time from the data base
if year < 2000
    offset_doy=datenum(year,1,1)-datenum(1996,1,1);     % find offset DOY
else
    offset_doy=0;
end
t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

%----------------------------------------------------------
% HMP air temperatures
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Air Temperature';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pth),...
   							fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth),...
   							fr_logger_to_db_fileName(ini_climMain, 'Temp_3_AVG', pth));
trace_legend = str2mat('HMP\_12m Met1', 'PT100\_12m Met1','TC\_12m');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Main Battery voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Main Battery Voltage';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Main_V_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Main_V_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Main_V_MIN', pth));
trace_legend = str2mat('Avg','Max','Min');
trace_units = '(V)';
y_axis      = [11 15.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Generator hut temperature
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Generator Hut Temperature';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Soil_10_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Main_V_Avg', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pth));
trace_legend = str2mat('Hut Temp.','MainBatt Avg.','Air Temp.');
trace_units = '(degC) and V';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Emergency Battery voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Emergency Battery Voltage';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_MIN', pth));
trace_legend = str2mat('Avg','Max','Min');
trace_units = '(V)';
y_axis      = [10.5 14.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: YF\_Clim Logger Voltage';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'Batt_Volt_AVG', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'Batt_Volt_MAX', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'Batt_Volt_MIN', pth));
trace_legend = str2mat('Avg','Max','Min');
trace_units = '(V)';
y_axis      = [11.0 12.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Main Pwr ON signal
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Main Power ON signal';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'MainPwr_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'MainPwr_MIN', pth));
trace_legend = str2mat('Max','Min');
trace_units = '(16 = Main pwr ON)';
y_axis      = [0 17];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% BB currents
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Inverter Current';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'I_invert_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'I_invert_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'I_invert_MIN', pth));
trace_legend = str2mat('I Avg','I Max','I Min');
trace_units = '(A)';
y_axis      = [0 100];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Climate box currents
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Climate System Current';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'I_main_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'I_main_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'I_main_MIN', pth));
trace_legend = str2mat('I Avg','I Max','I Min');
trace_units = '(A)';
y_axis      = [0 6];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Climate Box Power consumption
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Climate System Power Consumption';
Ibb = read_sig( [fr_logger_to_db_fileName(ini_climMain, 'I_main_AVG', pth)], ind,year, t, 0 );
BB2  = read_sig( [fr_logger_to_db_fileName(ini_climMain, 'Main_V_AVG', pth)], ind,year, t, 0 );
trace_path  = (Ibb) .* BB2;
trace_legend = [];
trace_units = '(W)';
y_axis      = [0 60];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Power consumption
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Total YF Power Consumption';
Ibb1 = read_sig( [fr_logger_to_db_fileName(ini_climMain, 'I_invert_AVG', pth)], ind,year, t, 0 );
trace_path  = (Ibb+Ibb1) .* BB2;
trace_legend = [];
trace_units = '(W)';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Panel temperatures/Box temperatures
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Panel/Box Temperatures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Panel_T_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Hut_T_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'FlxBox_T_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Ref_AM32_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'AM25T1ref_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pt_1002_AVG', pth));
trace_legend = str2mat('12m Pt-100','yf\_Clim T Avg','Hut T Avg','FlxBox T Avg','AM32 T Avg', 'AM25T T AVG','CNR1');
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Tank Pressures
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Tank Pressures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pres_ref_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pres_zer_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pres_cal1_AVG', pth));
                      %fr_logger_to_db_fileName(ini_climMain, 'Pres_cal2_AVG', pth));
                  
trace_legend = str2mat('Ref(R)','Ref(L)','Cal1','Pneumatic');
trace_units = '(psi)';
y_axis      = [0 2600];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
x=x_all(:,1);
ref_lim = 400;                              % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
px = polyfit(x(index),t(index),1);         % fit first order polynomial
lowLim = polyval(px,ref_lim);                   % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),250,sprintf('Rate of change = %4.0f psi per week',perWeek));
text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Low limit(%5.1f) will be reached on DOY = %4.0f',ref_lim,lowLim));
if pause_flag == 1;pause;end
zoom on

%----------------------------------------------------------
% Chamber Compressor
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Chamber compressor';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pres_cal2_AVG', pth));             
trace_legend = str2mat('Ch Compressor');
trace_units = '(psi)';
y_axis      = [0 130];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sample Tube Temperature
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Sample Tube Temperature';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'TubeTC_1_AVG', pth),...
   						fr_logger_to_db_fileName(ini_climMain, 'TubeTC_2_AVG', pth),...
    					fr_logger_to_db_fileName(ini_climMain, 'TubeTC_3_AVG', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth));
                        
trace_legend = str2mat('1','2','3','PT100 Met1');
trace_units = '(degC)';
y_axis      = [5 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Rain 
%----------------------------------------------------------
trace_name  = 'Climate: Rainfall';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'TBRG_1_TOT', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'TBRG_2_TOT', pth));
trace_units = '(mm)';
trace_legend = str2mat('TBRG1','TBRG2\_snow');
y_axis      = [-1 10];
fig_num = fig_num + fig_num_inc;
[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative rain 
%----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'Climate: Cumulative Rain';
y_axis      = [];
ax = [st ed];

[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
[x2,tx_new] = read_sig(trace_path(2,:), indx,year, tx,0);
fig_num = fig_num + fig_num_inc;
if year==1998
    addRain = 856.9;
else 
    addRain = 0;
end
plt_sig1( tx_new, [cumsum(x1) cumsum(x2)+addRain], trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Snow temperatures 
%----------------------------------------------------------
trace_name  = 'Climate: Snow Temperatures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Snow_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_5_AVG', pth));
trace_legend = str2mat('1 cm','5 cm','10 cm','20 cm','50 cm');
trace_units = '(degC)';
y_axis      = [0 40] - WINTER_TEMP_OFFSET;
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



%-----------------------------------
% Soil Temperatures
%-----------------------------------
trace_name  = 'Climate: Soil Temperatures ';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Soil_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_6_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_7_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_8_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_9_AVG', pth));
trace_legend = str2mat('2cm','5cm','10cm','20cm','50cm','100cm','0.5cm','1cm','2cm');
trace_units = 'deg C';
y_axis      = [5 25] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Tree/Surface temperatures 
%----------------------------------------------------------
trace_name  = 'Climate: Tree/Surface Temperatures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Tree_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_6_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Ever_Ttar_AVG', pth));
trace_legend = str2mat('tree1','tree2','tree3','tree4','tree5','tree6','Tree Surface');
trace_units = '(degC)';
y_axis      = [0 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Temperature profile
%----------------------------------------------------------
trace_name  = 'Climate: Temperature Profile';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Temp_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_6_AVG', pth));
trace_legend = str2mat('T20m','T16m','T11.5m','T6m','T3m','T1m');
trace_units = '(degC)';
y_axis      = [ 0 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Barometric pressure
%-----------------------------------
trace_name  = 'Climate: Barometric Pressure';
trace_path = fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pth);
trace_units = '(kPa)';
y_axis      = [96 102];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Relative humidity
%----------------------------------------------------------
trace_name  = 'Climate: Relative Humidity';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pth));
trace_legend = str2mat('HMP\_12m Gill');
trace_units = '(RH %)';
y_axis      = [0 1.10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture (TDR)
%----------------------------------------------------------
trace_name  = 'Climate: Soil Moisture (TDR)';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'CS615v_1', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_2', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_3', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_4', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_5', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_6', pth));
trace_legend = str2mat('1','2','3','4','5','6');
trace_units = 'VWC';
y_axis      = [0.1 0.6];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Speed Averages (RM Young)';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_MAX', pth));
trace_legend = str2mat('12m (avg)','12m (max)');
trace_units = '(m/s)';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Direction (RM Young)';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'WindDir_DU_WVT', pth));
trace_legend = str2mat('12m');
trace_units = '(^o)';
y_axis      = [0 360];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Gas Hound co2 concentration 
%----------------------------------------------------------
trace_name  = 'Climate: 10m CO2 Concentration (Gashound)';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'GH_co2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_clim2,    'GH_co2_MAX', pth),...
                      fr_logger_to_db_fileName(ini_clim2,    'GH_co2_MIN', pth));
trace_legend = str2mat('avg','max','min');
trace_units = '(umol/m2/s)';
y_axis      = [300 600];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% PAR 1,2
%-----------------------------------
trace_name  = 'Climate: PPFD';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_1_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'RAD_2_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'PAR_Tot_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'PAR_Diff_AVG', pth));
trace_legend = str2mat('downward','upward','BF2 Total','BF2 Diffuse');
trace_units = '(umol m^{-2} s^{-1})';
y_axis      = [-100 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% PSP
%-----------------------------------
trace_name  = 'Climate: Shortwave Radiation';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'RAD_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'RAD_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'S_upper_AVG', pth));
trace_legend = str2mat('LICOR down','Kipp down','Kipp up', 'CNR1 down');

trace_units = '(W/m^2)';
y_axis      = [-100 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net
%-----------------------------------
trace_name  = 'Climate: Net Radiation';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_6_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pth));
trace_legend = str2mat('Swissteco', 'CNR1');
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Soil heat flux
%-----------------------------------
trace_name  = 'Climate: Soil Heat Flux 3cm Below LFH';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP1_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP2_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP3_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP4_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP5_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP6_AVG', pth));
trace_legend = str2mat('1','2','3','4','5','6');
trace_units = '(W/m^2)';
y_axis      = [-100 100];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
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

%========================================================
% local functions

function [p,x1,x2] = polyfit_plus(x1in,x2in,n)
    x1=x1in;
    x2=x2in;
    tmp = find(abs(x2-x1) < 0.5*abs(max(x1,x2)));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
    diffr = x2-polyval(p,x1);
    tmp = find(abs(diffr)<3*std(diffr));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
    diffr = x2-polyval(p,x1);
    tmp = find(abs(diffr)<3*std(diffr));
    if isempty(tmp)
        p = [1 0];
        return
    end
    x1=x1(tmp);
    x2=x2(tmp);
    p=polyfit(x1,x2,n);
