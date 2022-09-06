function pl_neweddy_recalc(year,siteId,ind);

% Plots recalculation comparisons for new eddy systems
% the location of the new daily .mat files is obtained from fr_get_local_path
% and is assumed to be \\PAOA001\sites\siteId\hhour for the old files

% file created: Jan 23, 2009 (nick)

% Revisions:


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

pth_new = hhourPth;
pth_old = ['\\PAOA001\Sites\' siteId '\hhour\'];
%pth=pth_new;
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
        [means_new]  = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
        t_new = t;
    else
        [Fc_old] = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
        [Le_old] = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
        [H_old]  = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
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
  plot(t,means_new(:,[5]),'b-',t,means_old(:,[5]),'g-');
catch
  plot(t,means_new(:,[5]),'b-');
end
legend('new from recalc','old from site');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2'})
ylabel('\mumol mol^{-1} of dry air')
pause;

fig=fig+1;figure(fig);
plot_regression(Fc_old, Fc_new, [], [], 'ortho');
title('CO2 comparision');
zoom on;
xlabel('CO2 (old calc) (W/m^-2)');
ylabel('CO2 (new calc) (W/m^-2)');
zoom on; pause;

%-----------------------------------------------
% CO2 flux
%-----------------------------------------------
fig = fig+1;figure(fig);
try
   plot(t,Fc_new,'b-',t,Fc_old,'g-');
catch
   plot(t,Fc_new,'b-');
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
plot(t,H_new,'b-',t,H_old,'g-'); 
catch
    plot(t,H_new,'b-')
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-200 600],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Sensible Heat'})
ylabel('(Wm^{-2})')
%legend('Gill','Tc1','Tc2',-1)
legend('Gill',-1)
zoom on; pause;

fig=fig+1;figure(fig);
plot_regression(Fc_old, Fc_new, [], [], 'ortho');
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
plot(t,Le_new,'b-',t,Le_old,'g-');
catch
    plot(t,Le_new,'b-');
end
legend('new from recalc','old from site');
h = gca;
set(h,'YLim',[-10 400],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Latent Heat'})
ylabel('(Wm^{-2})')
pause;

fig=fig+1;figure(fig);
plot_regression(Fc_old, Fc_new, [], [], 'ortho');
title('Latent Heat comparision');
zoom on;
xlabel('LE (old calc) (W/m^-2)');
ylabel('LE (new calc) (W/m^-2)');
zoom on; pause;
