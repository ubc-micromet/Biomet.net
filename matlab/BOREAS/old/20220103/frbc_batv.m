function [t,x] = frbc_batv(ind, year, fig_num_inc,pause_flag)
%
% [t,x] = frbc_pl(ind, year, fig_num_inc)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       Jul  8, 1997
%                           Last modification:  Dec 21, 1997
%

% Revisions:
%
% 		  Dec 21, 1997
%				-	More axis changes
%       Nov 20, 1997
%           - legend changes
%       Oct  5, 1997
%           Added barometric pressure
%       Sep  22, 1997
%           Added FR_C Fan/Heater duty cycles, box/sample cell temperature. Fixed
%           cummulative rain plot.
%       Sep  1, 1997
%           Changed axes for wind speed and closure.
%       Aug 29, 1997
%           Added H_tc to the energy plots.
%       Aug 10, 1997
%           Added proper Gill cup wind speed and wind speed vector (Gill3D) plotting.
%       Aug 10, 1997
%           Solved problem with unequal lengths of CupRMYoung and CupGill files
%       Aug  5, 1997
%           Added net radiometer and Panel Temp #3 plotting
%       Jul 15, 1997
%           Added phone battery voltage and hut air temperature
%           to the plots.
%       Jul  8, 1997
%           Created program using paoa_pl.m as a starting point

%
if nargin < 4
    pause_flag = 0;
end
if nargin < 3
    fig_num_inc = 1;
end
if nargin < 2
    year = 1997;
elseif year == []
    year = 1997;
end
if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 7/24;                                    % offset to convert GMT to PST
if year >= 1996
%    pth = 'h:\zoran\bor96\';
%    pth = 'r:\paoa\newdata\';
    pth = '\\class\paoa\newdata\';
    if exist('h:\zoran\paoa\paoa_dt') 
        EddyPth = 'h:\zoran\paoa\';
    else
        EddyPth = '\\boreas_003\paoa\';
    end
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
else
    error 'Data for the requested year is not available!'
end

st = min(ind);                                      % first day of measurements
ed = max(ind);                                      % last day of measurements (approx.)

t=read_bor([ pth 'bonet\bnt_dt']);                  % get decimal time from the data base
if year == 1996
    offset_doy = 0;
elseif year == 1997
    offset_doy = 366;
else
    error 'Implementation of this software works until Dec 31, 1997'
end  
t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

if 1==1

%----------------------------------------------------------
% Battery voltage
%----------------------------------------------------------
trace_name  = 'Battery voltages';
trace_path  = str2mat([pth 'fr_a\fr_a.5'],[pth 'fr_b\fr_b.5'],[pth 'fr_e\fr_e.5']);
trace_legend = str2mat('FR-A','FR-B','FR-E');
trace_units = '(V)';
y_axis      = [10 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

end


