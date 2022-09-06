function [] = eddy_pl_CPEC(ind, year, SiteID, select);
%
% Revisions
%  Dec 13, 2011 (Nick/Zoran) 
%   - modified eddy_pl_new to plot YF vs CPEC 
%
st = datenum(year,1,min(ind));                         % first day of measurements
ed = datenum(year,1,max(ind));                         % last day of measurements (approx.)
startDate   = datenum(min(year),1,1);     
currentDate = datenum(year,1,ind(1));
days        = ind(end)-ind(1)+1;
GMTshift = 8/24; 

if nargin < 3
    select = 0;
end

pth = ['\\PAOA001\SITES\' SiteID '\hhour\'];
c = fr_get_init(SiteID,currentDate);
ext         = c.hhour_ext;
IRGAnum = c.System(1).Instrument(2);
SONICnum = c.System(1).Instrument(1);
nMainEddy = 1;

%load in fluxes
switch upper(SiteID)
    case 'YF'
        [pthc] = biomet_path(year,'yf','cl');
        pth_CPEC = biomet_path(year,'yf','CPEC200\Flux_logger');
        ini_climMain = fr_get_logger_ini('yf',year,[],'yf_clim_60');   % main climate-logger array
		  ini_clim2    = fr_get_logger_ini('yf',year,[],'yf_clim_61');   % secondary climate-logger array

		  ini_climMain = rmfield(ini_climMain,'LoggerName');
		  ini_clim2    = rmfield(ini_clim2,'LoggerName');
        
        fileName = fr_logger_to_db_fileName(ini_climMain, '_tv', pthc);
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);

		  trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'RAD_6_AVG', pthc));
        Rn = read_bor(trace_path,[],[],year,ind);
        
		  trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pthc));
        Rn_new = read_bor(trace_path,[],[],year,ind);
        if year>=2004
            Rn= Rn_new;
        end
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP1_AVG', pthc));
		  SHFP1 = read_bor(trace_path,[],[],year,ind);
		  trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP2_AVG', pthc));
		  SHFP2 = read_bor(trace_path,[],[],year,ind);
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP3_AVG', pthc));
		  SHFP3 = read_bor(trace_path,[],[],year,ind);
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP4_AVG', pthc));
		  SHFP4 = read_bor(trace_path,[],[],year,ind);
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP5_AVG', pthc));
		  SHFP5 = read_bor(trace_path,[],[],year,ind);
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'SHFP6_AVG', pthc));
		  SHFP6 = read_bor(trace_path,[],[],year,ind);
        G     = mean([SHFP1 SHFP2 SHFP3 SHFP4 SHFP5 SHFP6],2);
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_AVG', pthc));
        RMYu  = read_bor(trace_path,[],[],year,ind);

        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'WindDir_DU_WVT', pthc));
        RMY_WindDir  = read_bor(trace_path,[],[],year,ind);
        
        trace_path = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pthc));
        Pbar  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pthc));
        HMPT  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pthc));
        HMPRH = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pthc));
        Pt_T  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'GH_co2_AVG', pthc));
		  co2_GH= read_bor(trace_path,[],[],year,ind);
        diagFlagIRGA = 7;
        
        % CPEC traces
        co2_CPEC = read_bor(fullfile(pth_CPEC,'CO2_mean'),[],[],year,ind);
        h2o_CPEC = read_bor(fullfile(pth_CPEC,'H2O_mean'),[],[],year,ind);
        Pcell_CPEC = read_bor(fullfile(pth_CPEC,'cell_press_mean'),[],[],year,ind);
        Tcell_CPEC = read_bor(fullfile(pth_CPEC,'cell_tmpr_mean'),[],[],year,ind);
        Hs_CPEC = read_bor(fullfile(pth_CPEC,'Hs'),[],[],year,ind);
        LE_CPEC = read_bor(fullfile(pth_CPEC,'LE'),[],[],year,ind);
        Fc_CPEC = read_bor(fullfile(pth_CPEC,'Fc'),[],[],year,ind);
        Factor_CO2 = read_bor(fullfile(pth_CPEC,'factor_CO2'),[],[],year,ind);
        Factor_H2O = read_bor(fullfile(pth_CPEC,'factor_H2O'),[],[],year,ind);        
        wind_speed_CPEC = read_bor(fullfile(pth_CPEC,'wnd_spd'),[],[],year,ind);
        CSAT_samples_CPEC = read_bor(fullfile(pth_CPEC,'sonic_samples_tot'),[],[],year,ind);
        IRGA_samples_CPEC = read_bor(fullfile(pth_CPEC,'irga_samples_tot'),[],[],year,ind);
        Ts_CPEC = read_bor(fullfile(pth_CPEC,'Ts_avg'),[],[],year,ind);        
        WindDir_CPEC = read_bor(fullfile(pth_CPEC,'wnd_dir_compass'),[],[],year,ind);        
        
    otherwise
        error 'Wrong SiteID'
end

instrumentString = sprintf('Instrument(%d).',IRGAnum);
sonicString =  sprintf('Instrument(%d).',SONICnum);

StatsX = [];
t      = [];
for i = 1:days;
    
    filename_p = FR_DateToFileName(currentDate+.03);
    filename   = filename_p(1:6);
    
    pth_filename_ext = [pth filename ext];
    if ~exist([pth filename ext]);
        pth_filename_ext = [pth filename 's' ext];
    end
    
    if exist(pth_filename_ext);
       try
          load(pth_filename_ext);
          if i == 1;
             StatsX = [Stats];
             t      = [currentDate+1/48:1/48:currentDate+1];
          else
             StatsX = [StatsX Stats];
             t      = [t currentDate+1/48:1/48:currentDate+1];
          end
          
       catch
          disp(lasterr);    
       end
    end
    currentDate = currentDate + 1;
    
end

t        = t - GMTshift; %PST time
[C,IA,IB] = intersect(datestr(tv),datestr(t),'rows');

%[Fc,Le,H,means,eta,theta,beta] = ugly_loop(StatsX);
[Fc]        = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
[Le]        = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
[H]         = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
[means]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
maxAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Max');
minAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Min');
numOfSamplesEC = get_stats_field(StatsX,'MainEddy.MiscVariables.NumOfSamples');

% air temperature and pressure used in eddy flux calculations (Jan 25,
% 2010)
[Tair_calc]        = get_stats_field(StatsX,'MiscVariables.Tair');
[Pbar_calc]        = get_stats_field(StatsX,'MiscVariables.BarometricP');
%

    [Tbench]    = get_stats_field(StatsX,[instrumentString 'Avg(3)']);
    [Tbench_Min]= get_stats_field(StatsX,[instrumentString 'Min(3)']);
    [Tbench_Max]= get_stats_field(StatsX,[instrumentString 'Max(3)']);

    [Plicor]    = get_stats_field(StatsX,[instrumentString 'Avg(4)']);
    [Plicor_Min]= get_stats_field(StatsX,[instrumentString 'Min(4)']);
    [Plicor_Max]= get_stats_field(StatsX,[instrumentString 'Max(4)']);
    
    [Pgauge]    = get_stats_field(StatsX,[instrumentString 'Avg(5)']);
    [Pgauge_Min]= get_stats_field(StatsX,[instrumentString 'Min(5)']);
    [Pgauge_Max]= get_stats_field(StatsX,[instrumentString 'Max(5)']);
    
    [Dflag5]    = get_stats_field(StatsX,[sonicString 'Avg(5)']);
    [Dflag5_Min]= get_stats_field(StatsX,[sonicString 'Min(5)']);
    [Dflag5_Max]= get_stats_field(StatsX,[sonicString 'Max(5)']);
    
    [Dflag6]    = get_stats_field(StatsX,[instrumentString 'Avg(' num2str(diagFlagIRGA) ')']);
    [Dflag6_Min]= get_stats_field(StatsX,[instrumentString 'Min(' num2str(diagFlagIRGA) ')']);
    [Dflag6_Max]= get_stats_field(StatsX,[instrumentString 'Max(' num2str(diagFlagIRGA) ')']);

    numOfSamplesIRGA = get_stats_field(StatsX, [instrumentString 'MiscVariables.NumOfSamples']);
    numOfSamplesSonic = get_stats_field(StatsX,[sonicString 'MiscVariables.NumOfSamples']);

    Delays_calc       = get_stats_field(StatsX,'MainEddy.Delays.Calculated');
    Delays_set        = get_stats_field(StatsX,'MainEddy.Delays.Implemented');

    WindDir_Gill      = get_stats_field(StatsX,[ sonicString 'MiscVariables.WindDirection']);
    
%figures
if datenum(now) > datenum(year,4,15) & datenum(now) < datenum(year,11,1);
   Tax  = [0 30];
   EBax = [-200 800];
else
   Tax  = [-10 15];
   EBax = [-200 500];
end

%reset time vector to doy
t    = t - startDate + 1;
tv   = tv - startDate + 1;
st   = st - startDate + 1;
ed   = ed - startDate + 1;

[same_time,ind_t,ind_tv]=intersect(fr_round_time(t),fr_round_time(tv));

fig = 0;

%-----------------------------------------------
% Number of samples collected UBC
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,numOfSamplesSonic,t,numOfSamplesIRGA,t,numOfSamplesEC);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[35800 36800])
title({'Eddy Correlation: ';'Number of samples collected by UBC'});
set_figure_name(SiteID)
ylabel('1')
legend('Sonic','IRGA','EC')

%-----------------------------------------------
% Number of samples collected CPEC
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv,CSAT_samples_CPEC,tv,IRGA_samples_CPEC);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[17800 18200])
title({'Eddy Correlation: ';'Number of samples collected by CPEC'});
set_figure_name(SiteID)
ylabel('1')
legend('Sonic_{CPEC}','IRGA_{CPEC}')

%-----------------------------------------------
% Gill wind speed (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,means(:,[1]),tv,wind_speed_CPEC);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 10])
title({'Eddy Correlation: ';'Gill Wind Speed (After Rotation)'});
set_figure_name(SiteID)
ylabel('U (m/s)')

legend('Sonic','CSAT3-CPEC')
zoom on;

%-----------------------------------------------
% Gill wind speed (after rotation) 1:1
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(means(ind_t,[1]),wind_speed_CPEC(ind_tv),'.');
grid on;
zoom on;
xlabel('DOY')
minmax_u = [-5 5];
axis([minmax_u minmax_u])
line(minmax_u,minmax_u)

title({'Eddy Correlation: ';'Gill Wind Speed (After Rotation)'});
set_figure_name(SiteID)
xlabel('UBC (m/s)')
ylabel('CPEC (m/s)')
zoom on;

%-----------------------------------------------
% Gill wind direction
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,WindDir_Gill,tv,RMY_WindDir,tv,WindDir_CPEC);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 360])
title({'Eddy Correlation: ';'Wind Direction'});
set_figure_name(SiteID)
ylabel('Degrees North')

legend('Sonic','RMYoung','CSAT3-CPEC')
zoom on;

%-----------------------------------------------
% Air temperatures ALL
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,means(:,[4]),tv,HMPT,tv,Pt_T,t,Tair_calc,tv,Ts_CPEC);
h = gca;
set(h,'XLim',[st ed+1],'YLim',Tax)

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Air Temperatures ALL'});
set_figure_name(SiteID)
ylabel('Temperature (\circC)')
legend('Sonic','HMP','Pt100','usedinfluxcalc','Ts_{CPEC}',-1);
zoom on;

%-----------------------------------------------
% Air temperatures EC
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,means(:,[4]),tv,Pt_T,tv,Ts_CPEC);
h = gca;
set(h,'XLim',[st ed+1],'YLim',Tax)

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Air Temperatures EC'});
set_figure_name(SiteID)
ylabel('Temperature (\circC)')
legend('Sonic','Pt100','Ts_{CPEC}',-1);
zoom on;

%-----------------------------------------------
% Air temperatures (Sonic and Pt-100) 1:1
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(HMPT(IA), means(IB,[4]),'.',...
    HMPT(IA),Pt_T(IA),'.',...
    HMPT(IA),Ts_CPEC(IA),'.',...
    Tax,Tax);
h = gca;
set(h,'XLim',Tax,'YLim',Tax)
grid on;zoom on;ylabel('Sonic')
title({'Eddy Correlation: ';'Air Temperatures HMP, PRT, Gill 1:1'})
set_figure_name(SiteID)
xlabel('Temperature (\circC)')
legend('Sonic','Pt100','CSAT3_{CPEC}',-1)
zoom on;

%-----------------------------------------------
% Air temperatures (Gill and CSAT3) 1:1
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(means(IB,[4]),Ts_CPEC(IA), '.',...
    Tax,Tax);
h = gca;
set(h,'XLim',Tax,'YLim',Tax)
grid on;zoom on;ylabel('Sonic')
title({'Eddy Correlation: ';'Air Temperatures Gill and CSAT3 1:1'})
set_figure_name(SiteID)
xlabel('Gill (\circC)')
ylabel('CSAT3_{CPEC} (\circC)')
zoom on;

%-----------------------------------------------
% Barometric pressure
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv,Pbar,t,Pbar_calc);
h = gca;
set(h,'XLim',[st ed+1],'YLim',[90 102])

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Barometric Pressure'})
set_figure_name(SiteID)
ylabel('Pressure (kPa)')
legend('Pbar_{meas}','Pbar_{ECcalc}')

%-----------------------------------------------
%  Tbench
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Tbench Tbench_Min Tbench_Max],tv,Tcell_CPEC);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'T_{bench}'});
set_figure_name(SiteID)
a = legend('av','min','max','CPEC cell',-1);
set(a,'visible','on');zoom on;
h = gca;
ylabel('Temperature (\circC)')
zoom on;

%-----------------------------------------------
%  Diagnostic Flag, GillR3, Channel #5
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Dflag5 Dflag5_Min Dflag5_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'Diagnostic Flag, GillR3, Channel 5'});
set_figure_name(SiteID)
a = legend('av','min','max', -1);
set(a,'visible','on');zoom on;
h = gca;
ylabel('?')
zoom on;

%-----------------------------------------------
%  Diagnostic Flag, Li-7000
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Dflag6 Dflag6_Min Dflag6_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'Diagnostic Flag, Li-7000, Channel 6'});
set_figure_name(SiteID)
a = legend('av','min','max', -1);
set(a,'visible','on');zoom on;
h = gca;
ylabel('?')
zoom on;

%-----------------------------------------------
%  Plicor
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,[Plicor Plicor_Min Plicor_Max],tv,Pcell_CPEC);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'P_{Licor} '})
set_figure_name(SiteID)
a = legend('av','min','max','CPEC cell', -1);
set(a,'visible','on');zoom on;
h = gca;
ylabel('Pressure (kPa)')
zoom on;

%-----------------------------------------------
%  Pgauge
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,[Pgauge Pgauge_Min Pgauge_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'P_{gauge} '})
set_figure_name(SiteID)
a = legend('av','min','max', -1);
set(a,'visible','on');zoom on;
h = gca;
ylabel('Pressure (kPa)')
zoom on;


%-----------------------------------------------
% H_2O min/max/avg (mmol/mol of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,[means(:,[6]) maxAll(:,6) minAll(:,6)],tv,h2o_CPEC./Factor_H2O);
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'H_2O  min/max/avg '})
set_figure_name(SiteID)
ylabel('(mmol mol^{-1} of dry air)')

legend('IRGA_{avg}','IRGA_{max}','IRGA_{min}','CPEC',-1)
zoom on;



%-----------------------------------------------
% H_2O means (mmol/mol of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,means(:,[6]),tv,h2o_CPEC./Factor_H2O);
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'H_2O means'})
set_figure_name(SiteID)
ylabel('(mmol mol^{-1} of dry air)')

legend('IRGA_{avg}','CPEC',-1)
zoom on;


%-----------------------------------------------
% H_2O UBC:CPEC (mmol/mol of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(means(ind_t,[6]),h2o_CPEC(ind_tv)./Factor_H2O(ind_tv),'.');
minmax_h2o = [0 10];
axis([minmax_h2o minmax_h2o])
line(minmax_h2o,minmax_h2o)
grid on;zoom on;xlabel('DOY')

title({'Eddy Correlation: ';'H_2O UBC:CPEC'})
set_figure_name(SiteID)
xlabel('UBC (mmol mol^{-1} of dry air)')
ylabel('CPEC (mmol mol^{-1} of dry air)')
zoom on;

%-----------------------------------------------
% CO_2 min/max/avg(\mumol mol^-1 of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
%plot(t,[means(:,[5]) maxAll(:,5) minAll(:,5)],tv,co2_GH);
plot(t,[means(:,[5]) maxAll(:,5) minAll(:,5) ], tv,co2_CPEC./Factor_CO2);
legend('IRGA_{avg}','IRGA_{max}','IRGA_{min}','co2_{CPEC}');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2 min/max'})
set_figure_name(SiteID)
ylabel('\mumol mol^{-1} of dry air')

%-----------------------------------------------
% CO_2 means (\mumol mol^-1 of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
%plot(t,[means(:,[5]) maxAll(:,5) minAll(:,5)],tv,co2_GH);
plot(t(ind_t),[means(ind_t,[5])], tv(ind_tv),co2_CPEC(ind_tv)./Factor_CO2(ind_tv));
legend('IRGA_{avg}','co2_{CPEC}');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2 means'})
set_figure_name(SiteID)
ylabel('\mumol mol^{-1} of dry air')

%-----------------------------------------------
% CO_2 UBC:CPEC (\mumol mol^-1 of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(means(ind_t,[5]),co2_CPEC(ind_tv)./Factor_CO2(ind_tv),'.');
minmax = [380 430];
line(minmax,minmax)
axis([ minmax minmax])
grid on;zoom on
title({'Eddy Correlation: ';'CO_2  UBC - CPEC200'})
set_figure_name(SiteID)
ylabel('UBC \mumol mol^{-1} of dry air')
xlabel('CPEC200 \mumol mol^{-1} of dry air')

%-----------------------------------------------
% CO_2 & H_2O delay times
%
fig = fig+1;figure(fig);clf

plot(t,Delays_calc(:,1:2),'o')
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2));
    set(h,'color','y','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2));
    set(h,'color','m','linewidth',1.5)
else
    if strcmp(upper(SiteID),'YF') % Nick added Oct 8, 2009
        h = line([t(1) t(end)],18*ones(1,2));
        set(h,'color','y','linewidth',1.5)
        h = line([t(1) t(end)],20*ones(1,2));
        set(h,'color','m','linewidth',1.5)
    end
end
grid on;zoom on;xlabel('DOY')
title('CO_2 & H_2O delay times')
set_figure_name(SiteID)
ylabel('Samples')
legend('CO_2','H_2O','CO_2 setup','H_2O setup',-1)


%-----------------------------------------------
% Delay Times (histogram)
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
subplot(2,1,1); hist(Delays_calc(:,1),200); 
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2),ax(3:4));
    set(h,'color','y','linewidth',2)
else
  if strcmp(upper(SiteID),'YF') % Nick added Oct 8, 2009
        ax=axis;
        h = line(18*ones(1,2),ax(3:4));
        set(h,'color','y','linewidth',2)
  end
end
ylabel('CO_2 delay times')
subplot(2,1,2); hist(Delays_calc(:,2),200);
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2),ax(3:4));
    set(h,'color','y','linewidth',2)
else
  if strcmp(upper(SiteID),'YF') % Nick added Oct 8, 2009
        ax=axis;
        h = line(20*ones(1,2),ax(3:4));
        set(h,'color','y','linewidth',2)
  end
end
ylabel('H_{2}O delay times')
title('Delay times histogram')
set_figure_name(SiteID)
zoom_together(gcf,'x','on')
%-----------------------------------------------
% CO2 flux
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
Fc1 = Fc;
Fc1(23:48:end)=NaN;

plot(t,Fc1,tv,Fc_CPEC*1000/44);
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_c'})
set_figure_name(SiteID)
legend('LI-7000','CPEC')
ylabel('\mumol m^{-2} s^{-1}')

%-----------------------------------------------
% CO2 flux
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(Fc1(ind_t),Fc_CPEC(ind_tv)*1000/44,'.');
minmax_fc = [-15 5]; 
line(minmax_fc,minmax_fc)
axis([ minmax_fc minmax_fc])
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_c 1:1'})
set_figure_name(SiteID)
xlabel('UBC \mumol m^{-2} s^{-1}')
ylabel('CPEC \mumol m^{-2} s^{-1}')


%-----------------------------------------------
% Sensible heat
%
fig = fig+1;figure(fig);clf;
plot(t,H,tv,Hs_CPEC); 
h = gca;
set(h,'YLim',[-200 600],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Sensible Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
%legend('Gill','Tc1','Tc2',-1)
legend('Gill','CPEC',-1)

%-----------------------------------------------
% Sensible heat 1:1
%
fig = fig+1;figure(fig);clf;
plot(H(ind_t),Hs_CPEC(ind_tv),'.'); 
minmax_H = [-200 300]; 
line(minmax_H,minmax_H)
axis([ minmax_H minmax_H])
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Sensible Heat 1:1'})
set_figure_name(SiteID)
xlabel('UBC (Wm^{-2})')
ylabel('CPEC (Wm^{-2})')

%-----------------------------------------------
% Latent heat
%
fig = fig+1;figure(fig);clf;
Le1 = Le;
Le1(23:48:end)=NaN;
plot(t,Le,tv,LE_CPEC);
h = gca;
set(h,'YLim',[-10 400],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Latent Heat'})
set_figure_name(SiteID)
legend('LI-7000','CPEC')
ylabel('(Wm^{-2})')

%-----------------------------------------------
% Latent heat 1:1
%
fig = fig+1;figure(fig);clf;
plot(Le1(ind_t),LE_CPEC(ind_tv),'.'); 
minmax_LE = [-50 250]; 
axis([ minmax_LE minmax_LE])
line(minmax_LE,minmax_LE)
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Latent Heat 1:1'})
set_figure_name(SiteID)
xlabel('UBC (Wm^{-2})')
ylabel('CPEC (Wm^{-2})')


childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=childn(:)';
    if i < 200 
        figure(i);
%        if i ~= childn(N-1)                
            pause;    
%        end
    end
end


function [x, tv] = tmp_loop(Stats,field)
%tmp_loop.m pulls out specific structure info and places it in a matric 'x' 
%with an associated time vector 'tv' if Stats.TimeVector field exists
%eg. [Fc_ubc, tv]  = tmp_loop(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');


%E. Humphreys  May 26, 2003
%
%Revisions:
%July 28, 2003 - added documentation

L  = length(Stats);

for i = 1:L
   try,eval(['tmp = Stats(i).' field ';']);
      if length(size(tmp)) > 2;
         [m,n] = size(squeeze(tmp)); 
         
         if m == 1; 
            x(i,:) = squeeze(tmp); 
         else 
            x(i,:) = squeeze(tmp)';
         end      
      else         
         [m,n] = size(tmp); 
         if m == 1; 
            x(i,:) = tmp; 
         else 
            x(i,:) = tmp';
         end      
      end
      
      catch, x(i,:) = NaN; end
      try,eval(['tv(i) = Stats(i).TimeVector;']); catch, tv(i) = NaN; end
end
   

function set_figure_name(SiteID)
     title_string = get(get(gca,'title'),'string');
     set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'number','off')
  