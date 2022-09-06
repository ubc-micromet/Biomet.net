function [t,x] = paob_pl(ind, year, select, fig_num_inc,pause_flag)
%
% [t,x] = paob_pl(ind, year, select, fig_num_inc,pause_flag)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
%
% (c) Nesic Zoran           File created:       May 15, 1999
%                           Last modification:  Aug 26, 2010
%

% Revisions:
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
                      [pth 'BS_23x_5\Tc_Ta_25m_AVG'] );
trace_legend= str2mat('HMP_top','HMP_{Vent}','PRT_{vent}','Tc_{Vent}','Tc_{25m}');
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
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.22'],[pth 'BS_23x_5\HMP_T_1_AVG'],[pth 'BS_CR7_3\BS_3.24'],[pth 'BS_CR7_3\BS_3.25'],[pth 'BS_CR7_3\BS_3.33']);
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
% Snow depth
%----------------------------------------------------------
trace_name  = 'Snow Depth from SR50s';
trace_path  = str2mat([pth 'OBT\OBT.10'],[pth 'OBT\OBT.13'],[pth 'OBT\OBT.16']);
trace_legend= str2mat('Hut','NE soil moisture pit','NW soil moisture pit');
trace_units = '(mm)';
y_axis      = [0 1300] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-1200 -1200 -1200]);
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Event Rainfall
%----------------------------------------------------------
trace_name  = 'TBRG Event Rainfall';
trace_path  = str2mat([pth 'BS_CR7_3\BS_3.48']);
%trace_legend= str2mat('Belf3000');
trace_units = '(mm)';
y_axis      = [0 2] ;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% PAR 
%-----------------------------------
trace_name  = 'PAR';
trace_path  = str2mat([pth 'BS_23x_5\Rpd_Tp_AVG'],[pth 'BS_23x_5\Rpu_20m_AVG'], ...
                      [pth 'BS_23x_5\Rpd_Us_2_AVG'],[pth 'BS_cr7_3\BS_3.54'],...
                      [pth 'BS_cr7_3\BS_3.55']);
trace_legend= str2mat('PARdw_{TOP}','PARuw_{20m}','PARdw_{belc}',...
                      'PARtot_{BF2}','PARdif_{BF2}');
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
    lwd = read_bor([pth 'OBN\OBN.12']);
    lwu = read_bor([pth 'OBN\OBN.13']);
    RnCNR1 = swd-swu + lwd-lwu;
    trace_legend= str2mat('swdw','swuw','lwdw_{corr}','lwuw_{corr}','Rn_{CNR1}');
    trace_units = 'W m^{-2} s^{-1}';
    y_axis      = [ -200 1000];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [swd swu lwd lwu RnCNR1], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end

%-----------------------------------
% Radiation components from Eppley's and CM11's
%-----------------------------------
trace_name  = 'Radiation components from Eppley and CM11';
trace_path  = str2mat([pth 'BS_cr7_3\BS_3.8'],[pth 'BS_cr7_3\BS_3.9'],...
                      [pth 'BS_23x_5\BS_23x_210.15'],[pth 'BS_23x_5\BS_23x_210.16'],...
                      [pth 'BS_23x_5\Rn_Bm_AVG'] );
trace_units = '(W/m^2)';
y_axis      = [-50 1000];
trace_legend= str2mat('swd CM11 Top','swu CM11 Boom','lwd Epp Top',...
                      'lwu Epp Boom','Rn_{MID} Boom');
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%-----------------------------------
% Net Radiation components from Eppley's and CM11's
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
    trace_legend= str2mat('CNR1 (calculated)','Middleton (Boom)','4way');
x = plt_msig( [ RnCNR1 RnMid Rn4way], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
else
    trace_name  = 'Net Radiation Middleton';
    x = plt_msig( [ RnMid], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
end
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
