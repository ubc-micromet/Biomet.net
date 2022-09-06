function [t,x] = paob_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = paob_pl(ind, year, select, fig_num_inc,pause_flag)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       May 15, 1999
%                           Last modification:  Nov 29, 2013
%

% Revisions:
% Nov 29, 2013 (Nick)
%   -added Epplet PIR traces for body and dome thermistor resistances (used for
%   sigma*T^4 corrections to net lwd and net lwu)
%   -also corrected T_CNR1 trace
% Jan 25, 2013
%   -corrected input filename for CM11 swu on the boom
% Aug 26, 2010
%   - Nick changed air temperature plot-- MSC moved channels without
%   telling us!
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
%trace_path  = str2mat([pth 'BS_CR7_3\BS_3.25'],[pth 'BS_CR7_3\BS_3.33']);
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.22'],[pth 'BS_CR7_3\BS_3.25'],[pth 'BS_CR7_3\BS_3.33'],[pth 'BS_CR7_3\BS_3.34'],...
                      [pth 'BS_23x_5\Tc_Ta_25m_AVG'],[pth 'OBN\OBN.20'] );
trace_legend= str2mat('HMP_top','HMP_{Vent}','PRT_{vent}','Tc_{Vent}','Tc_{25m}','T_{CNR1}');
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
trace_path  = str2mat([pth 'BS_23x_2\BS_2.14'],[pth 'BS_23x_2\BS_2.15'],[pth 'BS_23x_2\BS_2.16'],[pth 'BS_23x_2\BS_2.18']);
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
trace_name  = 'Datalogger Battery Voltages';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.6'],[pth 'BS_23x_1\BS_1.18'], ...
                      [pth 'BS_23x_1\BS_1.12'],[pth 'BS_23x_5\VBattery_AVG'],...
                       [pth 'BS_cr7_3\BS_3.6'],[pth 'OBN\OBN.6'],[pth 'OBT\OBT.6'],...
                       [pth 'OBLW\OBLW.5'],[pth 'OBMPS\OBMPS.5'] );
trace_legend= str2mat('BS1_Min','BS1_Avg','BS2_Max','OB8','OB7','OBN','OBT','OBLW','OBMPS');
trace_units = 'volts';
y_axis      = [10 15];
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
% Barometric pressures
%-----------------------------------
trace_name  = 'Barometric Pressures';
trace_path  = str2mat([pth 'OBT\OBT.74'],[pth 'BS_cr7_3\BS_3.59']);
trace_legend= str2mat('Setra 200 (OBT)','Setra 280 (OB7)');
trace_units = '(kPa)';
y_axis      = [80 120] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[0.1 1],[0 0] );
if pause_flag == 1;pause;end


%-----------------------------------
% Reference tank pressures
%-----------------------------------
trace_name  = 'Reference tank pressures';
trace_path  = str2mat([pth 'BS_23x_1\BS_1.10'],[pth 'BS_23x_1\BS_1.23'],[pth 'BS_23x_1\BS_1.30']);
trace_legend= str2mat('Eddy','Profile','Chamber');
trace_units = '(psi)';
y_axis      = [0 2600];
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
y_axis      = [0 2600];
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
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.22'],[pth 'BS_23x_5\HMP_T_1_AVG'],[pth 'BS_CR7_3\BS_3.24'],[pth 'BS_CR7_3\BS_3.25'],...
                      [pth 'BS_CR7_3\BS_3.33']);
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
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.26'],[pth 'BS_23x_5\HMP_RH_1_AVG'], ...
                      [pth 'BS_CR7_3\BS_3.28'],[pth 'BS_CR7_3\BS_3.29']);
trace_legend= str2mat('HMP1','HMP3','HMP5','HMPVnt_{top}');
trace_units = '(%)';
y_axis      = [-5 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative Precip Belfort
%----------------------------------------------------------
trace_name  = 'Precipitation';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.49'],[pth 'BS_23x_5\BS_23x_210.20'],[pth 'BS_23x_5\BS_23x_210.21'],...
                      [pth 'BS_23x_5\BS_23x_210.22']);
trace_legend= str2mat('Belf3000','Geonor1','Geonor2','Geonor3');
trace_units = '(mm)';
y_axis      = [0 1000] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Snow depth raw
%----------------------------------------------------------
trace_name  = 'Raw Snow Depth from SR50s';
trace_path  = str2mat([pth 'OBT\OBT.84'],[pth 'OBT\OBT.85'],[pth 'OBT\OBT.86']);
trace_legend= str2mat('Hut','NE soil moisture pit','NW soil moisture pit');
trace_units = '(mm)';
y_axis      = [0 1500] ;
fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-1250 -1350 -1200]);
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Snow depth corrected
%----------------------------------------------------------
trace_name  = 'Corrected Snow Depth from SR50s';
sndpNE_raw = read_bor(fullfile(pth,'OBT\OBT.85'));
sndpNW_raw = read_bor(fullfile(pth,'OBT\OBT.86'));
% use the CS107 nearest the hut to do the temp correction.
Tair_HutSnwDp = read_bor(fullfile(pth,'OBT\OBT.9'));
mult=Tair_HutSnwDp/273.15;
sndpNE = sqrt(mult).*sndpNE_raw;
sndpNW = sqrt(mult).*sndpNW_raw;
sndpHut = read_bor(fullfile(pth,'OBT\OBT.10'));
trace_legend= str2mat('Hut','NE soil moisture pit','NW soil moisture pit');
trace_units = '(mm)';
y_axis      = [0 1300];
fig_num = fig_num + fig_num_inc;
%x = plt_msig( [sndpHut sndpNE sndpNW], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-1200 -1200 -1200]);
x = plt_msig( [sndpHut sndpNE sndpNW], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-1250 -1300 -1380]);
if pause_flag == 1;pause;end

%----------------------------------------------------------
% CSI-107 probes Tair for snowdepth correction
%----------------------------------------------------------
trace_name  = 'CSI-107 probes Tair for snowdepth correction';
trace_path  = str2mat([pth 'OBT\OBT.9'],[pth 'OBT\OBT.12'],[pth 'OBT\OBT.15']);
trace_legend= str2mat('Hut','NE soil moisture pit','NW soil moisture pit');
trace_units = '(\circC)';
y_axis      = [-40 30] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1],[273.15 273.15 273.15]);
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Event Rainfall
%----------------------------------------------------------
trace_name  = 'TBRG Event Rainfall';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.48'],[pth 'BS_CR7_3\BS_3.57'],[pth 'OBLW\OBLW.13']);
trace_legend= str2mat('TBRG','MSC CSI 237','Jilmarie CSI 237');
%trace_legend= str2mat('Belf3000');
trace_units = '(mm)';
tbrg=read_bor(fullfile(pth,'BS_CR7_3\BS_3.48'));
LW_msc=read_bor(fullfile(pth,'BS_CR7_3\BS_3.57'));
Rs=read_bor(fullfile(pth,'OBLW\OBLW.13'));
Rs(Rs==0.)=NaN;
LW_JM=500.*(1./(Rs+101)); % obtain VsVx and use MSC rescaling formula to plot
y_axis      = [0 10] ;
fig_num = fig_num + fig_num_inc;
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[ 1 1 1] );
x = plt_msig([tbrg LW_msc LW_JM], ind,trace_name,trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1]);
if pause_flag == 1;pause;end

%----------------------------------------------------
 % Leaf Wetness sensors
 %----------------------------------------------------
 
 trace_name  = 'Decagon Leaf Wetness Sensor';
 trace_path  = str2mat([pth 'OBLW\OBLW.14'],[pth 'OBLW\OBLW.18'],[pth 'OBLW\OBLW.22']);
 trace_units = 'mV';
 trace_legend= str2mat('AVG','MAX','MIN');
 y_axis      = [0 500];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig(trace_path, ind,trace_name,trace_legend, year, trace_units, y_axis, t, fig_num );
 if pause_flag == 1;pause;end

%----------------------------------------------------------
% Water Table Depth
%----------------------------------------------------------
trace_name  = 'Druck 1230 soil water table transducer';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.47']);
trace_units = '(mm)';
y_axis      = [0 2500] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% MPS sensor temps
%-----------------------------------
trace_name  = 'MPS Sensors: Temperatures';
trace_path  = str2mat([pth 'OBMPS\OBMPS.8'],[pth 'OBMPS\OBMPS.10'],[pth 'OBMPS\OBMPS.12'],...
                      [pth 'OBMPS\OBMPS.14'], [pth 'OBMPS\OBMPS.16'],[pth 'OBMPS\OBMPS.17'] );
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
trace_path  = str2mat([pth 'OBMPS\OBMPS.7'],[pth 'OBMPS\OBMPS.9'],[pth 'OBMPS\OBMPS.11'],...
                      [pth 'OBMPS\OBMPS.13'], [pth 'OBMPS\OBMPS.15'] );
trace_legend= str2mat('MPS1','MPS2','MPS3','MPS4','MPS5');
trace_units = '(kPa)';
y_axis      = [ -30 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% PAR 
%-----------------------------------
trace_name  = 'PAR';
trace_path  = str2mat([pth 'BS_23x_5\Rpd_Tp_AVG'],[pth 'BS_23x_5\Rpu_20m_AVG'], ...
                      [pth 'BS_cr7_3\BS_3.20'],[pth 'BS_23x_5\Rpd_Us_2_AVG'],[pth 'BS_cr7_3\BS_3.54'],...
                      [pth 'BS_cr7_3\BS_3.55']);
trace_legend= str2mat('PARdw_{TOP}','PARuw_{20m}','PARdw_{bc1}',...
                      'PARdw_{bc2}','PARtot_{BF2}','PARdif_{BF2}');
trace_units = 'umol m-2 s-1)';
y_axis      = [ -50 2200];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% CNR1
%-----------------------------------
if year>=2012
    trace_name  = 'CNR1 4-way components';
    swd = read_bor([pth 'OBN\OBN.8']);
    swu = read_bor([pth 'OBN\OBN.9']);
    lwd_raw = read_bor([pth 'OBN\OBN.10']);
    lwu_raw = read_bor([pth 'OBN\OBN.11']);
    lwd = read_bor([pth 'OBN\OBN.12']);
    lwu = read_bor([pth 'OBN\OBN.13']);
    RnCNR1 = swd-swu + lwd-lwu;
    trace_legend= str2mat('swdw','swuw','lwdw_{raw}','lwuw_{raw}',...
                         'lwdw_{corr}','lwuw_{corr}','Rn_{CNR1}');
    trace_units = 'W m^{-2} s^{-1}';
    y_axis      = [ -200 1000];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [swd swu lwd_raw lwu_raw lwd lwu RnCNR1], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end

%-----------------------------------
% Radiation components from Eppley's and CM11's
%-----------------------------------
trace_name  = 'Radiation components from Eppley and CM11';
trace_path  = str2mat([pth 'BS_cr7_3\BS_3.8'],[pth 'BS_cr7_3\BS_3.9'],...
                      [pth 'BS_23x_5\BS_23x_210.15'],[pth 'BS_cr7_3\BS_3.10'],[pth 'BS_23x_5\BS_23x_210.16'],...
                      [pth 'BS_cr7_3\BS_3.14'],[pth 'BS_23x_5\Rn_Bm_AVG'] );
trace_units = '(W/m^2)';
y_axis      = [-50 1000];
trace_legend= str2mat('swd CM11 Top','swu CM11 Boom','lwd Epp Top (raw)','lwd Epp Top (comp)',...
                      'lwu Epp Boom (raw)','lwu Epp Boom (comp)','Rn_{MID} Boom');
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Resistances from Eppley PIRs
%-----------------------------------
trace_name  = 'Thermistor Resistances from Eppley PIRs';
trace_path  = str2mat([pth 'BS_cr7_3\BS_3.12'],[pth 'BS_cr7_3\BS_3.13'],[pth 'BS_cr7_3\BS_3.16'],...
                      [pth 'BS_cr7_3\BS_3.17']);
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
RnMid = read_bor([pth 'BS_23x_5\Rn_Bm_AVG']);
swdx = read_bor([pth 'BS_cr7_3\BS_3.8']);
swux = read_bor([pth 'BS_cr7_3\BS_3.9']);
lwdx = read_bor([pth 'BS_23x_5\BS_23x_210.15']);
lwux = read_bor([pth 'BS_23x_5\BS_23x_210.16']);
Rn4way = swdx-swux + lwdx-lwux;
fig_num = fig_num + fig_num_inc;
if year>= 2012
    trace_name  = 'Net Radiation comparison';
    trace_legend= str2mat('CNR1 (calculated)','Middleton (Boom)','components');
x = plt_msig( [ RnCNR1 RnMid Rn4way], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
else
    trace_name  = 'Net Radiation Middleton';
    x = plt_msig( [ RnMid], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
if pause_flag == 1;pause;end

%----------------------------------------------------------
% UBC  thermometers
%----------------------------------------------------------
trace_name  = 'IR thermometers';
trace_path  = str2mat([pth 'OBLW\OBLW.15'],[pth 'OBMPS\OBMPS.17']);
trace_legend= str2mat('OBLW','OBMPS');
trace_units = '(degC)';
y_axis      = [0 30] - WINTER_TEMP_OFFSET/2;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% SHF
%-----------------------------------
if year>= 2012
trace_name  = 'Soil Heat Flux';
% trace_path  = str2mat([pth 'OBN\OBN.8'],[pth 'OBN\OBN.9'], ...
%                       [pth 'OBN\OBN.12'],[pth 'OBN\OBN.13'],...
%                       [pth 'BS_23x_5\Rn_Bm_AVG'] );
G1 = read_bor([pth 'OBT\OBT.54']);
G2 = read_bor([pth 'OBT\OBT.55']);
G3 = read_bor([pth 'OBT\OBT.56']);
G4 = read_bor([pth 'OBT\OBT.57']);
trace_legend= str2mat('NE #1','NE #2','NW #1','NW #2');
trace_units = 'W m^{-2} s^{-1}';
y_axis      = [ -50 100];
fig_num = fig_num + fig_num_inc;
x = plt_msig( [G1 G2 G3 G4], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end


%-----------------------------------
% Soil Temp profile 1
%-----------------------------------
trace_name  = 'OB7 Soil Tc profile (NE)';
trace_path  = str2mat([pth 'BS_cr7_3\BS_3.35'],[pth 'BS_cr7_3\BS_3.36'], ...
                      [pth 'BS_cr7_3\BS_3.37'],[pth 'BS_cr7_3\BS_3.38'],[pth 'BS_cr7_3\BS_3.39'],...
                       [pth 'BS_cr7_3\BS_3.40'] );
trace_legend= str2mat('2 cm','5 cm','10 cm','20 cm','50 cm','100 cm');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Soil Temp profile 2
%-----------------------------------
trace_name  = 'OBT Soil Tc profile (NW)';
trace_path  = str2mat([pth 'OBT\OBT.43'],[pth 'OBT\OBT.44'], ...
                      [pth 'OBT\OBT.45'],[pth 'OBT\OBT.46'],[pth 'OBT\OBT.47'],...
                       [pth 'OBT\OBT.48']);
trace_legend= str2mat('2 cm','5 cm','10 cm','20 cm','50 cm','100 cm');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end



%-----------------------------------
% Soil VWC #1
%-----------------------------------
trace_name  = '4 hour Soil VWC: CS615 profile, NW pit';
VWC2 = read_bor([pth 'BS_21x_4\BS_4a.12']);
VWC7 = read_bor([pth 'BS_21x_4\BS_4a.6']);
VWC22 = read_bor([pth 'BS_21x_4\BS_4a.7']);
VWC45 = read_bor([pth 'BS_21x_4\BS_4a.8']);
VWC60 = read_bor([pth 'BS_21x_4\BS_4a.14']);
tv    = read_bor([pth 'BS_21x_4\BS_4a_tv']);
indz= find(VWC2==0.);
VWC2(indz)=NaN;
VWC7(indz)=NaN;
VWC22(indz)=NaN;
VWC45(indz)=NaN;
VWC60(indz)=NaN;
% trace_path  = str2mat([pth 'BS_21x_4\BS_4a.12'],[pth 'BS_21x_4\BS_4a.6'], ...
%                       [pth 'BS_21x_4\BS_4a.7'],[pth 'BS_21x_4\BS_4a.8'],[pth 'BS_21x_4\BS_4a.14']);
% trace_legend= str2mat('2.5 cm','7.5 cm','22.5 cm','45 cm','60-90 cm');
% trace_units = '\circC';
% y_axis      = [ 0  1 ];
fig_num = fig_num + fig_num_inc;
figure(fig_num);
%x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
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

%-----------------------------------
% Soil VWC #2
%-----------------------------------

trace_name  = '4 hour Soil VWC: CS615 profile, NE pit';
VWC2 = read_bor([pth 'BS_21x_4\BS_4a.13']);
VWC7 = read_bor([pth 'BS_21x_4\BS_4a.9']);
VWC22 = read_bor([pth 'BS_21x_4\BS_4a.10']);
VWC45 = read_bor([pth 'BS_21x_4\BS_4a.11']);
VWC60 = read_bor([pth 'BS_21x_4\BS_4a.15']);
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


%-----------------------------------
% OBT AM25T PRT ref temps 
%-----------------------------------
trace_name  = 'OBT AM25T PRT reference temps';
trace_path  = str2mat([pth 'OBT\OBT.7'],[pth 'OBT\OBT.8']);
trace_legend= str2mat('AM25T_1','AM25T_2');
trace_units = '\circC';
y_axis      = [ 0 30 ];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Snow Tc Stake East
%-----------------------------------
trace_name  = 'OBT Snow Tc profile (East)';

Tref1=read_bor(fullfile(pth,'OBT\OBT.7'));
Tref2=read_bor(fullfile(pth,'Clean\Air_Temp_AbvGnd_1m_UBC')); % AM25T1 must be outside, so use Tair 1 m agl to correct 
                                                     % bad AM25T1 ref temp

TsnE1=read_bor(fullfile(pth,'OBT\OBT.35'))-Tref1+Tref2;
TsnE2=read_bor(fullfile(pth,'OBT\OBT.36'))-Tref1+Tref2;
TsnE5=read_bor(fullfile(pth,'OBT\OBT.37'))-Tref1+Tref2;
TsnE10=read_bor(fullfile(pth,'OBT\OBT.38'))-Tref1+Tref2;
TsnE20=read_bor(fullfile(pth,'OBT\OBT.39'))-Tref1+Tref2;
TsnE30=read_bor(fullfile(pth,'OBT\OBT.40'))-Tref1+Tref2;
TsnE40=read_bor(fullfile(pth,'OBT\OBT.41'))-Tref1+Tref2;
TsnE50=read_bor(fullfile(pth,'OBT\OBT.42'))-Tref1+Tref2;
% trace_path  = str2mat([pth 'OBT\OBT.35'],[pth 'OBT\OBT.36'], ...
%                       [pth 'OBT\OBT.37'],[pth 'OBT\OBT.38'],[pth 'OBT\OBT.39'],...
%                        [pth 'OBT\OBT.40'],[pth 'OBT\OBT.41'],[pth 'OBT\OBT.42']);
trace_legend= str2mat('1 cm','2 cm','5 cm','10 cm','20 cm','30 cm','40 cm','50 cm');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( [TsnE1 TsnE2 TsnE5 TsnE10 TsnE20 TsnE30 TsnE40 TsnE50], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Snow Tc Harp West
%-----------------------------------
trace_name  = 'OBT Snow Tc profile (West)';
% trace_path  = str2mat([pth 'OBT\OBT.21'],[pth 'OBT\OBT.22'], ...
%                       [pth 'OBT\OBT.23'],[pth 'OBT\OBT.24'],[pth 'OBT\OBT.25'],...
%                        [pth 'OBT\OBT.26'],[pth 'OBT\OBT.27'],[pth 'OBT\OBT.28']);

TsnW1=read_bor(fullfile(pth,'OBT\OBT.21'))-Tref1+Tref2;
TsnW2=read_bor(fullfile(pth,'OBT\OBT.22'))-Tref1+Tref2;
TsnW5=read_bor(fullfile(pth,'OBT\OBT.23'))-Tref1+Tref2;
TsnW10=read_bor(fullfile(pth,'OBT\OBT.24'))-Tref1+Tref2;
TsnW20=read_bor(fullfile(pth,'OBT\OBT.25'))-Tref1+Tref2;
TsnW30=read_bor(fullfile(pth,'OBT\OBT.26'))-Tref1+Tref2;
TsnW40=read_bor(fullfile(pth,'OBT\OBT.27'))-Tref1+Tref2;
TsnW50=read_bor(fullfile(pth,'OBT\OBT.28'))-Tref1+Tref2;
trace_legend= str2mat('1 cm','2 cm','5 cm','10 cm','20 cm','30 cm','40 cm','50 cm');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( [TsnW1 TsnW2 TsnW5 TsnW10 TsnW20 TsnW30 TsnW40 TsnW50], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Tree bole Tc West
%-----------------------------------
trace_name  = 'Tree bole Tcs W, 5'' agl';
trbN10=read_bor(fullfile(pth,'OBT\OBT.18'))-Tref1+Tref2;
trbN38=read_bor(fullfile(pth,'OBT\OBT.19'))-Tref1+Tref2;
trbS10=read_bor(fullfile(pth,'OBT\OBT.20'))-Tref1+Tref2;
% trace_path  = str2mat([pth 'OBT\OBT.18'],[pth 'OBT\OBT.19'], ...
%                       [pth 'OBT\OBT.20']);
trace_legend= str2mat('10 mm from N face','38 mm from N face','10 mm from south face');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( [trbN10 trbN38 trbS10], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Tree bole Tc West Northwest
%-----------------------------------
trace_name  = 'Tree bole Tcs WNW';
trbNW510=read_bor(fullfile(pth,'OBT\OBT.29'))-Tref1+Tref2;
trbNW560=read_bor(fullfile(pth,'OBT\OBT.30'))-Tref1+Tref2;
trbNW5S10=read_bor(fullfile(pth,'OBT\OBT.31'))-Tref1+Tref2;
trbNW1510=read_bor(fullfile(pth,'OBT\OBT.32'))-Tref1+Tref2;
trbNW1545=read_bor(fullfile(pth,'OBT\OBT.33'))-Tref1+Tref2;
trbNW15S10=read_bor(fullfile(pth,'OBT\OBT.34'))-Tref1+Tref2;

% trace_path  = str2mat([pth 'OBT\OBT.29'],[pth 'OBT\OBT.30'], ...
%                       [pth 'OBT\OBT.31'],[pth 'OBT\OBT.32'],...
%                       [pth 'OBT\OBT.33'],[pth 'OBT\OBT.34']);
trace_legend= str2mat('5 ft. agl,10 mm from N face','5 ft. agl, 60 mm from N face','5 ft. agl, 10 mm from S face',...
                       '15 ft. agl,10 mm from N face','15 ft. agl, 45 mm from N face','15 ft. agl,10 mm from S face' );
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( [trbNW510 trbNW560 trbNW5S10 trbNW1510 trbNW1545 trbNW15S10], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Tree bole Tc's Queen's on AM25T2
%-----------------------------------
trace_name  = 'Tree bole Tcs NW Queen''s U';
trace_path  = str2mat([pth 'OBT\OBT.59'],[pth 'OBT\OBT.50'], ...
                      [pth 'OBT\OBT.51']);
trace_legend= str2mat('NW1','NW2','NW3');
trace_units = '\circC';
y_axis      = [ 0 30 ] - WINTER_TEMP_OFFSET;
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
