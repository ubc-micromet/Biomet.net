function [t,x] = paoa_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = paoa_pl(ind, year, select, fig_num_inc)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       Jan 15, 1997
%                           Last modification:  Oct 19, 2015
%

% Revisions:
% Oct 19, 2015 (Zoran)
%   - Fixed plotting TBRG near Belford3000 by adding try-catch statements.
%   
% Nov 29, 2013 (Nick)
%   -corrections to Eppley PIR traces (raw thermopile traces) and T_CNR1.
%   Added Eppley PIR body and dome thermistor resistances used for sigma*T^4
%   corrections
% Nov 14, 2012 (Nick)
%   -added OAT2 logger traces (TDR and soil Tc)
% Sept 20, 2012 (Nick)
%   -added OAP logger traces: Belfort 3000 precip, TBRG, RMYoung wind speed in clearing
% Mar 1, 2011 (Zoran)
%   - changed trace used for temperature correction of tank pressures.
%   Instead of using Bonet temperature we'll now use panel temperature of
%   the Flow7 logger.
% Oct 23, 2009
%   - (finally!) commented out obselete bolic and bonet plots (Nick)
% Jan 12, 2005
%   - added plotting for net radiation above canopy 31m
% Jan 14, 2004
%   - added temperature compensation for tank pressure 
% Sept 16, 2003
%   - changed the structure for plotting gas tanks pressures. Plot reference tanks for all systems; Plot cals tanks;
%     Plot extra chamber tanks (David).
% Feb 1, 2002 - selected diagnostic info in this program  
% Jul 25, 2000
%   - added plotting of Profile and Chamber system ref. tank pressures
% Jun 5, 2000
%   - added TDR calibrations
% May 6, 2000
%   - changed axes
% Mar 5, 2000
%   - changed axes
% Dec 30 ,1999
%   - changes in biomet_path calling syntax.
% Nov 21, 1999
%   - added estimation of N2 usage (kPa/Week)
%   Sep 13, 1999
%       - added channel number changes for the Bonet4 (AES guys added channels
%         in the middle of the array - 37:PRT_Vent,  and 38:Tc_Vent
%   Jul 5, 1999
%       - axes changes
%   May 31, 1999
%       - corrected Rs up:  used to use a wrong channel (.9 instead of .10).
%   May 15, 1999
%       - introduced global paths (file biomet_path.m), removed LOCAL_PATH variable
%       - adjusted a few axes
%   Mar 20, 1999
%       - axis change (temp-limits)
%   Jan 1, 1999
%       - changes to alow for the new year (1999). The changes enabled
%         automatic handling of the "year" parameter.
%   Dec  6, 1998
%       - changed axes limits for the temp. measurements.
%   Nov 25, 1998
%			- added sonic heating temperatures
%			- added datalogger emerg power voltage
%   Nov  6, 1998
%       - removed plotting of w^T comparison and Closure (Eddy data logger hasn't been
%         measuring u,v,w,T since Oct 23.
%   Oct 14, 1998
%       - removed a few graphs that were not used 
%       - introduced WINTER_TEMP_OFFSET for one step rescaling of temperature axes in
%         the program

% more revisons at the end of file

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
    pth = biomet_path(year,'PA','cl');      % get the climate data path
    EddyPth = biomet_path(year,'PA','fl');  % get the flux data path
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

t=read_bor([ pth 'bonet_new\bntn_dt']);                  % get decimal time from the data base
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

if 1==1
    
%----------------------------------------------------------
% Air Temperatures at the top
%----------------------------------------------------------
trace_name  = 'Met-One air temperatures at the top (36 m)';
trace_path  = str2mat([pth 'bonet_new\bntn.24'],[pth 'bonet_new\bntn.37'],[pth 'bonet_new\bntn.38'],[pth 'OA8\OA8_2.16'],[pth 'OA8\OA8_2.11'],[pth 'OAN\OAN.8']);
trace_legend= str2mat('HMPVnt','PRTVnt','TcVnt','isolated Tc 36m','profile 37m','T_{CNR1}');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
zoom on;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Temperature profile using HMP data
%----------------------------------------------------------
trace_name  = 'Temperature profile using HMP data';
%trace_path  = str2mat([pth 'bonet_new\bntn.24'],[pth 'bonet_new\bntn.26'],[pth 'bonet_new\bntn.27'],[pth 'bonet_new\bntn.28']);
trace_path  = str2mat([pth 'OA8\OA8_2.11'],[pth 'bonet_new\bntn.26'],[pth 'bonet_new\bntn.27'],[pth 'OA8\OA8_2.12']);
trace_legend= str2mat('37m','18m','xxm','0.5m');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
zoom on;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% RH profile using HMP data
%----------------------------------------------------------
trace_name  = 'RH profile using HMP data';
%trace_path  = str2mat([pth 'bonet_new\bntn.29'],[pth 'bonet_new\bntn.31'],[pth 'bonet_new\bntn.32'],[pth 'bonet_new\bntn.33'],[pth 'bonet_new\bntn.35']);
trace_path  = str2mat([pth 'OA8\OA8_2.13'],[pth 'bonet_new\bntn.31'],[pth 'bonet_new\bntn.32'],[pth 'OA8\OA8_2.14'],[pth 'bonet_new\bntn.35']);
trace_legend= str2mat('36m','18m','xxm','0.5m','RotRH');
trace_units = '(%)';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Datalogger Battery voltages
%----------------------------------------------------------
trace_name  = 'Flow Datalogger and Emergency Battery Voltages';
trace_path  = str2mat([pth 'flow\flow.8'],[pth 'flow\flow.5'],[pth 'flow\flow.6'],[pth 'pcctrl2\pcct.6']);
trace_legend= str2mat('Min','Avg','Max','Backup Avg');
trace_units = 'volts';
y_axis      = [11.7 13];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Datalogger Battery voltages
%----------------------------------------------------------
trace_name  = 'Datalogger Voltages';
trace_path  = str2mat([pth 'flow\flow.5'],[pth 'bonet_new\bntn.6'],[pth 'OAN\OAN.6'],...
                      [pth 'OAW\OAW.6'],[pth 'OA8\OA8_2.6'],[pth 'Tower\tower.6'],[pth 'OAT2\Batt_volt_Avg'],...
                       [pth 'OALW\OALW.5'],[pth 'OAMPS\OAMPS.5']);
trace_legend= str2mat('Flow (tanks)','Bonet (metCR7)','OAN (CNR1)','OAW (SnowT)','OA8 (met23X)','Tower (samptube)','OAT2',...
                       'OALW','OAMPS');
trace_units = 'volts';
y_axis      = [10 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Phone-box temperature
%-----------------------------------
trace_name  = 'Phone-box temperature';
trace_path  = 'flow\flow.21';
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

if 1==0
%-----------------------------------
% Solenoid Box Temperature
%-----------------------------------
trace_name  = 'Solenoid Box Temperature';
trace_path  = str2mat([pth 'tower\tower.11'],[pth 'tower\tower.21'],[pth 'tower\tower.31']);
trace_legend = str2mat('Avg','Min','Max');
trace_units = '(deg)';
y_axis      = [10 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end

%-----------------------------------
% PowerBox temperature
%-----------------------------------
trace_name  = 'PowerBox temperature';
trace_path  = 'flow\flow.22';
trace_units = '(degC)';
y_axis      = [10 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sampling tube temperatures
%----------------------------------------------------------
trace_name  = 'Sampling tube temperatures';
% Shawn O'Neill 20040831 Changed Air Temp pth to bntn.26
%trace_path  = str2mat([pth 'tower\tower.12'],[pth 'tower\tower.13'],[pth 'tower\tower.14'],[pth 'tower\tower.15'],[pth 'tower\tower.16'],[pth 'bonet_new\bntn.24'],[pth 'tower\tower.21']);
trace_path  = str2mat([pth 'tower\tower.12'],[pth 'tower\tower.13'],[pth 'tower\tower.14'],[pth 'tower\tower.15'],[pth 'tower\tower.16'],[pth 'bonet_new\bntn.26'],[pth 'tower\tower.21']);
trace_legend = str2mat('Funnel','0.3m','1.75m','boxIN','LIC.IN','air Temp','min.boxT');
trace_units = 'degC';
y_axis      = [0 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Hut temperatures
%-----------------------------------
trace_name  = 'Hut temperatures';
trace_path  = str2mat([pth 'bonet_new\bntn.36'],[pth 'aessoil\soil.7']);
trace_legend= str2mat('Hut A','Hut B');
trace_units = '(degC)';
y_axis      = [10 70] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

if 1==0
%-----------------------------------
% Sonic Heater temperatures
%-----------------------------------
trace_name  = 'Sonic Heater Temperatures';
trace_path  = str2mat([pth 'tower\tower.7'],[pth 'tower\tower.46'],[pth 'tower\tower.49']);
trace_legend= str2mat('Sonic TC','Heater Box TC','Hinge TC');
trace_units = '(degC)';
y_axis      = [0 50] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end


%----------------------------------------------------------
% Barometric Pressure 
%----------------------------------------------------------
trace_name  = 'Barometric Pressure';
trace_path  = str2mat([pth 'PCCTRL2\pcct.5'],[pth 'bonet_new\bntn.44']);
trace_legend= str2mat('PCCTL2','OA7');
trace_units = '(kPa)';
y_axis      = [80 110] ;
fig_num = fig_num + fig_num_inc;
zoom on;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 0.1],[0 0] );
if pause_flag == 1;pause;end

%-----------------------------------
% Reference tank pressures
%-----------------------------------
trace_name  = 'Reference tank pressures';
%trace_path  = str2mat([pth 'flow\flow.17'],[pth 'flow\flow.27'],[pth 'flow\flow.28']);
T_hut = read_bor([pth 'flow\flow.11']);
T_hut = T_hut(ind);
indx = find(T_hut == 0);
indy = find(T_hut ~= 0);
T_hut(indx) = mean(T_hut(indy));
Tc = 290 ./(T_hut + 273.15);
P_ref_eddy = read_bor([pth 'flow\flow.17']);
P_ref_eddy = P_ref_eddy(ind);
P_ref_prof = read_bor([pth 'flow\flow.27']);
P_ref_prof = P_ref_prof(ind);
P_ref_cham = read_bor([pth 'flow\flow.28']);
P_ref_cham = P_ref_cham(ind);
trace_path = [P_ref_eddy.* Tc P_ref_prof.* Tc P_ref_cham.* Tc ];
trace_legend= str2mat('RefRight','RefLeft','Chamber');
trace_units = '(psi)';
y_axis      = [0 2500];
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
zoom on;
if pause_flag == 1;pause;end

%-----------------------------------
% Calibration tank pressures
%-----------------------------------
trace_name  = 'Calibration tank pressures';
%trace_path  = str2mat([pth 'flow\flow.18'],[pth 'flow\flow.19']);
P_cal0 = read_bor([pth 'flow\flow.18']);
P_cal1 = read_bor([pth 'flow\flow.19']);
trace_path = [P_cal0(ind).* Tc P_cal1(ind).* Tc];
trace_legend= str2mat('Cal0','Cal1');
trace_units = '(psi)';
y_axis      = [0 2200];
fig_num = fig_num + fig_num_inc;
x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Chamber extra tank pressures
%-----------------------------------
% trace_name  = 'Tank Pressure: 10% CO2 ';
% %trace_path  = str2mat([pth 'flow\flow.20']);
% P_cham = read_bor([pth 'flow\flow.20']);
% trace_path = [P_cham(ind).* Tc];
% trace_legend= str2mat('Ch 10% CO2');
% trace_units = '(psi)';
% y_axis      = [0 2200];
% fig_num = fig_num + fig_num_inc;
% x_all = plt_msig(trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end

%-----------------------------------
% Ref. gas tank pressure
%-----------------------------------
%trace_name  = 'Ref. gas tank pressure';
%trace_path  = 'flow\flow.17';
%trace_units = '(kPa)';
%y_axis      = [0 2200];
%fig_num = fig_num + fig_num_inc;
%[x,tx] = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
%ref_lim = 400;                              % lower limit for the ref. gas tank-pressure
%index = find(x >= 0 & x <=2500);
%px = polyfit(x(index),tx(index),1);         % fit first order polynomial
%px = polyval(px,ref_lim);                   % return DOY when tank is going to hit lower limit
%ax = axis;
%text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Low limit(%5.1f) will be reached on DOY = %4.0f',ref_lim,px));
%if pause_flag == 1;pause;end
%-----------------------------------
% Cal. zero gas tank pressure
%-----------------------------------
%trace_name  = 'Cal. zero gas tank pressure';
%trace_path  = 'flow\flow.18';
%trace_units = '(kPa)';
%y_axis      = [1200 1600];
%fig_num = fig_num + fig_num_inc;
%x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end
%-----------------------------------
% Cal. 335ppm gas tank pressure
%-----------------------------------
%trace_name  = 'Cal. 335ppm gas tank pressure';
%trace_path  = 'flow\flow.19';
%trace_units = '(kPa)';
%y_axis      = [1600 2000];
%fig_num = fig_num + fig_num_inc;
%x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end
%-----------------------------------
% Cal. 450ppm gas tank pressure
%-----------------------------------
%trace_name  = 'Cal. 450ppm gas tank pressure';
%trace_path  = 'flow\flow.20';
%trace_units = '(kPa)';
%y_axis      = [1600 2000];
%fig_num = fig_num + fig_num_inc;
%x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% LICOR heater/fan duty cycles
%----------------------------------------------------------
% trace_name  = 'LICOR heater/fan duty cycles';
% trace_path  = str2mat([pth 'bolic2\bol2.21'],[pth 'bolic2\bol2.22']);
% trace_legend = str2mat('Heater','Fan');
% trace_units = '(%)';
% y_axis      = [-10 120];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[100 100]);
% if pause_flag == 1;pause;end
% 
% %-----------------------------------
% % Bolic2: Sample cell gauge pressure
% %-----------------------------------
% trace_name  = 'Bolic2: Sample cell gauge pressure';
% trace_path  = 'bolic2\bol2.11';
% trace_units = '(kPa)';
% y_axis      = [12 20];
% fig_num = fig_num + fig_num_inc;
% x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
%-----------------------------------
% Bolic2: Reference cell gauge pressure
%-----------------------------------
%trace_name  = 'Bolic2: Reference cell gauge pressure';
%trace_path  = 'bolic2\bol2.12';
%trace_units = '(kPa)';
%y_axis      = [-20 20];
%fig_num = fig_num + fig_num_inc;
%x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Rain 
%----------------------------------------------------------
% trace_name  = 'Rain';
% trace_path  = str2mat([pth 'bonet_new\bntn.45']);
% trace_units = '(mm)';
% y_axis      = [-1 10];
% fig_num = fig_num + fig_num_inc;
% x = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative rain
%----------------------------------------------------------
% indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
% tx = t_all(indx);                                           % the beginning of the year
% 
% trace_name  = 'Cumulative rain';
% y_axis      = [];
% ax = [st ed];
% [x,tx_new] = read_sig(trace_path, indx,year, tx,0);
% 
% fig_num = fig_num + fig_num_inc;
% plt_sig1( tx_new, cumsum(x), trace_name, year, trace_units, ax, y_axis, fig_num );
% if pause_flag == 1;pause;end

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

%-----------------------------------
% Net radiation
%-----------------------------------
% trace_name  = 'Net-radiation (Middleton)';
% trace_path  = 'bonet_new\bntn.7';
% trace_units = '(W/m^2)';
% y_axis      = [-100 1000];
% fig_num = fig_num + fig_num_inc;
% x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%-----------------------------------
% CNR1
%-----------------------------------
trace_name  = 'CNR1 4-way components';
% trace_path  = str2mat([pth 'OBN\OBN.8'],[pth 'OBN\OBN.9'], ...
%                       [pth 'OBN\OBN.12'],[pth 'OBN\OBN.13'],...
%                       [pth 'BS_23x_5\Rn_Bm_AVG'] );
swd = read_bor([pth 'OAN\OAN.9']);
swu = read_bor([pth 'OAN\OAN.10']);
lwd = read_bor([pth 'OAN\OAN.11']);
lwu = read_bor([pth 'OAN\OAN.12']);
T_CNR1 = read_bor([pth 'OAN\OAN.8']);
LongWaveOffset =(5.67E-8*(273.15+T_CNR1).^4);
lwd_corr = lwd+LongWaveOffset;
lwu_corr = lwu+LongWaveOffset;
%RnMid = read_bor([pth 'bonet_new\bntn.7']);
RnCNR1 = swd-swu + lwd_corr-lwu_corr;
trace_legend= str2mat('swdw','swuw','lwdw','lwuw','lwdw_{corr}','lwuw_{corr}','Rn_{CNR1}');
trace_units = 'W m^{-2} s^{-1}';
y_axis      = [ -200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( [swd swu lwd lwu lwd_corr lwu_corr RnCNR1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Net radiation
%-----------------------------------
% trace_name  = 'Net-Radiation Above Canopy 31m';
% trace_path  = 'Net_Rad_AbvCnpy_31m';
% trace_units = '(W/m^2)';
% backSlash = findstr(pth, '\');
% NetRadpath = strcat(pth(1:backSlash(end-1)), 'BERMS\al1\')
% y_axis      = [-100 1000];
% fig_num = fig_num + fig_num_inc;
% x = plt_sig( [NetRadpath trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%-----------------------------------
% PARs down at 36m, 4m
%-----------------------------------
trace_name  = 'PAR Above and Below Canopy';
trace_path  = str2mat([pth 'OA8\OA8_2.8'],[pth 'OA8\OA8_2.9'],[pth 'OA8\OA8_2.10'],...
                      [pth 'bonet_new\bntn.55'], [pth 'bonet_new\bntn.56'] );
trace_legend= str2mat('36 m','4 m SW','4 m NE','BF2_{TOT}','BF2_{DIF}');
trace_units = '(umol m-2 s-1)';
y_axis      = [ -50 2200];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Radiation components from Eppley's and CM11's
%-----------------------------------
trace_name  = 'Radiation components from Eppley and CM11';
trace_path  = str2mat([pth 'bonet_new\bntn.8'],[pth 'bonet_new\bntn.9'],[pth 'bonet_new\bntn.10'],...
                      [pth 'bonet_new\bntn.11'],[pth 'bonet_new\bntn.12'],[pth 'bonet_new\bntn.15'],...
                       [pth 'bonet_new\bntn.16']);
                   
 %  ** LW upwelling raw and compensated channels might be 
 %     wired in reverse to what is labelled in the MSC logger programs:
 %     Nick, Nov 29, 2013
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
trace_legend= str2mat('swd CM11 Top','swd Eppley Top','swu CM11 Boom','lwd Epp Top (comp)',...
                      'lwd Epp Top (raw)','lwu Epp Boom (raw)','lwu Epp Boom (comp)');
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Resistances from Eppley PIRs
%-----------------------------------
trace_name  = 'Thermistor Resistances from Eppley PIRs';
trace_path  = str2mat([pth 'bonet_new\bntn.13'],[pth 'bonet_new\bntn.14'],[pth 'bonet_new\bntn.17'],...
                      [pth 'bonet_new\bntn.18']);
trace_units = '\Omega';
y_axis      = [0 200];
trace_legend= str2mat('Top Body','Top Dome','Boom Body','Boom Dome');
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Net Radiation comparison
%-----------------------------------
trace_name  = 'Net Radiation comparison';
trace_units = '(W/m^2)';
y_axis      = [-50 1000];
RnMid = read_bor([pth 'OA8\OA8_2.7']);
swdx = read_bor([pth 'bonet_new\bntn.8']);
swux = read_bor([pth 'bonet_new\bntn.10']);
lwdx = read_bor([pth 'bonet_new\bntn.12']); % use raw thermopile lwd
lwux = read_bor([pth 'bonet_new\bntn.15']); %**using compensated lwu
                                            %  upwelling raw and compensated channels might be 
                                            %  wired in reverse to what is labelled in the MSC logger programs
RnComp = swdx-swux + lwdx-lwux;
fig_num = fig_num + fig_num_inc;
if year>= 2012
    trace_name  = 'Net Radiation comparison';
    trace_legend= str2mat('CNR1 (calculated)','Middleton (Boom)','components');
x = plt_msig( [ RnCNR1 -RnMid RnComp], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
else
    trace_name  = 'Net Radiation Middleton';
    x = plt_msig( [ -RnMid], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
if pause_flag == 1;pause;end


%---------------------------------------------------------------
% Soil heat-flux plates
%---------------------------------------------------------------
trace_name  = 'Soil heat-flux plates';
trace_path  = str2mat([pth 'aessoil\soil.16'],[pth 'aessoil\soil.17'],[pth 'aessoil\soil.18'],[pth 'aessoil\soil.19'],...
                     [pth 'aessoil\soil.20'],[pth 'aessoil\soil.21'],[pth 'aessoil\soil.22'],...
                     [pth 'aessoil\soil.23'],[pth 'aessoil\soil.24'],...
                     [pth 'aessoil\soil.25']);
trace_legend= str2mat('S1','S2','S3','S4','S5','S6','S7','S8','S9','S10');
trace_units = '(W/m^2)';
y_axis      = [-20 60] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1 1 1 1 1 1], [0 0 0 0 0 0 0 0 0 0]);
if pause_flag == 1;pause;end


%-----------------------------------
% RM Young wind speeds
%-----------------------------------
trace_name  = 'RM Young wind speeds';
trace_path  = str2mat([pth 'bonet_new\bntn.48'],[pth 'OA8a\OA8a.11']);
trace_legend = str2mat('38m','3m (Rain)');
trace_units = '(m/2)';
y_axis      = [-2 15];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% RM Young wind directions
%-----------------------------------
trace_name  = 'RM Young wind directions (38m)';
trace_path  = str2mat([pth 'bonet_new\bntn.49'],[pth 'bonet_new\bntn.53']);
trace_legend = str2mat('D1','DU');
trace_units = '(deg)';
y_axis      = [-10 370];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end

if 1==2
%-----------------------------------
% Bolic2: CO2
%-----------------------------------
trace_name  = 'Bolic2: CO2';
trace_path  = 'bolic2\bol2.5';
trace_units = '(umol/mol)';
y_axis      = [330 380];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Bolic2: H2O
%-----------------------------------
trace_name  = 'Bolic2: H2O';
trace_path  = 'bolic2\bol2.6';
trace_units = '(mmol/mol)';
y_axis      = [-5 25];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Bolic2: Sample cell air temp.
%-----------------------------------
trace_name  = 'Bolic2: Sample cell air temp.';
trace_path  = 'bolic2\bol2.8';
trace_units = '(degC)';
y_axis      = [24 32];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end


if 0
%-----------------------------------
% Bolic2: Metal box air temp.
%-----------------------------------
trace_name  = 'Bolic2: Metal box air temp.';
trace_path  = 'bolic2\bol2.9';
trace_units = '(degC)';
y_axis      = [32 38];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Bolic2: Optical bench temp.
%-----------------------------------
trace_name  = 'Bolic2: Optical bench temp.';
trace_path  = 'bolic2\bol2.10';
trace_units = '(degC)';
y_axis      = [38 42];
fig_num = fig_num + fig_num_inc;
x = plt_sig( [pth trace_path], ind,trace_name, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%---------------------------------------------------------------
% Temperature comparison: HMP, PRT, thermocouple and Gill at 36m
%---------------------------------------------------------------
trace_name  = 'Temperature comparison';
%if LOCAL_PAOA==1
trace_path  = str2mat([pth 'bonet_new\bntn.24'],[pth 'eddy\eddy.12'], [pth 'bonet_new\bntn.34'], [pth 'bonet_new\bntn.37'], [pth 'bonet_new\bntn.38']);
trace_legend= str2mat('HMP','TC','Tair','PRT_{Vent}','Tc_{Vent}');
%else
%    trace_path  = str2mat([pth 'bonet_new\bntn.24'],[pth 'eddy\eddy.12'], [EddyPth 'paoa_8.2_2'],[pth 'bonet_new\bntn.34']);
%    trace_legend= str2mat('HMP','TC','Gill','Tair');
%end
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1], [0 273.16 0 0 0] );
if pause_flag == 1;pause;end
if 0
%---------------------------------------------------------------
% w^T comparison: Thermocouple and Gill at 36m
%---------------------------------------------------------------
trace_name  = 'w^T comparison';
%if LOCAL_PAOA == 1
trace_path  = str2mat([pth 'eddy\eddy.42'],[pth 'eddy\eddy.31']);
trace_legend= str2mat('TC','Gill');
%else
%    trace_path  = str2mat([pth 'eddy\eddy.42'],[pth 'eddy\eddy.31'], [EddyPth 'paoa_45.2_2']);
%    trace_legend= str2mat('TC','Gill','GillPC');
%end
trace_units = '(degC m/s)';
y_axis      = [-0.1 0.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end


if 0 
%---------------------------------------------------------------
% Closure 1 (plot H, LE, Rn)
%---------------------------------------------------------------
trace_name  = 'Closure';
%if LOCAL_PAOA == 1
trace_path  = str2mat([pth 'bonet_new\bntn.7'],[pth 'eddy\eddy.42']);
trace_legend= str2mat('Rn','Htc');
%else
%    trace_path  = str2mat([EddyPth 'paoa_81.2_2'],[EddyPth 'paoa_82.2_2'], [pth 'bonet_new\bntn.7'],[pth 'eddy\eddy.42']);
%    trace_legend= str2mat('H','LE','Rn','Htc');
%end
trace_units = '(W/m^2)';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1150], [0 0 0 0]);
if pause_flag == 1;pause;end
end

%---------------------------------------------------------------
% Closure 2 (plot H+LE, Rn)
%---------------------------------------------------------------
% trace_name  = 'Closure';
% H  = read_bor([EddyPth 'paoa_81.2_2']);
% LE = read_bor([EddyPth 'paoa_82.2_2']);
% trace_path  = str2mat(H+LE, [pth 'bonet\bnt.7']);
% trace_legend= str2mat('H+LE','Rn');
% trace_units = '(W/m^2)';
% y_axis      = [-200 1000];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end
if 0
    %---------------------------------------------------------------
    % LE LICOR vs Krypton 
    %---------------------------------------------------------------
    trace_name  = 'LE LICOR vs Krypton';
    trace_path  = str2mat([EddyPth 'paoa_82.2_2'],[EddyPth 'paoa_83.2_2']);
    trace_legend= str2mat('LE 6262','LE KH2O');
    trace_units = '(W/m^2)';
    y_axis      = [-100 600];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1], [0 0 0 0]);
    if pause_flag == 1;pause;end
end
%----------------------------------------------------------
% Temperature profile using HMP data
%----------------------------------------------------------
trace_name  = 'Temperature profile using HMP data';
trace_path  = str2mat([pth 'bonet_new\bntn.24'],[pth 'bonet_new\bntn.26'],[pth 'bonet_new\bntn.27'],[pth 'bonet_new\bntn.28']);
trace_legend= str2mat('36m','18m','xxm','0.5m');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Tree temperatures (17m)
%----------------------------------------------------------
trace_name  = 'Tree temperatures (17m)';
trace_path  = str2mat([pth 'tower\tower.37'],[pth 'tower\tower.38'],[pth 'tower\tower.39']);
trace_legend= str2mat('Tc_1','Tc_2','Tc_3');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%----------------------------------------------------------
% Barometric pressure
%----------------------------------------------------------
trace_name  = 'Barometric pressure';
trace_path  = str2mat([pth 'pcctrl2\pcct.5'],[pth 'bonet_new\bntn.44']);
trace_legend= str2mat('UBC','AES');
trace_units = '(kPa)';
y_axis      = [90 98];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 0.1] );
end

%----------------------------------------------------------
% Tree temperatures (3m)
%----------------------------------------------------------
trace_name  = 'Tree temperatures (3m)';
trace_path  = str2mat([pth 'aessoil\soil.64'],[pth 'aessoil\soil.65'],[pth 'aessoil\soil.66'],[pth 'aessoil\soil.67'],[pth 'aessoil\soil.68']);
trace_legend= str2mat('s_{bottom}','s_{middle}','s_{top}','north_{top}','n_{bottom}');
trace_units = '(degC)';
y_axis      = [0 35] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% TBRG near Belfort
%----------------------------------------------------------
try
 trace_name  = 'TBRG near Bel3000';
 trace_path  = str2mat([pth 'OA8a\OA8a.8'],[pth 'BONET_new\bntn.58'],[pth 'OALW\OALW.10']);
 trace_units = '(mm)';
 tbrg=read_bor(fullfile(pth,'OA8a\OA8a.8'));
 LW_msc=read_bor(fullfile(pth,'BONET_new\bntn.58'));
 Rs=read_bor(fullfile(pth,'OALW\OALW.10'));
 Rs(Rs==0.)=NaN;
 LW_JM=500.*(1./(Rs+101)); % obtain VsVx and use MSC rescaling formula to plot
 trace_legend= str2mat('TBRG','MSC CSI 237','Jilmarie CSI 237');
 y_axis      = [0 10];
 fig_num = fig_num + fig_num_inc;
 %x = plt_msig(trace_path, ind,trace_name,trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1]);
 x = plt_msig([tbrg LW_msc LW_JM], ind,trace_name,trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1]);
 if pause_flag == 1;pause;end
catch
    disp('**** => Failed plotting TBRG near Bel3000');
end

%----------------------------------------------------------
% Belfort 3000
%----------------------------------------------------------
 trace_name  = 'Bel3000';
 trace_path  = str2mat([pth 'OA8a\OA8a.7']);
 trace_units = '(mm)';
 y_axis      = [0 500];
 fig_num = fig_num + fig_num_inc;
 x = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
 if pause_flag == 1;pause;end

 %----------------------------------------------------
 % Leaf Wetness sensors
 %----------------------------------------------------
 
 trace_name  = 'Decagon Leaf Wetness Sensor';
 trace_path  = str2mat([pth 'OALW\OALW.11'],[pth 'OALW\OALW.15'],[pth 'OALW\OALW.19']);
 trace_units = 'mV';
 trace_legend= str2mat('AVG','MAX','MIN');
 y_axis      = [0 500];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig(trace_path, ind,trace_name,trace_legend, year, trace_units, y_axis, t, fig_num );
 if pause_flag == 1;pause;end
 
%-----------------------------------
% MPS sensor temps
%-----------------------------------
trace_name  = 'MPS Sensors: Temperatures';
trace_path  = str2mat([pth 'OAMPS\OAMPS.8'],[pth 'OAMPS\OAMPS.10'],[pth 'OAMPS\OAMPS.12'],...
                      [pth 'OAMPS\OAMPS.14'], [pth 'OAMPS\OAMPS.16'],[pth 'OAMPS\OAMPS.17'] );
trace_legend= str2mat('MPS1','MPS2','MPS3','MPS4','MPS5','IR Thermometer');
trace_units = '(\circC)';
y_axis      = [ -30 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% MPS sensors
%-----------------------------------
trace_name  = 'MPS Sensors';
trace_path  = str2mat([pth 'OAMPS\OAMPS.7'],[pth 'OAMPS\OAMPS.9'],[pth 'OAMPS\OAMPS.11'],...
                      [pth 'OAMPS\OAMPS.13'], [pth 'OAMPS\OAMPS.15'] );
trace_legend= str2mat('MPS1','MPS2','MPS3','MPS4','MPS5');
trace_units = '(kPa)';
y_axis      = [ -30 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

 


 %----------------------------------------------------------
% Raw Snow Depth at Belfort 3000 clearing
%----------------------------------------------------------
 trace_name  = 'Raw Snow Depth near Bel3000';
 trace_path  = str2mat([pth 'OA8a\OA8a.14'],[pth 'OAW\OAW.42']);
 trace_legend= str2mat('OAP','OAW');
 trace_units = '(mm)';
 y_axis      = [0 2000];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
 %x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[ -1 -1 ],[-2600 -1200] );
 if pause_flag == 1;pause;end
 

 %----------------------------------------------------------
% Snow Depth at Belfort 3000 clearing
%----------------------------------------------------------
 trace_name  = 'Corrected Snow Depth near Bel3000';
 trace_path  = str2mat([pth 'OA8a\OA8a.9'],[pth 'OAW\OAW.41']);
 trace_legend= str2mat('OAP','OAW');
 trace_units = '(mm)';
 y_axis      = [0 2700];
 fig_num = fig_num + fig_num_inc;
 %x = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
 x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[ -1 -1 ],[-1350 -1250] );
 if pause_flag == 1;pause;end
 
 %----------------------------------------------------------
% CSI-107 probes Tair for snowdepth correction
%----------------------------------------------------------
trace_name  = 'CSI-107 probes Tair for snowdepth correction';
trace_path  = str2mat([pth 'OA8a\OA8a.13'],[pth 'OAW\OAW.40']);
trace_legend= str2mat('OAP','OAW');
trace_units = '(\circC)';
y_axis      = [-40 30] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 ],[0 273.15 ]);
if pause_flag == 1;pause;end

%-----------------------------------
% Snow Tc Stake NorthEast
%-----------------------------------
trace_name  = 'OAW Snow Tc profile (NE)';

Tref1=read_bor(fullfile(pth,'OAW\OAW.7'));

TsnNE1=read_bor(fullfile(pth,'OAW\OAW.8'));
TsnNE2=read_bor(fullfile(pth,'OAW\OAW.9'));
TsnNE5=read_bor(fullfile(pth,'OAW\OAW.10'));
TsnNE10=read_bor(fullfile(pth,'OAW\OAW.11'));
TsnNE20=read_bor(fullfile(pth,'OAW\OAW.12'));
TsnNE30=read_bor(fullfile(pth,'OAW\OAW.13'));
TsnNE40=read_bor(fullfile(pth,'OAW\OAW.14'));
TsnNE50=read_bor(fullfile(pth,'OAW\OAW.15'));

trace_legend= str2mat('1 cm','2 cm','5 cm','10 cm','20 cm','30 cm','40 cm','50 cm');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( [TsnNE1 TsnNE2 TsnNE5 TsnNE10 TsnNE20 TsnNE30 TsnNE40 TsnNE50], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Snow Tc Stake NorthWast
%-----------------------------------
trace_name  = 'OAW Snow Tc profile (NW)';

TsnNW1=read_bor(fullfile(pth,'OAW\OAW.16'));
TsnNW2=read_bor(fullfile(pth,'OAW\OAW.17'));
TsnNW5=read_bor(fullfile(pth,'OAW\OAW.18'));
TsnNW10=read_bor(fullfile(pth,'OAW\OAW.19'));
TsnNW20=read_bor(fullfile(pth,'OAW\OAW.20'));
TsnNW30=read_bor(fullfile(pth,'OAW\OAW.21'));
TsnNW40=read_bor(fullfile(pth,'OAW\OAW.22'));
TsnNW50=read_bor(fullfile(pth,'OAW\OAW.23'));

trace_legend= str2mat('1 cm','2 cm','5 cm','10 cm','20 cm','30 cm','40 cm','50 cm');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( [TsnNW1 TsnNW2 TsnNW5 TsnNW10 TsnNW20 TsnNW30 TsnNW40 TsnNW50], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% TDRs
%----------------------------------------------------------
% trace_name  = 'TDRs';
% trace_units = '????';
% tx_tdr = read_bor([pth 'tdr\tdr_10_min_data\tdrn2_dt'])+ 1 - GMTshift;
% ind_tdr = find(tx_tdr >=st & tx_tdr<=ed);
% tx_tdr = tx_tdr(ind_tdr);
% x2 = read_bor([pth 'tdr\tdr_10_min_data\tdrn2.7']);
% x2 = x2(ind_tdr);
% x3 = read_bor([pth 'tdr\tdr_10_min_data\tdrn3.7']);
% x3 = x3(ind_tdr);
% x4 = read_bor([pth 'tdr\tdr_10_min_data\tdrn4.7']);
% x4 = x4(ind_tdr);
% x5 = read_bor([pth 'tdr\tdr_10_min_data\tdrn5.7']);
% x5 = x5(ind_tdr);
% x = polyval([0.0297 0.033],[x2 x3 x4 x5]);
% 
% 
% y_axis      = [];
% ax = [st ed];
% 
% fig_num = fig_num + fig_num_inc;
% plt_sig1( tx_tdr, x, trace_name, year, trace_units, ax, y_axis, fig_num,'.' );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Alan's soil temperatures
%----------------------------------------------------------
% trace_name  = 'Soil temperatures (AES sensors)';
% trace_path  = str2mat([pth 'bonet_new\bntn.39'],[pth 'bonet_new\bntn.40'],[pth 'bonet_new\bntn.41'],[pth 'bonet_new\bntn.42'],[pth 'bonet_new\bntn.43']);
% trace_legend= str2mat('2 cm','5 cm','10 cm','20 cm','50 cm');
% trace_units = '(degC)';
% y_axis      = [0 30] - WINTER_TEMP_OFFSET/2;
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% UBC soil temperatures
%----------------------------------------------------------
trace_name  = 'Soil temperatures (UBC sensors)';
trace_path  = str2mat([pth 'aessoil\soil.8'],[pth 'aessoil\soil.9'],[pth 'aessoil\soil.10'],[pth 'aessoil\soil.11'],[pth 'aessoil\soil.12'],[pth 'aessoil\soil.13']);
trace_legend= str2mat('0.02m','0.05m','0.10m','0.20m','0.50m','1.00m');
trace_units = '(degC)';
y_axis      = [0 30] - WINTER_TEMP_OFFSET/2;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% UBC IR thermometers
%----------------------------------------------------------
trace_name  = 'IR thermometers (UBC sensors)';
trace_path  = str2mat([pth 'aessoil\soil.14'],[pth 'aessoil\soil.15'],[pth 'OALW\OALW.12'],[pth 'OAMPS\OAMPS.17']);
trace_legend= str2mat('T_3 (0-3cm)','T_4 (0-3cm)','OALW','OAMPS');
trace_units = '(degC)';
y_axis      = [0 30] - WINTER_TEMP_OFFSET/2;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Alan's soil moisture
%----------------------------------------------------------
% trace_name  = 'Soil moisture (AES sensors)';
% trace_path  = str2mat([pth 'bonet_new\bntn3.6'],[pth 'bonet_new\bntn3.7'],[pth 'bonet_new\bntn3.8'],[pth 'bonet_new\bntn3.9'],[pth 'bonet_new\bntn3.10'],...
%                       [pth 'bonet_new\bntn3.11'],[pth 'bonet_new\bntn3.12'],[pth 'bonet_new\bntn3.13'],[pth 'bonet_new\bntn3.14'],[pth 'bonet_new\bntn3.15']);
% trace_path  = str2mat(trace_path,[pth 'bonet_new\bntn3.16']);       %,[pth 'bonet\bnt.48']);
% trace_legend = [];
% trace_units = 'm^3 m^{-3}';
% y_axis      = [-0.5 1.5];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

trace_name  = '4 hour Soil VWC: CS615 profile, N pit';
VWC2 = read_bor([pth 'bonet_new\bntn3.6']);
VWC7 = read_bor([pth 'bonet_new\bntn3.7']);
VWC22 = read_bor([pth 'bonet_new\bntn3.8']);
VWC45 = read_bor([pth 'bonet_new\bntn3.9']);
VWC60 = read_bor([pth 'bonet_new\bntn3.10']);
tv    = read_bor([pth 'bonet_new\bntn3_tv']);
indz= find(VWC2==0.);
VWC2(indz)=NaN;
VWC7(indz)=NaN;
VWC22(indz)=NaN;
VWC45(indz)=NaN;
VWC60(indz)=NaN;

fig_num = fig_num + fig_num_inc;
figure(fig_num);
plot(t,VWC2(ind),'rd',t,VWC7(ind),'bs',t,VWC22(ind),'go',t, VWC45(ind),'y^',....
     t,VWC60(ind),'m>','MarkerSize',10);
legend('2.5 cm','7.5 cm','22.5 cm','45 cm','60-90 cm');
ylabel('m^3 m^{-3}');
xlabel('DOY');
grid on;
set(gca,'YLim',[0 1]);
title(trace_name);
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',trace_name);

if pause_flag == 1;pause;end

% S pit

trace_name  = '4 hour Soil VWC: CS615 profile, S pit';
VWC2 = read_bor([pth 'bonet_new\bntn3.11']);
VWC7 = read_bor([pth 'bonet_new\bntn3.12']);
VWC22 = read_bor([pth 'bonet_new\bntn3.13']);
VWC45 = read_bor([pth 'bonet_new\bntn3.14']);
VWC60 = read_bor([pth 'bonet_new\bntn3.15']);
tv    = read_bor([pth 'bonet_new\bntn3_tv']);
indz= find(VWC2==0.);
VWC2(indz)=NaN;
VWC7(indz)=NaN;
VWC22(indz)=NaN;
VWC45(indz)=NaN;
VWC60(indz)=NaN;

fig_num = fig_num + fig_num_inc;
figure(fig_num);
plot(t,VWC2(ind),'rd',t,VWC7(ind),'bs',t,VWC22(ind),'go',t, VWC45(ind),'y^',....
     t,VWC60(ind),'m>','MarkerSize',10);
legend('2.5 cm','7.5 cm','22.5 cm','45 cm','60-90 cm');
ylabel('m^3 m^{-3}');
xlabel('DOY');
grid on;
set(gca,'YLim',[0 1]);
title(trace_name);
set(fig_num,'menubar','none',...
            'numbertitle','off',...
            'Name',trace_name);

if pause_flag == 1;pause;end

%--------------------------------
% OAT2 logger: TDR 'M' profile
%---------------------------------

trace_name  = 'OAT2 logger: VWC profile M';

trace_path  = str2mat([pth 'OAT2\VWC_M_2_5cm'],[pth 'OAT2\VWC_M_7_5cm'],[pth 'OAT2\VWC_M_0to15cm'],...
                       [pth 'OAT2\VWC_M_15to30cm'],[pth 'OAT2\VWC_M_30to60cm'],[pth 'OAT2\VWC_M_60to90cm'],...
                        [pth 'OAT2\VWC_M_90to120cm']);
trace_legend= str2mat('2.5cm','7.5cm','0to15cm','15to30cm','30to60cm','60to90cm','90to120cm');
trace_units = 'm3/m3';
y_axis      = [0 1];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%--------------------------------
% OAT2 logger: TDR 'N' profile
%---------------------------------

trace_name  = 'OAT2 logger: VWC profile N';

trace_path  = str2mat([pth 'OAT2\VWC_N_2_5cm'],[pth 'OAT2\VWC_N_7_5cm'],[pth 'OAT2\VWC_N_0to15cm'],...
                       [pth 'OAT2\VWC_N_15to30cm'],[pth 'OAT2\VWC_N_30to60cm'],[pth 'OAT2\VWC_N_60to90cm'],...
                        [pth 'OAT2\VWC_N_90to120cm']);
trace_legend= str2mat('2.5cm','7.5cm','0to15cm','15to30cm','30to60cm','60to90cm','90to120cm');
trace_units = 'm3/m3';
y_axis      = [0 1];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%--------------------------------
% OAT2 logger: TDR 'N' profile
%---------------------------------

trace_name  = 'OAT2 logger: VWC profile S';

trace_path  = str2mat([pth 'OAT2\VWC_S_2_5cm'],[pth 'OAT2\VWC_S_7_5cm'],[pth 'OAT2\VWC_S_0to15cm'],...
                       [pth 'OAT2\VWC_S_15to30cm'],[pth 'OAT2\VWC_S_30to60cm'],[pth 'OAT2\VWC_S_60to90cm'],...
                        [pth 'OAT2\VWC_S_90to120cm']);
trace_legend= str2mat('2.5cm','7.5cm','0to15cm','15to30cm','30to60cm','60to90cm','90to120cm');
trace_units = 'm3/m3';
y_axis      = [0 1];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%--------------------------------
% OAT2 logger: Tc 'M' profile
%---------------------------------

trace_name  = 'OAT2 logger: Tc profile M';

trace_path  = str2mat([pth 'OAT2\TempC_M_2cm_Avg'],[pth 'OAT2\TempC_M_5cm_Avg'],[pth 'OAT2\TempC_M_10cm_Avg'],...
                       [pth 'OAT2\TempC_M_20cm_Avg'],[pth 'OAT2\TempC_M_50cm_Avg'],[pth 'OAT2\TempC_M_100cm_Avg']);
trace_legend= str2mat('2cm','5cm','10cm','20cm','50cm','100cm');
trace_units = 'degC';
y_axis      = [0 30] - WINTER_TEMP_OFFSET/2;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

if 0
    %----------------------------------------------------------
    % Gill R2: W
    %----------------------------------------------------------
    trace_name  = 'Gill R2: W';
    trace_path  = str2mat([EddyPth 'paoa_7.1_2']);
    trace_units = '(m/s)';
    y_axis      = [-1 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_sig(trace_path, ind,trace_name, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end

if 0
%----------------------------------------------------------
% Alan's net radiometer test
%----------------------------------------------------------
trace_name  = 'Net radiometers';
trace_path  = str2mat([pth 'bonet_new\bntn1.11'],[pth 'bonet_new\bntn1.12'],[pth 'bonet_new\bntn1.13'],[pth 'bonet_new\bntn1.14'],[pth 'bonet_new\bntn1.15']);
trace_legend = str2mat('Mid','SwT','NR Lite','RebsQ6','RebsQ7');
trace_units = '(W/m^2)';
y_axis      = [-300 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
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

%   Jun 17, 1998
%       -   corrected plotting of AES Setra (it measures milibars -> needed to be divided
%           by ten).
%   Jun 8, 1998
%       -   New Bonet data structure required changes in file name/path changes.
%   May 25, 1998
%       -   added solenoid box temperature graph
%       -   commented out individual pressure plots
%       -   made pressure plot of all pressures
%
%   May  4, 1998
%       -   new plots added (RH profile, Duty cycles for LICOR fan/heater, Bel3000,
%           RM_Young)
%   Apr 24,1998
%       -   fixed the plots created Apr 9. All the channels were shifted for one
%           due to CSI software/hardware error (AESSOIL data logger has an old PROM,
%           and EDLOG doesn't know anything about it. So the EDLOG assumes in *.fsl
%           that the second output variable is YEAR but the old PROM doesn't support
%           the year output, hence the shift). Every channel number given in the *.fsl
%           for AESSOIL needs to be reduced by one!
%   Apr 9, 1998
%       -   changed axes for for temperature traces & soil h.flux plates
%   Apr 4, 1998
%       -   changed EddyPth = "\\class\paoa\paoa\" instead of "\\boreas_003\paoa\"
%    Mar 27, 1998
%       -   changed the default graph colors do "colordef none"
%	 Mar 25, 1998
%       -   added TreeTC plots
%   Mar 16, 1998
%       -   changes at PAOA site
%       -   changed tank pressure and temperature measurements so
%           they reflect the sensor migration from BONET to FLOW
%       -   changed the limits for all the pressures (the data base
%           has now correct (positive pressures)
%
%		  Feb  8, 1998
%				-	fixed hut_b temperature channel number (it's soil.7 not soil.8, all
%					channel numbers are screwed by one because the old PROM - it cannot
%					show the year field!)
%
%		  Feb  6, 1998
%				-	added hut-temperature plot
%
%		  Feb  5, 1998
%				-	Added support for 1998 (program now defaults to 1998 instaed 1997)
%	
%		  Dec  2, 1997
%				-	added mfc data logger plotting (sampling tube temp., solenoid box temp.)
%		  Dec  1, 1997
%				- changed axis limits
%				- changed barometric pressure source file from bol1.7 to pcct.5
%		  Nov 18, 1997
%				changed some axis limits
%       Sep  8, 1997
%                       Added NET radiation test plot.
%       Aug  5, 1997
%                       Added Gill R2 w - plot
%       Jul  3, 1997
%                       Changed axis limits for LE and PAR_36
%       Jun 30, 1997
%                       Added automatic scrolling of the figures at the end.
%       Jun 27, 1997
%                       Changed axis range.
%       Jun 26, 1997
%                       PAR_NE_4m added in parallel to PAR_down_4m
%       Jun 17, 1997
%                       Introduced pause_flag - now program defaults to
%                       quick plotting if the user doesn't specify the
%                       pause_flag = 1.
%                       Added cumulative rain plot.
%       Jun 11, 1997
%                       Changed path     pth = '\\class\c\paoa\newdata\';
%                       to               pth = '\\class\paoa\newdata\';
%                       to enable running of this program from the network PCs other
%                       than \\BOREAS003
%       Jun  9, 1997
%                       Changed axis limits for CO2.
%       May 27, 1997
%                       Added plot for rain
%       May 24, 1997
%                       Changed axes limits for a few graphs
%       May 11, 1997
%                       Changed axes limits for a few graphs
%       May 4, 1997     Added tank replacement functions
%                       (see plotting of tank pressures)
%