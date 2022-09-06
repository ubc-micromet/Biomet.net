function [t,x] = cr_ch_pl(ind, year, SiteID, select,pause_flag)
%
% [t,x] = cr_ch_pl(ind, year, select fig_num_inc)
%
%   This function plots selected data from the single-chamber system files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran/Paul Jassal   File created:       June 10, 2005
%                               Last modification:  Jan  29, 2008
%

% Revisions:
% 
% Jan 29, 2008 (Zoran/Christian)
%   - added SiteID (just to match the number of parameters used in all
%   other plotting programs).  This also fixed the bug when plotting data
%   with the diagnostics box unchecked

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
    [pth] = biomet_path(year,'CR','cl');            % get the climate data path
    axis1 = [340 400];
    axis2 = [-10 5];
    axis3 = [-50 250];
    axis4 = [-50 250];
end

% Find logger ini files
ini_climMain = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_105');   % main climate-logger array
ini_clim2    = fr_get_logger_ini('cr',year,'fr_clim','fr_clim_106');   % secondary climate-logger array
ini_soilMain = fr_get_logger_ini('cr',year,'fr_soil','fr_soil_101');   % main soil-logger array


st = min(ind);                                      % first day of measurements
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
% Soil CO_2 efflux
%----------------------------------------------------------
trace_name  = 'Single Soil Chamber: Soil CO_2 efflux';
trace_path  = str2mat([biomet_path(year,'CR','Chambers') 'flux.1']);
trace_legend = str2mat('Single soil chamber');
trace_units = '\mumol m^{-2} s^{-1}';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, 1 );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil chamber CO_2 mixing ratio
%----------------------------------------------------------
trace_name  = 'Single Soil Chamber: CO_2 mixing ratio';
trace_path  = str2mat([biomet_path(year,'CR','Chambers') 'co2_after.1'],...
    [biomet_path(year,'CR','profile') 'co2_avg.1']);
trace_legend = str2mat('Single soil chamber','Profile system');
trace_units = '\mumol mol^{-1}';
y_axis      = [350 500];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 1] );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temperature
%----------------------------------------------------------
trace_name  = 'Single Soil Chamber: Air Temperature';
trace_path  = str2mat([biomet_path(year,'CR','Chambers') 'tair.1'],[pth 'fr_f\fr_f.17']);
trace_legend = str2mat('Single soil chamber', 'T_2m');
trace_units = '(degC)';
y_axis      = [ 0 30] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 1] );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% ACS Plicor
%----------------------------------------------------------
trace_name  = 'ACS Soil Chambers: P_{licor}';
pth_acs = fullfile(biomet_path(year,'CR'),'ACS-DC\','');
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_2.Sample.Channel.Plicor.avg'],... 
                      [ pth_acs 'Chamber_3.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_4.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_5.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_6.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_7.Sample.Channel.Plicor.avg'],...
                      [ pth_acs 'Chamber_8.Sample.Channel.Plicor.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3','Ch 4','Ch 5','Ch 6','Ch 7','Ch 8');
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
                      [ pth_acs 'Chamber_3.Sample.Channel.Tlicor.avg'],...
                      [ pth_acs 'Chamber_4.Sample.Channel.Tlicor.avg'],...
                      [ pth_acs 'Chamber_5.Sample.Channel.Tlicor.avg'],...
                      [ pth_acs 'Chamber_6.Sample.Channel.Tlicor.avg'],...
                      [ pth_acs 'Chamber_7.Sample.Channel.Tlicor.avg'],...
                      [ pth_acs 'Chamber_8.Sample.Channel.Tlicor.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3','Ch 4','Ch 5','Ch 6','Ch 7','Ch 8');
trace_units = '\circC';
y_axis      = [ 0 30] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% ACS: Air Temp
%----------------------------------------------------------
trace_name  = 'ACS Soil Chambers: Air Temperature';
trace_path  = str2mat([ pth_acs 'Chamber_1.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_2.Sample.airTemperature'],... 
                      [ pth_acs 'Chamber_3.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_4.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_5.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_6.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_7.Sample.airTemperature'],...
                      [ pth_acs 'Chamber_8.Sample.airTemperature']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3','Ch 4','Ch 5','Ch 6','Ch 7','Ch 8');
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
                      [ pth_acs 'Chamber_3.Sample.efflux'],...
                      [ pth_acs 'Chamber_4.Sample.efflux'],...
                      [ pth_acs 'Chamber_5.Sample.efflux'],...
                      [ pth_acs 'Chamber_6.Sample.efflux'],...
                      [ pth_acs 'Chamber_7.Sample.efflux'],...
                      [ pth_acs 'Chamber_8.Sample.efflux']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3','Ch 4','Ch 5','Ch 6','Ch 7','Ch 8');
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
                      [ pth_acs 'Chamber_3.Sample.Channel.co2.avg'],...
                      [ pth_acs 'Chamber_4.Sample.Channel.co2.avg'],...
                      [ pth_acs 'Chamber_5.Sample.Channel.co2.avg'],...
                      [ pth_acs 'Chamber_6.Sample.Channel.co2.avg'],...
                      [ pth_acs 'Chamber_7.Sample.Channel.co2.avg'],...
                      [ pth_acs 'Chamber_8.Sample.Channel.co2.avg'],...
                      [biomet_path(year,'CR','profile') 'co2_avg.1']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3','Ch 4','Ch 5','Ch 6','Ch 7','Ch 8','Profile');
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
                      [ pth_acs 'Chamber_3.Sample.Channel.Vin.avg'],...
                      [ pth_acs 'Chamber_4.Sample.Channel.Vin.avg'],...
                      [ pth_acs 'Chamber_5.Sample.Channel.Vin.avg'],...
                      [ pth_acs 'Chamber_6.Sample.Channel.Vin.avg'],...
                      [ pth_acs 'Chamber_7.Sample.Channel.Vin.avg'],...
                      [ pth_acs 'Chamber_8.Sample.Channel.Vin.avg']);
trace_legend = str2mat('Ch 1','Ch 2','Ch 3','Ch 4','Ch 5','Ch 6','Ch 7','Ch 8');
trace_units = 'V';
y_axis      = [0 13];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Soil CO_2 probes
%----------------------------------------------------------
trace_name  = 'Soil CO_2 probes';
trace_path = [read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2.56']) ...
              read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2.57']) ...
              read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2.58'])];
ind_every_12 = [7:12:length(trace_path)]';
trace_path     = trace_path(ind_every_12,:);
t1 = read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2_dt']);
t1     = t1(ind_every_12);
ind1 = find( t1 >= st & t1 <= ed );                    % extract the requested period
t1 = t1(ind1);
trace_path     = trace_path(ind1,:);
%ind_1      = 1:2:length(t);
trace_legend = str2mat('CO2_1','CO2_2','CO2_3');
trace_units = '\mumol mol^{-1}';
y_axis      = [0 12000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t1, fig_num, [1 1 1] );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Temperatures
%----------------------------------------------------------
trace_name  = 'Soil Temperatures';
trace_path = [read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2.59']) ...
              read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2.60']) ...
              read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2.61'])];
ind_every_12 = [7:12:length(trace_path)]';
trace_path     = trace_path(ind_every_12,:);
t1 = read_bor([biomet_path(year,'CR','Climate\FR_C') 'fr_c2_dt']);
t1     = t1(ind_every_12);
ind1 = find( t1 >= st & t1 <= ed );                    % extract the requested period
t1 = t1(ind1);
trace_path     = trace_path(ind1,:);
trace_legend = str2mat('Ts_1','Ts_2','Ts_3');
trace_units = '(degC)';
y_axis      = [0 30] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t1, fig_num, [1 1 1] );
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
