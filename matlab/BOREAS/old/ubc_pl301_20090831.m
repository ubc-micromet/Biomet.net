function [t,x] = ubc_pl30(ind, year, select, fig_num_inc,pause_flag,corrected)
%
% [t,x] = ubc_pl(ind, year, fig_num_inc)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.

% NOTE: USE this to read from centralized database. Only 2004 available to date

% Revisions:
% May 17, 2005: Added select input paremeter for compatibility with
%               view_sites.  Not used at this time.  Zoran
% Jan 29, 2004: edited to run from centralized database, including CG data
% Jan 14, 2003: add Cecil Green rainfall data
% Jan 7, 2003: new year
% Jan 29, 2002: Corrected scale for snow depth plot (m not cm)
% Jan ??, 2002: Added snow depth plot
% May 31, 2001: new program to read 30 minute data
%
% Jan 16, 2001: change for new year 2001
%
% May 3, 2000: added option for looking at corrected or raw database
% use 1 as 5th parameter to look at corrected numbers (after 'clean_ubc_climate')
%
% Jan 10, 2000: change needed for new year 2000

LOCAL_PATH = 0;

colordef none

if ~exist('corrected') | isempty(corrected)
    corrected = 0;
end
if ~exist('pause_flag') | isempty(pause_flag)
    pause_flag = 0;
end
if ~exist('fig_num_inc') | isempty(fig_num_inc)
    fig_num_inc = 1;
end
if ~exist('select') | isempty(select)
    select = 0;
end
if ~exist('year') | isempty(year)
    year = 2009;
end

if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 8/24;                                    % ubc data is now in GMT


if year >= 2001
    if LOCAL_PATH == 1
        root_pth = 'd:\ubc_clim';
    else
%        [pth] = biomet_path(year,'YF','cl');                % get the climate data path
        root_pth = biomet_path(year,'UBC_Climate_Stations\Climate','');
    end
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
else
    error 'Data for the requested year is not available!'
end

orig_pth =[root_pth 'Totem\'];
clean_pth = [root_pth 'Totem\Cleaned\'];
cg_pth =  [root_pth 'CG\'];


st = min(ind);                                      % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

t=read_bor([ orig_pth 'ubc_dt']);                  % get decimal time from the data base



offset_doy = 0;

t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

if 1==1
   
if corrected == 0
   pth = orig_pth;
else
   pth = clean_pth;
end

%----------------------------------------------------------
% Data logger voltages
%----------------------------------------------------------
trace_name  = 'Battery Voltages';
trace_path  = str2mat([pth 'ubc.12'],[cg_pth 'cg.6']);

%trace_path  = str2mat([pth '\ubc.12'],[pth '\ubc.20']);
%trace_path  = str2mat([pth '\ubc.13'],[pth '\ubc.26'],[cg_pth '\cg.7']);

trace_legend = str2mat('UBC Pwr','Cecil Green Pwr');
trace_units = '(volts)';
y_axis      = [0 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% air temperatures
%----------------------------------------------------------
trace_name  = 'Air temperature';
trace_path  = str2mat([pth 'ubc.5'],[pth 'ubc.22'],[pth 'ubc.23']);
trace_legend = str2mat('HMP','S Screen','2 m FWTC');
trace_units = '(degC)';
y_axis      = [-5 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% soil temperatures
%----------------------------------------------------------
trace_name  = 'Soil temperature';
trace_path  = str2mat([pth 'ubc.8'],[pth 'ubc.9'],[pth 'ubc.10']);
trace_legend = str2mat('10 cm','20 cm','40 cm');
trace_units = '(degC)';
y_axis      = [0 25];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Rain 
%----------------------------------------------------------
trace_name  = 'Rain';
%trace_path  = str2mat([pth 'ubc.13'],[pth 'ubc.26']);
trace_path  = str2mat([pth 'ubc.13'],[pth 'ubc.26'],[cg_pth 'cg.7']);
trace_units = '(mm)';
trace_legend = str2mat('Rain 1','Rain 2','CG Rain');
y_axis      = [-1 10];
fig_num = fig_num + fig_num_inc;
%[x] = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

if pause_flag == 1;pause;end

if 0==1;
%----------------------------------------------------------
% Cumulative rain 
%----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'Cumulative rain ';
y_axis      = [];
ax = [st ed];

% this section produces weird errors if path is not explicitly defined????
if corrected == 0
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
[x2,tx_new] = read_sig(trace_path(2,:), indx,year, tx,0);
%[x1,tx_new] = read_sig('d:ubc_clim\database30\ubc.13', indx,year, tx,0);
%[x2,tx_new] = read_sig('d:\ubc_clim\database30\ubc.26', indx,year, tx,0);
%[x3,tx_new] = read_sig('\\annex001\database\2005\UBC_Climate_Stations\CG\'cg.7', indx,year, tx,0);
[x3,tx_new] = read_sig(fullfile(cg_pth,'cg.7'), indx,year, tx,0);
%[x3,tx_new] = read_sig(trace_path(3,:), indx,year, tx,0);
%[x,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
else
[x1,tx_new] = read_sig('\\annex001\database\2004\UBC_Climate_Stations\Totem\Cleaned\ubc.13', indx,year, tx,0);
[x2,tx_new] = read_sig('\\annex001\database\2004\UBC_Climate_Stations\Totem\Cleaned\ubc.26', indx,year, tx,0);
[x3,tx_new] = read_sig('\\annex001\database\2004\UBC_Climate_Stations\CG\cg.7', indx,year, tx,0);
end

fig_num = fig_num + fig_num_inc;

switch year
    case 2001
        addRain = 350.0;
    case 2002
        addRain2 = 520.0;
    otherwise
        addRain = 0;
        addRain2 = 0;        
end

plt_sig1( tx_new, [cumsum(x1) cumsum(x2)+addRain cumsum(x3)+addRain2], trace_name, year, trace_units, ax, y_axis, fig_num );
%plt_sig1( tx_new, [cumsum(x1) cumsum(x2)+addRain cumsum(x3)], trace_name, year, trace_units, ax, y_axis, fig_num );
%plt_sig1( tx_new, cumsum(x) , trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end

end % if 0==1

%-----------------------------------
% wind speed
%-----------------------------------
trace_name  = 'Windspeed';
trace_path  = str2mat([pth 'ubc.14'],[pth 'ubc.24'],[pth 'ubc.25']);
%trace_path  = [pth 'ubc.14'];
trace_legend = [];
trace_units = '(m/s)';
y_axis      = [0 15];
fig_num = fig_num + fig_num_inc;
%x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% wind direction
%-----------------------------------
trace_name  = 'Wind Direction';
trace_path  = [pth 'ubc.16'];
trace_units = 'degrees';
y_axis      = [0 400];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Solar radiation
%-----------------------------------
trace_name  = 'Solar';
trace_path  = [pth 'ubc.7'];
trace_units = 'Watts/m^2';
y_axis      = [0 1000];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Longwave radiation
%----------------------------------------------------------

trace_name  = 'Longwave radiation ';
y_axis      = [200 500];
ax = [st ed];

trace_path  = str2mat([pth 'ubc.30'],[pth 'ubc.31']);
trace_legend = str2mat('30','31');

[x1,tx_new] = read_sig(trace_path(1,:), ind,year, t,0);
[x2,tx_new] = read_sig(trace_path(2,:), ind,year, t,0);
x2 = x2 + 273.15;
longwave = x1+(5.67e-8*(x2.^4));

fig_num = fig_num + fig_num_inc;
%[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

plt_sig1( tx_new, longwave, trace_name, year, trace_units, ax, y_axis, fig_num );

if pause_flag == 1;pause;end


%-----------------------------------
% humidity
%-----------------------------------
trace_name  = 'Relative Humidity';
trace_path  = [pth 'ubc.6'];
trace_units = '%';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% snow depth
%-----------------------------------
trace_name  = 'Snow depth';
trace_path  = [pth 'ubc.29'];
trace_units = 'm';
y_axis      = [0 0.2];
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

end

colordef white

if pause_flag ~= 1;
    N=max(get(0,'children'));
    for i=1:N;
        figure(i);
        pause;
    end
end
