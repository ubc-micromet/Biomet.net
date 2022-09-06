function [t,x] = paoj_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = paoj_pl(ind, year, select, fig_num_inc,pause_flag)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       Nov 14, 1999 (based on paoa_pl.m)
%                           Last modification:  May  6, 2000
%

% Revisions:
% Sept 16, 2003
%   - changed the structure for plotting gas tanks pressures. Plot reference tanks for all systems; Plot cals tanks;
%     Plot extra chamber tanks (David).
% Feb 2, 2002 
%   - isolated diagnostics in this program  
% May  6, 2000
%   - changed axes
% Dec 30 ,1999
%   - changes in biomet_path calling syntax.
% Nov 21, 1999
%   - added estimation of N2 usage (kPa/Week)

if ind(end) > datenum(0,4,15) & ind(end) < datenum(0,10,15);
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

GMTshift = 0.25;                                    % offset to convert GMT to CST
if year >= 1996
    pth = biomet_path(year,'JP','cl');      % get the climate data path
    EddyPth = biomet_path(year,'JP','fl');  % get the flux data path
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
    
    %if LOCAL_PAOA == 1
    %    pth = 'd:\paoa_local_dbase\newdata\';
    %else
    %    pth = '\\class\paoa\newdata\';
    %    EddyPth = '\\class\paoa\paoa\';
    %    if exist('h:\zoran\paoa\paoa_dt') 
    %        EddyPth = 'h:\zoran\paoa\';
    %    else
    %        EddyPth = '\\boreas_003\paoa\';
    %    end
    %end
else
    error 'Data for the requested year is not available!'
end

st = min(ind);                                      % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

t=read_bor([ pth 'JP_23x_1\JP_1_dt']);                  % get decimal time from the data base
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
% Datalogger Battery voltages
%----------------------------------------------------------
trace_name  = 'HUT datalogger battery voltage';
trace_path  = str2mat([pth 'JP_23x_1\JP_1.6'],[pth 'JP_23x_1\JP_1.13'],[pth 'JP_23x_1\JP_1.20']);
trace_legend= str2mat('Min','Avg','Max');
trace_units = 'volts';
y_axis      = [11 14];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% PowerBox temperature
%-----------------------------------
trace_name  = 'PowerBox temperature';
trace_path  = str2mat([pth 'JP_10x_2\JP_2.16'],[pth 'JP_10x_2\JP_2.15']);
trace_legend= str2mat('Box','Air');
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Hut temperatures
%-----------------------------------
trace_name  = 'Hut temperatures';
trace_path  = str2mat([pth 'JP_23x_1\JP_1.12'],[pth 'JP_23x_1\JP_1.19'],[pth 'JP_23x_1\JP_1.12']);
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(degC)';
y_axis      = [10 60] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Pump house temperature
%-----------------------------------
trace_name  = 'Pump house temperature';
trace_path  = 'JP_23x_1\JP_1.11';
trace_units = '(degC)';
y_axis      = [-10 40];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Reference tank pressures
%-----------------------------------
trace_name  = 'Reference tank pressures';
trace_path  = str2mat([pth 'JP_23x_1\JP_1.7'],[pth 'JP_23x_1\JP_1.26'],[pth 'JP_23x_1\JP_1.27']);
trace_legend= str2mat('Eddy','Profile','Chamber');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
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
x=x_all(:,2);
ref_lim = 400;                             % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
px = polyfit(x(index),t(index),1);         % fit first order polynomial
lowLim = polyval(px,ref_lim);              % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),250,sprintf('Profile = %4.0f kPa/week - Low limit DOY %4.0f',perWeek,lowLim));
%Chamber
x=x_all(:,3);
ref_lim = 400;                             % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
px = polyfit(x(index),t(index),1);         % fit first order polynomial
lowLim = polyval(px,ref_lim);              % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Chamber = %4.0f kPa/week - Low limit DOY %4.0f',perWeek,lowLim));
if pause_flag == 1;pause;end

%-----------------------------------
% Calibration tank pressures
%-----------------------------------
trace_name  = 'Calibration tank pressures';
trace_path  = str2mat([pth 'JP_23x_1\JP_1.8'],[pth 'JP_23x_1\JP_1.9'],[pth 'JP_23x_1\JP_1.10']);
trace_legend= str2mat('Cal0','Cal1','Cal2');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Chamber extra tank pressures
%-----------------------------------
trace_name  = 'Chamber extra tank pressures (10% CO2)';
trace_path  = str2mat([pth 'JP_23x_1\JP_1.28']);
trace_legend= str2mat('Ch 10%CO2');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sampling tube temperatures
%----------------------------------------------------------
trace_name  = 'Sampling tube temperatures';
% [pth 'JP_10x_2\JP_2.11'],
trace_path  = str2mat([pth 'JP_10x_2\JP_2.12'], ...
                      [pth 'JP_10x_2\JP_2.13'],[pth 'JP_10x_2\JP_2.14'], ...
                      [pth 'JP_10x_2\JP_2.15']);
trace_legend = str2mat('???m','???m','???m','???m','Tair');
trace_units = 'degC';
y_axis      = [0 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, ...
               t, fig_num );
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
