function [t,x] = hjp75_pl(ind, year, select, fig_num_inc,pause_flag)

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

GMTshift = 0.25;                                    % offset to convert GMT to CST
if year >= 2003
    pth = biomet_path(year,'HJP75','cl');      % get the climate data path
    pth_CTR = fullfile(pth,'HUT_CTR');
    pth_MET1 = fullfile(pth,'MSC_MET1');
    pth_MET2 = fullfile(pth,'MSC_MET2');

%   pth = '\\ANNEX001\DATABASE\2004\HJP02\Climate\HJP02_23x1\';
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

t=read_bor(fullfile(pth_CTR,'HUT_CTR_dt'));                  % get decimal time from the data base
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
% Logger Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Temperature';
trace_path  = str2mat(fullfile(pth_CTR,'Panel_T_AVG'));
trace_legend= str2mat('Tlogger');
trace_units = 'Deg C';
y_axis      = [0 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Voltage';
trace_path  = str2mat(fullfile(pth_CTR,'Batt_Volt_AVG'));
trace_legend= str2mat('Vlogger');
trace_units = 'V';
y_axis      = [0 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% AC Power
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: AC Power';
trace_path  = str2mat(fullfile(pth_CTR,'AC_Main_AVG'));
trace_legend= str2mat('AC Power');
trace_units = '% ON time';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,100/64 );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Air Temperature';
trace_path  = str2mat(fullfile(pth_MET1,'HMPTa_1m_AVG'), fullfile(pth_MET1,'HMPTa_4m_AVG'), fullfile(pth_MET1,'HMPTa_16m_AVG'));
trace_legend= str2mat('1m', '4m', '16m');
trace_units = '\circC';
y_axis      = [-30 50];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Reference tank pressures
%-----------------------------------
trace_name  = 'Climate/Diagnostics: Reference Tank Pressure';
T_hut = read_bor(fullfile(pth_CTR,'Panel_T_AVG'));
T_hut = T_hut(ind);
indx = find(T_hut == 0);
indy = find(T_hut ~= 0);
T_hut(indx) = mean(T_hut(indy));
Tc = 290 ./(T_hut + 273.15);
P_ref_eddy = read_bor(fullfile(pth_CTR,'RefEddy_AVG'));
P_ref_eddy = P_ref_eddy(ind);
%P_ref_prof = read_bor([pth 'flow\flow.27']);
%P_ref_prof = P_ref_prof(ind);
%P_ref_cham = read_bor([pth 'flow\flow.28']);
%P_ref_cham = P_ref_cham(ind);
%trace_path = [P_ref_eddy.* Tc P_ref_prof.* Tc P_ref_cham.* Tc ];
trace_path = [P_ref_eddy.* Tc  ];
trace_legend= str2mat('Eddy'); %,'Profile','Chamber');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
%x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);

%Eddy
x=x_all(:,1);
ref_lim = 400;                             % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
px = polyfit(x(index),t(index),1);         % fit first order polynomial
lowLim = polyval(px,ref_lim);              % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),400,sprintf('Eddy = %4.0f kPa/week - Low limit DOY %4.0f',perWeek,lowLim));
%Profile
%x=x_all(:,2);
%ref_lim = 400;                             % lower limit for the ref. gas tank-pressure
%index = find(x > 0 & x <=2500);
%px = polyfit(x(index),t(index),1);         % fit first order polynomial
%lowLim = polyval(px,ref_lim);              % return DOY when tank is going to hit lower limit
%ax = axis;
%perWeek = abs(7/px(1));
%text(ax(1)+0.01*(ax(2)-ax(1)),250,sprintf('Profile = %4.0f kPa/week - Low limit DOY %4.0f',perWeek,lowLim));
%Chamber
%x=x_all(:,3);
%ref_lim = 400;                             % lower limit for the ref. gas tank-pressure
%index = find(x > 0 & x <=2500);
%px = polyfit(x(index),t(index),1);         % fit first order polynomial
%lowLim = polyval(px,ref_lim);              % return DOY when tank is going to hit lower limit
%ax = axis;
%perWeek = abs(7/px(1));
%text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Chamber = %4.0f kPa/week - Low limit DOY %4.0f',perWeek,lowLim));
if pause_flag == 1;pause;end

%-----------------------------------
% Calibration tank pressures
%-----------------------------------
trace_name  = 'Climate/Diagnostics: Calibration Tank Pressures';
%trace_path  = str2mat([pth 'flow\flow.18'],[pth 'flow\flow.19']);
P_cal0 = read_bor(fullfile(pth_CTR,'CAL0_AVG'));
P_cal1 = read_bor(fullfile(pth_CTR,'CAL1_AVG'));
trace_path = [P_cal0(ind).* Tc P_cal1(ind).* Tc];
trace_legend= str2mat('Cal0','Cal1');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Relative Humidity
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Relative Humidity';
trace_path  = str2mat(fullfile(pth_MET1,'HMPRH_1m_AVG'), fullfile(pth_MET1,'HMPRH_4m_AVG'), fullfile(pth_MET1,'HMPRH_16m_AVG'));
trace_legend= str2mat('1m','4m','16m');
trace_units = '%';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Radiation - Shortwave Down
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Radiation - Shortwave Down';
trace_path  = str2mat(fullfile(pth_MET1,'Rsd_AVG'));
trace_legend= str2mat('1m');
trace_units = '(W/m2)';
y_axis      = [-10 1500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Radiation - Soil Temperature East
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Soil Temperature East';
%trace_path  = str2mat(fullfile(pth_MET2,'TsE_2cm_AVG'), fullfile(pth_MET2,'TsE_5cm_AVG'), fullfile(pth_MET2,'TsE_10cm_AVG'), fullfile(pth_MET2,'TsE_20cm_AVG'), fullfile(pth_MET2,'TsE_50cm_AVG'), fullfile(pth_MET2,'TsE_100cm_AVG'));
%trace_legend= str2mat('2cm', '5cm', '10cm', '20cm', '50cm', '100cm');
%trace_units = '(\circC)';
%y_axis      = [-10 40];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Radiation - Soil Temperature West
%----------------------------------------------------------
%trace_name  = 'Climate/Diagnostics: Soil Temperature West';
%trace_path  = str2mat(fullfile(pth_MET2,'TsW_2cm_AVG'), fullfile(pth_MET2,'TsW_5cm_AVG'), fullfile(pth_MET2,'TsW_10cm_AVG'), fullfile(pth_MET2,'TsW_20cm_AVG'), fullfile(pth_MET2,'TsW_50cm_AVG'), fullfile(pth_MET2,'TsW_100cm_AVG'));
%trace_legend= str2mat('2cm', '5cm', '10cm', '20cm', '50cm', '100cm');
%trace_units = '(\circC)';
%y_axis      = [-10 40];
%fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%return

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
