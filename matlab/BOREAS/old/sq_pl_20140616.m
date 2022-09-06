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
pthClim = biomet_path(year,SiteID,'cl');         % get the climate data path
pthFl   = biomet_path(year,SiteID,'fl');         % get the eddy data path
pthClim = pthFl;                                 % all climate traces are output to Flux folders as instrument channels
pthEC = pthFl;

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

currentDate = datenum(year,1,ind(1));
c = fr_get_init(SiteID,currentDate);
IRGAnum = c.System(1).Instrument(2);
SONICnum = c.System(1).Instrument(1);


%----------------------------------------------------------
% Air Temp HMP
%----------------------------------------------------------
trace_name  = [SiteID '-Air temperature HMP'];
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
trace_name  = [SiteID '-Air temperature Sonic'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_1.Avg_4'),fullfile(pthFl,'Instrument_1.Min_4'),fullfile(pthFl,'Instrument_1.Max_4'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Air Temp comparison
%----------------------------------------------------------
trace_name  = [SiteID '-Air temperature'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_4'),fullfile(pthFl,'Instrument_1.Avg_4'));
trace_legend= str2mat('HMP Tair','Sonic_{Tc}');
trace_units = '(\circC)';
y_axis      = [0 40]-WINTER_TEMP_OFFSET;
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% RH HMP
%----------------------------------------------------------

trace_name  = [SiteID '-RH HMP'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_5'),fullfile(pthFl,'Instrument_5.Min_5'),fullfile(pthFl,'Instrument_5.Max_5'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(\circC)';
y_axis      = [0 120];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Battery Voltage Eddy Logger
%----------------------------------------------------------
 trace_name  = [SiteID '-Battery voltage'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_7.Avg_2'),fullfile(pthFl,'Instrument_7.Min_2'),fullfile(pthFl,'Instrument_7.Max_2'));
trace_legend= str2mat('EC logger BattVolt_{Avg}','EC logger BattVolt_{Min}','EC logger BattVolt_{Max}');
trace_units = '(V)';
y_axis      = [11.5 16];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Logger Temp
%----------------------------------------------------------
% trace_name  = [SiteID '-Logger temperature'];
% if strcmp(SiteID,'HP09')
%    trace_path  = str2mat(fullfile(pthClim,'RefT_MPLX_AVG'),fullfile(pthFl,'ref_temp_Avg'));
%    trace_legend= str2mat('MUX','Eddy Logger');
% elseif strcmp(SiteID,'HP11')
%     trace_path  = str2mat(fullfile(pthFl,'ref_temp_Avg'));
%     trace_legend= str2mat('Eddy Logger');
% end
% trace_units = '(\circC)';
% y_axis      = [0 50]-WINTER_TEMP_OFFSET;
% fig_num = fig_num + fig_num_inc;
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num, [1 1],[0 0]);
% if pause_flag == 1;pause;end

%----------------------------------------------------------
% IRGA Diagnostic
%----------------------------------------------------------


    trace_name  = 'SQT-IRGA diag';
    trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_8'));
    trace_legend= str2mat('Idiag LI7200');
    trace_units = '';
    y_axis      = [5000 10000];
    fig_num = fig_num + fig_num_inc;
    x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
    
    % break up diagnostic flag by binary bit
    Idiag_lgr = read_bor(fullfile(pthFl,'Instrument_2.Avg_8'));
    Idiag_lgrmax = read_bor(fullfile(pthFl,'Instrument_2.Max_8'));
    Idiag_lgrmin = read_bor(fullfile(pthFl,'Instrument_2.Min_8'));
    
    ind_bad= find( Idiag_lgr==-999);
    Idiag_lgr(ind_bad)=0;
    
    ind_bad= find( Idiag_lgrmax==-999);
    Idiag_lgrmax(ind_bad)=0;
    
    ind_bad= find( Idiag_lgrmin==-999);
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

%--------------------------------------------------------
% Number of Samples (sample frequency)
%--------------------------------------------------------
SONICnum = 1;
IRGAnum = 2;
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

trace_name  = [SiteID '-CO2 mixing ratio'];
trace_units = '(\mumol CO_{2} mol^{-1} dry air)';
y_axis      = [350 600];
% trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_1'),fullfile(pthFl,'Instrument_2.Min_1'),...
%                fullfile(pthFl,'Instrument_2.Max_1'),fullfile(pthFl,'Instrument_6.Avg_1'));
trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_1'),fullfile(pthFl,'Instrument_2.Min_1'),...
               fullfile(pthFl,'Instrument_2.Max_1'));
%trace_legend= str2mat('CO2_{AvgLogger}','CO2_{MinLogger}','CO2_{MaxLogger}','Boreal GasFinder');
trace_legend= str2mat('CO2_{AvgLogger}','CO2_{MinLogger}','CO2_{MaxLogger}');
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end


%----------------------------------------------------------
% H2O mixing ratio
%----------------------------------------------------------

trace_name  = [SiteID '-H2O mixing ratio'];
trace_units = '(mmol H_{2}O mol^{-1} dry air)';
y_axis      = [0 25];
trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_2'),fullfile(pthFl,'Instrument_2.Min_2'),fullfile(pthFl,'Instrument_2.Max_2'));
trace_legend= str2mat('H2O_{Avg logger}','H2O_{Min logger}','H2O_{Max logger}');
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
title({'Eddy Correlation: ';'LI-7200 CO_2 & H_2O delay times'})
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
    title({'Eddy Correlation: ';'Delay times histogram'})
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
trace_name  = [SiteID '-LI-7200 Flow Rate'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_2.Avg_10'),fullfile(pthFl,'Instrument_2.Min_10'),fullfile(pthFl,'Instrument_2.Max_10'));
trace_legend= str2mat('Avg','Min','Max');
trace_units = '(\circC)';
y_axis      = [0 20];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

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
trace_name  = [SiteID '-RMY81000 wind vector components'];
trace_path  = str2mat(fullfile(pthFl,'Instrument_1.Avg_1'),fullfile(pthFl,'Instrument_1.Avg_2'),fullfile(pthFl,'Instrument_1.Avg_3'));
trace_legend= str2mat('u wind','v wind','w wind');
trace_units = '(m s^{-1})';
y_axis      = [-10 10];
fig_num = fig_num + fig_num_inc;
x_CSAT = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%-----------------------------------
% Global Irradiance
%-----------------------------------
trace_name  = [SiteID '-Global Irradiance'];
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
trace_name  = [SiteID '-Barometric pressure'];
%trace_path  = str2mat(fullfile(pthEC,'MiscVariables.BarometricP'),fullfile(pthFl,'Irga_P_Avg'));
trace_path  = str2mat(fullfile(pthFl,'Instrument_5.Avg_3'),fullfile(pthFl,'Instrument_2.Avg_6'),fullfile(pthFl,'Instrument_2.Avg_7'));
trace_legend= str2mat('barometer','IRGA_{cell}','IRGA_{head}');
trace_units = '(kPa)';
y_axis      = [-10 110];
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

trace_name  = [ SiteID '-Climate/Diagnostics: Rainfall'];
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

trace_name  = [ SiteID '-Climate: Cumulative Rain'];
y_axis      = [];
ax = [st ed];
[x1,tx_new] = read_sig(trace_path(1,:), indx,year, tx,0);
x1 = x1*1;   
fig_num = fig_num + fig_num_inc;

plt_sig1( tx_new, [cumsum(x1)], trace_name, year, trace_units, ax, y_axis, fig_num );
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
trace_name  = [SiteID '-EC fluxes: Fc'];
 Fc_hf = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc'));
 %trace_legend= str2mat('Fc_{HFcalc}');
 trace_units = '(\mumol CO_{2} m^{-2} s^{-1})';
 y_axis      = [-10 15];
 fig_num = fig_num + fig_num_inc;
 x = plt_msig( [ Fc_hf(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );

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

trace_name  = [SiteID '-EC Fluxes: LE'];
LE_hf = read_bor(fullfile(pthEC,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L')); % LE LICOR
trace_units = '(W m^{-2} )';                                 
%trace_legend= str2mat('LE (3 rot from covs)', 'LE logger', 'LE (high freq)');
y_axis      = [-50 400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( [ LE_hf(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
 
if pause_flag == 1;pause;end


%----------------------------------------------------------
% Sonic wind speed
%----------------------------------------------------------
trace_name  = [SiteID '-Wind Speed'];
wspd_sonic = read_bor(fullfile(pthFl,'Instrument_1.MiscVariables.CupWindSpeed'));
wspd_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_1'));
trace_legend= str2mat('cup anemometer','RMY81000');
trace_units = '(m/s)';
y_axis      = [0 10];
fig_num = fig_num + fig_num_inc;
x = plt_msig( [wspd_cup2d(ind) wspd_sonic(ind) ], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );
if pause_flag == 1;pause;end

%----------------------------------------------------------
% Sonic wind direction
%----------------------------------------------------------
trace_name  = [SiteID '-Wind direction'];
wdir_sonic = read_bor(fullfile(pthFl,'Instrument_1.MiscVariables.WindDirection'));
wdir_cup2d  = read_bor(fullfile(pthFl,'Instrument_5.Avg_6'));
trace_legend= str2mat('cup anemometer','RMY81000');
trace_units = '(^o)';
y_axis      = [0 400];
fig_num = fig_num + fig_num_inc;
x = plt_msig( [wdir_cup2d(ind) wdir_sonic(ind)], ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num );


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

trace_name  = [SiteID '-Soil temperature profile'];
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
% trace_name  = [SiteID '-Soil heat flux'];
% 
% if strcmp(SiteID,'HP09')
%   trace_path  = str2mat(fullfile(pthClim,'SHF_1_AVG'),fullfile(pthClim,'SHF_2_AVG'),...
%                       fullfile(pthClim,'SHF_3_AVG'),fullfile(pthClim,'SHF_4_AVG'),fullfile(pthClim,'SHF_5_AVG'));
%   trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}','sheat_{5}');
% elseif strcmp(SiteID,'HP11')
%  trace_path  = str2mat(fullfile(pthClim,'SoilHeat_1_Avg'),fullfile(pthClim,'SoilHeat_2_Avg'),...
%                       fullfile(pthClim,'SoilHeat_3_Avg'),fullfile(pthClim,'SoilHeat_4_Avg'));
%  trace_legend= str2mat('sheat_{1}','sheat_{2}','sheat_{3}','sheat_{4}');
% end
% 
% trace_units = '(W m^{-2})';
% y_axis      = [-50 250];
% fig_num = fig_num + fig_num_inc;
% 
% x = plt_msig( trace_path, ind, trace_name, trace_legend, year, trace_units, y_axis, t, fig_num,[1 1 1 1 1]); 
% 
% if pause_flag == 1;pause;end

% -----------------------
% Energy Balance Closure
% -----------------------

% try
%     if strcmp(SiteID,'HP09')
%         S_upper_AVG = read_bor(fullfile(pthClim,'SW_DW_AVG'));
%         S_lower_AVG = read_bor(fullfile(pthClim,'SW_UW_AVG'));
%         L_upper_AVG = read_bor(fullfile(pthClim,'LW_DW_AVG'));
%         L_lower_AVG = read_bor(fullfile(pthClim,'LW_UW_AVG'));
% 
%         Rn = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
% 
%         SHFP1 = read_bor(fullfile(pthClim,'SHF_1_AVG'));
%         SHFP2 = read_bor(fullfile(pthClim,'SHF_2_AVG'));
%         SHFP3 = read_bor(fullfile(pthClim,'SHF_3_AVG'));
%         SHFP4 = read_bor(fullfile(pthClim,'SHF_4_AVG'));
%         SHFP5 = read_bor(fullfile(pthClim,'SHF_5_AVG'));
% 
%         G     = mean([SHFP1 SHFP2 SHFP3 SHFP4 SHFP5],2);
%     elseif strcmp(SiteID,'HP11')
%         Rn = Net_cnr4_calc;
% 
%         SHFP1 = read_bor(fullfile(pthClim,'SoilHeat_1_Avg'));
%         SHFP2 = read_bor(fullfile(pthClim,'SoilHeat_2_Avg'));
%         SHFP3 = read_bor(fullfile(pthClim,'SoilHeat_3_Avg'));
%         SHFP4 = read_bor(fullfile(pthClim,'SoilHeat_4_Avg'));
% 
%         G     = mean([SHFP1 SHFP2 SHFP3 SHFP4],2);
%         Hmix  = read_bor(fullfile(pthFl,'H2O_Avg'));
% 
%     end
% 
%     WaterMoleFraction = Hmix./(1+Hmix./1000);
%     rho_moist_air = rho_air_wet(Tair_logger,[],BarometricP_logger,WaterMoleFraction);
%     Cp_moist = spe_heat(Hmix);
%     H  = wT_rot .* rho_moist_air(ind) .* Cp_moist(ind);
% 
%     if strcmp(SiteID,'HP11')
%         H_hf = read_bor(fullfile(pthEC,'HP11.Three_Rotations.AvgDtr.Fluxes.Hs'));
%         H_hf = H_hf(ind);
%         ind_msg=find(H==0);
%         H(ind_msg)=H_hf(ind_msg);
%     end
% 
%     Le = LE_rot;
% 
%     fig_num = fig_num+fig_num_inc;figure(fig_num);clf;
%     plot(t,Rn(ind)-G(ind),t,H+Le);
%     xlabel('DOY');
%     ylabel('W m^{-2}');
%     title({'Eddy Correlation: ';'Energy budget'});
%     legend('Rn-G','H+LE');
% 
%     EBax = [-200 800];
% 
%     h = gca;
%     set(h,'YLim',EBax,'XLim',[st ed+1]);
%     grid on;zoom on;xlabel('DOY')
% 
%     A = Rn(ind)-G(ind);
%     T = H+Le;
%     %[C,IA,IB] = intersect(datestr(tv),datestr(t),'rows');
%     %A = A(IA);
%     %T = T(IB);
%     cut = find(isnan(A) | isnan(T) | A > 700 | A < -200 | T >700 | T < -200 |...
%         H == 0 | Le == 0 | Rn(ind) == 0 );
%     A = clean(A,1,cut);
%     T = clean(T,1,cut);
%     %Rn_clean = clean(Rn(ind),1,cut);
%     %G_clean = clean(G(ind),1,cut);
%     [p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);
% 
%     fig_num = fig_num+fig_num_inc;figure(fig_num);clf;
%     plot(Rn(ind)-G(ind),H+Le,'.',...
%         A,T,'o',...
%         EBax,EBax,...
%         EBax,polyval(p,EBax),'--');
%     text(-100, 400, sprintf('T = %2.3fA + %2.3f, R2 = %2.3f',p,R2));
%     xlabel('Ra (W/m2)');
%     ylabel('H+LE (W/m2)');
%     title({'Eddy Correlation: ';'Energy budget'});
%     h = gca;
%     set(h,'YLim',EBax,'XLim',EBax);
%     grid on;zoom on;
% catch
%     disp('...EBC regression plot failed');
% end

%----------------------------------------------------------
% Soil Moisture Profile
%----------------------------------------------------------

trace_name  = [SiteID '-Soil VWC profile'];
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
