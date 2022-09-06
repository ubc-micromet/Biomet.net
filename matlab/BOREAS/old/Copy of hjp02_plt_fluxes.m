function [] = hjp02_plt_fluxes(ind, year, SiteID, select);

% Revisions:
% Nov 2, 2007
%   -added delay times plots (Nick)
%
if nargin < 4
    select = 0;
end

startDate   = datenum(min(year),1,0);     
currentDate = datenum(year,1,ind(1));
days        = ind(end)-ind(1)+1;

%load in fluxes
switch upper(SiteID)
    case 'HJP02'
        pth = '\\PAOA001\SITES\hjp02\hhour\';
        ext         = '.hhjp02.mat';
        cpIRGA = 5;
        c = fr_get_init('HJP02',currentDate);
    case 'HJP75'
        pth = '\\PAOA001\SITES\hjp75\hhour\';
        ext         = '.hhjp75.mat';
        cpIRGA = 2;
    otherwise
        disp('Uknown site')
end


StatsX = [];
data_pointer = 0;
for i = 1:days;
    
    filename_p = FR_DateToFileName(currentDate+.03);
    filename   = filename_p(1:6);
    
%    if exist([pth filename ext]);
%        load([pth filename ext]);
%        for j = 1:length(Stats);
%            data_pointer = data_pointer + 1;
%            fNames = fieldnames(Stats);
%            for kk = 1:length(fNames)
%                StatsX = setfield(StatsX,{data_pointer},char(fNames(kk)),getfield(Stats,{j},char(fNames(kk))));
%            end
%        end
%    end

    if exist([pth filename ext]);
        try
            load([pth filename ext]);
            if i == 1;
                StatsX = [Stats];
                t      = [currentDate+1/48:1/48:currentDate+1];
            else
                StatsX = [StatsX Stats];
                t      = [t currentDate+1/48:1/48:currentDate+1];
            end
        end
    end

    currentDate = currentDate + 1;
    
end

%t = get_stats_field(StatsX,'TimeVector');
t = get_stats_field(StatsX,'TimeVector');

GMTshift = 6/24; 
t        = t - GMTshift; %PST time

%reset time vector to doy
fig = 0;
ind = find(t > startDate + ind(1) & t <= startDate + ind(end));
t = t(ind)-startDate;

st = datenum(year,1,min(ind));                         % first day of measurements
ed = datenum(year,1,max(ind));                         % last day of measurements (approx.)

%CSATn = 1;
%IRGAn = 2;
%Pn = 3;

%-----------------------------------------------
% 1. NumOfSamples
%
fig = fig+1;figure(fig);clf;
Nsonic = get_stats_field(StatsX,'Instrument(1).MiscVariables.NumOfSamples');
Nirga_op = get_stats_field(StatsX,'Instrument(2).MiscVariables.NumOfSamples');

switch upper(SiteID)
    case 'HJP02'
        Nirga_cp = get_stats_field(StatsX,'Instrument(5).MiscVariables.NumOfSamples');
    otherwise
        Nirga_cp = get_stats_field(StatsX,'Instrument(2).MiscVariables.NumOfSamples');
end

Nsonic(end-47:end) = Nsonic(end-47:end);
Nirga_cp(end-47:end) = Nirga_cp(end-47:end);
Nirga_op(end-47:end) = Nirga_op(end-47:end);

%plot(t,[Nsonic(ind) Nirga_op(ind) Nirga_cp(ind)]);
plot(t,[Nsonic(ind) Nirga_cp(ind)]);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'YLim',[35900 36700])
title({'Eddy Correlation: ';'Number of Samples'});
ylabel('1')
%legend('Sonic','LI7500','LI7000', -1)
legend('Sonic','LI7000', -1)


%-----------------------------------------------
% 2. Sonic wind speeds (before rotation)
%
fig = fig+1;figure(fig);clf;
U = get_stats_field(StatsX,'Instrument(1).Avg(1)');
V = get_stats_field(StatsX,'Instrument(1).Avg(2)');
W = get_stats_field(StatsX,'Instrument(1).Avg(3)');

plot(t,[U(ind) V(ind) W(ind)]);
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Sonic Wind Speed (Before Rotation)'});
ylabel('(m/s)')
legend('U','V','W', -1)

%-----------------------------------------------
% 3. Sonic wind speeds (before rotation)
%
fig = fig+1;figure(fig);clf;
plot(t,(U(ind).^2 +V(ind).^2 + W(ind).^2).^0.5);
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Sonic Cup Wind Speed (Before Rotation)'});
ylabel('(m/s)')
%legend('U','V','W')

%-----------------------------------------------
% 4. Sonic temperature
%
fig = fig+1;figure(fig);clf;
Tair = get_stats_field(StatsX,'Instrument(1).Avg(4)');
plot(t,Tair(ind));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Sonic Air Temperature'});
ylabel('\circC')

%switch upper(SiteID)
%   case 'HJP02'
%-----------------------------------------------
% LI-7500 Temperature
%
%fig = fig+1;figure(fig);clf;
%Tbench = [get_stats_field(StatsX,'Instrument(2).Avg(4)') ...
%          get_stats_field(StatsX,'Instrument(2).Min(4)') ...
%          get_stats_field(StatsX,'Instrument(2).Max(4)') ...
%          ];
%plot(t,Tbench(ind,:));
%grid on;
%zoom on;
%xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed])
%title({'Eddy Correlation: ';'LI-7500 Temperature'});
%ylabel('\circC')
%	otherwise
%end

%-----------------------------------------------
% LI-7000 Temperature
%
fig = fig+1;figure(fig);clf;
Tbench = [get_stats_field(StatsX,['Instrument(' num2str(cpIRGA) ').Avg(3)']) ...
          get_stats_field(StatsX,['Instrument(' num2str(cpIRGA) ').Min(3)']) ...
          get_stats_field(StatsX,['Instrument(' num2str(cpIRGA) ').Max(3)']) ...
          ];
plot(t,Tbench(ind,:));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'LI-7000 Temperature'});
ylabel('\circC')

%-----------------------------------------------
% LI-7000 Pressure
%
fig = fig+1;figure(fig);clf;
Plicor = [get_stats_field(StatsX,['Instrument(' num2str(cpIRGA) ').Avg(4)']) ...
          get_stats_field(StatsX,['Instrument(' num2str(cpIRGA) ').Min(4)']) ...
          get_stats_field(StatsX,['Instrument(' num2str(cpIRGA) ').Max(4)']) ...
          ];
plot(t,Plicor(ind,:));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'LI-7000 Pressure'});
ylabel('(kPa)')

switch upper(SiteID)
   case 'HJP02'
%-----------------------------------------------
% CSAT3 Diagnostic Flag Channel#5
%
fig = fig+1;figure(fig);clf;
DF_CSAT_5 = [get_stats_field(StatsX,'Instrument(1).Avg(5)') ...
          get_stats_field(StatsX,'Instrument(1).Min(5)') ...
          get_stats_field(StatsX,'Instrument(1).Max(5)') ...
          ];
plot(t,DF_CSAT_5(ind,:));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'CSAT3 Diagnostic Flag Channel#5'});
ylabel('?')

%-----------------------------------------------
% Li-7000 Diagnostic Flag Channel#6
%
fig = fig+1;figure(fig);clf;
DF_LI7000_6 = [get_stats_field(StatsX,'Instrument(5).Avg(6)') ...
          get_stats_field(StatsX,'Instrument(5).Min(6)') ...
          get_stats_field(StatsX,'Instrument(5).Max(6)') ...
          ];
plot(t,DF_LI7000_6(ind,:));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Li-7000 Diagnostic Flag Channel#6'});
ylabel('?')

%-----------------------------------------------
% Li-7500 Diagnostic Flag Channel#6
%
%fig = fig+1;figure(fig);clf;
%DF_LI7500_6 = [get_stats_field(StatsX,'Instrument(2).Avg(6)') ...
%          get_stats_field(StatsX,'Instrument(2).Min(6)') ...
%          get_stats_field(StatsX,'Instrument(2).Max(6)') ...
%          ];
%plot(t,DF_LI7500_6(ind,:));
%grid on;
%zoom on;
%xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed])
%title({'Eddy Correlation: ';'Li-7500 Diagnostic Flag Channel#6'});
%ylabel('?')

	otherwise
        
%-----------------------------------------------
% GillR3 Diagnostic Flag Channel#5
%
fig = fig+1;figure(fig);clf;
DF_CSAT_5 = [get_stats_field(StatsX,'Instrument(1).Avg(5)') ...
          get_stats_field(StatsX,'Instrument(1).Min(5)') ...
          get_stats_field(StatsX,'Instrument(1).Max(5)') ...
          ];
plot(t,DF_CSAT_5(ind,:));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'GillR3 Diagnostic Flag Channel#5'});
ylabel('?')
 
%-----------------------------------------------
% Li-7000 Diagnostic Flag Channel#6
%
fig = fig+1;figure(fig);clf;
DF_LI7000_6 = [get_stats_field(StatsX,'Instrument(2).Avg(6)') ...
          get_stats_field(StatsX,'Instrument(2).Min(6)') ...
          get_stats_field(StatsX,'Instrument(2).Max(6)') ...
          ];
plot(t,DF_LI7000_6(ind,:));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Li-7000 Diagnostic Flag Channel#6'});
ylabel('?')
      
end

%-----------------------------------------------
% IRGA CO2 (mmol/m^3)
%
%fig = fig+1;figure(fig);clf;
%CO2 = get_stats_field(StatsX,'Instrument(2).Avg(1)');
%plot(t,CO2(ind));
%grid on;
%zoom on;
%xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed])
%title({'Eddy Correlation: ';'IRGA CO2 (mmol/m^3)'});
%ylabel('mmol/m^3')

%-----------------------------------------------
% IRGA CO2 (umol/mol)
%
fig = fig+1;figure(fig);clf;
CO2_main = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg(5)');
CO2_main_max = get_stats_field(StatsX,'MainEddy.Three_Rotations.Max(5)');
CO2_main_min = get_stats_field(StatsX,'MainEddy.Three_Rotations.Min(5)');
%CO2_sec = get_stats_field(StatsX,'SecondEddy.Three_Rotations.Avg(5)');
%CO2_sec_max = get_stats_field(StatsX,'SecondEddy.Three_Rotations.Max(5)');
%CO2_sec_min = get_stats_field(StatsX,'SecondEddy.Three_Rotations.Min(5)');
%plot(t,[CO2_main(ind,:) CO2_main_max(ind,:) CO2_main_min(ind,:) ...
%        CO2_sec(ind,:) CO2_sec_max(ind,:) CO2_sec_min(ind,:)]);
plot(t,[CO2_main(ind,:) CO2_main_max(ind,:) CO2_main_min(ind,:)]);
grid on;
zoom on;
xlabel('DOY')
%legend('CO_2 CP Avg','CO_2 CP Max','CO_2 CP Min','CO_2 OP Avg','CO_2 OP Max','CO_2 OP Min', -1)
legend('CO_2 CP Avg','CO_2 CP Max','CO_2 CP Min',-1);
h = gca;
set(h,'YLim',[330 500])
title({'Eddy Correlation: ';'IRGA CO2 (umol/mol)'});
ylabel('umol/mol')

%-----------------------------------------------
% IRGA H2O (mmol/m^3)
%
%fig = fig+1;figure(fig);clf;
%H2O = get_stats_field(StatsX,'Instrument(2).Avg(2)');
%plot(t,H2O(ind));
%grid on;
%zoom on;
%xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed])
%title({'Eddy Correlation: ';'IRGA H2O (mmol/m^3)'});
%ylabel('mmol/m^3')

%-----------------------------------------------
% IRGA H2O (mmol/mol)
%
fig = fig+1;figure(fig);clf;
H2O_main = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg(6)');
H2O_main_max = get_stats_field(StatsX,'MainEddy.Three_Rotations.Max(6)');
H2O_main_min = get_stats_field(StatsX,'MainEddy.Three_Rotations.Min(6)');
%H2O_sec = get_stats_field(StatsX,'SecondEddy.Three_Rotations.Avg(6)');
%H2O_sec_max = get_stats_field(StatsX,'SecondEddy.Three_Rotations.Max(6)');
%H2O_sec_min = get_stats_field(StatsX,'SecondEddy.Three_Rotations.Min(6)');
%plot(t,[H2O_main(ind,:) H2O_main_max(ind,:) H2O_main_min(ind,:) ...
%        H2O_sec(ind,:) H2O_sec_max(ind,:) H2O_sec_min(ind,:)]);
plot(t,[H2O_main(ind,:) H2O_main_max(ind,:) H2O_main_min(ind,:)]);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'YLim',[0 15])
title({'Eddy Correlation: ';'IRGA H2O (mmol/mol)'});
ylabel('mmol/mol')
%legend('H_2O CP Avg','H_2O CP Max','H_2O CP Min','H_2O OP Avg','H_2O OP Max','H_2O OP Min', -1)
legend('H_2O CP Avg','H_2O CP Max','H_2O CP Min', -1);

%-----------------------------------------------
% CO_2 & H_2O delay times
%
Delays_calc       = get_stats_field(StatsX,'MainEddy.Delays.Calculated');
Delays_set        = get_stats_field(StatsX,'MainEddy.Delays.Implemented');

plot(t,Delays_calc(ind,1:2),'o')
if c.Instrument(cpIRGA).Delays.Samples ~= [ 0 0 ]
    h = line([t(1) t(end)],c.Instrument(cpIRGA).Delays.Samples(1)*ones(1,2));
    set(h,'color','y','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(cpIRGA).Delays.Samples(2)*ones(1,2));
    set(h,'color','m','linewidth',1.5)
end
grid on;zoom on;xlabel('DOY')
title('CO_2 & H_2O delay times')
ylabel('Samples')
legend('CO_2','H_2O','CO_2 setup','H_2O setup',-1)


%-----------------------------------------------
% Delay Times (histogram)
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
subplot(2,1,1); hist(Delays_calc(ind,1),200); 
if c.Instrument(cpIRGA).Delays.Samples ~= [ 0 0 ]
    ax=axis;
    h = line(c.Instrument(cpIRGA).Delays.Samples(1)*ones(1,2),ax(3:4));
    set(h,'color','y','linewidth',2)
end
ylabel('CO_2 delay times')
subplot(2,1,2); hist(Delays_calc(ind,2),200);
if c.Instrument(cpIRGA).Delays.Samples ~= [ 0 0 ]
    ax=axis;
    h = line(c.Instrument(cpIRGA).Delays.Samples(2)*ones(1,2),ax(3:4));
    set(h,'color','y','linewidth',2)
end
ylabel('H_{2}O delay times')

%-----------------------------------------------
% Energy fluxes
%
fig = fig+1;figure(fig);clf;
LE = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
H = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
%LE_op = get_stats_field(StatsX,'SecondEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
%plot(t,[H(ind) LE(ind) LE_op(ind)]);
plot(t,[H(ind) LE(ind)]);
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Energy fluxes'});
ylabel('W/m^2')
%legend('H','LE_{cp}','LE_{op}');
legend('H','LE_{cp}');

%-----------------------------------------------
% CO2 flux
%
fig = fig+1;figure(fig);clf;
Fc = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
%try
%    Fc_sec = get_stats_field(StatsX,'SecondEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
%catch
%    Fc_sec =  NaN * ones(size(Fc));
%end

%plot(t,Fc(ind),t,Fc_sec(ind));
plot(t,Fc(ind));
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed])
title({'Eddy Correlation: ';'Fc'});
ylabel('?')
%legend('Main EC','Second EC')


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

return

%-----------------------------------------------
% Air temperatures (Gill and 0.001" Tc)
%
fig = fig+1;figure(fig);clf;
plot(t,means(:,[4]));
h = gca;
set(h,'XLim',[st ed],'YLim',Tax)

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Air Temperature CSAT'})
ylabel('\circC')
%legend('sonic','HMP',-1)
zoom on;

%-----------------------------------------------
% Barometric pressure
%
fig = fig+1;figure(fig);clf;
plot(t,Pbar);
h = gca;
set(h,'XLim',[st ed],'YLim',[90 102])

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Barometric pressure'})
ylabel('(kPa)')

%-----------------------------------------------
% H_2O (mmol/mol of dry air)
%
fig = fig+1;figure(fig);clf;

tmp = (0.61365*exp((17.502*HMPT)./(240.97+HMPT)));  %HMP vapour pressure
HMP_mixratio = (1000.*tmp.*HMPRH)./(Pbar-HMPRH.*tmp); %mixing ratio

plot(t,means(:,[6]),tv,HMP_mixratio);
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed], 'YLim',[-1 22])
title({'Eddy Correlation: ';'H_2O'})
ylabel('(mmol mol^{-1} of dry air)')

legend('IRGA','HMP',-1)
zoom on;

%-----------------------------------------------
% H_2O (mmol/mol of dry air) vs. HMP
%
fig = fig+1;figure(fig);clf;

plot(means(IB,[6]),HMP_mixratio(IA),'.',...
    [-1 22],[-1 22]);
grid on;zoom on;ylabel('HMP mixing ratio (mmol/mol)')
h = gca;
set(h,'XLim',[-1 22], 'YLim',[-1 22])
title({'Eddy Correlation: ';'H_2O'})
xlabel('irga (mmol mol^{-1} of dry air)')
zoom on;

%-----------------------------------------------
% CO_2 (\mumol mol^-1 of dry air)
%
fig = fig+1;figure(fig);clf;
plot(t,means(:,[5]));

grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2'})
ylabel('\mumol mol^{-1} of dry air')


%-----------------------------------------------
% CO2 flux
%
fig = fig+1;figure(fig);clf;
plot(t,Fc);
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_c'})
ylabel('\mumol m^{-2} s^{-1}')

%-----------------------------------------------
% Sensible heat
%
fig = fig+1;figure(fig);clf;
plot(t,H); 
h = gca;
set(h,'YLim',[-200 600],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Sensible Heat'})
ylabel('(Wm^{-2})')
legend('Gill','Tc1','Tc2',-1)

%-----------------------------------------------
% Latent heat
%
fig = fig+1;figure(fig);clf;
plot(t,Le); 
h = gca;
set(h,'YLim',[-10 400],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Latent Heat'})
ylabel('(Wm^{-2})')

%-----------------------------------------------
% Energy budget components
%
fig = fig+1;figure(fig);clf;
plot(tv,Rn,t,Le,t,H,tv,G); 
ylabel('W/m2');
legend('Rn','LE','H','G');

h = gca;
set(h,'YLim',EBax,'XLim',[st ed]);
grid on;zoom on;xlabel('DOY')

fig = fig+1;figure(fig);clf;
plot(tv,Rn-G,t,H+Le);
xlabel('DOY');
ylabel('W m^{-2}');
title({'Eddy Correlation: ';'Energy Budget'});
legend('Rn-G','H+LE');

h = gca;
set(h,'YLim',EBax,'XLim',[st ed]);
grid on;zoom on;xlabel('DOY')

A = Rn-G;
T = H+Le;
[C,IA,IB] = intersect(datestr(tv),datestr(t),'rows');
A = A(IA);
T = T(IB);
cut = find(isnan(A) | isnan(T) | A > 700 | A < -200 | T >700 | T < -200 |...
   H(IB) == 0 | Le(IB) == 0 | Rn(IA) == 0 );
A = clean(A,1,cut);
T = clean(T,1,cut);
[p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);

fig = fig+1;figure(fig);clf;
plot(Rn(IA)-G(IA),H(IB)+Le(IB),'.',...
   A,T,'o',...
   EBax,EBax,...
   EBax,polyval(p,EBax),'--');
text(-100, 400, sprintf('T = %2.3fA + %2.3f, R2 = %2.3f',p,R2));
xlabel('Ra (W/m2)');
ylabel('H+LE (W/m2)');
title({'Eddy Correlation: ';'Energy Budget'});
h = gca;
set(h,'YLim',EBax,'XLim',EBax);
grid on;zoom on;



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

