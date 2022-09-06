function [t,x] = test(ind, year, fig_num_inc,pause_flag)
LOCAL_PATH = 0;

colordef none

if nargin < 4
    pause_flag = 0;
end
if nargin < 3
    fig_num_inc = 1;
end
if nargin < 2
    year = 1998;
elseif year == []
    year = 1998;
end
if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 8/24;                                    % offset to convert GMT to PST
if year >= 1996
    if LOCAL_PATH == 1
        pth = 'd:\local_dbase\';
    else
        pth = '\\class\paoa\newdata\';
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

t=read_bor([ pth 'fr_a\fr_a_dt']);                  % get decimal time from the data base
if year == 1996
	 offset_doy = 0;
elseif year == 1997
    offset_doy = 366;
elseif year == 1998
    offset_doy = 731;
else
    error 'Implementation of this software works until Dec 31, 1996'
end  
t = t - offset_doy + 1 - GMTshift;                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

if 1==1

%----------------------------------------------------------
% Rain 
%----------------------------------------------------------
trace_name  = 'Rain';
trace_path  = str2mat([pth 'fr_a\fr_a.24'],[pth 'fr_a\fr_a.79']);
trace_units = '(mm)';
trace_legend = str2mat('Rain 1','Rain 2');
y_axis      = [-1 10];
fig_num = fig_num + fig_num_inc;
%[x] = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

if pause_flag == 1;pause;end


%----------------------------------------------------------
% Cumulative rain #1
%----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'Cumulative rain ';
y_axis      = [];
ax = [st ed];
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
[x2,tx_new] = read_sig(trace_path(2,:), indx,year, tx,0);
%x=[x1 x2];
fig_num = fig_num + fig_num_inc;
plt_sig1( tx_new, [cumsum(x1) cumsum(x2)+856.9], trace_name, year, trace_units, ax, y_axis, fig_num );
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
