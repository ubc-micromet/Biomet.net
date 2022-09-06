function [t,x] = PM_pl(ind, year, select, fig_num_inc, pause_flag)

% view sites plotting program for Port McNeill variable retention site

% file created: Sept 3, 2008 (Nick)     Last modified: Sept 3, 2008

% Revisions:
% Sep 5, 2008
%   -Soil moisture for N30m (Station 5) is now SoilM_19; sensor had to be
%   isolated with its own excitation channel on the AM16/32

if ind(1) > datenum(0,4,15) & ind(1) < datenum(0,10,15);
    WINTER_TEMP_OFFSET = 0;
else
    WINTER_TEMP_OFFSET = 10;
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

GMTshift = 1/3;                                    % offset to convert GMT to CST
if year >= 2008
    pth = biomet_path(year,'PM','cl');      % get the climate data path
    pth_MET1 = fullfile(pth,'PM_Clim');
    pth_Transect = fullfile(pth,'PM_Transect');
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
    
else
    error 'Data for the requested year is not available!'
end

st = min(ind);                                      % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

% time vector for MH climate station

t=read_bor(fullfile(pth_MET1,'PM_Clim_dt'));            % get decimal time from the data base
%t_TM = read_bor(fullfile(pth_Transect,'PM_Transect_160_dt')); % time vector for PM Transect: soil T and M (30 min output)
t_PAR = read_bor(fullfile(pth_Transect,'PM_Transect_150_dt')); % time vector for PM Transect PAR measurements (3 min output)

if year < 2000
    offset_doy=datenum(year,1,1)-datenum(1996,1,1);     % find offset DOY
else
   offset_doy=0;
end
t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                  % decimal DOY local time
%t_TM = t_TM - offset_doy + 1 - GMTshift;     
t_PAR = t_PAR - offset_doy + 1 - GMTshift;
                                                
t_all = t;                                          % save time trace for later
%t_all_TM = t_TM;
t_all_PAR = t_PAR;
ind = find( t >= st & t <= ed );                    % extract the requested periods
%ind_TM = find( t_TM >= st & t_TM <= ed );          % for both Climate station and
                                                    % Transect
ind_PAR = find( t_PAR >= st & t_PAR <= ed ); 
t = t(ind);
%t_TM = t_TM(ind_TM);
t_PAR = t_PAR(ind_PAR);
fig_num = 1 - fig_num_inc;


%----------------------------------------------------------
% Logger Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Temperatures';
trace_path  = str2mat(fullfile(pth_MET1,'Panel_Tmp_AVG'),...
                      fullfile(pth_Transect,'Panel_Tmp_AVG'));
trace_legend= str2mat('T_{clim}','T_{trans}');
trace_units = 'Deg C';
y_axis      = [0 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Voltages';
trace_path  = str2mat(fullfile(pth_MET1,'Batt_Volt_AVG'),fullfile(pth_Transect,'Batt_Volt_AVG'),fullfile(pth_Transect,'Phone_Vlt_AVG'),fullfile(pth_MET1,'Phone_Vlt_AVG'));
trace_legend= str2mat('V_{clim}','V_{trans}','V_{phone trans}','V_{phone clim}');
trace_units = 'Volts';
y_axis      = [12 13];
fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[ 1; 1; 1; 1 ],[ 0; 0; 0; 0 ]);

if pause_flag == 1;pause;end


%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Air Temperature ';
trace_path  = str2mat(fullfile(pth_MET1,'CS500_Tmp_AVG'), fullfile(pth_MET1,'CS500_Tmp_MAX'), fullfile(pth_MET1,'CS500_Tmp_MIN'));
trace_legend= str2mat('Avg', 'Max', 'Min');
trace_units = '\circC';
y_axis      = [-10 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Relative Humidity
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Relative Humidity';
trace_path  = str2mat(fullfile(pth_MET1,'CS500_RH_Avg'), fullfile(pth_MET1,'CS500_RH_Max'), fullfile(pth_MET1,'CS500_RH_Min'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '%';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Rain
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Rain';
trace_path  = str2mat(fullfile(pth_MET1,'Rainfall_TOT'));
trace_legend= str2mat('Rain Gauge');
trace_units = 'mm';
y_axis      = [0 8];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Wind Speed';
trace_path  = str2mat(fullfile(pth_MET1,'Wind_Spd_AVG'),fullfile(pth_MET1,'Wind_Spd_MAX'),fullfile(pth_MET1,'Wind_Spd_MIN'));
trace_legend= str2mat('AVG','MAX','MIN');
trace_units = 'm/s';
y_axis      = [0 8];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Wind Direction';
trace_path  = str2mat(fullfile(pth_MET1,'Wind_Dir_SDU_WVT'),fullfile(pth_MET1,'Wind_Dir_DU_WVT'));
trace_legend= str2mat('SDU_WVT','DU_WVT');
trace_units = 'degrees from North';
y_axis      = [0 360];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Radiation - PAR
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: PAR';
trace_path  = str2mat(fullfile(pth_MET1,'BF3_Total_Avg'), fullfile(pth_MET1,'PAR_Avg'),...
                      fullfile(pth_MET1,'BF3_Diff_AVG'));
trace_legend= str2mat('BF3 Total','LS190','BF3 Diff');
trace_units = 'umol/m2/s';
y_axis      = [0 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Soil Temperature';
trace_path  = str2mat(fullfile(pth_MET1,'Soil_Tmp_Avg'), fullfile(pth_MET1,'Soil_Tmp_Max'),fullfile(pth_MET1,'Soil_Tmp_Min'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Soil Moisture';
trace_path  = str2mat(fullfile(pth_MET1,'Soil_Mst_Avg'));
trace_legend= str2mat('Soil Moist');
trace_units = 'mV ?';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


% PM TRANSECT DATA

%----------------------------------------------------------
% Radiation - PAR
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: PAR Averages';
trace_path  = str2mat(fullfile(pth_Transect,'Quan_1_AVG'),...
                      fullfile(pth_Transect,'Quan_2_AVG'),...
                      fullfile(pth_Transect,'Quan_3_AVG'),...
                      fullfile(pth_Transect,'Quan_4_AVG'),...
                      fullfile(pth_Transect,'Quan_5_AVG'),...
                      fullfile(pth_Transect,'Quan_6_AVG'),...
                      fullfile(pth_Transect,'Quan_7_AVG'),...
                      fullfile(pth_Transect,'Quan_8_AVG'),...
                      fullfile(pth_Transect,'Quan_9_AVG'),...
                      fullfile(pth_Transect,'Quan_10_AVG'),...
                      fullfile(pth_Transect,'Quan_11_AVG'),...
                      fullfile(pth_Transect,'Quan_12_AVG'),...
                      fullfile(pth_Transect,'Quan_13_AVG'),...
                      fullfile(pth_Transect,'Quan_14_AVG'),...
                      fullfile(pth_Transect,'Quan_15_AVG'),...
                      fullfile(pth_Transect,'Quan_16_AVG'),...
                      fullfile(pth_Transect,'Quan_17_AVG'));
trace_legend= str2mat('E_{edge}','E_{5m}','E_{15m}','E_{30m}','N_{edge}','N_{5m}','N_{15m}','N_{30m}','S_{edge}',...
                      'S_{5m}','S_{15m}','S_{30m}','W_{edge}','W_{5m}','W_{15m}','W_{30m}','Centre');
trace_units = 'umol/m2/s';
y_axis      = [0 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind_PAR, trace_name, trace_legend, year, trace_units, y_axis, t_PAR, fig_num );
if pause_flag == 1;pause;end


%
%---Plot Soil Temperatures in separate panels to allow easier viewing of
%   max/min values
%

%----------------------------------------------------------
% Soil Temperature Averages
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature Averages';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_1_AVG'),...
                      fullfile(pth_Transect,'SoilT_2_AVG'),...
                      fullfile(pth_Transect,'SoilT_3_AVG'),...
                      fullfile(pth_Transect,'SoilT_4_AVG'),...
                      fullfile(pth_Transect,'SoilT_5_AVG'),...
                      fullfile(pth_Transect,'SoilT_6_AVG'),...
                      fullfile(pth_Transect,'SoilT_7_AVG'),...
                      fullfile(pth_Transect,'SoilT_8_AVG'),...
                      fullfile(pth_Transect,'SoilT_9_AVG'),...
                      fullfile(pth_Transect,'SoilT_10_AVG'),...
                      fullfile(pth_Transect,'SoilT_11_AVG'),...
                      fullfile(pth_Transect,'SoilT_12_AVG'),...
                      fullfile(pth_Transect,'SoilT_13_AVG'),...
                      fullfile(pth_Transect,'SoilT_14_AVG'),...
                      fullfile(pth_Transect,'SoilT_15_AVG'),...
                      fullfile(pth_Transect,'SoilT_16_AVG'),...
                      fullfile(pth_Transect,'SoilT_17_AVG'));
                  
trace_legend= str2mat('E_{edge}','E_{5m}','E_{15m}','E_{30m}','N_{edge}','N_{5m}','N_{15m}','N_{30m}','S_{edge}',...
                      'S_{5m}','S_{15m}','S_{30m}','W_{edge}','W_{5m}','W_{15m}','W_{30m}','Centre');        
                  
% trace_legend= str2mat('SoilT_1','SoilT_2','SoilT_3','SoilT_4','SoilT_5','SoilT_6',...
%                       'SoilT_7','SoilT_8','SoilT_9','SoilT_{10}','SoilT_{11}','SoilT_{12}',...
%                       'SoilT_{13}','SoilT_{14}','SoilT_{15}','SoilT_{16}','SoilT_{17}');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Soil Temperature: Station 1
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature E edge';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_1_AVG'),...
                      fullfile(pth_Transect,'SoilT_1_MAX'),...
                      fullfile(pth_Transect,'SoilT_1_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 2
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature E 5m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_2_AVG'),...
                      fullfile(pth_Transect,'SoilT_2_MAX'),...
                      fullfile(pth_Transect,'SoilT_2_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 3
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature E 15m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_3_AVG'),...
                      fullfile(pth_Transect,'SoilT_3_MAX'),...
                      fullfile(pth_Transect,'SoilT_3_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 4
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature E 30m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_4_AVG'),...
                      fullfile(pth_Transect,'SoilT_4_MAX'),...
                      fullfile(pth_Transect,'SoilT_4_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 5
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature N edge';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_5_AVG'),...
                      fullfile(pth_Transect,'SoilT_5_MAX'),...
                      fullfile(pth_Transect,'SoilT_5_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 6
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature N 5m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_6_AVG'),...
                      fullfile(pth_Transect,'SoilT_6_MAX'),...
                      fullfile(pth_Transect,'SoilT_6_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 7
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature N 15m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_7_AVG'),...
                      fullfile(pth_Transect,'SoilT_7_MAX'),...
                      fullfile(pth_Transect,'SoilT_7_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 8
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature N 30m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_8_AVG'),...
                      fullfile(pth_Transect,'SoilT_8_MAX'),...
                      fullfile(pth_Transect,'SoilT_8_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 9
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature S edge';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_9_AVG'),...
                      fullfile(pth_Transect,'SoilT_9_MAX'),...
                      fullfile(pth_Transect,'SoilT_9_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 10
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature S 5m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_10_AVG'),...
                      fullfile(pth_Transect,'SoilT_10_MAX'),...
                      fullfile(pth_Transect,'SoilT_10_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 11
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature S 15m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_11_AVG'),...
                      fullfile(pth_Transect,'SoilT_11_MAX'),...
                      fullfile(pth_Transect,'SoilT_11_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 12
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature S 30m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_12_AVG'),...
                      fullfile(pth_Transect,'SoilT_12_MAX'),...
                      fullfile(pth_Transect,'SoilT_12_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 13
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature W edge';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_13_AVG'),...
                      fullfile(pth_Transect,'SoilT_13_MAX'),...
                      fullfile(pth_Transect,'SoilT_13_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 14
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature W 5m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_14_AVG'),...
                      fullfile(pth_Transect,'SoilT_14_MAX'),...
                      fullfile(pth_Transect,'SoilT_14_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 15
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature W 15m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_15_AVG'),...
                      fullfile(pth_Transect,'SoilT_15_MAX'),...
                      fullfile(pth_Transect,'SoilT_15_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 16
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature W 30m';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_16_AVG'),...
                      fullfile(pth_Transect,'SoilT_16_MAX'),...
                      fullfile(pth_Transect,'SoilT_16_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperature: Station 17
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Temperature Centre';
trace_path  = str2mat(fullfile(pth_Transect,'SoilT_17_AVG'),...
                      fullfile(pth_Transect,'SoilT_17_MAX'),...
                      fullfile(pth_Transect,'SoilT_17_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 30];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture Probes (EC-20s)
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture Averages';
trace_path  = str2mat(fullfile(pth_Transect,'SoilM_1_AVG'),...
                      fullfile(pth_Transect,'SoilM_2_AVG'),...
                      fullfile(pth_Transect,'SoilM_3_AVG'),...
                      fullfile(pth_Transect,'SoilM_4_AVG'),...
                      fullfile(pth_Transect,'SoilM_5_AVG'),...
                      fullfile(pth_Transect,'SoilM_6_AVG'),...
                      fullfile(pth_Transect,'SoilM_7_AVG'),...
                      fullfile(pth_Transect,'SoilM_19_AVG'),... % N30m had to be excited separately
                      fullfile(pth_Transect,'SoilM_9_AVG'),...
                      fullfile(pth_Transect,'SoilM_10_AVG'),...
                      fullfile(pth_Transect,'SoilM_11_AVG'),...
                      fullfile(pth_Transect,'SoilM_12_AVG'),...
                      fullfile(pth_Transect,'SoilM_13_AVG'),...
                      fullfile(pth_Transect,'SoilM_14_AVG'),...
                      fullfile(pth_Transect,'SoilM_15_AVG'),...
                      fullfile(pth_Transect,'SoilM_16_AVG'),...
                      fullfile(pth_Transect,'SoilM_17_AVG'));

 trace_legend= str2mat('E_{edge}','E_{5m}','E_{15m}','E_{30m}','N_{edge}','N_{5m}','N_{15m}','N_{30m}','S_{edge}',...
                      'S_{5m}','S_{15m}','S_{30m}','W_{edge}','W_{5m}','W_{15m}','W_{30m}','Centre');
                  
%                   trace_legend= str2mat('SoilM_1','SoilM_2','SoilM_3','SoilM_4','SoilM_5','SoilM_6',...
%                       'SoilM_7','SoilM_8','SoilM_9','SoilM_{10}','SoilM_{11}','SoilM_{12}',...
%                       'SoilM_{13}','SoilM_{14}','SoilM_{15}','SoilM_{16}','SoilM_{17}');
trace_units = 'mV';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Soil Moisture: Station 1
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture E edge';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_1_AVG'),...
                      fullfile(pth_Transect,'soilM_1_MAX'),...
                      fullfile(pth_Transect,'soilM_1_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 2
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture E 5m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_2_AVG'),...
                      fullfile(pth_Transect,'soilM_2_MAX'),...
                      fullfile(pth_Transect,'soilM_2_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 3
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture E 15m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_3_AVG'),...
                      fullfile(pth_Transect,'soilM_3_MAX'),...
                      fullfile(pth_Transect,'soilM_3_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 4
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture E 30m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_4_AVG'),...
                      fullfile(pth_Transect,'soilM_4_MAX'),...
                      fullfile(pth_Transect,'soilM_4_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 5
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture N edge';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_5_AVG'),...
                      fullfile(pth_Transect,'soilM_5_MAX'),...
                      fullfile(pth_Transect,'soilM_5_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 6
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture N 5m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_6_AVG'),...
                      fullfile(pth_Transect,'soilM_6_MAX'),...
                      fullfile(pth_Transect,'soilM_6_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 7
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture N 15m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_7_AVG'),...
                      fullfile(pth_Transect,'soilM_7_MAX'),...
                      fullfile(pth_Transect,'soilM_7_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 8
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture N 30m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_19_AVG'),...
                      fullfile(pth_Transect,'soilM_19_MAX'),...
                      fullfile(pth_Transect,'soilM_19_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 9
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture S edge';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_9_AVG'),...
                      fullfile(pth_Transect,'soilM_9_MAX'),...
                      fullfile(pth_Transect,'soilM_9_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 10
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture S 5m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_10_AVG'),...
                      fullfile(pth_Transect,'soilM_10_MAX'),...
                      fullfile(pth_Transect,'soilM_10_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 11
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture S 15m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_11_AVG'),...
                      fullfile(pth_Transect,'soilM_11_MAX'),...
                      fullfile(pth_Transect,'soilM_11_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 12
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture S 30m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_12_AVG'),...
                      fullfile(pth_Transect,'soilM_12_MAX'),...
                      fullfile(pth_Transect,'soilM_12_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 13
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture W edge';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_13_AVG'),...
                      fullfile(pth_Transect,'soilM_13_MAX'),...
                      fullfile(pth_Transect,'soilM_13_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 14
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture W 5m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_14_AVG'),...
                      fullfile(pth_Transect,'soilM_14_MAX'),...
                      fullfile(pth_Transect,'soilM_14_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 15
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture W 15m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_15_AVG'),...
                      fullfile(pth_Transect,'soilM_15_MAX'),...
                      fullfile(pth_Transect,'soilM_15_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 16
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture W 30m';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_16_AVG'),...
                      fullfile(pth_Transect,'soilM_16_MAX'),...
                      fullfile(pth_Transect,'soilM_16_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Moisture: Station 17
%----------------------------------------------------------
trace_name  = 'Transect/Diagnostics: Soil Moisture Centre';
trace_path  = str2mat(fullfile(pth_Transect,'soilM_17_AVG'),...
                      fullfile(pth_Transect,'soilM_17_MAX'),...
                      fullfile(pth_Transect,'soilM_17_MIN'));
trace_legend= str2mat('Avg','Max','Min');
trace_units = '\circC';
y_axis      = [0 1000];
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
%               end
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

%----------------------------------------------------------
% Soil Temp on Southern station
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Soil Temperature';
%trace_path  = str2mat([pth 'HJP02_Clim1.14'], [pth 'HJP02_Clim1.15'], [pth 'HJP02_Clim1.16'], [pth 'HJP02_Clim1.17'], [pth 'HJP02_Clim1.18'], [pth 'HJP02_Clim1.19']);
%trace_legend= str2mat('2cm', '5cm', '10cm', '20cm', '50cm', '100cm');
%trace_units = '\circC';
%y_axis      = [-40 50];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Snow temp/depth
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Snow Temperature/Depth';
%trace_path  = str2mat([pth 'HJP02_Clim1.20'], [pth 'HJP02_Clim1.21'], [pth 'HJP02_Clim1.22'], [pth 'HJP02_Clim1.23'], [pth 'HJP02_Clim1.24'], [pth 'HJP02_Clim1.25'], [pth 'HJP02_Clim1.26'], [pth 'HJP02_Clim1.27'], [pth 'HJP02_Clim1.53']);
%trace_legend= str2mat('1cm', '2cm', '5cm', '10cm', '20cm', '30cm', '40cm', '50cm', 'depth');
%trace_units = '\circC';
%y_axis      = [-50 50];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wetness
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Wetness';
%trace_path  = str2mat([pth 'HJP02_Clim1.51']);
%trace_legend= str2mat('wetness');
%trace_units = '?';
%y_axis      = [-5 15];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Downwelling/upwelling shortwave Radiation
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Shortwave Radiation';
%trace_path  = str2mat([pth 'HJP02_Clim1.8'], [pth 'HJP02_Clim1.9']);
%trace_legend= str2mat('Down', 'Up');
%trace_units = 'W/m2';
%y_axis      = [-10 1500];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end


%----------------------------------------------------------
% photosynthetic photon flux density
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Photosynthetic pfd';
%trace_path  = str2mat([pth 'HJP02_Clim1.41'], [pth 'HJP02_Clim1.42']);
%trace_legend= str2mat('downwelling', 'upwelling');
%trace_units = 'mmol/m2/s';
%y_axis      = [-10 2500];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end


%----------------------------------------------------------
% Downwelling/upwelling longwave Radiation
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Longwave Radiation';
%trace_path  = str2mat([pth 'HJP02_Clim1.10'], [pth 'HJP02_Clim1.11']);
%trace_legend= str2mat('Down', 'Up');
%trace_units = 'W/m2';
%y_axis      = [-700 500];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end


%----------------------------------------------------------
% Heat Flux
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Heat Flux Through Soil';
%trace_path  = str2mat([pth 'HJP02_Clim1.36'], [pth 'HJP02_Clim1.37']);
%trace_legend= str2mat('southern plate', 'northern plate');
%trace_units = 'W/m2';
%y_axis      = [-100 200];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end


%----------------------------------------------------------
% Wind Speed
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Wind Speed';
%trace_path  = str2mat([pth 'HJP02_Clim1.48']);
%trace_legend= str2mat('wind');
%trace_units = 'm/s';
%y_axis      = [0 20];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind Direction
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Wind Direction';
%trace_path  = str2mat([pth 'HJP02_Clim1.49']);
%trace_legend= str2mat('wind');
%trace_units = 'deg';
%y_axis      = [0 360];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end
