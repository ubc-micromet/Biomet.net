function [t,x] = paob_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = paob_pl(ind, year, select, fig_num_inc,pause_flag)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       May 15, 1999
%                           Last modification:  Jul 25, 2000
%

% Revisions:
% Sept 16, 2003
%   - changed the structure for plotting gas tanks pressures. Plot reference tanks for all systems; Plot cals tanks;
%     Plot extra chamber tanks (David).
%   - removed CAL2 from eddy tank pressure and replaced it with chamber pneumatic air pressure in chamber
%     tank pressure (David)
% Feb 1, 2002 
%   - isolated all diagnostic info in this program
% Jul 25, 2000
%   - added plotting of profile and chamber system N2 tanks (ref.)
% May 6, 2000
%   - changed axes
% Dec 30 ,1999
%   - changes in biomet_path calling syntax.
% Nov 21, 1999
%   - added estimation of N2 usage (kPa/Week)
%   Nov 14, 1999
%       - added many new traces, major update
%   June 1, 1999
%       - corrected pressure tank labels


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
    pth = biomet_path(year,'BS','cl');      % get the climate data path
    EddyPth = biomet_path(year,'BS','fl');  % get the flux data path
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
else
    error 'Data for the requested year is not available!'
end

st = min(ind);                                      % first day of measurements
ed = max(ind)+1;                                    % last day of measurements (approx.)
ind = st:ed;

t=read_bor([ pth 'bs_cr7_3\bs_3_dt']);              % get decimal time from the data base
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
% Temperatures at the top
%----------------------------------------------------------
trace_name  = 'Temperatures at the top';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.25'],[pth 'BS_CR7_3\BS_3.33']);
trace_legend= str2mat('HMP_{Vent}','PRT_{Vent}');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Pump Box temperature
%-----------------------------------
trace_name  = 'Pump Box temperature';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.26'],[pth 'BS_23x_1\BS_1.27'],[pth 'BS_23x_1\BS_1.28']);
trace_legend = str2mat('Avg','Max','Min');
trace_units = 'degC';
y_axis      = [0 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Sampling tube temperatures
%----------------------------------------------------------
trace_name  = 'Sampling tube temperatures';
trace_path  = str2mat([pth 'BS_23x_2\BS_2.15'],[pth 'BS_23x_2\BS_2.16'],[pth 'BS_23x_2\BS_2.17'],[pth 'BS_23x_2\BS_2.18']);
trace_legend = str2mat('0.35m','2.2m','4.2m','air Temp');
trace_units = 'degC';
y_axis      = [0 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% PowerBox temperature
%-----------------------------------
trace_name  = 'PowerBox temperature';
trace_path  = str2mat([pth 'BS_23x_2\BS_2.6'],[pth 'BS_23x_2\BS_2.9'],[pth 'BS_23x_2\BS_2.12'],[pth 'BS_23x_2\BS_2.18']);
trace_legend = str2mat('Avg','Max','Min','Air');
trace_units = 'degC';
y_axis      = [0 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Power Box Datalogger Battery voltages
%----------------------------------------------------------
trace_name  = 'Power Box Battery Voltages';
trace_path  = str2mat([pth 'BS_23x_2\BS_2.7'],[pth 'BS_23x_2\BS_2.10'],[pth 'BS_23x_2\BS_2.13']);
trace_legend= str2mat('Avg','Max','Min');
trace_units = 'volts';
y_axis      = [10 14];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Datalogger Battery voltages
%----------------------------------------------------------
trace_name  = 'Hut Datalogger Battery Voltages';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.6'],[pth 'BS_23x_1\BS_1.18'], ...
                      [pth 'BS_23x_1\BS_1.12']);
trace_legend= str2mat('Min','Avg','Max');
trace_units = 'volts';
y_axis      = [10 14];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Hut temperatures
%-----------------------------------
trace_name  = 'Hut temperatures';
trace_path  = [pth 'BS_23x_1\BS_1.5'];
trace_units = '(degC)';
y_axis      = [10 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Reference tank pressures
%-----------------------------------
trace_name  = 'Reference tank pressures';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.10'],[pth 'BS_23x_1\BS_1.23'],[pth 'BS_23x_1\BS_1.30']);
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
zoom on

%-----------------------------------
% Calibration tank pressures
%-----------------------------------
trace_name  = 'Calibration tank pressures';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.7'],[pth 'BS_23x_1\BS_1.8']);
trace_legend= str2mat('Cal0','Cal1');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
zoom on

%-----------------------------------
% Chamber extra tank pressures
%-----------------------------------
trace_name  = 'Chamber extra tank pressures';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.29'],[pth 'BS_23x_1\BS_1.9']);
trace_legend= str2mat('Ch 10%CO2','Ch PneuAP');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
x=x_all(:,2);
ref_lim = 400;                             % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
px = polyfit(x(index),t(index),1);         % fit first order polynomial
lowLim = polyval(px,ref_lim);              % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Ch pneu AP = %4.0f kPa/week - Low limit DOY %4.0f',perWeek,lowLim));
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


%----------------------------------------------------------
% Temperature profile using HMP data
%----------------------------------------------------------
trace_name  = 'Temperature profile using HMP data';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.22'],[pth 'BS_CR7_3\BS_3.23'],[pth 'BS_CR7_3\BS_3.24'],[pth 'BS_CR7_3\BS_3.25'],[pth 'BS_CR7_3\BS_3.33']);
trace_legend= str2mat('HMP1','HMP3','HMP5','HMP_Vent','PRT_Vent');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% RH profile using HMP data
%----------------------------------------------------------
trace_name  = 'RH profile using HMP data';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.26'],[pth 'BS_CR7_3\BS_3.27'], ...
                      [pth 'BS_CR7_3\BS_3.28']);
trace_legend= str2mat('HMP1','HMP3','HMP5');
trace_units = '(%)';
y_axis      = [-5 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


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
