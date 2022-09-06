function pl_neweddy_recalc(year,siteId,ind,pth_new,pth_old);

% Plots recalculation comparisons for new eddy systems
% the location of the new daily .mat files is obtained from fr_get_local_path
% and is assumed to be \\PAOA001\sites\siteId\hhour for the old files if
% pth_old is not input by the user

% file created: Jan 23, 2009 (nick)
% last modified: March 31, 2010

% Revisions:
% May 28, 2010
%   -gave user control over the hhour path for the recalc files, with the
%   path listed in fr_get_local_path the default.
% March 31, 2010
%   -user can now supply pth_old to compare flux files in any directory
%   with files produced in met-data\hhour by recalculation and set in
%   fr_get_local_path


st = datenum(year,1,min(ind));                         % first day of measurements
ed = datenum(year,1,max(ind));                         % last day of measurements (approx.)
startDate   = datenum(min(year),1,1);     
currentDate = datenum(year,1,ind(1));
days        = ind(end)-ind(1)+1;
GMTshift = 8/24; 

%ext         = '.hy.mat';
c = fr_get_init(siteId,currentDate);
ext = c.hhour_ext;

[dataPth,hhourPth,databasePth,csiPth] = FR_get_local_path;

arg_default('pth_new',hhourPth);
arg_default('pth_old',['\\PAOA001\Sites\' siteId '\hhour\']);

StatsX = [];
for n=1:48
    StatsX_msg(n).TimeVector = NaN;
    StatsX_msg(n).RecalcTime = NaN;
    StatsX_msg(n).Configuration = NaN;
    StatsX_msg(n).Instrument = NaN;
    StatsX_msg(n).MiscVariables = NaN;
    StatsX_msg(n).MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc = NaN;
    StatsX_msg(n).MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L = NaN;
    StatsX_msg(n).MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs = NaN;
    StatsX_msg(n).MainEddy.Three_Rotations.Avg(1:6) = NaN.*ones(1,6);
    switch upper(siteId)
        case 'HJP94'
            StatsX_msg(n).SecondEddy.Three_Rotations.AvgDtr.Fluxes.Fc = NaN;
            StatsX_msg(n).SecondEddy.Three_Rotations.AvgDtr.Fluxes.LE_L = NaN;
            StatsX_msg(n).SecondEddy.Three_Rotations.AvgDtr.Fluxes.Hs = NaN;
            StatsX_msg(n).SecondEddy.Three_Rotations.Avg(1:6) = NaN.*ones(1,6);
    end
end
t      = [];
dataset = {'new' 'old'};
for j=1:length(dataset);
    currentDate = datenum(year,1,ind(1));
    t=[];
    for i = 1:days;
        filename_p = FR_DateToFileName(currentDate+.03);
        filename   = filename_p(1:6);
        eval(['pth = pth_' char(dataset{j}) ';' ]);
        pth_filename_ext = [pth filename ext];
        if ~exist([pth filename ext]);
            pth_filename_ext = [pth filename 's' ext];
        end
        
        if exist(pth_filename_ext);
            try
                load(pth_filename_ext);
                disp(['Read ' pth_filename_ext ]);
                if i == 1;
                    StatsX = [Stats];
                    t = [t currentDate+1/48:1/48:currentDate+1];
                else
                    StatsX = [StatsX Stats];
                    t = [t currentDate+1/48:1/48:currentDate+1];
                end
                
            catch
                disp(lasterr);    
            end
        else
            disp(['Short file ' pth_filename_ext ' not found']);
            StatsX = [StatsX StatsX_msg];
        end
        currentDate = currentDate + 1;
    end
    if strcmp(char(dataset{j}),'new')
        [Fc_new] = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
        [Le_new] = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
        [H_new]  = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
        BarometricP_new  = get_stats_field(StatsX,'MiscVariables.BarometricP');
        Tair_new  = get_stats_field(StatsX,'MiscVariables.Tair');
        CAL0_CO2_new  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(2)');
        CAL1_CO2_new  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(1)');
        CAL0_H2O_new  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.H2O(2)');
        [means_new]  = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
        t_new = t;
    else
        [Fc_old] = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
        [Le_old] = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
        [H_old]  = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
        BarometricP_old  = get_stats_field(StatsX,'MiscVariables.BarometricP');
        Tair_old  = get_stats_field(StatsX,'MiscVariables.Tair');
        CAL0_CO2_old  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(2)');
            CAL0_CO2_old =interp1(t(1:48:end),CAL0_CO2_old(1:48:end),t)';
        CAL1_CO2_old  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.CO2(1)');
            CAL1_CO2_old =interp1(t(1:48:end),CAL1_CO2_old(1:48:end),t)';
        CAL0_H2O_old  = get_stats_field(StatsX,'Configuration.Instrument(2).Cal.H2O(2)');
            CAL0_H2O_old =interp1(t(1:48:end),CAL0_H2O_old(1:48:end),t)';
        [means_old]  = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
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
  plot(t,means_new(:,[5]),'bo-',t,means_old(:,[5]),'g-');
catch
  plot(t,means_new(:,[5]),'bo-');
end
legend('new from recalc','old from site');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2'})
ylabel('\mumol mol^{-1} of dry air')
pause;

fig=fig+1;figure(fig);
plot_regression(means_old(:,[5]), means_new(:,[5]), [], [], 'ortho');
title('CO2 comparision');
zoom on;
xlabel('CO2 (old calc) (\mumol mol^-1)');
ylabel('CO2 (new calc) (\mumol mol^-1)');
zoom on; pause;

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
zoom on; pause;

fig=fig+1;figure(fig);
plot_regression(Fc_old, Fc_new, [], [], 'ortho');
title('F_{C} comparision');
zoom on;
xlabel('F_{C} (old calc) (\mumol m^-2 s^-1)');
ylabel('F_{C} (new calc) (\mumol m^-2 s^-1)');
zoom on; pause;

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
zoom on; pause;

fig=fig+1;figure(fig);
plot_regression(H_old, H_new, [], [], 'ortho');
title('Sensible Heat comparision');
zoom on;
xlabel('H (old calc) (W/m^-2)');
ylabel('H (new calc) (W/m^-2)');
zoom on; pause;

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
pause;

fig=fig+1;figure(fig);
plot_regression(Le_old, Le_new, [], [], 'ortho');
title('Latent Heat comparision');
zoom on;
xlabel('LE (old calc) (W/m^-2)');
ylabel('LE (new calc) (W/m^-2)');
zoom on; pause;

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
pause;

fig=fig+1;figure(fig);
plot_regression(BarometricP_old, BarometricP_new, [], [], 'ortho');
title('BarometricP comparision');
zoom on;
xlabel('BarometricP (old calc) (kPa)');
ylabel('BarometricP (new calc) (kPa)');
zoom on; pause;

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
pause;

fig=fig+1;figure(fig);
plot_regression(Tair_old, Tair_new, [], [], 'ortho');
title('Tair comparision');
zoom on;
xlabel('Tair (old calc) (C)');
ylabel('Tair (new calc) (C)');
zoom on; pause;

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
pause;

fig=fig+1;figure(fig);
plot_regression(CAL0_CO2_old, CAL0_CO2_new, [], [], 'ortho');
title('CO2 zero offset comparision');
zoom on;
xlabel('CAL0_CO2 (old calc) (ppm)');
ylabel('CAL0_CO2 (new calc) (ppm)');
zoom on; pause;

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
pause;

fig=fig+1;figure(fig);
plot_regression(CAL0_CO2_old, CAL0_CO2_new, [], [], 'ortho');
title('H2O zero offset comparision');
zoom on;
xlabel('CAL0_H2O (old calc) (mmol/mol)');
ylabel('CAL0_H2O (new calc) (mmol/mol)');
zoom on; pause;

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
pause;

fig=fig+1;figure(fig);
plot_regression(CAL1_CO2_old, CAL1_CO2_new, [], [], 'ortho');
title('CO2 span comparision');
zoom on;
xlabel('CAL1_CO2 (old calc) (1)');
ylabel('CAL1_CO2 (new calc) (1)');
zoom on; pause;
