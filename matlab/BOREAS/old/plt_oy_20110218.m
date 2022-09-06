function[] = plt_oy(doys,years, select);
%Program to plot OY site data
%
%
% E.Humphreys   July 11, 2000
% Revisions:
% Jan 21, 2011 Added geonor warning (dom)
% May 22, 2008 (Zoran)
%   - added plotting of min and max of HMP temp and RH
%   - moved HMP RH to Diagnostics_only plots
% July 5,2006 - Turned on legends for snow, soil and surface soil temps...Nick
% Nov 24, 2005 - Added sample tube temperature plot (Dominic)
% Jan 7, 2001 - Fixed startDate to work on any year
% Mar 4, 2001 - Switched G to the SHFP with largest values
% May 3, 2001 - enabled winter and summer temp. and eb axes
% May 22,2001 - added Everest measurement
% Dec 15, 2001 - climate only now
% Feb 1, 2002 - removed diagnostic info from this program
% March 27, 2002 - added in current and power figures
% April 4, 2002 - added in main batt V at culvert
% April 24, 2002 - added in am32 and am25T ref T, pt-100 T, tank limit info
% Aug 18, 2002 - added oy_ctl info
% Oct 7, 2002 - added min and max to phone V
% Jan 21, 2003 - Zoran changed:
%               tv = read_bor(fr_logger_to_db_fileName(ini_flxMain, '_tv', pth),8);
%           to:
%               tv = read_bor(fr_logger_to_db_fileName(ini_flxMain, '_tv', pth),8,[],years);
%                Bug fix.  It would only plot the current year in the previous version.
% Oct 13, 2004
%   added pressure plots (Ref, CAL_0, CAL_1) (z)

localdbase = 0;
pause_flag = 0;

figNames = ['HMP Air Temperature                '; 
            'Main Battery Voltage               '; 
            'Culvert Voltage Drop               '; 
            'Main Battery State                 '; 
            'Emergency Battery Voltage          '; 
            'Datalogger Voltage                 '; 
            'Panel Temperatures                 '; 
            'Reference Tank Pressure            '; 
            'Calibration Tank Pressures         '; 
            'Generator Hut Temperature          '; 
            'Wind Direction                     '; 
            'Air Temperatures                   '; 
            'Surface Soil Temperatures          '; 
            'Snow Temperatures                  '; 
            'Soil Temperatures                  '; 
            'Radiation                          '; 
            'Net Radiation                      '; 
            'HMP Relative Humidity              '; 
            'Soil Heat Flux                     '; 
            'Rainfall                           '; 
            'Geonor Raw Precipitation           '; 
            'Cumulative Precipitation           '; 
            'Cumulative Precip - Cumulative TBRG'; 
            'Volumetric Water Content           '];

if exist('years')==0 |isempty(years);
    years  = [2000];
end

if nargin < 3
    select = 0;
end

switch localdbase
case 0;
    pth   = biomet_path('yyyy','oy','fl');
    pthoy = biomet_path('yyyy','oy','cl');
case 1;
    pth   = 'c:\local_dbase\oy\flux\';
    pthoy = 'c:\local_dbase\oy\climate\'; 
end


% Find logger ini files
%ini_flxMain = fr_get_logger_ini('oy',years,[],'oy_flux_53','fl');   % main climate-logger array
%ini_flx2    = fr_get_logger_ini('oy',years,[],'oy_flux_56','fl');   % secondary climate-logger array
ini_climMain = fr_get_logger_ini('oy',years,[],'oy_clim1','cl');   % main climate-logger array

%ini_flxMain = rmfield(ini_flxMain,'LoggerName');
%ini_flx2    = rmfield(ini_flx2,'LoggerName');
ini_climMain = rmfield(ini_climMain,'LoggerName');


GMT_shift =  8/24;       %shift grenich mean time to 24hr day
tv = read_bor(fr_logger_to_db_fileName(ini_climMain, '_tv', pthoy),8,[],years);
tv = tv-GMT_shift;

startDate = datenum(min(years),1,1);     
st        = doys(1);
ed        = doys(end)+1;

if max(doys) > 70000
    indOut    = find(tv >=st & tv <= ed);
else
    indOut    = find(tv >=st+startDate-1 & tv <= ed+startDate-1);
    st = st+startDate-1;
    ed = ed+startDate-1;
end

t = tv(indOut)-startDate+1;
st = st - startDate + 1;
ed = ed - startDate + 1;

%-----------------------------------------------
%System diagnostics (oy_clim and oy_flux)
%-----------------------------------------------

DOY     = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Day_RTM', pthoy),[],[],years,indOut);

Panel_T2    = read_bor([pthoy 'oy_clim1.6'],[],[],years,indOut);

Batt_V2     = read_bor([pthoy 'oy_clim1.5'],[],[],years,indOut);
Batt_V2_max = read_bor([pthoy 'oy_clim1.10'],[],[],years,indOut);
Batt_V2_min = read_bor([pthoy 'oy_clim1.15'],[],[],years,indOut);

Batt_V3     = NaN.*ones(size(Batt_V2));
Batt_V3_max = NaN.*ones(size(Batt_V2));
Batt_V3_min = NaN.*ones(size(Batt_V2));

Panel_T3    = NaN.*ones(size(Batt_V2));

Emer_V      = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_AVG', pthoy),[],[],years,indOut);
Main_V      = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Main_V_AVG', pthoy),[],[],years,indOut);
Emer_V_max  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_MAX', pthoy),[],[],years,indOut);
Main_V_max  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Main_V_MAX', pthoy),[],[],years,indOut);
Emer_V_min  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Emerg_V_MIN', pthoy),[],[],years,indOut);
Main_V_min  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Main_V_MIN', pthoy),[],[],years,indOut);

Phone_V     = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Phone_V_AVG', pthoy),[],[],years,indOut);
Phone_V_max = NaN.*ones(size(Phone_V));
Phone_V_min = NaN.*ones(size(Phone_V));

Main_V2     = read_bor(fr_logger_to_db_fileName(ini_climMain, 'Main_V2_AVG', pthoy),[],[],years,indOut);

I_main      = read_bor(fr_logger_to_db_fileName(ini_climMain, 'I_main_AVG', pthoy),[],[],years,indOut);
I_main_max  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'I_main_MAX', pthoy),[],[],years,indOut);
I_main_min  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'I_main_MIN', pthoy),[],[],years,indOut);

MainPwr      = read_bor(fr_logger_to_db_fileName(ini_climMain, 'MainPwr', pthoy),[],[],years,indOut);
MainPwr_max  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'MainPwr_MAX', pthoy),[],[],years,indOut);
MainPwr_min  = read_bor(fr_logger_to_db_fileName(ini_climMain, 'MainPwr_MIN', pthoy),[],[],years,indOut);

Tube_TC12_avg = read_bor(fr_logger_to_db_fileName(ini_climMain, 'TC_12_AVG', pthoy),[],[],years,indOut);
Tube_TC13_avg = read_bor(fr_logger_to_db_fileName(ini_climMain, 'TC_13_AVG', pthoy),[],[],years,indOut);
Tube_TC14_avg = read_bor(fr_logger_to_db_fileName(ini_climMain, 'TC_14_AVG', pthoy),[],[],years,indOut);

newBatt_V3     = read_bor([pthoy 'oy_ctl_57.5'],[],[],years,indOut);
newBatt_V3_max = read_bor([pthoy 'oy_ctl_57.12'],[],[],years,indOut);
newBatt_V3_min = read_bor([pthoy 'oy_ctl_57.19'],[],[],years,indOut);

newPanel_T3    = read_bor([pthoy 'oy_ctl_57.6'],[],[],years,indOut);

newEmer_V      = read_bor([pthoy 'oy_ctl_57.8'],[],[],years,indOut);
newMain_V      = read_bor([pthoy 'oy_ctl_57.7'],[],[],years,indOut);
newEmer_V_max  = read_bor([pthoy 'oy_ctl_57.15'],[],[],years,indOut);
newMain_V_max  = read_bor([pthoy 'oy_ctl_57.14'],[],[],years,indOut);
newEmer_V_min  = read_bor([pthoy 'oy_ctl_57.22'],[],[],years,indOut);
newMain_V_min  = read_bor([pthoy 'oy_ctl_57.21'],[],[],years,indOut);

newPhone_V     = read_bor([pthoy 'oy_ctl_57.9'],[],[],years,indOut);
newPhone_V_max = read_bor([pthoy 'oy_ctl_57.16'],[],[],years,indOut);
newPhone_V_min = read_bor([pthoy 'oy_ctl_57.23'],[],[],years,indOut);

newMain_V2     = read_bor([pthoy 'oy_ctl_57.10'],[],[],years,indOut);

newI_main      = read_bor([pthoy 'oy_ctl_57.11'],[],[],years,indOut);
newI_main_max  = read_bor([pthoy 'oy_ctl_57.18'],[],[],years,indOut);
newI_main_min  = read_bor([pthoy 'oy_ctl_57.25'],[],[],years,indOut);

newMainPwr      = read_bor([pthoy 'oy_ctl_57.28'],[],[],years,indOut);
newMainPwr_max  = read_bor([pthoy 'oy_ctl_57.29'],[],[],years,indOut);
newMainPwr_min  = read_bor([pthoy 'oy_ctl_57.30'],[],[],years,indOut);

genTemp  = read_bor([pthoy 'oy_ctl_57.31'],[],[],years,indOut);
genTempMax  = read_bor([pthoy 'oy_ctl_57.32'],[],[],years,indOut);
genTempMin  = read_bor([pthoy 'oy_ctl_57.33'],[],[],years,indOut);


ind = find(t >= datenum(2002,8,15,14,0,0)- startDate + 1);
Batt_V3(ind)= newBatt_V3(ind);
Batt_V3_max(ind)= newBatt_V3_max(ind);
Batt_V3_min(ind)= newBatt_V3_min(ind);

Panel_T3(ind)= newPanel_T3(ind);

Emer_V(ind)= newEmer_V(ind);
Main_V(ind)= newMain_V(ind);
Emer_V_max(ind)= newEmer_V_max(ind);
Main_V_max(ind)= newMain_V_max(ind);
Emer_V_min(ind)= newEmer_V_min(ind);
Main_V_min(ind)= newMain_V_min(ind);

Phone_V(ind)= newPhone_V(ind);
Phone_V_max(ind)= newPhone_V_max(ind);
Phone_V_min(ind)= newPhone_V_min(ind);

Main_V2(ind)= newMain_V2(ind);

I_main(ind)= newI_main(ind);
I_main_max(ind)= newI_main_max(ind);
I_main_min(ind)= newI_main_min(ind);

MainPwr(ind)= newMainPwr(ind);
MainPwr_max(ind)= newMainPwr_max(ind);
MainPwr_min(ind)= newMainPwr_min(ind);

P_ref      = read_bor([pthoy 'oy_clim1.119'],[],[],years,indOut);
CAL_0      = read_bor([pthoy 'oy_clim1.120'],[],[],years,indOut);
CAL_1      = read_bor([pthoy 'oy_clim1.121'],[],[],years,indOut);



%
%Climate measurements
%
Rn          = read_bor([pthoy 'oy_clim1.55'],[],[],years,indOut);
if years >= 2003
    Rn_cnr1 = read_bor([pthoy 'OY_ClimT\NetCNR_AVG'],[],[],years,indOut);
    ind_no_Rn = find(tv(indOut)>datenum(2004,1,35)); % DOY 35, 2003 the S1 net radiometer was removed
    Rn(ind_no_Rn) = NaN;
end

SKipp_downwelling   = read_bor([pthoy 'oy_clim1.53'],[],[],years,indOut);
SLicor_downwelling  = read_bor([pthoy 'oy_clim1.52'],[],[],years,indOut);
Q_downwelling       = read_bor([pthoy 'oy_clim1.50'],[],[],years,indOut);
SKipp_upwelling     = read_bor([pthoy 'oy_clim1.54'],[],[],years,indOut);
Q_upwelling         = read_bor([pthoy 'oy_clim1.51'],[],[],years,indOut);

tc_1000   = read_bor([pthoy 'oy_clim1.38'],[],[],years,indOut);
tc_500    = read_bor([pthoy 'oy_clim1.39'],[],[],years,indOut);
tc_250    = read_bor([pthoy 'oy_clim1.40'],[],[],years,indOut);
tc_100    = read_bor([pthoy 'oy_clim1.41'],[],[],years,indOut);
tc_50     = read_bor([pthoy 'oy_clim1.42'],[],[],years,indOut);
tc_20     = read_bor([pthoy 'oy_clim1.43'],[],[],years,indOut);

tc_0_5    = read_bor([pthoy 'oy_clim1.44'],[],[],years,indOut);
tc_1      = read_bor([pthoy 'oy_clim1.45'],[],[],years,indOut);
tc_2      = read_bor([pthoy 'oy_clim1.46'],[],[],years,indOut);
tc_log    = read_bor([pthoy 'oy_clim1.47'],[],[],years,indOut);

SHFP1  = read_bor([pthoy 'oy_clim1.57'],[],[],years,indOut);
SHFP2  = read_bor([pthoy 'oy_clim1.58'],[],[],years,indOut);
SHFP3  = read_bor([pthoy 'oy_clim1.59'],[],[],years,indOut);
SHFP4  = read_bor([pthoy 'oy_clim1.60'],[],[],years,indOut);
SHFP5  = read_bor([pthoy 'oy_clim1.61'],[],[],years,indOut);
SHFP6  = read_bor([pthoy 'oy_clim1.62'],[],[],years,indOut);

th_1     = read_bor([pthoy 'oy_clim1.87'],[],[],years,indOut);
th_2     = read_bor([pthoy 'oy_clim1.88'],[],[],years,indOut);
th_3     = read_bor([pthoy 'oy_clim1.89'],[],[],years,indOut);
th_4     = read_bor([pthoy 'oy_clim1.90'],[],[],years,indOut);
th_5     = read_bor([pthoy 'oy_clim1.91'],[],[],years,indOut);
th_6     = read_bor([pthoy 'oy_clim1.92'],[],[],years,indOut);

HMP_T    = read_bor([pthoy 'oy_clim1.48'],[],[],years,indOut);
HMP_T_min = read_bor([pthoy 'oy_clim2.48'],[],[],years,indOut);
HMP_T_max  = read_bor([pthoy 'oy_clim2.22'],[],[],years,indOut);

HMP_RH   = read_bor([pthoy 'oy_clim1.49'],[],[],years,indOut);
HMP_RH_min   = read_bor([pthoy 'oy_clim2.49'],[],[],years,indOut);
HMP_RH_max   = read_bor([pthoy 'oy_clim2.23'],[],[],years,indOut);

cup_u    = read_bor([pthoy 'oy_clim1.26'],[],[],years,indOut);
winddir  = read_bor([pthoy 'oy_clim1.31'],[],[],years,indOut);

Everest_Ttar  = read_bor([pthoy 'oy_clim1.70'],[],[],years,indOut);

GH_co2_av     = read_bor([pthoy 'oy_clim1.131'],[],[],years,indOut);
GH_co2_max    = read_bor([pthoy 'oy_clim2.236'],[],[],years,indOut);
GH_co2_min    = read_bor([pthoy 'oy_clim2.237'],[],[],years,indOut);

snow_tc_1    = read_bor([pthoy 'oy_clim1.101'],[],[],years,indOut);
snow_tc_5    = read_bor([pthoy 'oy_clim1.102'],[],[],years,indOut);
snow_tc_10   = read_bor([pthoy 'oy_clim1.103'],[],[],years,indOut);
snow_tc_20   = read_bor([pthoy 'oy_clim1.104'],[],[],years,indOut);
snow_tc_50   = read_bor([pthoy 'oy_clim1.105'],[],[],years,indOut);

soil_tc_2    = read_bor([pthoy 'oy_clim1.95'],[],[],years,indOut);
soil_tc_5    = read_bor([pthoy 'oy_clim1.96'],[],[],years,indOut);
soil_tc_10   = read_bor([pthoy 'oy_clim1.97'],[],[],years,indOut);
soil_tc_20   = read_bor([pthoy 'oy_clim1.98'],[],[],years,indOut);
soil_tc_50   = read_bor([pthoy 'oy_clim1.99'],[],[],years,indOut);
soil_tc_100  = read_bor([pthoy 'oy_clim1.100'],[],[],years,indOut);

PT_100   = read_bor([pthoy 'oy_clim1.139'],[],[],years,indOut);
AM32_refT= read_bor([pthoy 'oy_clim1.140'],[],[],years,indOut);
AM25T_refT= read_bor([pthoy 'oy_clim1.37'],[],[],years,indOut);

P1       = read_bor([pthoy 'oy_clim1.33'],[],[],years,indOut);
P2       = read_bor([pthoy 'oy_clim1.34'],[],[],years,indOut);
P_cum_geonor  = read_bor([pthoy 'OY_ClimT\Pre_avg'],[],[],years,indOut);

P1_all       = read_bor([pthoy 'oy_clim1.33'],[],[],years);
P2_all       = read_bor([pthoy 'oy_clim1.34'],[],[],years);
P_cum_all   = read_bor([pthoy 'OY_ClimT\Pre_avg'],[],[],years);

L_lower   = read_bor([pthoy 'OY_ClimT\L_lower_AVG'],[],[],years,indOut);
L_upper   = read_bor([pthoy 'OY_ClimT\L_upper_AVG'],[],[],years,indOut);
S_lower   = read_bor([pthoy 'OY_ClimT\S_lower_AVG'],[],[],years,indOut);
S_upper   = read_bor([pthoy 'OY_ClimT\S_upper_AVG'],[],[],years,indOut);
CNR1_net  = read_bor([pthoy 'OY_ClimT\NetCNR_AVG'],[],[],years,indOut);

% Calculate cumulative rain
rain    = 0.5*(P1_all+P2_all);
cum_P1_all = cumsum(P1_all);
cum_P2_all = cumsum(P2_all);
cumrain = cumsum(rain);

% Find index of bucket emptying, i.e. exclude events when
% data is dropping and coming back up again
P_cum_diff = diff(P_cum_all);
ind_neg = find(P_cum_diff<-50);
ind_neg = ind_neg(1:end-1); % Last drop is always there
ind_pos = find(P_cum_diff>50);
ind_pair = [];
for i = 1:length(ind_pos)
    ind_pair_tmp = find(ind_pos(i)-ind_neg<3*48 & ind_pos(i)-ind_neg>0); % Find jump up within 3 days
    ind_pair = [ind_pair ; ind_pair_tmp];
end 
ind_pair = unique(ind_pair);
ind_neg = ind_neg(setdiff(1:length(ind_neg),ind_pair));

cumprecip = P_cum_all;
for i  = 1:length(ind_neg)
    cumprecip(ind_neg(i)+1:end) = cumprecip(ind_neg(i)+1:end)-P_cum_diff(ind_neg(i));
end
cumprecip = cumprecip - P_cum_all(1);

cumrain   = cumrain(indOut);
cum_P1_all = cum_P1_all(indOut);
cum_P2_all = cum_P2_all(indOut);
cumprecip = cumprecip(indOut);

%
%fix climate msmt problems
%
ind     = find(t < datenum(2000,7,28,12,0,0)-startDate+1);
Rn(ind) = -Rn(ind);

ind     = find(t < datenum(2000,08,23,15+8/24,30,0)-startDate+1);
SHFP1(ind) = -SHFP1(ind);
SHFP2(ind) = -SHFP2(ind);
SHFP3(ind) = -SHFP3(ind);
SHFP4(ind) = -SHFP4(ind);

SHFP_all   = mean([SHFP1 SHFP2 SHFP3 SHFP4 SHFP5 SHFP6],2);
SHFP_max   = SHFP1 ; %use the bigest valued SHFP for closure issues.

%----------------------------------------------------------
%figures
%----------------------------------------------------------

if datenum(now) > datenum(years,4,15) & datenum(now) < datenum(years,10,15);
   Tax  = [0 40];
   EBax = [-200 800];
else
   Tax  = [-10 20];
   EBax = [-200 600];
end

fig = 0;

%----------------------------------------------------------
% HMP air temperatures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,HMP_T,...
    t,PT_100,t,HMP_T_max,t,HMP_T_min);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: HMP Air Temperature 2.5m'});
a = legend('HMP','PT100','HMP_{max}','HMP_{min}');
%set(a,'Visible','off');
h = gca;
set(h,'YLim',Tax,'XLim',[st ed]);
%%datetick('x','dd');
zoom on;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Main Battery Voltage
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, Main_V,...
    t, Main_V_max,...
    t, Main_V_min,...
    t, Main_V2);
xlabel('DOY');
ylabel('Voltage (V)');
title({'Climate: Main Battery Voltage'});
a = legend('av','max','min','av-culv', -1);
set(a,'visible','on');zoom on;
h = gca;
set(h,'YLim',[10 15],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Culvert Voltage drop
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, Main_V-Main_V2);
xlabel('DOY');
ylabel('Voltage (V)');
title({'Climate: Culvert Voltage Drop'});
set(a,'visible','off');zoom on;
h = gca;
set(h,'YLim',[0 0.5],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

% Commented out by Shawn O'Neill 24.08.2004
%----------------------------------------------------------
% BB currents
%----------------------------------------------------------
%fig = fig+1;figure(fig);clf;
%title('System Current');
%plot(t, I_main,...
%   t, I_main_max,...
%    t, I_main_min);
%xlabel('DOY');
%ylabel('(A)');
%a = legend('I Avg','I Max','I Min');
%set(a,'visible','off');zoom on;
%h = gca;
%set(h,'YLim',[0 5], 'XLim',[st ed]);
%datetick('x','dd');
%if pause_flag == 1;pause;end

% Commented out by Shawn O'Neill 24.08.2004
%----------------------------------------------------------
% Power consumption
%----------------------------------------------------------
%Ibb  = I_main;
%BB2  = Main_V;
%power= (Ibb) .* BB2;
%fig = fig+1;figure(fig);clf;
%plot(t, power);
%xlabel('DOY');
%ylabel('(W)');
%h = gca;
%set(h,'YLim',[0 50], 'XLim',[st ed]);
%%datetick('x','dd');
%title('Power consumption');

%if pause_flag == 1;pause;end


%----------------------------------------------------------
% Main Pwr ON signal
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, MainPwr_max,...
    t, MainPwr_min);
xlabel('DOY');
ylabel('(1 = Main pwr ON)');
title({'Climate: Main Battery State'});
a = legend('max','min');
set(a,'visible','off');zoom on;
h = gca;
set(h,'YLim',[0 2],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Emergency Battery Voltage
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, Emer_V,...
    t, Emer_V_max,...
    t, Emer_V_min);
xlabel('DOY');
ylabel('Voltage (V)');
title({'Climate: Emergency Battery Voltage'});
a = legend('av','max','min', -1);
set(a,'visible','on');zoom on;
h = gca;
set(h,'YLim',[10 14],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Data Logger Voltage
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
%Shawn O'Neill 24.08.2004
%plot(t,BattV,'-',...
%    t, Batt_V2, ...
%    t, Batt_V3);
plot(t,Batt_V2,'-',...
    t, Batt_V3);
xlabel('DOY');
ylabel('Voltage (V)');
title({'Climate: Datalogger Voltage'});
legend('oy-clim', 'oy-ctl');zoom on;
h = gca;
set(h,'YLim',[10 14],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

%fig = fig+1;figure(fig);clf;
%plot(t,Phone_V, ...
%    t, Phone_V_max, ...
%    t, Phone_V_min);
%xlabel('DOY');
%ylabel('V');
%title('Phone Batt');
%zoom on;
%legend('avg','max', 'min');zoom on;
%h = gca;
%set(h,'YLim',[10 13],'XLim',[st ed]);
%%datetick('x','dd');
%if pause_flag == 1;pause;end

%----------------------------------------------------------
% Panel Temperatures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
%Shawn O'Neill 24.08.2004
%plot(t,PanelT,...
%    t,Panel_T2,...
%    t,Panel_T3,...
%    t,AM32_refT,...
%    t,AM25T_refT);
plot(t,Panel_T2,...
    t,Panel_T3,...
    t,AM32_refT,...
    t,AM25T_refT);
h = gca;
set(h,'XLim',[st ed],'YLim',Tax+5);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Panel Temperatures'});
a = legend('clim','ctl','AM32','AM25T');
set(a,'Visible','on');
%%datetick('x','dd');
zoom on;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Reference Tank Pressure
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,P_ref,'-');
h = gca;
set(h,'YLim',[0 2800],'XLim',[st ed]);
xlabel('DOY');
ylabel('Pressure (kPa)');
title({'Climate: Reference Tank Pressure'});
ref_lim = 300;                              % lower limit for the ref. gas tank-pressure
index = find(P_ref > 0 & P_ref <=2500);
px = polyfit(P_ref(index),t(index),1);             % fit first order polynomial
lowLim = polyval(px,ref_lim);                   % return DOY when tank is going to hit lower limit
ax = axis;
perWeek = abs(7/px(1));
text(ax(1)+0.01*(ax(2)-ax(1)),250,sprintf('Rate of change = %4.0f psi per week',perWeek));
text(ax(1)+0.01*(ax(2)-ax(1)),100,sprintf('Low limit(%5.1f) will be reached on %s',ref_lim,datestr(lowLim,1)));
zoom on



%----------------------------------------------------------
% CAL Tank Pressures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[CAL_0 CAL_1]);
h = gca;
set(h,'YLim',[0 2800],'XLim',[st ed]);
xlabel('DOY');
ylabel('Pressure (kPa)');
title({'Climate: Calibration Tank Pressures'});
legend('CAL_0','CAL_1')
zoom on



%----------------------------------------------------------
% Generator Hut Temperature
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[genTemp genTempMin genTempMax HMP_T],'-');
h = gca;
legend('Avg','Max','Min','Air', -1)
%set(h,'YLim',[0 2800],'XLim',[st ed]);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Generator Hut Temperature'});
%%datetick('x','dd');
zoom on;


if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sample Tube Temperature
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[PT_100 Tube_TC13_avg Tube_TC14_avg],'-');
h = gca;
set(h,'YLim',Tax,'XLim',[st ed]);
legend('PT\_100','TC13','TC14', -1);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Sample Tube Temperature'});
zoom on;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% HMP Relative Humidity
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,HMP_RH,t,HMP_RH_max,t,HMP_RH_min);
xlabel('DOY');
ylabel('%');
title({'Climate: HMP Relative Humidity'});
zoom on;
h = gca;
set(h,'YLim',[0 1],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Rainfall
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,P1,t,P2);
xlabel('DOY');
ylabel('Amount (mm)');
title({'Climate: Rainfall Tipping Buckets'});
legend('TB1','TB2');
zoom on;
h = gca;
set(h,'YLim',[0 4],'XLim',[st ed]);
%%datetick('x','dd');


if pause_flag == 1;pause;end

%----------------------------------------------------------
% Geonor Raw Precip
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,P_cum_geonor);
xlabel('DOY');
ylabel('(mm)');
title({'Climate: Geonor Raw Precipitation'});
zoom on;
h = gca;
set(h,'YLim',[0 700],'XLim',[st ed]);

%genonor service warning

%if P_cum_geonor(end) > 450
x = find(P_cum_geonor > 450);
if ~isempty(x);
    ax=axis;
    text(ax(1)+0.05*(ax(2)-ax(1)),400,'URGENT: geonor need servicing (Full at 600mm)','FontSize',30);
end



if pause_flag == 1;pause;end

%----------------------------------------------------------
% Cumulative Geonor & TBRG
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,cum_P1_all,t,cum_P2_all,t,cumprecip);
xlabel('DOY');
ylabel('(mm)');
title({'Climate: Cumulative Geonor & TBRG'});
zoom on;
a = legend('TBRG1','TBRG2','Geonor', -1);
set(a,'visible','on');
h = gca;
set(h,'YLim',[min([cum_P1_all;cum_P2_all;cumprecip])-10 max([cum_P1_all;cum_P2_all;cumprecip])+10],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Snow: Cumulative Geonor - Cumulative TBRG
%----------------------------------------------------------
% fig = fig+1;figure(fig);clf;
% plot(t,cumprecip-cumrain);
% xlabel('DOY');
% ylabel('(mm)');
% title({'Climate: Snow: Cumulative Geonor - Cumulative TBRG'});
% zoom on;
% h = gca;
% set(h,'YLim',[min([cumprecip-cumrain])-5 max([cumprecip-cumrain])+5],'XLim',[st ed]);
% %%datetick('x','dd');
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% Snow Temperatures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,snow_tc_1,...
    t,snow_tc_5,...
    t,snow_tc_10,...
    t,snow_tc_20,...
    t,snow_tc_50);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Snow temperatures'});
a = legend('1cm','5cm','10cm','20cm','50cm');
%set(a,'Visible','off');
set(a,'Visible','on');

h = gca;
set(h,'YLim',Tax+5,'XLim',[st ed]);
%%datetick('x','dd');
zoom on;
if pause_flag == 1;pause;end


%------------------------------------------
if select == 1 %diagnostics only
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
    return
end

%----------------------------------------------------------
% Wind Direction
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,winddir);
xlabel('DOY');
ylabel('Direction (^o from N)');
title({'Climate: Wind direction'});
h = gca;
set(h,'YLim',[0 360],'XLim',[st ed]);
%%datetick('x','dd');
zoom on;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temperatures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,tc_1000,...
    t,tc_500,...
    t,tc_250,...
    t,tc_100,...
    t,tc_50,...
    t,tc_20);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Air Temperatures'});
a = legend('10 m','5 m','2.5 m','1 m','0.5 m','0.2 m');
set(a,'Visible','off');
h = gca;
set(h,'YLim',Tax,'XLim',[st ed]);
%%datetick('x','dd');
zoom on;


if pause_flag == 1;pause;end

%----------------------------------------------------------
% Surface Soil Temperatures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,tc_0_5,...
    t,tc_1,...
    t,tc_2,...
    t,tc_log,...
    t,Everest_Ttar);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Surface Soil Temperatures'});
a = legend('0.5','1','2','log','Everest');
%set(a,'Visible','off');
set(a,'Visible','on');

h = gca;
set(h,'YLim',Tax+5,'XLim',[st ed]);
%%datetick('x','dd');
zoom on;
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Soil Temperatures
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,soil_tc_2,...
    t,soil_tc_5,...
    t,soil_tc_10,...
    t,soil_tc_20,...
    t,soil_tc_50,...
    t,soil_tc_100);
xlabel('DOY');
ylabel('Temperature (^oC)');
title({'Climate: Soil Temperatures'});
a = legend('2cm','5cm','10cm','20cm','50cm','100cm');
%set(a,'Visible','off');
set(a,'Visible','on');

h = gca;
set(h,'YLim',Tax+5,'XLim',[st ed]);
%%datetick('x','dd');
zoom on;


if pause_flag == 1;pause;end

%----------------------------------------------------------
% Radiation
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
%plot(t,Q_downwelling,...
%    t,Q_upwelling,...
%    t,SLicor_downwelling,...
%    t,SKipp_downwelling,...
%    t,SKipp_upwelling);
plot(t,Q_downwelling,t,Q_upwelling);
xlabel('DOY');
ylabel('W m^{-2} / \mumol m^{-2} s^{-1}');
title({'PAR'});
a = legend('Q-dw','Q-uw');
%set(a,'visible','off');
h = gca;
set(h,'YLim',[0 2000],'XLim',[st ed]);
%%datetick('x','dd');
zoom on;
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Net Radiation
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
if years>=2003
    plot(t,L_upper,t,L_lower,t,S_upper,t,S_lower);
    legend('L lower','L upper','S lower','S upper');
else
    plot(t,Rn);    
end
xlabel('DOY');
ylabel('W m^{-2}');
title({'CNR1 radiation raw'});
h = gca;
set(h,'YLim',EBax,'XLim',[st ed]);
%%datetick('x','dd');
zoom on;


if pause_flag == 1;pause;end

%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,SHFP1,t,SHFP2,t,SHFP3,t,SHFP4,t,SHFP5,t,SHFP6,...
t,SHFP_max,'.');
xlabel('DOY');
ylabel('SHFP (W m^{-2})');
title({'Climate: Soil Heat Flux'});
zoom on;
h = gca;
set(h,'YLim',[-150 200],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Volumetric Water Content
%----------------------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,th_1,t,th_2,t,th_3,t,th_4,t,th_5,t,th_6);
xlabel('DOY');
ylabel('??????????');
title({'Climate: Volumetric Water Content'});
a = legend('1','2','3','4','5','6');
set(a,'visible','off');
zoom on;
h = gca;
set(h,'YLim',[0 0.6],'XLim',[st ed]);
%%datetick('x','dd');
if pause_flag == 1;pause;end


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
 
 
function title_figure(title_1)
    figure
    axes
    set(gca,'box','off','position',[0 0 1 1])
    text(0.1,0.5,title_1,'fontsize',28)
    drawnow
