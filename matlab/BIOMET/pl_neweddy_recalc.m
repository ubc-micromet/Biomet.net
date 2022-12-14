function pl_neweddy_recalc(year,siteId,ind,pth_new,pth_old,EC_system_name)

% Plots recalculation comparisons for new eddy systems
% the location of the new daily .mat files is obtained from fr_get_local_path
% and is assumed to be \\PAOA001\sites\siteId\hhour for the old files if
% pth_old is not input by the user

% file created: Jan 23, 2009 (nick)
% last modified: Apr 7, 2020 (Zoran)

% Revisions:
%
% Apr 7, 2020 (Zoran)
%   - multiple edits to improve robustness regarding the EC system names
%   (made them dynamic)
% Oct 18, 2017 (Zoran)
%   - added plotting of EC NumOfSamples
%   - added new input parameter EC_system_name so the program can extract
%   data that is stored in the structures NOT named MainEddy
% Jan 26, 2017 (Zoran)
%   - Fixed up a few bugs that caused crashes when there were missing hhour
%     files
%   - Added plots for BarometricP, Tair, CO2 and H2O zero and span, Delay
%     times for CO2 and H2O
%   - added StatsX_msg option for YF site (EnclosedPathEddy)
%   - changed plotting (added symbols for _new traces to make them more
%     visible when _new and _old traces overlap)
%   - added figure names
%   - added some try-catch statements to prevent the plotting from crashing
%     when some data is missing or not valid
% May 28, 2010
%   -gave user control over the hhour path for the recalc files, with the
%   path listed in fr_get_local_path the default.
% March 31, 2010
%   -user can now supply pth_old to compare flux files in any directory
%   with files produced in met-data\hhour by recalculation and set in
%   fr_get_local_path

warning off
arg_default('EC_system_name','MainEddy');
switch upper(siteId)
    case 'HJP94'
        SecondEddy = 'SecondEddy';
    case 'YF'
        SecondEddy = 'EnclosedPathEddy';
    otherwise
        SecondEddy = [];
end

st = datenum(year,1,min(ind));                         % first day of measurements
ed = datenum(year,1,max(ind));                         % last day of measurements (approx.)
startDate   = datenum(min(year),1,1);     
currentDate = datenum(year,1,ind(1));
days        = ind(end)-ind(1)+1;
GMTshift = 8/24; 

%ext         = '.hy.mat';
c = fr_get_init(siteId,currentDate);
ext = c.hhour_ext;

[dataPth,hhourPth] = fr_get_local_path; %#ok<*ASGLU>

arg_default('pth_new',hhourPth);
arg_default('pth_old',['\\PAOA001\Sites\' siteId '\hhour\']);
arg_default('EC_system_name','MainEddy');

if pth_new(end) ~= '\'
    pth_new = [pth_new '\']; %#ok<*NASGU>
end
if pth_old(end) ~= '\'
    pth_old = [pth_old '\'];
end

for n=1:48
    StatsX_msg(n).TimeVector = NaN; %#ok<*AGROW>
    StatsX_msg(n).RecalcTime = NaN;
    StatsX_msg(n).Configuration = NaN;
    StatsX_msg(n).Instrument = NaN;
    StatsX_msg(n).MiscVariables = NaN;
    StatsX_msg(n).(EC_system_name).Three_Rotations.AvgDtr.Fluxes.Fc = NaN;
    StatsX_msg(n).(EC_system_name).Three_Rotations.AvgDtr.Fluxes.LE_L = NaN;
    StatsX_msg(n).(EC_system_name).Three_Rotations.AvgDtr.Fluxes.Hs = NaN;
    StatsX_msg(n).(EC_system_name).Three_Rotations.Avg(1:6) = NaN.*ones(1,6);
    if ~isempty(SecondEddy)
            StatsX_msg(n).(SecondEddy).Three_Rotations.AvgDtr.Fluxes.Fc = NaN;
            StatsX_msg(n).(SecondEddy).Three_Rotations.AvgDtr.Fluxes.LE_L = NaN;
            StatsX_msg(n).(SecondEddy).Three_Rotations.AvgDtr.Fluxes.Hs = NaN;
            StatsX_msg(n).(SecondEddy).Three_Rotations.Avg(1:6) = NaN.*ones(1,6);
    end
end

dataset = {'new' 'old'};
for j=1:length(dataset)
    currentDate = datenum(year,1,ind(1));
    t=[];
    StatsX = [];
    for i = 1:days
        filename_p = FR_DateToFileName(currentDate+.03);
        filename   = filename_p(1:6);
        eval(['pth = pth_' char(dataset{j}) ';' ]);
        pth_filename_ext = [pth filename ext];
        if ~exist([pth filename ext]) %#ok<*EXIST>
            pth_filename_ext = [pth filename 's' ext];
        end
        
        if exist(pth_filename_ext)
            try
                load(pth_filename_ext); %#ok<*LOAD>
                disp(['Read ' pth_filename_ext ]);
                if i == 1
                    StatsX = Stats;
                    t = [t currentDate+1/48:1/48:currentDate+1];
                else
                    StatsX = [StatsX Stats];
                    t = [t currentDate+1/48:1/48:currentDate+1];
                end
                
            catch
                disp(lasterr);     %#ok<LERR>
            end
        else
            disp(['Short file ' pth_filename_ext ' not found']);
            if currentDate >= datenum(2015,7,14)
                StatsX = [StatsX StatsX_msg];
            else
                StatsX_Tmp = rmfield(StatsX_msg,'EnclosedPathEddy');
                StatsX = [StatsX StatsX_Tmp];
            end
            t = [t currentDate+1/48:1/48:currentDate+1];
        end
        currentDate = currentDate + 1;
    end
    if strcmp(char(dataset{j}),'new')
        [Fc_new] = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.AvgDtr.Fluxes.Fc']);
        [Le_new] = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.AvgDtr.Fluxes.LE_L']);
        [H_new]  = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.AvgDtr.Fluxes.Hs']);
        Delay_CO2_new  = get_stats_field(StatsX,[ EC_system_name '.Delays.Implemented(1)']);
        Delay_H2O_new  = get_stats_field(StatsX,[ EC_system_name '.Delays.Implemented(2)']);
        BarometricP_new  = get_stats_field(StatsX,'MiscVariables.BarometricP');
        Tair_new  = get_stats_field(StatsX,'MiscVariables.Tair');
        CAL0_CO2_new  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(2)');
            CAL0_CO2_new =interp1(t(1:48:end),CAL0_CO2_new(1:48:end),t)';
        CAL1_CO2_new  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(1)');
            CAL1_CO2_new =interp1(t(1:48:end),CAL1_CO2_new(1:48:end),t)';        
        CAL0_H2O_new  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.H2O(2)');
            CAL0_H2O_new =interp1(t(1:48:end),CAL0_H2O_new(1:48:end),t)';
        [means_new]  = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.Avg']);
        NumOfSamples_new.EC  = get_stats_field(StatsX,[ EC_system_name '.MiscVariables.NumOfSamples']);
        %InstrumentSonic = ['Instrument(' StatsX(1).Configuration.System.Instrument(1) ')']
        %NumOfSamples.Instrument(1).N = get_stats_field(StatsX,'Instrument(');
        t_new = t;
    else
        [Fc_old] = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.AvgDtr.Fluxes.Fc']);
        [Le_old] = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.AvgDtr.Fluxes.LE_L']);
        [H_old]  = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.AvgDtr.Fluxes.Hs']);
        BarometricP_old  = get_stats_field(StatsX,'MiscVariables.BarometricP');
        Delay_CO2_old  = get_stats_field(StatsX,[ EC_system_name '.Delays.Implemented(1)']);
        Delay_H2O_old  = get_stats_field(StatsX,[ EC_system_name '.Delays.Implemented(2)']);
        Tair_old  = get_stats_field(StatsX,'MiscVariables.Tair');
        CAL0_CO2_old  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(2)');
            CAL0_CO2_old =interp1(t(1:48:end),CAL0_CO2_old(1:48:end),t)';
        CAL1_CO2_old  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(1)');
            CAL1_CO2_old =interp1(t(1:48:end),CAL1_CO2_old(1:48:end),t)';
        CAL0_H2O_old  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.H2O(2)');
            CAL0_H2O_old =interp1(t(1:48:end),CAL0_H2O_old(1:48:end),t)';
        [means_old]  = get_stats_field(StatsX,[ EC_system_name '.Three_Rotations.Avg']);
        NumOfSamples_old.EC  = get_stats_field(StatsX,[ EC_system_name '.MiscVariables.NumOfSamples']);
        t_old=t;
    end
end

t=t_new;
t        = t - GMTshift; %PST time

%reset time vector to doy
t    = t - startDate + 1;
%tv   = tv - startDate + 1;
st   = st - startDate + 1;
ed   = ed - startDate + 1;

fig=0;



%-----------------------------------------------
% CO_2 (\mumol mol^-1 of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);
try
  plot(t,means_new(:,5),'bo-',t,means_old(:,5),'g-');
catch
  plot(t,means_new(:,5),'bo-');
end
legend('new from recalc','old from site');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2'})
ylabel('\mumol mol^{-1} of dry air')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    new_reg_v = real(means_new(:,5));
    old_reg_v = real(means_old(:,5));
    ind = find(abs(new_reg_v)< 10e5 & abs(old_reg_v)< 10e5);
    plot_regression(old_reg_v(ind), new_reg_v(ind), [], [], 'ortho'); %#ok<*NOPRT>
    title('CO2 comparision');
    zoom on;
    xlabel('CO2 (old calc) (\mumol mol^-1)');
    ylabel('CO2 (new calc) (\mumol mol^-1)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: CO2 comparision');
end
    
%-----------------------------------------------
% CO2 flux
%-----------------------------------------------
fig = fig+1;figure(fig);
try
   plot(t,Fc_new,'bo-',t,Fc_old,'g-');
catch
   plot(t,Fc_new,'bo-');
end
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed+1]);
legend('new from recalc','old from site');
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_c'})
ylabel('\mumol m^{-2} s^{-1}')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
zoom on; pause;

fig=fig+1;figure(fig);
try
    new_reg_v = real(Fc_new);
    old_reg_v = real(Fc_old);
    ind = find(abs(new_reg_v)< 10e5 & abs(old_reg_v)< 10e5);
    plot_regression(old_reg_v(ind), new_reg_v(ind), [], [], 'ortho');
    title('F_{C} comparision');
    zoom on;
    xlabel('F_{C} (old calc) (\mumol m^-2 s^-1)');
    ylabel('F_{C} (new calc) (\mumol m^-2 s^-1)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: F_{C} comparision');    
end

%-----------------------------------------------
% Sensible heat
%
fig = fig+1;figure(fig);
try
plot(t,H_new,'bo-',t,H_old,'g-'); 
catch
    plot(t,H_new,'bo-')
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-200 600],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Sensible Heat'})
ylabel('(Wm^{-2})')
%legend('Gill','Tc1','Tc2',-1)
%legend('Gill',-1)
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
zoom on; pause;

fig=fig+1;figure(fig);
try
    new_reg_v = real(H_new);
    old_reg_v = real(H_old);
    ind = find(abs(new_reg_v)< 10e5 & abs(old_reg_v)< 10e5);
    plot_regression(old_reg_v(ind), new_reg_v(ind), [], [], 'ortho');
%    plot_regression(H_old, H_new, [], [], 'ortho');
    title('Sensible Heat comparision');
    zoom on;
    xlabel('H (old calc) (W/m^-2)');
    ylabel('H (new calc) (W/m^-2)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: Sensible Heat comparision');
end


%-----------------------------------------------
% H2O (\mmol mol^-1 of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);
try
  plot(t,means_new(:,6),'bo-',t,means_old(:,6),'g-');
catch
  plot(t,means_new(:,6),'bo-');
end
legend('new from recalc','old from site');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[0 25])
title({'Eddy Correlation: ';'H_2O'})
ylabel('mmol mol^{-1} of dry air')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    new_reg_v = real(means_new(:,6));
    old_reg_v = real(means_old(:,6));
    ind = find(abs(new_reg_v)< 10e5 & abs(old_reg_v)< 10e5);
    plot_regression(old_reg_v(ind), new_reg_v(ind), [], [], 'ortho');
 %   plot_regression(means_old(:,6), means_new(:,6), [], [], 'ortho');
    title('H_2O comparision');
    zoom on;
    xlabel('H_2O (old calc) (mmol mol^-1)');
    ylabel('H_2O (new calc) (mmol mol^-1)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: H_2O comparision');
end

%-----------------------------------------------
% Latent heat
%
fig = fig+1;figure(fig);
try
plot(t,Le_new,'bo-',t,Le_old,'g-');
catch
    plot(t,Le_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-10 400],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Latent Heat'})
ylabel('(Wm^{-2})')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    new_reg_v = real(Le_new);
    old_reg_v = real(Le_old);
    ind = find(abs(new_reg_v)< 10e5 & abs(old_reg_v)< 10e5);
    plot_regression(old_reg_v(ind), new_reg_v(ind), [], [], 'ortho');
 %   plot_regression(Le_old, Le_new, [], [], 'ortho');
    title('Latent Heat comparision');
    zoom on;
    xlabel('LE (old calc) (W/m^-2)');
    ylabel('LE (new calc) (W/m^-2)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: Latent Heat comparision');
end

%-----------------------------------------------
% Barometric pressure
%
fig = fig+1;figure(fig);
try
    plot(t,BarometricP_new,'bo-',t,BarometricP_old,'g-');
catch
    plot(t,BarometricP_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[90 110],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'BarometricP'})
ylabel('(kPa)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    plot_regression(BarometricP_old, BarometricP_new, [], [], 'ortho');
    title('BarometricP comparision');
    zoom on;
    xlabel('BarometricP (old calc) (kPa)');
    ylabel('BarometricP (new calc) (kPa)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: BarometricP comparision');
end

%-----------------------------------------------
% Air Temperature
%
fig = fig+1;figure(fig);
try
    plot(t,Tair_new,'bo-',t,Tair_old,'g-');
catch
    plot(t,Tair_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-40 40],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Tair'})
ylabel('(degC)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    new_reg_v = real(Tair_new);
    old_reg_v = real(Tair_old);
    ind = find(abs(new_reg_v)< 10e5 & abs(old_reg_v)< 10e5);
    plot_regression(old_reg_v(ind), new_reg_v(ind), [], [], 'ortho');
%    plot_regression(Tair_old, Tair_new, [], [], 'ortho');
    title('Tair comparision');
    zoom on;
    xlabel('Tair (old calc) (C)');
    ylabel('Tair (new calc) (C)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: Tair comparision');
end

%-----------------------------------------------
% Cal 0 CO2
%
fig = fig+1;figure(fig);
try
plot(t,CAL0_CO2_new,'bo-',t,CAL0_CO2_old,'g-');
catch
    plot(t,CAL0_CO2_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-10 10],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'CAL0 CO2'})
ylabel('(ppm)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    plot_regression(CAL0_CO2_old, CAL0_CO2_new, [], [], 'ortho');
    title('CO2 zero offset comparision');
    zoom on;
    xlabel('CAL0_CO2 (old calc) (ppm)');
    ylabel('CAL0_CO2 (new calc) (ppm)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: CAL0 CO2 comparision');
end

%-----------------------------------------------
% Cal 0 H2O
%
fig = fig+1;figure(fig);
try
plot(t,CAL0_H2O_new,'bo-',t,CAL0_H2O_old,'g-');
catch
    plot(t,CAL0_H2O_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-10 10],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'CAL0 H2O'})
ylabel('(mmol/mol)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    plot_regression(CAL0_CO2_old, CAL0_CO2_new, [], [], 'ortho');
    title('H2O zero offset comparision');
    zoom on;
    xlabel('CAL0_H2O (old calc) (mmol/mol)');
    ylabel('CAL0_H2O (new calc) (mmol/mol)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: CAL0 H2O comparision');
end

%-----------------------------------------------
% Cal 1 CO2
%
fig = fig+1;figure(fig);
try
plot(t,CAL1_CO2_new,'bo-',t,CAL1_CO2_old,'g-');
catch
    plot(t,CAL1_CO2_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[0.95 1.05],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'CAL1 CO2'})
ylabel('(1)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    plot_regression(CAL1_CO2_old, CAL1_CO2_new, [], [], 'ortho');
    title('CO2 span comparision');
    zoom on;
    xlabel('CAL1_CO2 (old calc) (1)');
    ylabel('CAL1_CO2 (new calc) (1)');
    zoom on; pause;
catch
    clf
    title('Error plotting: CO2 span comparision');
end
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))

%-----------------------------------------------
% Delays CO2
%
fig = fig+1;figure(fig);
try
plot(t,Delay_CO2_new,'bo-',t,Delay_CO2_old,'g-');
catch
    plot(t,Delay_CO2_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-50 50],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'CO2 delays'})
ylabel('(samples)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    plot_regression(Delay_CO2_old, Delay_CO2_new, [], [], 'ortho');
    title('CO2 delay comparision');
    zoom on;
    xlabel('CO2 delays (old calc) (samples)');
    ylabel('CO2 delays (new calc) (samples)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: CO2 delays comparision');
end

%-----------------------------------------------
% Delays H2O
%
fig = fig+1;figure(fig);
try
plot(t,Delay_H2O_new,'bo-',t,Delay_H2O_old,'g-');
catch
    plot(t,Delay_H2O_new,'bo-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-50 50],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'H2O delays'})
ylabel('(samples)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;

fig=fig+1;figure(fig);
try
    plot_regression(Delay_H2O_old, Delay_H2O_new, [], [], 'ortho');
    title('H2O delay comparision');
    zoom on;
    xlabel('H2O delays (old calc) (samples)');
    ylabel('H2O delays (new calc) (samples)');
    h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
    zoom on; pause;
catch
    clf
    title('Error in: H2O delays comparision');
end

%-----------------------------------------------
% EC NumOfSamples
%
fig = fig+1;figure(fig);
try
plot(t,NumOfSamples_new.EC,'bo-',t,NumOfSamples_old.EC,'g-');
catch
    plot(t,NumOfSamples_new.EC,'bo-');
end
legend('new from recalc','old from site');
h = gca;
%set(h,'YLim',[35000 40000],'XLim',[st ed+1]);
set(h,'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'NumOfSamples: EC'})
ylabel('(samples)')
h=get(get(gca,'title'),'string');set(gcf,'name',char(h(size(h,1),:)))
pause;
