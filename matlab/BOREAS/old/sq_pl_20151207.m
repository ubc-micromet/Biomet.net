function [t,x] = sq_pl(ind, year, SiteID, select, fig_num_inc,pause_flag)
% SQ_pl - plotting program for Shell Quest CCS site
%       -created from hp_pl
%
%
% file created: May 30, 2012

% Revisions:
% 

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

GMTshift = 6/24;                                 %changed from 8/24 (Nov16 2010)
% GMTshift = 1/3;                                  
pthClim = biomet_path(year,'SQT','cl');         % get the climate data path (points to SQT always)
pthFl   = biomet_path(year,'SQT','fl');         % get the eddy data path (EC measured at SQT untl July 4, 2014, then moved to SQM).
pthClim = pthFl;                                 % all climate traces are output to Flux folders as instrument channels
pthCNR4 = biomet_path(year,'SQM','cl'); 

%pthCtrl = [];

axis1 = [340 400];
axis2 = [-10 5];
axis3 = [-50 250];
axis4 = [-50 250];    

st = min(ind);                                   % first day of measurements
ed = max(ind)+1;                                 % last day of measurements (approx.)
ind = st:ed;

tv=read_bor(fullfile(pthFl,'clean_tv'),8);             % get decimal time from the data base
t = tv - tv(1) + 1 - GMTshift;                  % convert time to decimal DOY local time
t_all = t;                                          % save time trace for later
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;
%whitebg('w'); 

ind_newEC=find(tv(ind)>=datenum(2014,7,4));

dv_x = datevec(tv(ind(1)));
year_x = dv_x(1);
currentDate = datenum(year,1,ind(1));
if isempty(ind_newEC) % EC array and climate sensors collocated
    pthEC=pthFl;
    c = fr_get_init(SiteID,currentDate);
%elseif length(ind_newEC)<ind % EC data from both array positions is being plotted (SQT and SQM)
else
    if year_x==2014
      ECnewLoc = 1;
    elseif year_x>=2015
      ECnewLoc = 2;
    end
    pthEC=biomet_path(year,'SQM','fl');
    pthLgr = biomet_path(year,'SQM','Flux_Logger');
    fr_set_site('SQM','n');
    c = fr_get_init('SQM',currentDate);
end



IRGAnum = c.System(1).Instrument(2);
SONICnum = c.System(1).Instrument(1);


%----------------------------------------------------------
% Air Temp HMP
%----------------------------------------------------------
trace_name  = [ 'SQ-Air temperature HMP'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_4'),fullfile(pthFl,'Instrument_5.Min_4'),fullfile(pthFl,'Instrument_5.Max_4'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp Sonic
%----------------------------------------------------------
trace_name  = ['SQ-Air temperature Sonic'];
if ~ECnewLoc
  trace_path  = str2mat(fullfile(pthFl,'Instrument_1.Avg_4'),fullfile(pthFl,'Instrument_1.Min_4'),fullfile(pthFl,'Instrument_1.Max_4'));
                         trace_legend= str2mat('Avg','Min','Max');
elseif ECnewLoc==1
  trace_path  = str2mat(fullfile(pthEC,'Instrument_2.Avg_4'),fullfile(pthEC,'Instrument_2.Min_4'),fullfile(pthEC,'Instrument_2.Max_4'),...
                        fullfile(pthFl,'Instrument_1.Avg_4'),fullfile(pthFl,'Instrument_1.Min_4'),fullfile(pthFl,'Instrument_1.Max_4'),...
                         fullfile(pthLgr,'computed_fluxes/sonic_air_temperature'));
  trace_legend= str2mat('Avg','Min','Max','Avg_{oldloc}','Min_{oldloc}','Max_{oldloc}','Sonic T_{air} logger');
else
  trace_path  = str2mat(fullfile(pthEC,'Instrument_2.Avg_4'),fullfile(pthEC,'Instrument_2.Min_4'),fullfile(pthEC,'Instrument_2.Max_4'),...
                         fullfile(pthLgr,'computed_fluxes/sonic_air_temperature'));
  trace_legend= str2mat('Avg','Min','Max','Sonic T_{air} logger');
end
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp comparison
%----------------------------------------------------------
trace_name  = ['SQ-Air temperature comparison'];
if ~ECnewLoc
  trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_4'),fullfile(pthEC,'Instrument_1.Avg_4'));
  trace_legend= str2mat('HMP Tair','Sonic_{Tc}');
elseif ECnewLoc==1
  trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_4'),fullfile(pthEC,'Instrument_2.Avg_4'),fullfile(pthFl,'Instrument_1.Avg_4'),...
                           fullfile(pthLgr,'computed_fluxes/sonic_air_temperature') );
  trace_legend= str2mat('HMP Tair','Sonic_{Tc}','Sonic_{Tc} oldloc','Sonic T_{air}');
else
  trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_4'),fullfile(pthEC,'Instrument_2.Avg_4'),...
                           fullfile(pthLgr,'computed_fluxes/sonic_air_temperature') );
  trace_legend= str2mat('HMP Tair','Sonic_{Tc}','Sonic T_{air}');  
end
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% RH HMP
%----------------------------------------------------------

trace_name  = ['SQ-RH HMP'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_5'),fullfile(pthFl,'Instrument_5.Min_5'),fullfile(pthFl,'Instrument_5.Max_5'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(\circC)';
y_axis      = [0 120];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Voltages SQT mast
%----------------------------------------------------------
 trace_name  = ['Battery voltage SQ Climate'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_7.Avg_2'),fullfile(pthFl,'Instrument_7.Min_2'),fullfile(pthFl,'Instrument_7.Max_2'));
trace_legend= str2mat('SQT logger BattVolt_{Avg}','SQT logger BattVolt_{Min}','SQT logger BattVolt_{Max}');
trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Voltage SQM tripod
%----------------------------------------------------------

if ECnewLoc
    trace_name  = [SiteID '-Battery voltage SQ EC'];
    trace_path  = str2mat(fullfile(pthLgr,'BattVolt_Avg'),fullfile(pthLgr,'BattVolt_Max'),fullfile(pthLgr,'BattVolt_Min'));
    trace_legend= str2mat('EC logger BattVolt_{Avg}','EC logger BattVolt_{Max}','EC logger BattVolt_{Min}');
    trace_units = '(V)';
    y_axis      = [11.5 16];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% Battery Temp SQM tripod
%----------------------------------------------------------

if ECnewLoc
    trace_name  = [SiteID '-Battery Temperature SQ EC'];
    trace_path  = str2mat(fullfile(pthLgr,'Battery_temp_Avg'),fullfile(pthLgr,'Battery_temp_Max'),fullfile(pthLgr,'Battery_temp_Min'));
    trace_legend= str2mat('EC logger BattTemp_{Avg}','EC logger BattTemp_{Max}','EC logger BattTemp_{Min}');
    trace_units = '(V)';
    y_axis      = [-5 40];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% IRGA Diagnostic
%----------------------------------------------------------



    trace_name  = 'SQ-IRGA diag';
    if ~ECnewLoc
      trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_8'));
      Idiag_lgr = read_bor(fullfile(pthFl,'Instrument_2.Avg_8'));
      Idiag_lgrmax = read_bor(fullfile(pthFl,'Instrument_2.Max_8'));
      Idiag_lgrmin = read_bor(fullfile(pthFl,'Instrument_2.Min_8'));
    else % SQM
      trace_path  = str2mat(fullfile(pthEC,'Instrument_3.Avg_5')); 
      Idiag_lgr = read_bor(fullfile(pthEC,'Instrument_3.Avg_5'));
      Idiag_lgrmax = read_bor(fullfile(pthEC,'Instrument_3.Max_5'));
      Idiag_lgrmin = read_bor(fullfile(pthEC,'Instrument_3.Min_5'));
      
      AGC_Avg=read_bor(fullfile(pthLgr,'Irga_AGC_Avg'));
      AGC_Max=read_bor(fullfile(pthLgr,'Irga_AGC_Max'));
      AGC_Min=read_bor(fullfile(pthLgr,'Irga_AGC_Min'));
    end
    
    if ~ECnewLoc
        trace_legend= str2mat('Idiag LI7200');
        trace_units = '';
        y_axis      = [5000 10000];
        fig_num = fig_num + fig_num_inc;
        x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    end
    
    % break up diagnostic flag by binary bit
%     Idiag_lgr = read_bor(fullfile(pthFl,'Instrument_2.Avg_8'));
%     Idiag_lgrmax = read_bor(fullfile(pthFl,'Instrument_2.Max_8'));
%     Idiag_lgrmin = read_bor(fullfile(pthFl,'Instrument_2.Min_8'));
    if max(Idiag_lgr) > 100
    ind_bad= find( Idiag_lgr==-999 | isnan(Idiag_lgr) );
    Idiag_lgr(ind_bad)=0;
    
    ind_bad= find( Idiag_lgrmax==-999 | isnan(Idiag_lgrmax) );
    Idiag_lgrmax(ind_bad)=0;
    
    ind_bad= find( Idiag_lgrmin==-999 | isnan(Idiag_lgrmin) );
    Idiag_lgrmin(ind_bad)=0;
    
    

    diag_rawlgr  = dec2bin(round(Idiag_lgr));
    Head_lgr     = bin2dec(diag_rawlgr(:,1));
    ToutTC_lgr   = bin2dec(diag_rawlgr(:,2));
    TinTC_lgr    = bin2dec(diag_rawlgr(:,3));
    Aux_lgr      = bin2dec(diag_rawlgr(:,4));
    DeltaP_lgr   = bin2dec(diag_rawlgr(:,5));
    Chopper_lgr  = bin2dec(diag_rawlgr(:,6));
    Detector_lgr = bin2dec(diag_rawlgr(:,7));
    PLL_lgr      = bin2dec(diag_rawlgr(:,8));
    Sync_lgr     = bin2dec(diag_rawlgr(:,9));
    AGC_lgr      = bin2dec(diag_rawlgr(:,10:end))*6.25+6.25;
    
    diag_rawlgrmax  = dec2bin(round(Idiag_lgrmax));
    Head_lgrmax     = bin2dec(diag_rawlgrmax(:,1));
    ToutTC_lgrmax   = bin2dec(diag_rawlgrmax(:,2));
    TinTC_lgrmax    = bin2dec(diag_rawlgrmax(:,3));
    Aux_lgrmax      = bin2dec(diag_rawlgrmax(:,4));
    DeltaP_lgrmax   = bin2dec(diag_rawlgrmax(:,5));
    Chopper_lgrmax  = bin2dec(diag_rawlgrmax(:,6));
    Detector_lgrmax = bin2dec(diag_rawlgrmax(:,7));
    PLL_lgrmax      = bin2dec(diag_rawlgrmax(:,8));
    Sync_lgrmax     = bin2dec(diag_rawlgrmax(:,9));
    AGC_lgrmax      = bin2dec(diag_rawlgrmax(:,10:end))*6.25+6.25;
    
    diag_rawlgrmin  = dec2bin(round(Idiag_lgrmin));
    Head_lgrmin     = bin2dec(diag_rawlgrmin(:,1));
    ToutTC_lgrmin   = bin2dec(diag_rawlgrmin(:,2));
    TinTC_lgrmin    = bin2dec(diag_rawlgrmin(:,3));
    Aux_lgrmin      = bin2dec(diag_rawlgrmin(:,4));
    DeltaP_lgrmin   = bin2dec(diag_rawlgrmin(:,5));
    Chopper_lgrmin  = bin2dec(diag_rawlgrmin(:,6));
    Detector_lgrmin = bin2dec(diag_rawlgrmin(:,7));
    PLL_lgrmin      = bin2dec(diag_rawlgrmin(:,8));
    Sync_lgrmin     = bin2dec(diag_rawlgrmin(:,9));
    AGC_lgrmin      = bin2dec(diag_rawlgrmin(:,10:end))*6.25+6.25;
    

    % diagnostic plots LI-7200

    % Head Detetctor
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Head Detector (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Head_lgr Head_lgrmax Head_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end

    % Tout TC
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Tout TC (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [ToutTC_lgr ToutTC_lgrmax ToutTC_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end

    % Tin TC
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Tin TC (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [TinTC_lgr TinTC_lgrmax TinTC_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end

    % Aux
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Aux (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Aux_lgr Aux_lgrmax Aux_lgrmin+0.1], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end

    % DeltaP
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, DeltaP (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [DeltaP_lgr DeltaP_lgrmax DeltaP_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
    
    % Chopper
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Chopper (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Chopper_lgr Chopper_lgrmax Chopper_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
    
    % Detector
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Detector (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Detector_lgr Detector_lgrmax Detector_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
    
    % PLL
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, PLL (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [PLL_lgr PLL_lgrmax PLL_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
    
    % Sync
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, Sync (OK = 1)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}+0.1');
    trace_units = '';
    y_axis      = [0 1];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [Sync_lgr Sync_lgrmax Sync_lgrmin+0.1 ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
    
    % AGC
    trace_name  = 'Climate/Diagnostics: IRGA diagnostics, AGC (window clarity %)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}');
    trace_units = '';
    y_axis      = [0 100];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [AGC_lgr AGC_lgrmax AGC_lgrmin ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
    
  end

 % AGC
    
 if ECnewLoc
    AGC_lgr=AGC_Avg;
    AGC_lgrmax = AGC_Max;
    AGC_lgrmin = AGC_Min;
    
    trace_name  = 'SQ: IRGA diagnostics, AGC (window clarity %)';
    trace_legend= str2mat('logger_{AVG}','logger_{MAX}','logger_{MIN}');
    trace_units = '';
    y_axis      = [0 100];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( [AGC_lgr AGC_lgrmax AGC_lgrmin ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    if pause_flag == 1;pause;end
 end
%--------------------------------------------------------
% Number of Samples (sample frequency)
%--------------------------------------------------------

if ~ECnewLoc
    SONICnum = 1;
    IRGAnum = 2;
else
    SONICnum = 2;
    IRGAnum = 3;
end

instrumentString = sprintf('Instrument_%d.',IRGAnum);
sonicString =  sprintf('Instrument_%d.',SONICnum);

numOfSamplesIRGA = read_bor([pthEC instrumentString 'MiscVariables.NumOfSamples']);
numOfSamplesSonic = read_bor([pthEC sonicString 'MiscVariables.NumOfSamples']);
numOfSamplesEC = read_bor([pthEC 'MainEddy.MiscVariables.NumOfSamples']);

fig_num = fig_num+1;figure(fig_num);clf;
plot(t,numOfSamplesSonic(ind),t,numOfSamplesIRGA(ind),t,numOfSamplesEC(ind));
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[5000 40000])
title({'Eddy Correlation: ';'Number of samples collected'});
set_figure_name(SiteID)
ylabel('1')
legend('Sonic','IRGA','EC')

%----------------------------------------------------------
% CO2 mixing ratio
%----------------------------------------------------------
% trace_name  = 'HP09-Climate/Diagnostics: CO2';
% trace_path  = str2mat(fullfile(pthEC,'Instrument_5.Avg_1'),fullfile(pthEC,'Instrument_5.Min_1'),fullfile(pthEC,'Instrument_5.Max_1')...
%     ,fullfile(pthFl,'CO2_Avg'));
%trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}','CO2_{Avg
%Logger}');

trace_name  = ['SQ-CO2 mixing ratio'];
trace_units = '(\mumol CO_{2} mol^{-1} dry air)';
y_axis      = [300 800];

if ~ECnewLoc
  trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_1'),fullfile(pthFl,'Instrument_2.Min_1'),...
                fullfile(pthFl,'Instrument_2.Max_1'),fullfile(pthFl,'Instrument_6.Avg_1'));
            trace_legend= str2mat('CO2_{Avg}','CO2_{Min}','CO2_{Max}','Boreal GasFinder');
elseif ECnewLoc==1
   trace_path  = str2mat(fullfile(pthLgr,'computed_fluxes/co2_avg_irga_op_logger'),fullfile(pthEC,'Instrument_3.Avg_1'),fullfile(pthEC,'Instrument_3.Min_1'),...
                fullfile(pthEC,'Instrument_3.Max_1'),fullfile(pthFl,'Instrument_2.Avg_1'),fullfile(pthFl,'Instrument_2.Min_1'),...
                fullfile(pthFl,'Instrument_2.Max_1'),fullfile(pthFl,'Instrument_6.Avg'));
            trace_legend= str2mat('CO2_{logger}','CO2_{Avg}','CO2_{Min}','CO2_{Max}','CO2_{AvgOldLoc}','CO2_{MinOldLoc}','CO2_{MaxOldLoc}','Boreal GasFinder');
else
%   trace_path  = str2mat(fullfile(pthLgr,'computed_fluxes/co2_avg_irga_op_logger'),fullfile(pthEC,'Instrument_3.Avg_1'),fullfile(pthEC,'Instrument_3.Min_1'),...
%                 fullfile(pthEC,'Instrument_3.Max_1'),fullfile(pthFl,'Instrument_6.Avg'));
  trace_path  = str2mat(fullfile(pthLgr,'computed_fluxes/co2_avg_irga_op_logger'),fullfile(pthLgr,'CO2_Avg'),fullfile(pthLgr,'CO2_Min'),...
                fullfile(pthLgr,'CO2_Max'),fullfile(pthFl,'Instrument_6.Avg'));            
            trace_legend= str2mat('CO2_{logger}','CO2_{Avg}','CO2_{Min}','CO2_{Max}','Boreal GasFinder');  
end
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%--------------------------------------------
% Boreal Gas finder vs. IRGA 1:1 for [CO2]
%--------------------------------------------

try
    GF = read_bor(fullfile(pthFl,'Instrument_6.Avg'));
    if ~ECnewLoc
        LICOR=read_bor(fullfile(pthFl,'Instrument_2.Avg_1'));
    else
        LICOR=read_bor(fullfile(pthEC,'Instrument_3.Avg_1'));
    end
    fig_num = fig_num + fig_num_inc;
    % quick limit check/clean
    LICOR(LICOR>2000|LICOR<0)=NaN;
    GF(GF>2000|GF<0)=NaN;
    ind_reg=find(~isnan(GF(ind))&~isnan(LICOR(ind))&(LICOR(ind)~=0.)&(GF(ind)~=0.));
    figure(fig_num);
    plot_regression(LICOR(ind(ind_reg)),GF(ind(ind_reg)),[],[],'ortho');
    title('Licor 7200 vs. Boreal GasFinder');
    grid on;

    xlabel('LICOR [CO2] (ppm)');
    ylabel('GasFinder [CO2] (ppm)');
    if pause_flag == 1;pause;end
catch
    disp('Problem plotting 1:1 of LI-7200 vs. GasFinder'); clf(fig_num);
    close(gcf);
end
%----------------------------------------------------------
% H2O mixing ratio
%----------------------------------------------------------

trace_name  = ['SQ-H2O mixing ratio'];
trace_units = '(mmol H_{2}O mol^{-1} dry air)';
y_axis      = [0 30];

if ~ECnewLoc
  trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_2'),fullfile(pthFl,'Instrument_2.Min_2'),...
                fullfile(pthFl,'Instrument_2.Max_2'));
            trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H2O_{Max}');
elseif ECnewLoc==1
   trace_path  = str2mat(fullfile(pthEC,'Instrument_3.Avg_2'),fullfile(pthEC,'Instrument_3.Min_2'),...
                fullfile(pthEC,'Instrument_3.Max_2'),fullfile(pthFl,'Instrument_2.Avg_2'),fullfile(pthFl,'Instrument_2.Min_2'),...
                fullfile(pthFl,'Instrument_2.Max_2'),fullfile(pthLgr,'computed_fluxes/h2o_avg_irga_op_logger'));
            trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H2O_{Max}','H2O_{AvgOldLoc}','H2O_{MinOldLoc}','H2O_{MaxOldLoc}',...
                                   'H2O_{logger}');
else 
   trace_path  = str2mat(fullfile(pthEC,'Instrument_3.Avg_2'),fullfile(pthEC,'Instrument_3.Min_2'),...
                fullfile(pthEC,'Instrument_3.Max_2'),fullfile(pthLgr,'computed_fluxes/h2o_avg_irga_op_logger'));
            trace_legend= str2mat('H2O_{Avg}','H2O_{Min}','H2O_{Max}',...
                                   'H2O_{logger}'); 
end
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%---------------------------------------------------------
% Delay Times (LI-7200)
%---------------------------------------------------------

nMainEddy = 1;
    %-----------------------------------------------
    % Read calculated dealy times from database
delay_co2_calc = read_bor([pthEC 'MainEddy.Delays.Calculated_1']);
delay_h2o_calc = read_bor([pthEC 'MainEddy.Delays.Calculated_2']);

    %-------------------------------------------------------
    % Read delay times used in calculation (one value a day)
delay_co2_set = read_bor([pthEC 'MainEddy.Delays.Implemented_1']);
delay_h2o_set = read_bor([pthEC 'MainEddy.Delays.Implemented_2']);

fig_num = fig_num+1;figure(fig_num);clf

plot(t,[delay_co2_calc(ind) delay_h2o_calc(ind)],'o')
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2));
    set(h,'color','y','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2));
    set(h,'color','m','linewidth',1.5)
end
grid on;zoom on;xlabel('DOY')
title({'SQ Eddy Correlation: ';'LI-7200 CO_2 & H_2O delay times'})
set_figure_name(SiteID)
ylabel('Samples')
set(gca,'YLim',[-50 50]);
legend('CO_2','H_2O','CO_2 setup','H_2O setup',-1)

%-----------------------------------------------
% Delay times histogram
%------------------------------------------------

    fig_num = fig_num+1;figure(fig_num);clf;
    subplot(2,1,1); hist(delay_co2_calc(ind),200);
    set(gca,'XLim',[-50 50]);
    title({'SQ Eddy Correlation: ';'Delay times histogram'})
    set_figure_name(SiteID)
    if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
        ax=axis;
        h = line(c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2),ax(3:4));
        set(h,'color','y','linewidth',2)
    end
    ylabel('CO_2 delay times')
    subplot(2,1,2); hist(delay_h2o_calc(ind),200);
    set(gca,'XLim',[-50 50]);
    if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
        ax=axis;
        h = line(c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2),ax(3:4));
        set(h,'color','y','linewidth',2)
    end
    ylabel('H_{2}O delay times')
    zoom_together(gcf,'x','on')

% ----------------------------------
% Flow rate - IRGA
% -----------------------------------
if ~ECnewLoc
trace_name  = ['SQ-LI-7200 Flow Rate'];
trace_path  = str2mat(fullfile(pthEC,'Instrument_2.Avg_10'),fullfile(pthEC,'Instrument_2.Min_10'),fullfile(pthEC,'Instrument_2.Max_10'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(\circC)';
y_axis      = [0 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end
end

%----------------------------------------------------------
% Sonic Diagnostic
%----------------------------------------------------------
% try 
% trace_name  = [SiteID '-Sonic diag'];
% 
% trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_2'),fullfile(pthFl,'Instrument_2.Min_2'),fullfile(pthFl,'Instrument_2.Max_2'));
% %trace_legend= str2mat('Sdiag','Sdiag logger');
% trace_legend= str2mat('Sdiag logger_{avg}','Sdiag logger_{max}','Sdiag logger_{min}','Sdiag EC_{avg}');
% trace_units = '';
% y_axis      = [-10 700];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% npts_Apm_Low_Sum_Bad     = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.BadPointsFlag.Apm_Low_Sum_Bad'));
% npts_Apm_Hi_Sum_Bad      = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.BadPointsFlag.Apm_Hi_Sum_Bad'));
% npts_Poor_Lock_Sum_Bad   = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.BadPointsFlag.Poor_Lock_Sum_Bad'));
% npts_Path_Length_Sum_Bad = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.BadPointsFlag.Path_Length_Sum_Bad'));
% npts_Pts_Sum_Bad         = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.BadPointsFlag.Pts_Sum_Bad'));
% 
% 
%  % Number of bad points per hhour by type
%     
%      fig_num = fig_num + fig_num_inc;
%      figure(fig_num);
%      plot(t,npts_Apm_Low_Sum_Bad(ind),'rd',t,npts_Apm_Hi_Sum_Bad(ind),'bs',t,...
%            npts_Poor_Lock_Sum_Bad(ind),'go',t,npts_Path_Length_Sum_Bad(ind),'y^',...
%            t,npts_Pts_Sum_Bad(ind),'m>','MarkerSize',10,'Linewidth',2);
%      trace_name=[SiteID ' Climate/Diagnostics: Sonic errors per half-hour by type'];
%      title(trace_name);
%      set(fig_num,'menubar','none',...
%             'numbertitle','off',...
%             'Name',trace_name);
%      legend('Apm_{Low}','Apm_{Hi}','Poor Lock','Path Length','Pts');
%      %set(gca,'YLim',[0 20])
%      grid on;
%     if pause_flag == 1;pause;end
% catch
%     disp(lasterr);
% end
%----------------------------------------------------------
% Sonic wind speed logger
%----------------------------------------------------------
trace_name  = ['SQ-RMY81000 wind vector components (Logger)'];
if ~ECnewLoc
  trace_path  = str2mat(fullfile(pthEC,'Instrument_1.Avg_1'),fullfile(pthEC,'Instrument_1.Avg_2'),fullfile(pthEC,'Instrument_1.Avg_3'));
  trace_legend= str2mat('u wind','v wind','w wind');
elseif ECnewLoc==1
  trace_path  = str2mat(fullfile(pthEC,'Instrument_2.Avg_1'),fullfile(pthEC,'Instrument_2.Avg_2'),fullfile(pthEC,'Instrument_2.Avg_3'),...
                   fullfile(pthFl,'Instrument_1.Avg_1'),fullfile(pthFl,'Instrument_1.Avg_2'),fullfile(pthFl,'Instrument_1.Avg_3'));
               trace_legend= str2mat('u wind','v wind','w wind','u wind (oldloc)','v wind (oldloc)','w wind (oldloc)');
else
  trace_path  = str2mat(fullfile(pthLgr,'u_wind_Avg'),fullfile(pthLgr,'v_wind_Avg'),fullfile(pthLgr,'w_wind_Avg'));  
  trace_legend= str2mat('u wind','v wind','w wind');
end
%trace_legend= str2mat('u wind','v wind','w wind','u wind (oldloc)','v wind (oldloc)','w wind (oldloc)');
trace_units = '(m s^{-1})';
y_axis      = [-10 10];
fig_num = fig_num + fig_num_inc;
x_CSAT = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%-----------------------------------
% Net radiation
%-----------------------------------


trace_name  = 'SQM-Net radiation above canopy';
trace_path  = str2mat(fullfile(pthCNR4,'Rn_Avg'));
trace_legend = str2mat('Net Avg');
trace_units = '(W m^{-2})';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation SW and LW
%-----------------------------------


trace_name  = 'SQM-Radiation above canopy';
trace_path  = str2mat(fullfile(pthCNR4,'short_dn_Avg'),fullfile(pthCNR4,'short_up_Avg'),fullfile(pthCNR4,'long_dn_Avg'),fullfile(pthCNR4,'long_up_Avg'));
trace_legend = str2mat('swu Avg','swd Avg','lwu Avg','lwd Avg');
trace_units = '(W m^{-2})';
y_axis      = [-200 1000];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end

%---------------------------------
% Corrected Radiation above Canopy
%----------------------------------

T_CNR4 = read_bor(fullfile(pthCNR4,'cnr4_T_C_Avg'));
LongWaveOffset =(5.67E-8*(273.15+T_CNR4).^4);
S_upper_AVG = read_bor(fullfile(pthCNR4,'short_up_Avg'));
S_lower_AVG = read_bor(fullfile(pthCNR4,'short_dn_Avg'));
lwu = read_bor(fullfile(pthCNR4,'long_dn_Avg'));
lwd = read_bor(fullfile(pthCNR4,'long_up_Avg'));
trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
trace_units = '(W m^{-2})';
y_axis      = [-200 1000];
L_upper_AVG = lwd + LongWaveOffset;
L_lower_AVG = lwu + LongWaveOffset;
Net_cnr4_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
trace_path = [S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr4_calc];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
if pause_flag == 1;pause;end



%-----------------------------------
% Global Irradiance
%-----------------------------------
trace_name  = ['SQ-Global Irradiance'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_7'));
trace_legend = str2mat('Net Avg');
trace_units = '(W m^{-2})';
y_axis      = [-200 1400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Net radiation SW and LW
%-----------------------------------

% if strcmp(SiteID,'HP09')
%  trace_name  = 'HP09-Radiation above canopy';
%  trace_path  = str2mat(fullfile(pthClim,'SW_DW_AVG'),fullfile(pthClim,'SW_UW_AVG'),fullfile(pthClim,'LW_DW_AVG'),fullfile(pthClim,'LW_UW_AVG'));
% elseif strcmp(SiteID,'HP11')
%  trace_name  = 'HP11-Radiation above canopy';
%  trace_path  = str2mat(fullfile(pthClim,'short_dn_Avg'),fullfile(pthClim,'short_up_Avg'),fullfile(pthClim,'long_dn_Avg'),fullfile(pthClim,'long_up_Avg'));
% end
% trace_legend = str2mat('swu Avg','swd Avg','lwu Avg','lwd Avg');
% trace_units = '(W m^{-2})';
% y_axis      = [-200 2000];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end

%---------------------------------
% Corrected Radiation above Canopy
%----------------------------------

% if strcmp(SiteID,'HP11')
% T_CNR4 = read_bor(fullfile(pthClim,'cnr4_T_C_Avg'));
% LongWaveOffset =(5.67E-8*(273.15+T_CNR4).^4);
% 
% S_upper_AVG = read_bor(fullfile(pthClim,'short_up_Avg'));
% S_lower_AVG = read_bor(fullfile(pthClim,'short_dn_Avg'));
% lwu = read_bor(fullfile(pthClim,'long_dn_Avg'));
% lwd = read_bor(fullfile(pthClim,'long_up_Avg'));
% trace_legend = str2mat('swd Avg','swu Avg','lwd Avg','lwu Avg','Net_{calc}');
% trace_units = '(W m^{-2})';
% y_axis      = [-200 1400];
% L_upper_AVG = lwd + LongWaveOffset;
% L_lower_AVG = lwu + LongWaveOffset;
% Net_cnr4_calc = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
% trace_path = [S_upper_AVG S_lower_AVG L_upper_AVG L_lower_AVG Net_cnr4_calc];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num);
% if pause_flag == 1;pause;end
% end

%----------------------------------------------------------
% Barometric Pressure
%----------------------------------------------------------
trace_name  = ['SQ-Barometric pressure'];

trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_3'),fullfile(pthFl,'Instrument_2.Avg_6'),fullfile(pthFl,'Instrument_2.Avg_7'),...
                      fullfile(pthLgr,'Irga_P_Avg') );
trace_legend= str2mat('Pbar(Sea Level)','Pbar (absolute)','IRGA_{cell} (oldloc)','IRGA_{head} (oldloc)','IRGA_{cell}');

if ~ECnewLoc
  trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_3'),fullfile(pthFl,'Instrument_2.Avg_6'),fullfile(pthFl,'Instrument_2.Avg_7'),...
                      fullfile(pthLgr,'Irga_P_Avg') );
  trace_legend= str2mat('Pbar(Sea Level)','Pbar (absolute)','IRGA_{cell} (oldloc)','IRGA_{head} (oldloc)','IRGA_{cell}');
else 
  trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_3'),fullfile(pthEC,'Instrument_3.Avg_4'),...
                      fullfile(pthLgr,'Irga_P_Avg') );
  trace_legend= str2mat('Pbar(Sea Level)','Pbar (absolute)','IRGA_{cell}','IRGA_{cell_lgr}');
end


trace_units = '(kPa)';
y_axis      = [-10 110];

Tair=read_bor(fullfile(pthFl,'Instrument_5.Avg_4'));
Pbar  = read_bor(fullfile(pthFl,'Instrument_5.Avg_3'));
UBC_Biomet_constants;
Psite = Pbar.*exp(9.8*(0-624)./(Rd.*(Tair+ZeroK))); % calculate absolute pressure from sea level normalized pressure (use dry air correction)
 
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
clf;
if ~ECnewLoc
 plt_msig( [x(:,1) Psite(ind) x(:,2:4)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
 plt_msig( [x(:,1) Psite(ind) x(:,2:3)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num ); 
end
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Gauge Pressure
%----------------------------------------------------------
trace_name  = ['SQ-Gauge Pressure'];

Pbar= read_bor(fullfile(pthFl,'Instrument_5.Avg_3'));
Pcell=read_bor( fullfile(pthLgr,'Irga_P_Avg'));
if ~ECnewLoc
  Pcell=read_bor(fullfile(pthFl,'Instrument_2.Avg_6'));
else
   Pcell=read_bor(fullfile(pthEC,'Instrument_3.Avg_4')); 
end   

Pgauge=Psite-Pcell;

Pgauge(find(Pgauge>90))=NaN;
%Pgauge_old(find(Pgauge_old>90))=NaN;
trace_legend= str2mat('Pgauge','Pgauge_{old}');
trace_units = '(kPa)';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;

x = plt_msig( [Pgauge ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    
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

trace_name  = [ 'SQ-Climate/Diagnostics: Rainfall'];
trace_path  = str2mat(fullfile(pthClim,'Instrument_5.Avg_2'));
trace_legend= str2mat('Rainfall_{tot}');
trace_units = '(mm)';
y_axis      = [0 5];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,1000,0 );

if pause_flag == 1;pause;end

% ----------------------------------------------------------
% Cumulative Precipitation
% ----------------------------------------------------------
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the year

trace_name  = ['SQ-Climate: Cumulative Rain'];
y_axis      = [];
ax = [st ed];
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
x1 = x1*1;   
fig_num = fig_num + fig_num_inc;
x1(find(isnan(x1)))=0;
plt_sig1( tx_new, [1000*cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
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


% %----------------------------------------------------------
% % Covariances
% %----------------------------------------------------------
% trace_name  = [SiteID '-Covariance: w*CO2 (raw)'];
% trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov5'));
% trace_legend= str2mat('wco2_{covAvg}');
% trace_units = '(mmol CO_{2} m^{-2} s^{-1})';
% y_axis      = [-0.05 0.05];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% %----------------------------------------------------------
% % Covariances
% %----------------------------------------------------------
% trace_name  = [SiteID '-Covariance: w*H2O (raw)'];
% trace_path  = str2mat(fullfile(pthFl,'CO2_cov_Cov9'));
% trace_legend= str2mat('wh2o_{covAvg}');
% trace_units = '(mmol H_{2}O m^{-2} s^{-1})';
% if strcmp(SiteID,'HP11')
%   y_axis      = [-0.05 0.5];
% elseif strcmp(SiteID,'HP09')
%    y_axis      = [-0.05 10 ];
% end
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end
% 
% %----------------------------------------------------------
% % Covariances
% %----------------------------------------------------------
% trace_name  = [SiteID '-Covariance: w*T (kinematic)'];
% trace_path  = str2mat(fullfile(pthFl,'Tc_Temp_cov_Cov4'),fullfile(pthFl,'Tsonic_cov_Cov4'));
% trace_legend= str2mat('wTceddy_{covAvg}','wTsonic_{covAvg}');
% trace_units = '(\circC m s^{-1})';
% y_axis      = [-0.05 0.5];
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
% if pause_flag == 1;pause;end

%----------------------------------------------------------
%  CO2 flux rotated and unrotated, WPL-corrected
%----------------------------------------------------------
trace_name  = ['SQ-EC fluxes: Fc'];

if ~ECnewLoc
 Fc_hf = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc'));
 trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
 y_axis      = [-10 15];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig( [ Fc_hf ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif ECnewLoc==1
 Fc_hf = read_bor(fullfile(pthFl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc'));
 Fc_new = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc'));
 Fc_lgr = read_bor(fullfile(pthLgr,'computed_fluxes/fc_blockavg_rotated_50cm_ep_logger'));
 trace_legend = str2mat('Fc','Fc oldloc','Fc_{logger}');
 trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
 y_axis      = [-10 15];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig( [ Fc_new Fc_hf  Fc_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
 Fc_new = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc'));
 Fc_lgr = read_bor(fullfile(pthLgr,'computed_fluxes/fc_blockavg_rotated_50cm_ep_logger'));
 trace_legend = str2mat('Fc','Fc_{logger}');
 trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
 y_axis      = [-10 15];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig( [ Fc_new Fc_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );   
end

if pause_flag == 1;pause;end

%----------------------------------------------------------
% LE
%----------------------------------------------------------


trace_name  = ['SQ-EC Fluxes: LE'];

if ~ECnewLoc
  LE_hf = read_bor(fullfile(pthFl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L')); % LE LICOR
  trace_units = '(W m^{-2} )';                                 
  %trace_legend= str2mat('LE (3 rot from covs)', 'LE logger', 'LE (high freq)');
  y_axis      = [-50 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [ LE_hf], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif ECnewLoc==1
  LE_hf = read_bor(fullfile(pthFl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L')); % LE LICOR
  LE_new = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L')); % LE LICOR 
  LE_lgr = read_bor(fullfile(pthLgr,'computed_fluxes/le_blockavg_rotated_50cm_ep_logger'));
  trace_units = '(W m^{-2} )'; 
  trace_legend= str2mat('LE','LE oldloc','LE_{logger}');
  y_axis      = [-50 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [ LE_new LE_hf LE_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
  LE_new = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L')); % LE LICOR 
  LE_lgr = read_bor(fullfile(pthLgr,'computed_fluxes/le_blockavg_rotated_50cm_ep_logger'));
  trace_units = '(W m^{-2} )'; 
  trace_legend= str2mat('LE','LE_{logger}');
  y_axis      = [-50 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [ LE_new LE_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );  
end
 
if pause_flag == 1;pause;end


%----------------------------------------------------------
% H
%----------------------------------------------------------


trace_name  = ['SQ-EC Fluxes: H'];

if ~ECnewLoc
  H_hf = read_bor(fullfile(pthFl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs')); % LE LICOR
  trace_units = '(W m^{-2} )';                                 
  %trace_legend= str2mat('LE (3 rot from covs)', 'LE logger', 'LE (high freq)');
  y_axis      = [-50 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [ H_hf], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif ECnewLoc==1
  H_hf = read_bor(fullfile(pthFl,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs')); % LE LICOR
  H_new = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs')); % LE LICOR  
  H_lgr = read_bor(fullfile(pthLgr,'computed_fluxes/h_sonic_blockavg_rotated_50cm_logger'));
  trace_units = '(W m^{-2} )'; 
  trace_legend= str2mat('H','H oldloc','H_{logger}');
  y_axis      = [-50 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [ H_new H_hf H_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
  H_new = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs')); % LE LICOR  
  H_lgr = read_bor(fullfile(pthLgr,'computed_fluxes/h_sonic_blockavg_rotated_50cm_logger'));
  trace_units = '(W m^{-2} )'; 
  trace_legend= str2mat('H','H_{logger}');
  y_axis      = [-50 400];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [ H_new H_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num ); 
end
 
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind speed
%----------------------------------------------------------
trace_name  = ['SQ-Wind Speed Comparison'];
if ~ECnewLoc
  wspd_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_1'));
  wspd_sonic = read_bor(fullfile(pthFl,'Instrument_1.MiscVariables.CupWindSpeed'));
  trace_legend= str2mat('cup anemometer','RMY81000');
  trace_units = '(m/s)';
  y_axis      = [0 10];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [wspd_cup2d wspd_sonic ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif ECnewLoc==1
  wspd_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_1'));
  wspd_sonic = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.CupWindSpeed'));
  wspd_sonic_old = read_bor(fullfile(pthFl,'Instrument_1.MiscVariables.CupWindSpeed'));
  trace_legend= str2mat('cup anemometer','RMY81000','RMY81000_{oldloc}');
  trace_units = '(m/s)';
  y_axis      = [0 10];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [wspd_cup2d wspd_sonic wspd_sonic_old], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
  wspd_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_1'));
  u_son = read_bor(fullfile(pthLgr,'u_wind_Avg'));
  v_son = read_bor(fullfile(pthLgr,'v_wind_Avg'));
  wspdson_lgr = (u_son.^2 + v_son.^2).^0.5;
  wspd_sonic = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.CupWindSpeed'));
  trace_legend= str2mat('cup anemometer','RMY81000','RMY81000 (logger)');
  trace_units = '(m/s)';
  y_axis      = [0 10];
  fig_num = fig_num + fig_num_inc;
  x = plt_msig( [wspd_cup2d wspd_sonic wspdson_lgr], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num ); 
end

if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind direction
%----------------------------------------------------------
trace_name  = ['SQ-Wind direction comparison'];

if ~ECnewLoc
  wdir_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_6'));
  wdir_sonic = read_bor(fullfile(pthFl,'Instrument_1.MiscVariables.WindDirection'));
  trace_legend= str2mat('cup anemometer','RMY81000');
   trace_units = '(^o)';
   y_axis      = [0 400];
   fig_num = fig_num + fig_num_inc;
   x = plt_msig( [wdir_cup2d wdir_sonic], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
elseif ECnewLoc==1
  wdir_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_6'));
  wdir_sonic = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.WindDirection'));  
  wdir_sonic_old = read_bor(fullfile(pthFl,'Instrument_1.MiscVariables.WindDirection'));
  trace_legend= str2mat('cup anemometer','RMY81000','RMY81000_{oldloc}');
   trace_units = '(^o)';
   y_axis      = [0 400];
   fig_num = fig_num + fig_num_inc;
   x = plt_msig( [wdir_cup2d wdir_sonic wdir_sonic_old], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
else
  wdir_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_6'));
  wdir_sonic = read_bor(fullfile(pthEC,'Instrument_2.MiscVariables.WindDirection'));  
  wind_lgr = [u_son'; v_son'];
  wdir_lgr   = FR_Sonic_wind_direction(wind_lgr,'RMY');
  trace_legend= str2mat('cup anemometer','RMY81000','RMY81000 (logger)');
   trace_units = '(^o)';
   y_axis      = [0 400];
   fig_num = fig_num + fig_num_inc;
   x = plt_msig( [wdir_cup2d wdir_sonic wdir_lgr'], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );  
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

trace_name  = ['SQ-Soil temperature profile'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_7.Avg_4'),fullfile(pthFl,'Instrument_7.Avg_5'));
trace_legend= str2mat('soilT_{3cm}','soilT_{10cm}');
trace_units = '(\circC)';
y_axis      = [-20 40];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1]); 

if pause_flag == 1;pause;end


%----------------------------------------------------------
% Soil Heat Flux
%----------------------------------------------------------
trace_name  = ['SQ-Soil heat flux'];
trace_path  = str2mat(fullfile(pthClim,'Instrument_7.Avg_26'),fullfile(pthClim,'Instrument_7.Avg_27'),...
                      fullfile(pthClim,'Instrument_7.Avg_28'));
 trace_legend= str2mat('SHFP_{1}','SHFP_{2}','SHFP_{3}');

trace_units = 'W m^{-2}';
y_axis      = [-100 300];
fig_num = fig_num + fig_num_inc;

x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[84.03 68.03 79.37]); 

if pause_flag == 1;pause;end

% -----------------------
% Energy Balance Closure
% -----------------------
try
    % do an EBC plot as long as not one of the traces is all zeros
    if  ECnewLoc 
        Rn = Net_cnr4_calc;
        %
        SHFP1 = read_bor(fullfile(pthClim,'Instrument_7.Avg_26'));
        SHFP2 = read_bor(fullfile(pthClim,'Instrument_7.Avg_27'));
        SHFP3 = read_bor(fullfile(pthClim,'Instrument_7.Avg_28'));
        
        % calibration constants
        SHFP1=84.03.*SHFP1;
        SHFP2=68.03.*SHFP2;
        SHFP3=79.37.*SHFP3;

        G     = mean([SHFP1 SHFP2 SHFP3],2);

        %     Hmix  = read_bor(fullfile(pthFl,'H2O_Avg'));
        %     WaterMoleFraction = Hmix./(1+Hmix./1000);
        %     rho_moist_air = rho_air_wet(Tair_logger,[],BarometricP_logger,WaterMoleFraction);
        %     Cp_moist = spe_heat(Hmix);
        %     H  = wT_rot .* rho_moist_air(ind) .* Cp_moist(ind);
        %

        H = H_lgr;
        %        H_hf = read_bor(fullfile(pthEC,'HP11.Three_Rotations.AvgDtr.Fluxes.Hs'));
        %          H_hf = H_hf(ind);
        %          ind_msg=find(H==0);
        %          H(ind_msg)=H_hf(ind_msg);

        %
        LE = LE_lgr;
        %
        fig_num = fig_num+fig_num_inc;figure(fig_num);clf;
        plot(t,Rn(ind)-G(ind),t,H(ind)+LE(ind));
        xlabel('DOY');
        ylabel('W m^{-2}');
        title({'Eddy Correlation: ';'Energy budget'});
        legend('Rn-G','H+LE');
        %
        EBax = [-200 800];
        %
        h = gca;
        set(h,'YLim',EBax,'XLim',[st ed+1]);
        grid on;zoom on;xlabel('DOY')
        %
        
        % if any of the EBC components is all zeros, skip the regression
        % plot
        if length(find(G(ind)==0.))~=length(ind) & length(find(Rn(ind)==0.))~=length(ind) &...
                  length(find(H(ind)==0.))~=length(ind) & length(find(LE(ind)==0.))~=length(ind)
        
        A = Rn(ind)-G(ind);
        T = H(ind)+LE(ind);
        % [C,IA,IB] = intersect(datestr(tv),datestr(t),'rows');
        % A = A(IA);
        % T = T(IB);
        cut = find(isnan(A) | isnan(T) | A > 700 | A < -200 | T >700 | T < -200 |...
            H(ind) == 0 | LE(ind) == 0 | Rn(ind) == 0 );
        A = clean(A,1,cut);
        T = clean(T,1,cut);

        [p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);
        %
        fig_num = fig_num+fig_num_inc;figure(fig_num);clf;
        plot(Rn(ind)-G(ind),H(ind)+LE(ind),'.',...
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
      end
  end

 catch
     disp('...EBC regression plot failed');
 end

%----------------------------------------------------------
% Soil Moisture Profile
%----------------------------------------------------------

trace_name  = ['SQ-Soil VWC profile'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_7.Avg_6'),fullfile(pthFl,'Instrument_7.Avg_7'));
trace_legend= str2mat('VWC_{3cm}','VWC_{10cm}');
trace_units = 'm^{3} m^{-3}';
y_axis      = [0 1];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,...
              [0.0011 0.0011],[0.37 0.37 ]); 

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



function set_figure_name(SiteID)
     title_string = get(get(gca,'title'),'string');
     set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'number','off')
