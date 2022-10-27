function [t,x] = yf_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = yf_pl(ind, year, select, fig_num_inc)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
% (c) Elyn Humphreys         File created:       Sept 6, 2001      
%                            Last modification:  Jan 23, 2022
% (c) Nesic Zoran           
%

% Revisions:
%
% Jan 23, 2022 (Zoran)
%   - Modifications to work with datetime plt_msig
% Apr 29, 2021 (Zoran)
%   - Moved RH plotting to the second figure.
% Nov 28, 2019 (Zoran)
%   - added total power consumption
% Aug 30, 2019 (Zoran)
%`  - added more BB1/2 plots
% Jul 28, 2019 (Zoran)
%   - changed Inverter current plotting to make it work with the new power
%   system that now has two battery/charger/inverter systems
% Nov 28, 2018 (Nick L)
%   - added the new-tower rain gauge plot
% Apr 28, 2018 (Zoran)
%   - created panel temperatures #1 and #2
% Apr 25, 2015 (Zoran)
%   - added "The number of generator start attempts" plot.
% July 13, 2010 (Zoran)
%   - added inverter current plot and the system power plot
% Nov 24, 2005 - Add sample tube temperature plot
% Feb 1, 2002 - isolated diagnostic info in this program

if ind(1) > datenum(0,3,15) & ind(1) < datenum(0,11,15) %#ok<*AND2>
    WINTER_TEMP_OFFSET = 0;
else
    WINTER_TEMP_OFFSET = 10;
end

colordef white

arg_default('pause_flag',0);
arg_default('fig_num_inc',1);
arg_default('select',0);
foo = datevec(now);
arg_default('year',foo(1));

if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 8/24;                                    % offset to convert GMT to PST
[pth] = biomet_path(year,'YF','cl');                % get the climate data path

pth_CPEC = biomet_path(year,'YF','CPEC200\Flux_logger');

axis1 = [340 400];
axis2 = [-10 5];
axis3 = [-50 250];
axis4 = [-50 250];


% Find logger ini files
ini_climMain = fr_get_logger_ini('yf',year,[],'yf_clim_60');   % main climate-logger array
ini_clim2    = fr_get_logger_ini('yf',year,[],'yf_clim_61');   % secondary climate-logger array

ini_climMain = rmfield(ini_climMain,'LoggerName');
ini_clim2    = rmfield(ini_clim2,'LoggerName');

st = min(ind);                                        % first day of measurements
ed = max(ind)+1;                                      % last day of measurements (approx.)
ind = st:ed;

datesTmp = datenum(year,1,[st ed]);
[rangeYears,~,~,~,~,~] = datevec(datesTmp);
rangeYears = [rangeYears(1):rangeYears(2)];
% year = rangeYears(end);                         % seems crazy to do this but view_sites uses
%                                                 % last year for regular plotting (now-7, now-14, now-30)
%                                                 % but uses the *first* year when using selected start/stop dates
%                                                 % this solves the issue and makes sure that years is the last 
%                                                 % year in the range.
                                                
fileName = fr_logger_to_db_fileName(ini_climMain, '_tv', pth);
indYear = strfind(fileName,sprintf('%d',year));
fileName(indYear:indYear+3) = 'yyyy';
tv_all = fr_round_time(read_bor(fileName,8,[],rangeYears));
t = tv_all - datenum(year,1,0) - GMTshift;          % convert decimal tv to 
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later    

ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;
indAxes = 0;

%----------------------------------------------------------
% HMP air temperatures
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Air Temperature';
if year<=2017
    trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pth),...
   							fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth),...
   							fr_logger_to_db_fileName(ini_climMain, 'Temp_3_AVG', pth));
    trace_legend = str2mat('HMP\_12m Met1', 'PT100\_12m Met1','TC\_12m');
    trace_units = '(degC)';
    y_axis      = [0 35] - WINTER_TEMP_OFFSET;
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
if year>=2017
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_HMP_T_2m_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','MET_HMP_T_16m_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','MET_HMP_T_24m_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','TC_Ta_Avg'));
    trace_legend = str2mat('HMP\_2m Met1', 'HMP\_16m Met1','HMP\_24m Met1','TC\_32m');
    trace_units = '(degC)';
    y_axis      = [-5 35] - WINTER_TEMP_OFFSET;
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
% remember xlim, you'll need it to rescale cumulative rain
originalXlim = xlim;
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Relative humidity
%----------------------------------------------------------
trace_name  = 'Climate: Relative Humidity';
if year<=2017
    trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pth));
    trace_legend = str2mat('HMP\_12m Gill');
    trace_units = '(RH %)';
    y_axis      = [0 1.10];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
if year>=2017
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_HMP_RH_2m_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','MET_HMP_RH_16m_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','MET_HMP_RH_24m_Avg'));
    trace_legend = str2mat('HMP\_2m','HMP\_16m','HMP\_24m');
    trace_units = '(RH %)';
    y_axis      = [0 110];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Main Battery voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Main Battery Voltage';
if year(1)>= 2013
    trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Main_V_AVG', pth),...
                          fr_logger_to_db_fileName(ini_climMain, 'Main_V_MAX', pth),...
                          fr_logger_to_db_fileName(ini_climMain, 'Main_V_MIN', pth),...                      
                          fullfile(pth,'YF_Snow','AC_ON_AVG'));
                          trace_legend = str2mat('Avg','Max','Min','GEN ON');

else
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Main_V_AVG', pth),...
                          fr_logger_to_db_fileName(ini_climMain, 'Main_V_MAX', pth),...
                          fr_logger_to_db_fileName(ini_climMain, 'Main_V_MIN', pth));
                          trace_legend = str2mat('Avg','Max','Min');
end
endtrace_units = '(V)';
y_axis      = [12 15.5];
fig_num = fig_num + fig_num_inc;
% if year(1)>= 2013
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 12.25] );
%     h=get(gcf,'chi');
%     for ind_h = 1:length(h)
%         if strcmp(get(h(ind_h),'tag'),'legend')
%             p1=get(h(ind_h),'pos');
%         end
%     end
%     ah=axes('position',[p1(1) 0.1 0.99-p1(1) 0.2],'visible','off');
%     text(0.1,0.1,sprintf('Gen runtime =%5.1f h',sum(x(:,4)/2))) 
%     zoom on;
% else
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1] );
% end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% The number of generator start attempts
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Generator Start Attempts';
trace_path  = str2mat(fullfile(pth,'YF_Snow', 'YF_Snow.20'));
trace_legend = str2mat('The number of starts');
trace_units = '#';
y_axis      = [0 5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Generator hut temperature
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Generator Hut Temperature';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Soil_10_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Main_V_Avg', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pth));
trace_legend = str2mat('Hut Temp.','MainBatt Avg.','Air Temp.');
trace_units = '(degC) and V';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Emergency Battery voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Emergency Battery Voltage';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_MIN', pth));
trace_legend = str2mat('Avg','Max','Min');
trace_units = '(V)';
y_axis      = [12 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger voltage
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: YF_Clim Logger Voltage';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'Batt_Volt_AVG', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'Batt_Volt_MAX', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'Batt_Volt_MIN', pth));
trace_legend = str2mat('Avg','Max','Min');
trace_units = '(V)';
y_axis      = [11.0 12.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Main Pwr ON signal
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Main Power ON signal';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'MainPwr_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'MainPwr_MIN', pth));
trace_legend = str2mat('Max','Min');
trace_units = '(16 = Main pwr ON)';
y_axis      = [0 17];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% BB voltages
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Battery Voltages';
if datenum(year(end),1,0+t(end)) >= datenum(2019,07,24,0,0,0)
    % new power system installed on 20190725
    trace_path  = str2mat(fullfile(pth,'YF_Snow', 'YF_Snow.31'),...
                          fullfile(pth,'YF_Snow', 'YF_Snow.33'));
    trace_legend = str2mat('BB1','BB2');
    y_axis      = [];
    trace_units = '(V)';

    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end   
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% BB currents
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Inverter Current';
if datenum(year(end),1,0+t(end)) < datenum(2019,07,24,0,0,0)
    trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'I_invert_AVG', pth),...
                          fr_logger_to_db_fileName(ini_climMain, 'I_invert_MAX', pth),...
                          fr_logger_to_db_fileName(ini_climMain, 'I_invert_MIN', pth));
    trace_legend = str2mat('I Avg','I Max','I Min');
    y_axis      = [0 20];
else
    % new power system installed on 20190725
    trace_path  = str2mat(fullfile(pth,'YF_Snow', 'YF_Snow.32'),...
                          fullfile(pth,'YF_Snow', 'YF_Snow.34'));
    trace_legend = str2mat('BB1','BB2');
    y_axis      = [];
end    
trace_units = '(A)';

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Climate box currents
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Climate System Current';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'I_main_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'I_main_MAX', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'I_main_MIN', pth));
trace_legend = str2mat('I Avg','I Max','I Min');
trace_units = '(A)';
y_axis      = [0 2];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Climate Box Power consumption
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Climate System Power Consumption';
Ibb = read_sig( [fr_logger_to_db_fileName(ini_climMain, 'I_main_AVG', pth)], ind,year, t, 0 ); %#ok<*NBRAK>
if datenum(year(end),1,0+t(end)) < datenum(2019,07,24,0,0,0)
    [BB1, t_I]  = read_sig( [fr_logger_to_db_fileName(ini_climMain, 'Main_V_AVG', pth)], ind,year, t, 0 );
else
    [BB1, t_I] = read_sig( fullfile(pth,'YF_Snow', 'YF_Snow.31'), ind,year, t, 0 );
    [BB2, t_I] = read_sig( fullfile(pth,'YF_Snow', 'YF_Snow.33'), ind,year, t, 0 );
end
trace_path  = (Ibb) .* BB1;
trace_legend = [];
trace_units = '(W)';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Power consumption
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Total YF Power Consumption';
if datenum(year(end),1,0+t(end)) < datenum(2019,07,24,0,0,0)
    [Ibb1, t_I] = read_sig( [fr_logger_to_db_fileName(ini_climMain, 'I_invert_AVG', pth)], ind,year, t, 0 );
    trace_path  = (Ibb+Ibb1) .* BB1;
    y_axis      = [0 200];
    trace_legend = [];
else
    [Ibb1, t_I] = read_sig( fullfile(pth,'YF_Snow', 'YF_Snow.32'), ind,year, t, 0 );
    [Ibb2, t_I] = read_sig( fullfile(pth,'YF_Snow', 'YF_Snow.34'), ind,year, t, 0 );
    trace_path  = [(Ibb1) .* BB1 (Ibb2) .* BB2 (Ibb1) .* BB1+(Ibb2) .* BB2+(Ibb).* BB1];
    trace_legend = str2mat('BB1','BB2','Tot');
    y_axis      = [];
end
trace_units = '(W)';

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery discharge rate
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: YF Available Energy';
if datenum(year(end),1,0+t(end)) < datenum(2019,07,24,0,0,0)
    trace_path  = (Ibb+Ibb1)/2;
    trace_path = (1+cumsum(trace_path)/2600)*100;
    trace_legend = [];
else
    trace_path  = [(Ibb1)/2 (Ibb2)/2];   
    trace_path = (1+cumsum(trace_path)/2600)*100;
    trace_legend = str2mat('BB1','BB2');
end
trace_units = '(%)';

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Total energy consumption
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: YF Total Energy Consumption';
if datenum(year(end),1,0+t(end)) < datenum(2019,07,24,0,0,0)
    trace_path  = (Ibb+Ibb1) .* BB1/2;
    trace_path = cumsum(trace_path);
    trace_legend = [];
else
    trace_path  = [(Ibb1) .* BB1 /2 (Ibb2) .* BB2 /2];   
    trace_path = cumsum(trace_path);    
    trace_legend = str2mat('BB1','BB2');
end
trace_units = '(Wh)';

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Panel temperatures/Box temperatures #1
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Panel/Box Temperatures 1/2';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Panel_T_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Hut_T_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'FlxBox_T_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Ref_AM32_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'AM25T1ref_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pt_1002_AVG', pth));
trace_legend = str2mat('12m Pt-100','yf\_Clim T Avg','Hut T Avg','FlxBox T Avg','AM32 T Avg', 'AM25T T AVG','CNR1');
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Panel temperatures/Box temperatures #2
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Panel/Box Temperatures 2/2';
trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','SYS_PanelT_AM25T_Avg'));
trace_legend = str2mat('yf\_Clim LoggerT Avg');
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Tank Pressures
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Tank Pressures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pres_ref_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pres_zer_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pres_cal1_AVG', pth));
                      %fr_logger_to_db_fileName(ini_climMain, 'Pres_cal2_AVG', pth));
                  
trace_legend = str2mat('Ref(R)','Ref(L)','Cal1','Pneumatic');
trace_units = '(psi)';
y_axis      = [0 2600];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
x=x_all(:,1);
ref_lim = 400;                              % lower limit for the ref. gas tank-pressure
index = find(x > 0 & x <=2500);
wOld = warning;
warning 'off'
px = polyfit(x(index),t(index),1);         % fit first order polynomial
warning(wOld)
lowLim = polyval(px,ref_lim);                   % return DOY when tank is going to hit lower limit
ax = xlim;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),250,sprintf('Rate of change = %4.0f psi per week',perWeek));
text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Low limit(%5.1f) will be reached on DOY = %4.0f',ref_lim,lowLim));
if pause_flag == 1;pause;end
zoom on
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Chamber Compressor
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Chamber compressor';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pres_cal2_AVG', pth));             
trace_legend = str2mat('Ch Compressor');
trace_units = '(psi)';
y_axis      = [0 130];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sample Tube Temperature
%----------------------------------------------------------
trace_name  = 'Climate/Diagnostics: Sample Tube Temperature';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'TubeTC_1_AVG', pth),...
   						fr_logger_to_db_fileName(ini_climMain, 'TubeTC_2_AVG', pth),...
    					fr_logger_to_db_fileName(ini_climMain, 'TubeTC_3_AVG', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth));
                        
trace_legend = str2mat('1','2','3','PT100 Met1');
trace_units = '(degC)';
y_axis      = [5 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Rain 
%----------------------------------------------------------
trace_name  = 'Climate: Rainfall';
%if year<2018
%if datenum(now)<=datenum('18-Jun-2018 16:00:00')
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'TBRG_1_TOT', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'TBRG_2_TOT', pth),...
                        fullfile(pth,'YF_CR1000_1_MET_30','MET_RainTips_Tot'));
trace_units = '(mm)';
trace_legend = str2mat('TBRG1','TBRG2\_snow','TR525M');
y_axis      = [-1 10];
fig_num = fig_num + fig_num_inc;
[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
%end


%if year>=2018
%if datenum(now)>=datenum('18-Jun-2018 16:00:00') %20180618
%trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_RainTips_Tot'));
%trace_units = '(mm)';
%trace_legend = str2mat('TR525M');
%y_axis      = [-1 10];
%fig_num = fig_num + fig_num_inc;
%[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
%end
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative rain 
%----------------------------------------------------------
% *** in case of multiple-year plots it plots only the last year
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the last year
indNew = [1:length(indx)]+round(GMTshift*48);               % use GMTshift to align the data with time vector
trace_name  = 'Climate: Cumulative Rain (current year only)';
trace_legend = str2mat('TBRG1','TBRG2\_snow','TR525M');
y_axis      = [];

[x1,tx_new] = read_sig(trace_path(1,:), indNew,year, tx,0); %#ok<*ASGLU>
[x2,tx_new] = read_sig(trace_path(2,:), indNew,year, tx,0);
[x3,tx_new] = read_sig(trace_path(3,:), indNew,year, tx,0);
fig_num = fig_num + fig_num_inc;
if year==1998
    addRain = 856.9;
else 
    addRain = 0;
end
x = plt_msig( [cumsum(x1) cumsum(x2) cumsum(x3)+addRain], indNew, trace_name, trace_legend, year, trace_units, y_axis, tx_new, fig_num);
xlim(originalXlim);
%plt_sig1( tx_new, [cumsum(x1) cumsum(x2) cumsum(x3)+addRain], trace_name, year, trace_units, ax, y_axis, fig_num );
%legend('TBRG1','TBRG2\_snow','TR525M');
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Snow
%----------------------------------------------------------
trace_name  = 'Climate: Snow Depth';
trace_path  = str2mat( fullfile(pth,'YF_Snow','SnowDepth_AVG'),fullfile(pth,'YF_Snow','SnowDepth_MAX'),...
                         fullfile(pth,'YF_Snow','SnowDepth_MIN'));
trace_units = '(m)';
trace_legend = str2mat('AVG','MAX','MIN');
y_axis      = [-0.05 1];
fig_num = fig_num + fig_num_inc;
[x] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Snow temperatures 
%----------------------------------------------------------
trace_name  = 'Climate: Snow Temperatures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Snow_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Snow_5_AVG', pth));
trace_legend = str2mat('1 cm','5 cm','10 cm','20 cm','50 cm');
trace_units = '(degC)';
y_axis      = [0 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%-----------------------------------
% Net
%-----------------------------------
trace_name  = 'Climate: Net Radiation';
if year<=2017
    trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_6_AVG', pth),...
        fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pth));
    trace_legend = str2mat('Swissteco', 'CNR1');
    trace_units = '(W/m^2)';
    y_axis      = [-200 1000];
    fig_num = fig_num + fig_num_inc;
    x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
if year>=2017
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_Net_Avg'));
    trace_legend = str2mat('CNR1');
    trace_units = '(W/m^2)';
    y_axis      = [-200 1000];
    fig_num = fig_num + fig_num_inc;
    x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% CNR1 temperature
%----------------------------------------------------------
trace_name  = 'CNR1 temperature';
if year<=2017
%     T_CNR1 = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Pt_1002_AVG', pth));
%     T_HMP = read_bor(fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pth));
%     T_PRT = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth));
%     trace_path  = [T_CNR1 T_HMP T_PRT];
    trace_path = char(fr_logger_to_db_fileName(ini_climMain, 'Pt_1002_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pth));            
    trace_legend = str2mat('CNR1_{PRT}','T_{HMP}','T_{PRT}');
    trace_units = '(degC)';
    y_axis      = [0 35] - WINTER_TEMP_OFFSET;
    fig_num = fig_num + fig_num_inc;
    outputMatrix = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    T_CNR1 = outputMatrix(:,1);
end
if year>=2017
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_TC_Avg'));
    trace_legend = str2mat('CNR1_{PRT}');
    trace_units = '(degC)';
    y_axis      = [0 35] - WINTER_TEMP_OFFSET;
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%-----------------------------------
% Net radiation SW and LW
%-----------------------------------
trace_name  = 'Radiation Above Canopy';
if year<=2017
%     Net_cnr1_AVG = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pth));
%     S_upper_AVG = read_bor(fr_logger_to_db_fileName(ini_climMain, 'S_upper_AVG', pth));
%     S_lower_AVG = read_bor(fr_logger_to_db_fileName(ini_climMain, 'S_lower_AVG', pth));
%     lwu = read_bor(fr_logger_to_db_fileName(ini_climMain, 'L_lower_AVG', pth));
%     lwd = read_bor(fr_logger_to_db_fileName(ini_climMain, 'L_upper_AVG', pth));
    trace_path = char(fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'S_upper_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'S_lower_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'L_lower_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'L_upper_AVG', pth));
    trace_legend = str2mat('Net','swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
    trace_units = '(W m^{-2})';
    y_axis      = [-200 1400];
 
    fig_num = fig_num + fig_num_inc;
    outputNetRadiation = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);   
    LongWaveOffset =(5.67E-8*(273.15+T_CNR1).^4);
    L_upper_AVG = outputNetRadiation(:,5) + LongWaveOffset;
    L_lower_AVG = outputNetRadiation(:,4) + LongWaveOffset;
    S_upper_AVG = outputNetRadiation(:,2);
    S_lower_AVG = outputNetRadiation(:,3);
    Net_cnr1_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
    trace_path = [Net_cnr1_AVG S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr1_calc];
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
if year>=2017
%     Net_cnr1_AVG = read_bor(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_Net_Avg'));
%     S_upper_AVG = read_bor(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_SWi_Avg'));
%     S_lower_AVG = read_bor(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_SWo_Avg'));
%     L_upper_AVG = read_bor(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_LWo_Avg'));
%     L_lower_AVG = read_bor(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_LWi_Avg'));
    % first plot is there just to pull all the variables in
    trace_path = char(fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_Net_Avg'),...
                      fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_SWi_Avg'),...
                      fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_SWo_Avg'),...
                      fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_LWo_Avg'),...
                      fullfile(pth,'YF_CR1000_1_MET_30','MET_CNR1_LWi_Avg'));
    trace_legend = str2mat('Net','swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
    trace_units = '(W m^{-2})';
    y_axis      = [-200 1400];
    fig_num = fig_num + fig_num_inc;
    [outputNetRadiation,outputDateTime] = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);                 
    %Net_cnr1_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
    Net_cnr1_calc = outputNetRadiation(:,5) - outputNetRadiation(:,4)  + outputNetRadiation(:,2) - outputNetRadiation(:,3);
    %trace_path = [Net_cnr1_AVG S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr1_calc];
    trace_path = [ outputNetRadiation Net_cnr1_calc];
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%-----------------------------------
% Barometric pressure
%-----------------------------------
trace_name  = 'Climate: Barometric Pressure';
if year<=2017
    trace_path = fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pth);
    trace_units = '(kPa)';
    y_axis      = [96 102];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
if year>=2017
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_Barometric_Pressure_Avg'));
    trace_units = '(kPa)';
    y_axis      = [96 102];
    fig_num = fig_num + fig_num_inc;
    %x = plt_sig( trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
    x = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%------------------------------------------
if select == 1 %diagnostics only
    linkaxes(allAxes,'x');
    if pause_flag ~= 1
        childn = get(0,'children');
        childn = sort(childn);
        N = length(childn);
        for i=1:N
            if i < 200
                figure(i);
                pause;
            end
        end
    end
    return
end


%-----------------------------------
% Soil Temperatures
%-----------------------------------
trace_name  = 'Climate: Soil Temperatures ';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Soil_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_6_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_7_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_8_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Soil_9_AVG', pth));
trace_legend = str2mat('2cm','5cm','10cm','20cm','50cm','100cm','0.5cm','1cm','2cm');
trace_units = 'deg C';
y_axis      = [5 25] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Tree/Surface temperatures 
%----------------------------------------------------------
trace_name  = 'Climate: Tree/Surface Temperatures';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'T_Tree_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'T_Tree_6_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Ever_Ttar_AVG', pth));
trace_legend = str2mat('tree1','tree2','tree3','tree4','tree5','tree6','Tree Surface');
trace_units = '(degC)';
y_axis      = [0 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Temperature profile
%----------------------------------------------------------
trace_name  = 'Climate: Temperature Profile';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Temp_1_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'Temp_6_AVG', pth));
trace_legend = str2mat('T20m','T16m','T11.5m','T6m','T3m','T1m');
trace_units = '(degC)';
y_axis      = [ 0 40] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Soil Moisture (TDR)
%----------------------------------------------------------
trace_name  = 'Climate: Soil Moisture (TDR)';
trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'CS615v_1', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_2', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_3', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_4', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_5', pth),...
                        fr_logger_to_db_fileName(ini_climMain, 'CS615v_6', pth));
trace_legend = str2mat('1','2','3','4','5','6');
trace_units = 'VWC';
y_axis      = [0.1 0.6];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Speed Averages (RM Young)';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_MAX', pth));
trace_legend = str2mat('12m (avg)','12m (max)');
trace_units = '(m/s)';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
trace_name  = 'Climate: Wind Direction (RM Young)';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'WindDir_DU_WVT', pth));
trace_legend = str2mat('12m');
trace_units = '(^o)';
y_axis      = [0 360];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Gas Hound co2 concentration 
%----------------------------------------------------------
trace_name  = 'Climate: 10m CO2 Concentration (Gashound)';
    trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'GH_co2_AVG', pth),...
                      fr_logger_to_db_fileName(ini_clim2,    'GH_co2_MAX', pth),...
                      fr_logger_to_db_fileName(ini_clim2,    'GH_co2_MIN', pth));
    trace_legend = str2mat('avg','max','min');
    trace_units = '(umol/m2/s)';
    y_axis      = [300 600];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','IRGA_CO2_Avg')); %#ok<*NASGU>
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% LI-7500 co2 concentration 
%----------------------------------------------------------
trace_name  = 'Climate: 31m CO2 Concentration (LI-7500)';
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','IRGA_CO2_Avg'));
    trace_legend = str2mat('avg');
    trace_units = '(mmol/m3)';
    y_axis      = [0 60];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% LI-7500 h2o concentration 
%----------------------------------------------------------
trace_name  = 'Climate: 31m H2O Concentration (LI-7500)';
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','IRGA_H2O_Avg')); %#ok<*DSTRMT>
    trace_legend = str2mat('avg');
    trace_units = '(mmol/m3)';
    y_axis      = [100 1000];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%-----------------------------------
% PAR 1,2
%-----------------------------------
trace_name  = 'Climate: PPFD';
if year<=2017
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_1_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'RAD_2_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'PAR_Tot_AVG', pth),...
    fr_logger_to_db_fileName(ini_climMain, 'PAR_Diff_AVG', pth));
trace_legend = str2mat('downward','upward','BF2 Total','BF2 Diffuse');
trace_units = '(umol m^{-2} s^{-1})';
y_axis      = [-100 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
if year>=2017
    trace_path  = str2mat(fullfile(pth,'YF_CR1000_1_MET_30','MET_PAR_in_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','MET_PAR_out_Avg'),...
                          fullfile(pth,'YF_CR1000_1_MET_30','MET_BF3_diffuse_Avg'));
trace_legend = str2mat('downward','upward','BF3 Diffuse');
trace_units = '(umol m^{-2} s^{-1})';
y_axis      = [-100 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

%-----------------------------------
% PSP
%-----------------------------------
trace_name  = 'Climate: Shortwave Radiation';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_3_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'RAD_4_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'RAD_5_AVG', pth),...
                      fr_logger_to_db_fileName(ini_climMain, 'S_upper_AVG', pth));
trace_legend = str2mat('LICOR down','Kipp down','Kipp up', 'CNR1 down');

trace_units = '(W/m^2)';
y_axis      = [-100 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end




%-----------------------------------
% Soil heat flux
%-----------------------------------
trace_name  = 'Climate: Soil Heat Flux 3cm Below LFH';
trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP1_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP2_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP3_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP4_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP5_AVG', pth),...
                    fr_logger_to_db_fileName(ini_climMain, 'SHFP6_AVG', pth));
trace_legend = str2mat('1','2','3','4','5','6');
trace_units = '(W/m^2)';
y_axis      = [-100 100];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
indAxes = indAxes+1; allAxes(indAxes) = gca;
if pause_flag == 1;pause;end

linkaxes(allAxes,'x');

if pause_flag ~= 1
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=1:N
        if i < 200
            figure(i);
            pause;
        end
    end
end

%========================================================
% local functions

function [p,x1,x2] = polyfit_plus(x1in,x2in,n) %#ok<DEFNU>
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
