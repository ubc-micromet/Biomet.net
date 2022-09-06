function [t,x] = hjp94_pl(ind, year, select, fig_num_inc,pause_flag)

% created for HJP94 following migration of EC system from HJP02 to HJP94

% file created: August 5, 2008      Last revision:

% Revisions:


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
    pth = [biomet_path(year,'HJP94','cl') 'HJP94_23x1\'];      % get the climate data path
    pthCtrl = [biomet_path(year,'HJP94','cl') 'HJP94_10x1\'];      % get the 10x1 data path

%   pth = '\\ANNEX001\DATABASE\2004\HJP94\Climate\HJP94_23x1\';
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

t=read_bor([ pth 'HJP94_Clim1_dt']);                  % get decimal time from the data base
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
trace_path  = str2mat([pth 'HJP94_Clim1.17']);
trace_legend= str2mat('Tlogger');
trace_units = '(\circC)';
y_axis      = [0 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Logger Voltage';
trace_path  = str2mat([pth 'HJP94_Clim1.6']);
trace_legend= str2mat('Vlogger');
trace_units = '(V)';
y_axis      = [0 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Tank pressures
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Tank Pressures';
trace_path  = str2mat(fullfile(pthCtrl,'EddyRef_AVG'),fullfile(pthCtrl,'CAL0_AVG'),fullfile(pthCtrl,'CAL1_AVG'));
trace_legend= str2mat('Ref.tank','CAL_0','CAL_1');
trace_units = '(kPa)';
y_axis      = [0 2500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Air Temperature';
trace_path  = str2mat([pth 'HJP94_Clim1.11'], [pth 'HJP94_Clim1.13'], [pth 'HJP94_Clim1.14'],...
                            fullfile(pthCtrl,'TubeTemp_AVG'));
trace_legend= str2mat('CNR1_PRT', 'HMP_1m', 'HMP_4m','Sample Tube');
trace_units = 'Deg C';
y_axis      = [-30 50];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Relative Humidity
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Relative Humidity';
trace_path  = str2mat([pth 'HJP94_Clim1.15'], [pth 'HJP94_Clim1.16']);
trace_legend= str2mat('1m', '4m');
trace_units = '%';
y_axis      = [0 120];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


% %----------------------------------------------------------
% % Soil Temp on Southern station
% %----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Soil Temperature';
% trace_path  = str2mat([pth 'HJP94_Clim1.14'], [pth 'HJP94_Clim1.15'], [pth 'HJP94_Clim1.16'], [pth 'HJP94_Clim1.17'], [pth 'HJP94_Clim1.18'], [pth 'HJP94_Clim1.19']);
% trace_legend= str2mat('2cm', '5cm', '10cm', '20cm', '50cm', '100cm');
% trace_units = 'Deg C';
% y_axis      = [-40 50];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

% %----------------------------------------------------------
% % Snow temp/depth
% %----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Snow Temperature/Depth';
% trace_path  = str2mat([pth 'HJP94_Clim1.20'], [pth 'HJP94_Clim1.21'], [pth 'HJP94_Clim1.22'], [pth 'HJP94_Clim1.23'], [pth 'HJP94_Clim1.24'], [pth 'HJP94_Clim1.25'], [pth 'HJP94_Clim1.26'], [pth 'HJP94_Clim1.27'], [pth 'HJP94_Clim1.53']);
% trace_legend= str2mat('1cm', '2cm', '5cm', '10cm', '20cm', '30cm', '40cm', '50cm', 'depth');
% trace_units = 'Deg C';
% y_axis      = [-50 50];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wetness
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Wetness';
trace_path  = str2mat([pth 'HJP94_Clim1.24']);
trace_legend= str2mat('wetness');
trace_units = '?';
y_axis      = [-5 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Downwelling/upwelling shortwave Radiation
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Shortwave Radiation';
trace_path  = str2mat([pth 'HJP94_Clim1.7'], [pth 'HJP94_Clim1.8']);
trace_legend= str2mat('Down', 'Up');
trace_units = 'W/m2';
y_axis      = [-10 1500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% photosynthetic photon flux density
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Photosynthetic pfd';
%trace_path  = str2mat([pth 'HJP94_Clim1.41'], [pth 'HJP94_Clim1.42']);
trace_path  = str2mat([pth 'HJP94_Clim1.12']);
%trace_legend= str2mat('downwelling', 'upwelling');
trace_legend= str2mat('upwelling');
trace_units = 'mmol/m2/s';
%y_axis      = [-10 2500];
y_axis      = [-10 500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Downwelling/upwelling longwave Radiation
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Longwave Radiation';
trace_path  = str2mat([pth 'HJP94_Clim1.9'], [pth 'HJP94_Clim1.10']);
trace_legend= str2mat('Down', 'Up');
trace_units = 'W/m2';
y_axis      = [-700 500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


% %----------------------------------------------------------
% % Heat Flux
% %----------------------------------------------------------
% trace_name  = 'Climate/Diagnostics: Heat Flux Through Soil';
% trace_path  = str2mat([pth 'HJP94_Clim1.36'], [pth 'HJP94_Clim1.37']);
% trace_legend= str2mat('southern plate', 'northern plate');
% trace_units = 'W/m2';
% y_axis      = [-100 200];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end


%----------------------------------------------------------
% Wind Speed
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Wind Speed';
trace_path  = str2mat([pth 'HJP94_Clim1.18']);
trace_legend= str2mat('wind');
trace_units = 'm/s';
y_axis      = [0 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind Direction
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Wind Direction';
trace_path  = str2mat([pth 'HJP94_Clim1.19']);
trace_legend= str2mat('wind');
trace_units = 'deg';
y_axis      = [0 360];
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
