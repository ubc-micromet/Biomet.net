function [t,x] = hdf11_ch_pl(ind, year, SiteID, select,pause_flag)
%
% [t,x] = cr_ch_pl(ind, year, select fig_num_inc)
%
%   This function plots selected data from the ACS system files. 
%
%
% (c) Nick Grant                File created:       Aug 2, 2011
%                               Last modification:  Aug 2, 2011
%

% Revisions:
% 
% Aug 2, 2011
%   -Nick set up based on cr_ch_pl

if ind(end) > datenum(0,4,15) & ind(end) < datenum(0,10,15);
    WINTER_TEMP_OFFSET = 0;
else
    WINTER_TEMP_OFFSET = 15;
end

colordef none

fig_num_inc = 1;

if ~exist('pause_flag') | isempty(pause_flag)
    pause_flag = 0;
end
if ~exist('select') | isempty(select)
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
if year < 2001
    [t,x] = frbc_pl_old(ind, year, fig_num_inc,pause_flag);
    return
else
    [pth] = biomet_path(year,'HDF11','cl');            % get the climate data path
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
end

% Find logger ini files
% ini_climMain = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_105');   % main climate-logger array
% ini_clim2    = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_106');   % secondary climate-logger array
% ini_soilMain = fr_get_logger_ini('cr',year,'fr_soil','fr_soil_101');   % main soil-logger array


st = min(ind);                                      % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

% fileName = fr_logger_to_db_fileName(ini_climMain, '_dt', pth);
% t=read_bor(fileName);                               % get decimal time from the data base

pth_acs = fullfile(biomet_path(year,'HDF11'),'ACS-DC\','');
t=read_bor(fullfile(pth_acs,'TimeVector'),8);

if year < 2000
    offset_doy=datenum(year,1,1)-datenum(1996,1,1);     % find offset DOY
else
    offset_doy=0;
end
t = t - t(1);                  % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

%----------------------------------------------------------
% ACS Plicor
%----------------------------------------------------------
trace_name  = 'ACS Soil Chambers: P_{licor}';

trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_2.Sample.Channel.Plicor.avg'],... 
                      [ pth_acs 'Chamber_3.Sample.Channel.Plicor.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3');
trace_units = 'kPa';
y_axis      = [0 105];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% ACS Tlicor
%----------------------------------------------------------
trace_name  = 'ACS Soil Chambers: T_{licor}';
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.Channel.Tlicor.avg'],...
                      [ pth_acs 'Chamber_2.Sample.Channel.Tlicor.avg'],... 
                      [ pth_acs 'Chamber_3.Sample.Channel.Tlicor.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3');
trace_units = '\circC';
y_axis      = [ 40 60];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% ACS: Air Temp
%----------------------------------------------------------
trace_name  = 'ACS Soil Chambers: Air Temperature';
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_2.Sample.airTemperature'],... 
                      [ pth_acs 'Chamber_3.Sample.airTemperature']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3');
trace_units = '\circC';
y_axis      = [ 0 30] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% ACS: Soil CO_2 efflux
%----------------------------------------------------------
trace_name  = 'ACS Soil Chambers: Soil CO_2 efflux';
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.efflux'],...
                      [ pth_acs 'Chamber_2.Sample.efflux'],... 
                      [ pth_acs 'Chamber_3.Sample.efflux']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3');
trace_units = '\mumol m^{-2} s^{-1}';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% ACS: Soil chamber CO_2 mixing ratio
%----------------------------------------------------------
trace_name  = 'ACS soil chambers: CO_2 mixing ratio';
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.Channel.co2.avg'],...
                      [ pth_acs 'Chamber_2.Sample.Channel.co2.avg'],... 
                      [ pth_acs 'Chamber_3.Sample.Channel.co2.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3');
trace_units = '\mumol mol^{-1}';
y_axis      = [350 500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%----------------------------------------------------------
% ACS: Voltages
%----------------------------------------------------------
trace_name  = 'ACS soil chambers: Voltages';
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.Channel.Vin.avg'],...
                      [ pth_acs 'Chamber_2.Sample.Channel.Vin.avg'],... 
                      [ pth_acs 'Chamber_3.Sample.Channel.Vin.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3');
trace_units = 'V';
y_axis      = [0 13];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
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

%========================================================


% local functions

function [p,x1,x2] = polyfit_plus(x1in,x2in,n);
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
