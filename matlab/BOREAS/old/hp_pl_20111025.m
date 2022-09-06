function [t,x] = HP_pl(ind, year, SiteID, select, fig_num_inc,pause_flag)
% HP_pl - plotting program for Alberta Hybrid Poplar sites--
%       -created from MPB_pl
%
%
%

% Revisions
% Oct 4, 2011 (Nick)
%   -added plots for CO2 and H2O mixing ratio
% Feb 21, 2011
%   -reduced size of rotation matrixes to ind rather than one whole year!
% Dec 16, 2010
% added HP09 to all the trace titles
% Nov 30, 2010 
% Changed (Ta range and units for Soil temperature trace)
% Nov 16, 2010
%   changed GMT offset from 8/24 to 7/24 (Paul and Lakhwinder)
% June 15, 2010
%   -vaisala GMM traces renamed without the "_AVG".
% August 1, 2010 (Amanda)
%  - added WPL rotated and unrotated CO2 and H2O flux
%  - edited units and titles of plots

if ind(1) > datenum(0,4,15) & ind(1) < datenum(0,10,15);
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

GMTshift = 7/24;                                 %changed from 8/24 (Nov16 2010)
% GMTshift = 1/3;                                  
pthClim = biomet_path(year,SiteID,'cl');         % get the climate data path
pthEC   = biomet_path(year,SiteID,'fl');         % get the eddy data path
%pthEC   = fullfile(pthEC,'Above_Canopy');
pthFl   = biomet_path(year,SiteID,'Flux_Logger'); 

%pthCtrl = [];

axis1 = [340 400];
axis2 = [-10 5];
axis3 = [-50 250];
axis4 = [-50 250];    

st = min(ind);                                   % first day of measurements
ed = max(ind)+1;                                 % last day of measurements (approx.)
ind = st:ed;

tv=read_bor(fullfile(pthClim,'clean_tv'),8);             % get decimal time from the data base
t = tv - tv(1) + 1 - GMTshift;                  % convert time to decimal DOY local time
t_all = t;                                          % save time trace for later
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;
%whitebg('w'); 

%----------------------------------------------------------
% Air Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Air temperature'];
if strcmp(SiteID,'HP11')
   trace_path  = str2mat(fullfile(pthClim,'HMP_T_Avg'),fullfile(pthFl,'Eddy_TC_Avg'),...
                      fullfile(pthFl,'Tsonic_Avg'),fullfile(pthClim,'cnr4_T_C_Avg'));
   trace_legend= str2mat('HMP Tair','Eddy_{Tc}','Sonic_{Tc}','T_{CNR4}');
elseif strcmp(SiteID,'HP09')
    trace_path  = str2mat(fullfile(pthFl,'Eddy_TC_Avg'),...
                      fullfile(pthFl,'Tsonic_Avg'));
   trace_legend= str2mat('Eddy_{Tc}','Sonic_{Tc}');
end
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% RH
%----------------------------------------------------------
if strcmp(SiteID,'HP11')
trace_name  = [SiteID '-Relative Humidity'];
trace_path  = str2mat(fullfile(pthClim,'HMP_RH_Avg'),fullfile(pthClim,'HMP_RH_Min'),fullfile(pthClim,'HMP_RH_Max'));
trace_legend= str2mat('HMP Tair Avg','HMP Tair Min','HMP Tair Max');
trace_units = '(%)';
y_axis      = [0 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end


%----------------------------------------------------------
% Battery Voltage
%----------------------------------------------------------
trace_name  = [SiteID '-Battery voltage'];
if strcmp(SiteID,'HP09')
   trace_path  = str2mat(fullfile(pthClim,'BattV_AVG'),fullfile(pthFl,'batt_volt_Avg'));
   trace_legend= str2mat('CLIM BattVolt_{Avg}','EC logger BattVolt_{Avg}');
elseif strcmp(SiteID,'HP11')
    trace_path  = str2mat(fullfile(pthFl,'batt_volt_Avg'),fullfile(pthFl,'batt_volt_Min'),fullfile(pthFl,'batt_volt_Max'));
    trace_legend= str2mat('EC logger BattVolt_{Avg}','EC logger BattVolt_{Min}','EC logger BattVolt_{Max}');
end
trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Temp
%----------------------------------------------------------
trace_name  = [SiteID '-Logger temperature'];
if strcmp(SiteID,'HP09')
   trace_path  = str2mat(fullfile(pthClim,'RefT_MPLX_AVG'),fullfile(pthFl,'ref_temp_Avg'));
   trace_legend= str2mat('MUX','Eddy Logger');
elseif strcmp(SiteID,'HP11')
    trace_path  = str2mat(fullfile(pthFl,'ref_temp_Avg'));
    trace_legend= str2mat('Eddy Logger');
end
trace_units = '(\circC)';
y_axis      = [0 50]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 1],[0 0]);
if pause_flag == 1;pause;end

%----------------------------------------------------------
% IRGA Diagnostic
%----------------------------------------------------------
% trace_name  = 'HP09-Climate/Diagnostics: IRGA diag';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_4'),fullfile(pthFl,'Idiag_Avg'));
% trace_legend= str2mat('Idiag','Idiag logger');
if strcmp(SiteID,'HP09')
    trace_name  = 'HP09-IRGA diag';
    trace_path  = str2mat(fullfile(pthFl,'Idiag_Avg'));
    trace_legend= str2mat('Idiag logger');
    trace_units = '';
    y_axis      = [240 260];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end
%----------------------------------------------------------
% CO2 density
%----------------------------------------------------------
% trace_name  = 'HP09-Climate/Diagnostics: CO2';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_1'),fullfile(pthEC,'Instrument_5.Min_1'),fullfile(pthEC,'Instrument_5.Max_1')...
%     ,fullfile(pthFl,'CO2_Avg'));
%trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}','CO2_{Avg
%Logger}');

if strcmp(SiteID,'HP09')
 trace_name  = 'HP09-CO2 density';
 trace_units = '(mmol CO_{2} m^{-3})';
 y_axis      = [-5 40];
elseif strcmp(SiteID,'HP11')
  trace_name  = 'HP11-CO2 mixing ratio';
   trace_units = '(\mumol CO_{2} mol^{-1} dry air)';
  y_axis      = [350 600];
end
trace_path  = str2mat(fullfile(pthFl,'CO2_Avg'),fullfile(pthFl,'CO2_Min'),fullfile(pthFl,'CO2_Max'));
trace_legend= str2mat('CO2_{AvgLogger}','CO2_{MinLogger}','CO2_{MaxLogger}');

fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% CO2 mixing ratio for HP09
%----------------------------------------------------------

if strcmp(SiteID,'HP09')
    trace_name  = 'HP09-CO2 mixing ratio';
    trace_units = '(\mumol CO_{2} mol^{-1} dry air)';
    y_axis      = [350 600];
    co2_avg = read_bor(fullfile(pthFl,'CO2_Avg'));
    %co2_std = read_bor(fullfile(pthFl,'CO2_Std'));
    co2_max = read_bor(fullfile(pthFl,'CO2_Max'));
    co2_min = read_bor(fullfile(pthFl,'CO2_Min'));
    h2o_avg = read_bor(fullfile(pthFl,'H2O_Avg'));
    %h2o_std = read_bor(fullfile(pthFl,'H2O_Std'));
    h2o_max = read_bor(fullfile(pthFl,'H2O_Max'));
    h2o_min = read_bor(fullfile(pthFl,'H2O_Min'));
    
    Tair = read_bor(fullfile(pthFl,'Tsonic_Avg'));
    pbar = read_bor(fullfile(pthFl,'Irga_P_Avg'));
    
    [Cmix_avg, Hmix_avg,Cmolfr_avg, Hmolfr_avg] = fr_convert_open_path_irga(co2_avg,h2o_avg,Tair,pbar);
    [Cmix_max,Hmix_max,junk,junk]               = fr_convert_open_path_irga(co2_max,h2o_max,Tair,pbar);
    [Cmix_min,Hmix_min,junk,junk]               = fr_convert_open_path_irga(co2_min,h2o_min,Tair,pbar);
    
    trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}');

    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Cmix_avg(ind) Cmix_min(ind) Cmix_max(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end

end

%----------------------------------------------------------
% H2O density
%----------------------------------------------------------

if strcmp(SiteID,'HP09')
 trace_name  = 'HP09-H2O density';
 trace_units = '(mmol H_{2}O m^{-3})';
 y_axis      = [100 1200];
elseif strcmp(SiteID,'HP11')
    trace_name  = 'HP11-H2O mixing ratio';
    trace_units = '(mmol H_{2}O mol^{-1} dry air)';
    y_axis      = [0 25];
end

trace_path  = str2mat(fullfile(pthFl,'H2O_Avg'),fullfile(pthFl,'H2O_Min'),fullfile(pthFl,'H2O_Max'));
trace_legend= str2mat('H2O_{Avg logger}','H2O_{Min logger}','H2O_{Max logger}');
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% H2O mixing ratio for HP09
%----------------------------------------------------------

if strcmp(SiteID,'HP09')
    trace_name  = 'HP09-H2O mixing ratio';
    trace_units = '(mmol H_{2}O mol^{-1} dry air)';
    y_axis      = [0 25];
    
    
    trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H20_{Max}');

    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Hmix_avg(ind) Hmix_min(ind) Hmix_max(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end

end

%----------------------------------------------------------
% Sonic Diagnostic
%----------------------------------------------------------
trace_name  = [SiteID '-Sonic diag'];
%trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_9'),fullfile(pthFl,'Sdiag_Avg'));
trace_path  = str2mat(fullfile(pthFl,'Sdiag_Avg'));
%trace_legend= str2mat('Sdiag','Sdiag logger');
trace_legend= str2mat('Sdiag logger');
trace_units = '';
y_axis      = [-10 700];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind speed logger
%----------------------------------------------------------
trace_name  = [SiteID '-CSAT wind vector components'];
trace_path  = str2mat(fullfile(pthFl,'u_wind_Avg'),fullfile(pthFl,'v_wind_Avg'),fullfile(pthFl,'w_wind_Avg'));
trace_legend= str2mat('u wind','v wind','w wind');
trace_units = '(m s^{-1})';
y_axis      = [-10 10];
fig_num = fig_num + fig_num_inc;
x_CSAT = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation
%-----------------------------------

if strcmp(SiteID,'HP09')
 trace_name  = 'HP09-Net radiation above canopy';
 trace_path  = str2mat(fullfile(pthClim,'Net_Radn_AVG'));
elseif strcmp(SiteID,'HP11')
 trace_name  = 'HP11-Net radiation above canopy';
 trace_path  = str2mat(fullfile(pthClim,'Rn_Avg'));
end
trace_legend = str2mat('Net Avg');
trace_units = '(W m^{-2})';
y_axis      = [-200 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation SW and LW
%-----------------------------------

if strcmp(SiteID,'HP09')
 trace_name  = 'HP09-Radiation above canopy';
 trace_path  = str2mat(fullfile(pthClim,'SW_DW_AVG'),fullfile(pthClim,'SW_UW_AVG'),fullfile(pthClim,'LW_DW_AVG'),fullfile(pthClim,'LW_UW_AVG'));
elseif strcmp(SiteID,'HP11')
 trace_name  = 'HP11-Radiation above canopy';
 trace_path  = str2mat(fullfile(pthClim,'short_dn_Avg'),fullfile(pthClim,'short_up_Avg'),fullfile(pthClim,'long_dn_Avg'),fullfile(pthClim,'long_up_Avg'));
end
trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg');
trace_units = '(W m^{-2})';
y_axis      = [-200 2000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%---------------------------------
% Corrected Radiation above Canopy
%----------------------------------

if strcmp(SiteID,'HP11')
T_CNR4 = read_bor(fullfile(pthClim,'cnr4_T_C_Avg'));
LongWaveOffset =(5.67E-8*(273.15+T_CNR4).^4);

S_upper_AVG = read_bor(fullfile(pthClim,'short_up_Avg'));
S_lower_AVG = read_bor(fullfile(pthClim,'short_dn_Avg'));
lwu = read_bor(fullfile(pthClim,'long_dn_Avg'));
lwd = read_bor(fullfile(pthClim,'long_up_Avg'));
trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
trace_units = '(W m^{-2})';
y_axis      = [-200 1400];
L_upper_AVG = lwd + LongWaveOffset;
L_lower_AVG = lwu + LongWaveOffset;
Net_cnr4_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
trace_path = [S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr4_calc];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = [SiteID '-Barometric pressure'];
%trace_path  = str2mat(fullfile(pthEC,'MiscVariables.BarometricP'),fullfile(pthFl,'Irga_P_Avg'));
trace_path  = str2mat(fullfile(pthFl,'Irga_P_Avg'),fullfile(pthFl,'Irga_P_Min'),fullfile(pthFl,'Irga_P_Max'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(kPa)';
y_axis      = [30 110];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Wind speed (RM Young)
%----------------------------------------------------------
% trace_name  = 'Climate: Wind Speed Averages (RM Young)';
% trace_path  = str2mat(fullfile(pthClim,'WS_ms_S_WVT'));
% trace_legend = str2mat('CSAT','RMYoung (avg)');
% trace_units = '(m/s)';
% y_axis      = [0 10];
% fig_num = fig_num + fig_num_inc;
% x_RMYoung = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% clf
% x = plt_msig( [sqrt(sum(x_CSAT'.^2))' x_RMYoung], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end


% ----------------------------------------------------------
% Precipitation - needs a multiplier
% ----------------------------------------------------------

if strcmp(SiteID,'HP11')
trace_name  = 'HP11-Climate/Diagnostics: Rainfall';
trace_path  = str2mat(fullfile(pthClim,'Rain_Tot'));
trace_legend= str2mat('Rainfall_{tot}');
trace_units = '(mm)';
y_axis      = [0 5];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

if pause_flag == 1;pause;end

% ----------------------------------------------------------
% Cumulative Precipitation
% ----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = 'HP11 Climate: Cumulative Rain';
y_axis      = [];
ax = [st ed];
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
x1 = x1*1;   
fig_num = fig_num + fig_num_inc;

plt_sig1( tx_new, [cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
if pause_flag == 1;pause;end
end

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
% Covariances
%----------------------------------------------------------
trace_name  = [SiteID '-Covariance: w*CO2 (raw)'];
trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov5'));
trace_legend= str2mat('wco2_{covAvg}');
trace_units = '(mmol CO_{2} m^{-2} s^{-1})';
y_axis      = [-0.05 0.05];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = [SiteID '-Covariance: w*H2O (raw)'];
trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov9'));
trace_legend= str2mat('wh2o_{covAvg}');
trace_units = '(mmol H_{2}O m^{-2} s^{-1})';
if strcmp(SiteID,'HP11')
  y_axis      = [-0.05 0.5];
elseif strcmp(SiteID,'HP09')
   y_axis      = [-0.05 10 ];
end
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Covariances
%----------------------------------------------------------
trace_name  = [SiteID '-Covariance: w*T (kinematic)'];
trace_path  = str2mat(fullfile(pthFl,'Tc_Temp_cov_Cov4'),fullfile(pthFl,'Tsonic_cov_Cov4'));
trace_legend= str2mat('wTceddy_{covAvg}','wTsonic_{covAvg}');
trace_units = '(\circC m s^{-1})';
y_axis      = [-0.05 0.5];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
%  CO2 flux rotated and unrotated, WPL-corrected
%----------------------------------------------------------

trace_name  = [SiteID '-CO2 flux WPL-corrected']; 

%load mean wind vector
u = read_bor(fullfile(pthFl, 'u_wind_Avg'));
v = read_bor(fullfile(pthFl, 'v_wind_Avg'));
w = read_bor(fullfile(pthFl, 'w_wind_Avg'));

meansIn = [u v w];

% load raw covariances 

% c, H, u, v, w
c_c = read_bor(fullfile(pthFl, 'CO2_cov_Cov1'));
pthFl = biomet_path(year,SiteID,'Flux_Logger'); 
c_H = read_bor(fullfile(pthFl,'CO2_cov_Cov2'));
c_u = read_bor(fullfile(pthFl,'CO2_cov_Cov3'));
c_v = read_bor(fullfile(pthFl,'CO2_cov_Cov4')); 
c_w = read_bor(fullfile(pthFl,'CO2_cov_Cov5'));   
H_H = read_bor(fullfile(pthFl,'CO2_cov_Cov6')); 
H_u = read_bor(fullfile(pthFl,'CO2_cov_Cov7'));
H_v = read_bor(fullfile(pthFl,'CO2_cov_Cov8'));
H_w = read_bor(fullfile(pthFl,'CO2_cov_Cov9'));
u_u = read_bor(fullfile(pthFl,'CO2_cov_Cov10'));
u_v = read_bor(fullfile(pthFl,'CO2_cov_Cov11'));
u_w = read_bor(fullfile(pthFl,'CO2_cov_Cov12'));
v_v = read_bor(fullfile(pthFl,'CO2_cov_Cov13'));
v_w = read_bor(fullfile(pthFl,'CO2_cov_Cov14'));
w_w = read_bor(fullfile(pthFl,'CO2_cov_Cov15'));

% % Tsonic, u, v, w
T_T = read_bor(fullfile(pthFl,'Tsonic_cov_Cov1'));
T_u = read_bor(fullfile(pthFl,'Tsonic_cov_Cov2'));
T_v = read_bor(fullfile(pthFl,'Tsonic_cov_Cov3'));
T_w = read_bor(fullfile(pthFl,'Tsonic_cov_Cov4'));

cc = read_bor(fullfile(pthFl,'CO2_Avg'));              % cc is molar CO2 density (mmol/m3)
cv = read_bor(fullfile(pthFl,'H2O_Avg'));              % cv is molar water vapour density (mmol/m3)
T = read_bor(fullfile(pthFl,'Tsonic_avg'));   % load T and P
P = read_bor(fullfile(pthFl,'Irga_P_Avg'));

% rotation of raw covariances
C1 = [u_u  u_v  v_v  u_w  v_w  w_w  c_u  c_v  c_w  c_c  H_u  H_v  H_w  c_H  H_H ];
C2 = [u_u  u_v  v_v  u_w  v_w  w_w  T_u  T_v  T_w  T_T];

[wT_rot, wH_rot, wc_rot] = rotate_cov_matrices(meansIn(ind,:), C1(ind,:),C2(ind,:),T_w(ind));

BarometricP_logger           = read_bor(fullfile(pthFl,'Irga_P_Avg'));
if strcmp(SiteID,'HP11')
  Tair_logger                  = read_bor(fullfile(pthClim,'HMP_T_Avg'));
elseif strcmp(SiteID,'HP09')
  Tair_logger                  = read_bor(fullfile(pthFl,'Tsonic_Avg'));
end

UBC_biomet_constants;

if strcmp(SiteID,'HP11')
  Fc_log = read_bor(fullfile(pthFl,'Fc'));
  try
    mol_density_dry_air   = (BarometricP_logger./(1+cv/1000)).*(1000./(R*(Tair_logger+ZeroK)));
    convC = mol_density_dry_air(ind);             % convert umol co2/mol dry air -> umol co2/m3 dry air (refer to Pv = nRT)
    Fc_rot    = wc_rot .* convC;                      % CO2 flux (umol m-2 s-1)
    Fc_hf = read_bor(fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.Fc']));
    trace_legend= str2mat('Fc (3 rot from covs)', 'Fc_{logger}', 'Fc_{HFcalc}');
    trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
    y_axis      = [-10 15];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [ Fc_rot Fc_log(ind) Fc_hf(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
  catch
    mol_density_dry_air   = (BarometricP_logger./(1+cv/1000)).*(1000./(R*(Tair_logger+ZeroK)));
    convC = mol_density_dry_air(ind);             % convert umol co2/mol dry air -> umol co2/m3 dry air (refer to Pv = nRT)
    Fc_rot    = wc_rot .* convC;                      % CO2 flux (umol m-2 s-1)
    trace_legend= str2mat('Fc (3 rot from covs)','Fc_{logger}'); 
    y_axis      = [-10 15];
    trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [ Fc_rot Fc_wpl Fc_log(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
  end  
elseif strcmp(SiteID,'HP09')
  try
    % WPL for rotated and unrotated covariances
    [Fc_wpl, E_wpl] = apply_WPL_correction(c_w(ind),H_w(ind),T_w(ind),cc(ind),cv(ind),T(ind),P(ind));  %unrotated
    [Fc_rot, E_rot] = apply_WPL_correction(wc_rot, wH_rot, wT_rot, cc(ind), cv(ind), T(ind), P(ind));  %rotated
    Fc_hf = read_bor(fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.Fc']));
    trace_legend= str2mat('Fc WPL 3 rotations', 'Fc WPL unrotated','Fc_{HFcalc}');
    trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
    y_axis      = [-25 25];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [ Fc_rot Fc_wpl Fc_hf(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
  catch
    trace_legend= str2mat('Fc WPL 3 rotations', 'Fc WPL unrotated');
    trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
    y_axis      = [-25 25];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [ Fc_rot Fc_wpl ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );  
  end
end

if pause_flag == 1;pause;end

%----------------------------------------------------------
% add  prelim H20 flux WPL calculation (link to Amanda's function)
%----------------------------------------------------------
% trace_name  = 'HP09-H20 flux WPL-corrected';
% trace_legend= str2mat('H_{2}O WPL 3 rotations', 'H_{2}O WPL unrotated', 'LE_{logger}');
% trace_units = '(mmol m^{-2} s^{-1})';
% 
% fig_num = fig_num + fig_num_inc;
% y_axis      = [-1 5];
% LE_log = read_bor(fullfile(pthFl,'LE'));
% x = plt_msig( [E_rot E_wpl LE_log], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% 
% if pause_flag == 1;pause;end

trace_name  = [SiteID '-Climate/Diagnostics: LE flux'];

trace_units = '(W m^{-2} )';

if strcmp(SiteID,'HP09')
    [Cmix, Hmix, C, H] = fr_convert_open_path_irga(cc, cv, Tair_logger, BarometricP_logger);
    mol_density_dry_air_logger   = (BarometricP_logger./(1+Hmix/1000)).*(1000./(R*(Tair_logger+ZeroK)));
    LE_rot = E_rot.*mol_density_dry_air_logger(ind);
    LE_wpl = E_wpl.*mol_density_dry_air_logger(ind);
    
    try
        LE_hf = read_bor(fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.LE_L']));
        trace_legend= str2mat('LE 3 rotations (high freq)', 'LE WPL 3 rotations (raw)', 'LE WPL unrotated (raw)');
        y_axis      = [0 400];
        fig_num = fig_num + fig_num_inc;
        x = plt_msig( [ LE_rot LE_wpl LE_hf(ind) ],ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    catch
        FCfnstr = fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.LE_L']);
        disp(['Could not load ' FCfnstr ]);
        disp(lasterr);
        trace_legend= str2mat('LE WPL 3 rotations (raw)', 'LE WPL unrotated (raw)');
        y_axis      = [0 400];
        fig_num = fig_num + fig_num_inc;
        x = plt_msig( [LE_rot LE_wpl], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    end

elseif strcmp(SiteID,'HP11') % HP11 has an LI7200 and outputs mixing ratios (dry mol fractions) directly
   % mol_density_dry_air   = (BarometricP_logger./(1+cv/1000)).*(1000./(R*(Tair_logger+ZeroK)));
    LE_log = read_bor(fullfile(pthFl,'LE'));
    LE_hf = read_bor(fullfile(pthEC,[SiteID '.Three_Rotations.AvgDtr.Fluxes.LE_L']));
    L_v      = Latent_heat_vaporization(Tair_logger-ZeroK)./1000;    % J/g latent heat of vaporization Stull (1988)
    convH    = mol_density_dry_air.*Mw./1000;
    wH_g     = wH_rot .* convH(ind);                                  % convert m/s(mmol/mol) -> m/s(g/m^3)
    LE_rot   = wH_g .* L_v(ind);                                  % LE LICOR
    trace_legend= str2mat('LE (3 rot from covs)', 'LE logger', 'LE (high freq)');
    y_axis      = [0 400];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [LE_rot LE_log(ind) LE_hf(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end

if pause_flag == 1;pause;end


%----------------------------------------------------------
% Sonic wind speed
%----------------------------------------------------------
trace_name  = [SiteID '-Wind Speed'];
wspd2d = sqrt(u.^2 + v.^2);
if strcmp(SiteID,'HP11')
  wspd_Gill = read_bor(fullfile(pthClim,'WindSpeed_Avg'));
  trace_legend= str2mat('CSAT3','Gill WindSonic');
  trace_units = '(m/s)';
  y_axis      = [0 10];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [wspd2d(ind) wspd_Gill(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif strcmp(SiteID,'HP09')
    trace_legend= str2mat('CSAT3');
    trace_units = '(m/s)';
    y_axis      = [0 10];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [wspd2d(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end

if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind direction
%----------------------------------------------------------
trace_name  = [SiteID '-Wind direction'];
wdir   = FR_Sonic_wind_direction([u'; v'],'CSAT3');
if strcmp(SiteID,'HP11')
  wdir_Gill  = read_bor(fullfile(pthClim,'WindDir_Avg'));
  trace_legend= str2mat('CSAT3','Gill WindSonic');
  trace_units = '(^o)';
  y_axis      = [-10 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [wdir(ind)' wdir_Gill(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif strcmp(SiteID,'HP09')
    trace_legend= str2mat('CSAT3');
    trace_units = '(^o)';
    y_axis      = [-10 400];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [wdir(ind)' ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
end

if pause_flag == 1;pause;end


%----------------------------------------------------------
% Wind direction (RM Young)
%----------------------------------------------------------
% trace_name  = 'Climate: Wind Direction (RM Young)';
% trace_path  = str2mat(fullfile(pthClim,'WindDir_D1_WVT'),fullfile(pthClim,'WindDir_SD1_WVT'));
% trace_legend = str2mat('wdir 25m','wdir stdev 25m');
% trace_units = '(^o)';
% y_axis      = [0 360];
% fig_num = fig_num + fig_num_inc;
% if SiteID=='MPB3'
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% else
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% end
% if pause_flag == 1;pause;end


%----------------------------------------------------------
% Soil Temperature Profile
%----------------------------------------------------------

if strcmp(SiteID,'HP11')

    trace_name  = [SiteID '-Soil temperature profile'];
trace_path  = str2mat(fullfile(pthClim,'SoilT_3cm_Avg'),fullfile(pthClim,'SoilT_10cm_Avg'),...
                      fullfile(pthClim,'SoilT_20cm_Avg'),fullfile(pthClim,'SoilT_50cm_Avg'),...
                      fullfile(pthClim,'SoilT_80cm_Avg'));
trace_legend= str2mat('soilT_{3cm}','soillT_{10cm}','soilT_{20cm}','soilT_{50cm}','soilT_{80cm}');
trace_units = '(\circC)';
y_axis      = [-10 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 

if pause_flag == 1;pause;end

end

%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
trace_name  = [SiteID '-Soil heat flux'];

if strcmp(SiteID,'HP09')
  trace_path  = str2mat(fullfile(pthClim,'SHF_1_AVG'),fullfile(pthClim,'SHF_2_AVG'),...
                      fullfile(pthClim,'SHF_3_AVG'),fullfile(pthClim,'SHF_4_AVG'),fullfile(pthClim,'SHF_5_AVG'));
  trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}','sheat_{5}');
elseif strcmp(SiteID,'HP11')
 trace_path  = str2mat(fullfile(pthClim,'SoilHeat_1_Avg'),fullfile(pthClim,'SoilHeat_2_Avg'),...
                      fullfile(pthClim,'SoilHeat_3_Avg'),fullfile(pthClim,'SoilHeat_4_Avg'));
 trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}');
end

trace_units = '(W m^{-2})';
y_axis      = [-50 50];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 

if pause_flag == 1;pause;end

% -----------------------
% Energy Balance Closure
% -----------------------

if strcmp(SiteID,'HP09')
    S_upper_AVG = read_bor(fullfile(pthClim,'SW_DW_AVG'));
    S_lower_AVG = read_bor(fullfile(pthClim,'SW_UW_AVG'));
    L_upper_AVG = read_bor(fullfile(pthClim,'LW_DW_AVG'));
    L_lower_AVG = read_bor(fullfile(pthClim,'LW_UW_AVG'));

    Rn = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;

    SHFP1 = read_bor(fullfile(pthClim,'SHF_1_AVG'));
    SHFP2 = read_bor(fullfile(pthClim,'SHF_2_AVG'));
    SHFP3 = read_bor(fullfile(pthClim,'SHF_3_AVG'));
    SHFP4 = read_bor(fullfile(pthClim,'SHF_4_AVG'));
    SHFP5 = read_bor(fullfile(pthClim,'SHF_5_AVG'));

    G     = mean([SHFP1 SHFP2 SHFP3 SHFP4 SHFP5],2);
    
elseif strcmp(SiteID,'HP11')

    Rn = Net_cnr4_calc;
    
    SHFP1 = read_bor(fullfile(pthClim,'SoilHeat_1_Avg'));
    SHFP2 = read_bor(fullfile(pthClim,'SoilHeat_2_Avg'));
    SHFP3 = read_bor(fullfile(pthClim,'SoilHeat_3_Avg'));
    SHFP4 = read_bor(fullfile(pthClim,'SoilHeat_4_Avg'));

    G     = mean([SHFP1 SHFP2 SHFP3 SHFP4],2);
    Hmix  = read_bor(fullfile(pthFl,'H2O_Avg'));
    
end

WaterMoleFraction = Hmix./(1+Hmix./1000); 
rho_moist_air = rho_air_wet(Tair_logger,[],BarometricP_logger,WaterMoleFraction);
Cp_moist = spe_heat(Hmix);
H  = wT_rot .* rho_moist_air(ind) .* Cp_moist(ind);

if strcmp(SiteID,'HP11')
  H_hf = read_bor(fullfile(pthEC,'HP11.Three_Rotations.AvgDtr.Fluxes.Hs'));
  H_hf = H_hf(ind);
  ind_msg=find(H==0);
  H(ind_msg)=H_hf(ind_msg);
end

Le = LE_rot;

fig_num = fig_num+fig_num_inc;figure(fig_num);clf;
plot(t,Rn(ind)-G(ind),t,H+Le);
xlabel('DOY');
ylabel('W m^{-2}');
title({'Eddy Correlation: ';'Energy budget'});
legend('Rn-G','H+LE');

EBax = [-200 800];

h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')

try
    A = Rn(ind)-G(ind);
    T = H+Le;
    %[C,IA,IB] = intersect(datestr(tv),datestr(t),'rows');
    %A = A(IA);
    %T = T(IB);
    cut = find(isnan(A) | isnan(T) | A > 700 | A < -200 | T >700 | T < -200 |...
        H == 0 | Le == 0 | Rn(ind) == 0 );
    A = clean(A,1,cut);
    T = clean(T,1,cut);
    %Rn_clean = clean(Rn(ind),1,cut);
    %G_clean = clean(G(ind),1,cut);
    [p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);

    fig_num = fig_num+fig_num_inc;figure(fig_num);clf;
    plot(Rn(ind)-G(ind),H+Le,'.',...
        A,T,'o',...
        EBax,EBax,...
        EBax,polyval(p,EBax),'--');
    text(-100, 400, sprintf('T = %2.3fA + %2.3f, R2 = %2.3f',p,R2));
    xlabel('Ra (W/m2)');
    ylabel('H+LE (W/m2)');
    title({'Eddy Correlation: ';'Energy budget'});
    h = gca;
    set(h,'YLim',EBax,'XLim',EBax);
    grid on;zoom on;
catch
    disp('...EBC regression plot failed');
end
%-----------------------------------
% Soil Tc's for SHF correction
%-----------------------------------
if strcmp(SiteID,'HP09')
trace_name  = 'HP09-Soil temperature at 3 cm for SHF correction';

trace_path  = str2mat(fullfile(pthClim,'TC_3cm_1_AVG'),fullfile(pthClim,'TC_3cm_2_AVG'));
trace_legend = str2mat('Rep 1','Rep 2');

trace_units = '(W m^{-2})';
y_axis      = [0 35 ];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end
%----------------------------------------------------------
% Soil Moisture Profile
%----------------------------------------------------------

if strcmp(SiteID,'HP11')

    trace_name  = [SiteID '-Soil Moisture profile'];
trace_path  = str2mat(fullfile(pthClim,'CS616_percent1'),fullfile(pthClim,'CS616_percent2'),...
                      fullfile(pthClim,'CS616_percent3'),fullfile(pthClim,'CS616_percent4'),...
                      fullfile(pthClim,'CS616_percent5'));
trace_legend= str2mat('VWC_{3cm}','VWC_{10cm}','VWC_{20cm}','VWC_{50cm}','VWC_{80cm}');
trace_units = '';
y_axis      = [0 1];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 

if pause_flag == 1;pause;end

end

%----------------------------------------------------------
% MPS sensors
%----------------------------------------------------------

if strcmp(SiteID,'HP11')

    trace_name  = [SiteID '-Moisture Potential'];
trace_path  = str2mat(fullfile(pthClim,'MPS_kPa1'),fullfile(pthClim,'MPS_kPa2'),...
                      fullfile(pthClim,'MPS_kPa3'),fullfile(pthClim,'MPS_kPa4'),...
                      fullfile(pthClim,'MPS_kPa5'));
trace_legend= str2mat('MPS_{3cm}','MPS_{10cm}','MPS_{20cm}','MPS_{50cm}','MPS_{80cm}');
trace_units = '(kPa)';
y_axis      = [-100 0];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 

if pause_flag == 1;pause;end

end
%-----------------------------------
% Soil CO2 measurements
%-----------------------------------
if strcmp(SiteID,'HP09')
trace_name  = 'HP09-Soil CO2 concentration';

% June 15, 2010
%trace_path  = str2mat(fullfile(pthClim,'GMM_0cm_AVG'),fullfile(pthClim,'GMM_5cm_AVG'),fullfile(pthClim,'GMM_15cm_AVG'),...
%                     fullfile(pthClim,'GMM_30cm_AVG'),fullfile(pthClim,'GMM_50cm_AVG')); %
                      
trace_path  = str2mat(fullfile(pthClim,'GMM_0cm'),fullfile(pthClim,'GMM_5cm'),fullfile(pthClim,'GMM_15cm'),...
                      fullfile(pthClim,'GMM_30cm'),fullfile(pthClim,'GMM_50cm'));                      
trace_legend = str2mat('0 cm','5 cm','15 cm','30 cm','50 cm');

trace_units = 'ppm_v';
y_axis      = [0 12000 ];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end
end
%----------------------------------------------------------
% PAR
%----------------------------------------------------------

trace_name  = [SiteID '-PAR above canopy'];
if strcmp(SiteID,'HP09')
  trace_path  = str2mat(fullfile(pthClim,'PAR_dn_AVG'),fullfile(pthClim,'PAR_up_AVG'));
  trace_legend= str2mat('PAR_{uw}','PAR_{dw}');
elseif strcmp(SiteID,'HP11')
 trace_path  = str2mat(fullfile(pthClim,'Par_DownWell_Avg'),fullfile(pthClim,'Par_UpWell_Avg'));
  trace_legend= str2mat('PAR_{uw}','PAR_{dw}');
end

trace_units = '(\mumol photons m^{-2} s^{-1})';
y_axis      = [-5 2500];
fig_num = fig_num + fig_num_inc;
% if SiteID == 'MPB1'
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end




%-----------------------------------
% SW comparison: CNR1 and Dave's Eppley
%-----------------------------------
% if SiteID == 'MPB3'
%     trace_name  = 'SW comparison: CNR1 and Dave''s Eppley';
%     trace_path  = str2mat(fullfile(pthClim,'swu_3m_Avg'),fullfile(pthClim,'swu_Avg'));
%     trace_legend = str2mat('Eppley swu 3m','CNR1 swu 30m');
%     trace_units = '(W/m^2)';
%     y_axis      = [-10 50];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[110.1 1],[0 0]);
%     if pause_flag == 1;pause;end
% end

% %-----------------------------------
% % Snow Tc
% %-----------------------------------
% % if SiteID=='MPB3'
% %     trace_name  = 'Snow Thermocouple';
% %     trace_path  = str2mat(fullfile(pthClim,'Snow_tc_Avg'),fullfile(pthClim,'Snow_tc_Max'),fullfile(pthClim,'Snow_tc_Min'));
% %     trace_legend = str2mat('Tc Avg','Tc Max','Tc Min');
% %     trace_units = '(^oC)';
% %     y_axis      = [-20 20];
% %     fig_num = fig_num + fig_num_inc;
% %     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% %     if pause_flag == 1;pause;end
% % end
% 
% %-----------------------------------
% % Snow Depth
% %-----------------------------------
% if SiteID=='MPB3'
%     trace_name  = 'Snow Depth';
%     trace_path  = str2mat(fullfile(pthClim,'SnowDepth_Avg'),fullfile(pthClim,'SnowDepth_Max'),fullfile(pthClim,'SnowDepth_Min'));
%     trace_legend = str2mat('Snowdepth Avg','Snowdepth Max','Snowdepth Min');
%     trace_units = '(m)';
%     y_axis      = [0 5];
%     fig_num = fig_num + fig_num_inc;
%     x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[-1 -1 -1],[-3.6 -3.6 -3.6] );
%     if pause_flag == 1;pause;end
% end
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



