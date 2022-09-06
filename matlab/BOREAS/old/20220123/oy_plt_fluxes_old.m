function[] = oy_plt_fluxes(doys,years,select);
%Program to plot OY flux data
%
%
% E.Humphreys   July 11, 2000
% Revisions:    
% Aug 3, 2000
% Jan 7, 2001 - Fixed startDate to work on any year
% Mar 4, 2001 - Switched G to the SHFP with largest values
% May 3, 2001 - enabled winter and summer temp. and eb axes
% May 22,2001 - added Everest measurement
% Nov 16, 2001 - new closed-path system
% Feb 2, 2002 - isolated diagnostic info in this program
% July 18, 2002 - added gauge pressure graph

localdbase = 0;
pause_flag = 0;

if exist('years')==0 |isempty(years);
    years  = [2000];
end
if nargin < 3
    select = 0;
end

switch localdbase
case 0;
    pth     = biomet_path('yyyy','oy','fl');
    pthoy   = biomet_path('yyyy','oy','cl');
case 1;
    pth    = 'c:\local_dbase\oy\flux\';
    pthoy  = 'c:\local_dbase\oy\climate\';
end



% Find logger ini files
ini_flxMain = fr_get_logger_ini('oy',years,[],'oy_flux_53','fl');   % main climate-logger array
ini_flx2    = fr_get_logger_ini('oy',years,[],'oy_flux_56','fl');   % secondary climate-logger array
ini_clim1   = fr_get_logger_ini('oy',years,[],'oy_clim1','cl');   % secondary climate-logger array

ini_flxMain = rmfield(ini_flxMain,'LoggerName');
ini_flx2    = rmfield(ini_flx2,'LoggerName');
ini_clim1   = rmfield(ini_clim1,'LoggerName');


GMT_shift =  8/24;       %shift grenich mean time to 24hr day
tv = read_bor(fr_logger_to_db_fileName(ini_flxMain, '_tv', pth),8,[],years); tv = tv-GMT_shift;

startDate = datenum(min(years),1,1);     
st        = min(doys);
ed        = max(doys);

if max(doys) > 70000
    indOut    = find(tv >=st & tv <= ed);
else
    indOut    = find(tv >=st+startDate-1 & tv <= ed+startDate-1);
    st = st+startDate-1;
    ed = ed+startDate-1;
end

t = tv(indOut);

%-----------------------------------------------
%System diagnostics (oy_clim and oy_flux)
%

DOY     = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Day_RTM', pth),[],[],years,indOut);
ID      = read_bor(fr_logger_to_db_fileName(ini_flxMain, '53', pth),[],[],years,indOut);
BattV   = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Batt_V_AVG', pth),[],[],years,indOut);
PanelT  = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Panel_T_AVG', pth),[],[],years,indOut);

nmbr_smpl_TOT  = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'counter', pth),[],[],years,indOut);
Ts_co          = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'Ts_c_o', pth),[],[],years,indOut);
FW_co          = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'FW_c_o', pth),[],[],years,indOut);
co2_co         = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'co2_c_o', pth),[],[],years,indOut);
h2o_co         = read_bor(fr_logger_to_db_fileName(ini_flxMain, 'h2o_c_o', pth),[],[],years,indOut);

heat_sum   = read_bor(fr_logger_to_db_fileName(ini_flx2, 'HeatSum', pth),[],[],years,indOut);
fan_sum    = read_bor(fr_logger_to_db_fileName(ini_flx2, 'FanSum', pth),[],[],years,indOut);
total_sum  = read_bor(fr_logger_to_db_fileName(ini_flx2, 'TotalSum', pth),[],[],years,indOut);

Tsample_av  = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Tsample_AVG', pth),[],[],years,indOut);
Tsample_max = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Tsample_MAX', pth),[],[],years,indOut);
Tsample_min = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Tsample_MIN', pth),[],[],years,indOut);

Pcell_av  = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Pcell_AVG', pth),[],[],years,indOut);
Pcell_max = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Pcell_MAX', pth),[],[],years,indOut);
Pcell_min = read_bor(fr_logger_to_db_fileName(ini_flx2, 'Pcell_MIN', pth),[],[],years,indOut);

Pbar  = read_bor(fr_logger_to_db_fileName(ini_clim1, 'Pbar_AVG', pthoy),[],[],years,indOut);

%
%Climate measurements
%
Rn     = read_bor([pthoy 'oy_clim1.55'],[],[],years,indOut);

SHFP1  = read_bor([pthoy 'oy_clim1.57'],[],[],years,indOut);
SHFP2  = read_bor([pthoy 'oy_clim1.58'],[],[],years,indOut);
SHFP3  = read_bor([pthoy 'oy_clim1.59'],[],[],years,indOut);
SHFP4  = read_bor([pthoy 'oy_clim1.60'],[],[],years,indOut);
SHFP5  = read_bor([pthoy 'oy_clim1.61'],[],[],years,indOut);
SHFP6  = read_bor([pthoy 'oy_clim1.62'],[],[],years,indOut);

HMP_T    = read_bor([pthoy 'oy_clim1.48'],[],[],years,indOut);
HMP_RH   = read_bor([pthoy 'oy_clim1.49'],[],[],years,indOut);

GH_co2_av     = read_bor([pthoy 'oy_clim1.131'],[],[],years,indOut);
GH_co2_max    = read_bor([pthoy 'oy_clim2.236'],[],[],years,indOut);
GH_co2_min    = read_bor([pthoy 'oy_clim2.237'],[],[],years,indOut);

G_all   = [SHFP1 SHFP2 SHFP3 SHFP4 SHFP5 SHFP6];
%G       = mean(G_all,[],2);
SHFP_max   = SHFP1 ; %use the bigest valued SHFP for closure issues.
G       = SHFP_max;

RMYu  = read_bor([pthoy 'oy_clim1.26'],[],[],years,indOut);
RMYdir= read_bor([pthoy 'oy_clim1.31'],[],[],years,indOut);

%
%Eddy stats and Fluxes
%

if t(end) <= datenum(2001,12,12);
    [statsar, statsbr, stats] = oy_calc_main(doys,years);
else
    [statsar, statsbr, stats] = oy_calc_main_cp(doys,years);
end


mg2umol     = 10^6./1000./44;
L_v         = Lv(statsar.means(:,5))./1000;                   %J/g

F_uc        = statsar.scalcovsw(:,4).*mg2umol;                %uncorrected umol/m2/s

H_uc        = statsar.scalcovsw(:,2).*1200;
H_uc_fw     = statsar.scalcovsw(:,3).*1200;

LE_uc       = statsar.scalcovsw(:,5).*L_v;
LE_uc_kh20  = statsar.scalcovsw(:,1).*L_v;

Fc          = statsar.fluxes(:,4);
LE_licor    = statsar.fluxes(:,1);
LE_krypton  = statsar.fluxes(:,5);
H_sonic     = statsar.fluxes(:,2);
H_fwtc      = statsar.fluxes(:,3);


%
%figures
%

if datenum(now) > datenum(years,4,15) & datenum(now) < datenum(years,11,1);
   Tax  = [0 30];
   EBax = [-200 800];
else
   Tax  = [-10 15];
   EBax = [-200 600];
end
   
%reset time vector to doy
t    = t - startDate + 1;
st   = st - startDate + 1;
ed   = ed - startDate + 1;
  
   
fig = 0;


%-----------------------------------------------
% Gill wind speed (after rotation)
%
fig = fig+1;figure(fig);clf;
plot(t,statsar.means(:,[1]),t,RMYu);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed],'YLim',[0 10])
title('Gill wind speed (after rotation)');
ylabel('U (m/s)')
legend('Sonic','RMYoung')

%-----------------------------------------------
% Barometric/Cell pressure
%
fig = fig+1;figure(fig);clf;
plot(t,Pcell_av,t,Pcell_max,t,Pcell_min,...
    t,Pbar);
h = gca;
set(h,'XLim',[st ed],'YLim',[70 102])
legend('mean','max','min','Atm',-1);

grid on;zoom on;xlabel('DOY')
title('Barometric/Cell pressure')
ylabel('kPa')

%-----------------------------------------------
% Gauge pressure
%
fig = fig+1;figure(fig);clf;
plot(t,Pbar-Pcell_av,t,Pbar-Pcell_max,t,Pbar-Pcell_min);
h = gca;
set(h,'XLim',[st ed],'YLim',[0 20])
legend('mean','max','min',-1);

grid on;zoom on;xlabel('DOY')
title('Gauge pressure')
ylabel('kPa')

%-----------------------------------------------
% Heater/Fan cycles
%
%fig = fig+1;figure(fig);clf;
%plot(t,100.*heat_sum./total_sum,t,100.*fan_sum./total_sum);
%legend('% heater on','% fan on',-1);
%h = gca;
%set(h,'YLim',[-1  101],'XLim',[st ed]);

%grid on;zoom on;xlabel('DOY')
%ylabel('min');
%title('Heater/Fan cycle')

%-----------------------------------------------
% T sample
%
fig = fig+1;figure(fig);clf;
plot(t,Tsample_av,t,Tsample_max,t,Tsample_min);
legend('av','max','min',-1);
h = gca;
set(h,'YLim',[26 30],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
ylabel('degC');
title('Sample temperature')

%------------------------------------------
if select == 1 %diagnostics only
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=childn(:)';
        if i < 200 
            figure(i);
            if i ~= childn(N-1)
                pause;
            end
        end
    end
    return
end

%-----------------------------------------------
% Air temperatures (Sonic and 0.001" Tc)
%
fig = fig+1;figure(fig);clf;
plot(t,statsar.means(:,[5]),...
    t,statsar.means(:,[6]),...
    t,HMP_T);
h = gca;
set(h,'XLim',[st ed],'YLim',Tax);

grid on;zoom on;xlabel('DOY')
title('Air temperatures (Sonic, tc,  and HMP)')
ylabel('\circC')
legend('sonic','tc','HMP',-1)
zoom on;

%-----------------------------------------------
% Air temperatures (Sonic)
%
fig = fig+1;figure(fig);clf;
plot(t,statsar.means(:,[5]),...
    t,statsar.max(:,[5]),...
    t,statsar.min(:,[5]),...
    t,Ts_co);
h = gca;
set(h,'XLim',[st ed],'YLim',Tax);

grid on;zoom on;xlabel('DOY')
title('Air temperatures (Sonic)')
ylabel('\circC')
legend('av','max','min','cnst',-1)
zoom on;

%-----------------------------------------------
% Air temperatures (Sonic)
%
fig = fig+1;figure(fig);clf;
plot(HMP_T,statsar.means(:,[5]),'.',...
    HMP_T,statsar.max(:,[6]),'.',...
    Tax,Tax);
h = gca;
set(h,'XLim',Tax,'YLim',Tax);
grid on;zoom on;xlabel('HMP')
title('Air temperatures')
ylabel('^oC')
legend('sonic','tc',-1)
zoom on;


%-----------------------------------------------
% H_2O (mmol/mol of dry air)
%
fig = fig+1;figure(fig);clf;
plot(t,statsar.means(:,[8]),...
    t,statsar.max(:,8),...
    t,statsar.min(:,8),...
    t,h2o_co);
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed], 'YLim',[-1 22])
legend('mean','max','min','cnst',-1);
title('H_2O ')
ylabel('(mmol mol^{-1} of dry air)')

zoom on;


%-----------------------------------------------
% H_2O (mmol/mol of dry air) vs. HMP
%
fig = fig+1;figure(fig);clf;

tmp = (0.61365*exp((17.502*HMP_T)./(240.97+HMP_T)));  %HMP vapour pressure
HMP_mixratio = (1000.*tmp.*HMP_RH)./(Pbar-HMP_RH.*tmp); %mixing ratio

plot(statsar.means(:,[8]),HMP_mixratio,'.',...
    [-1 22],[-1 22]);
grid on;zoom on;ylabel('HMP mixing ratio (mmol/mol)')
h = gca;
set(h,'XLim',[-1 22], 'YLim',[-1 22])
title('H_2O ')
xlabel('irga (mmol mol^{-1} of dry air)')
zoom on;
   
    
    
%-----------------------------------------------
% CO_2 (\mumol mol^-1 of dry air)
%
fig = fig+1;figure(fig);clf;
plot(t,statsar.means(:,[7]),...
    t,statsar.max(:,7),...
    t,statsar.min(:,7),...
    t,co2_co);
legend('mean','max','min','cnst',-1);

grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed], 'YLim',[350 500])
title('CO_2')
ylabel('\mumol mol^{-1} of dry air')


%-----------------------------------------------
% CO2 flux
%
fig = fig+1;figure(fig);clf;
plot(t,Fc);
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
title('F_c')
ylabel('\mumol m^{-2} s^{-1}')
legend('F_c',-1);

%-----------------------------------------------
% Sensible heat
%
fig = fig+1;figure(fig);clf;
ind = find(H_fwtc > EBax(1) & H_fwtc < EBax(2));
plot(t,H_sonic,t(ind),H_fwtc(ind)); 
a = legend('sonic','tc');
set(a,'Visible','off');
h = gca;
set(h,'YLim',[EBax(1) EBax(2)-100],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
title('Sensible heat')
ylabel('(Wm^{-2})')
legend('Gill','Tc1','Tc2',-1)

%-----------------------------------------------
% Latent heat
%
fig = fig+1;figure(fig);clf;
plot(t,LE_licor); 
h = gca;
set(h,'YLim',[EBax(1)+100 EBax(2)-200],'XLim',[st ed]);

grid on;zoom on;xlabel('DOY')
title('Latent heat')
ylabel('(Wm^{-2})')
legend('LE',-1);

%-----------------------------------------------
% Energy budget components
%
fig = fig+1;figure(fig);clf;
plot(t,Rn,t,LE_licor,t,H_sonic,t,G); 
ylabel('W/m2');
legend('Rn','LE','H','G',-1);

h = gca;
set(h,'YLim',EBax,'XLim',[st ed]);
grid on;zoom on;xlabel('DOY')

fig = fig+1;figure(fig);clf;
plot(t,Rn-G,t,H_sonic+LE_licor);
xlabel('DOY');
ylabel('W m^{-2}');
title('Energy budget');
legend('Rn-G','H+LE');
h = gca;
set(h,'YLim',EBax,'XLim',[st ed]);
grid on;zoom on;xlabel('DOY')


A = Rn-G;
T = H_sonic+LE_licor;
[C,IA,IB] = intersect(datestr(t),datestr(t),'rows');
A = A(IA);
T = T(IB);
cut = find(isnan(A) | isnan(T) | A > 700 | A < -200 | T >700 | T < -200 |...
   H_sonic(IB) == 0 | LE_licor(IB) == 0 | Rn(IA) == 0 );
A = clean(A,1,cut);
T = clean(T,1,cut);
[p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);

fig = fig+1;figure(fig);clf;
plot(Rn(IA)-G(IA),H_sonic(IB)+LE_licor(IB),'.',...
   A,T,'o',...
   EBax,EBax,...
   EBax,polyval(p,EBax),'--');
text(-100, 400, sprintf('T = %2.3fA + %2.3f, R2 = %2.3f',p,R2));
xlabel('Ra (W/m2)');
ylabel('H+LE (W/m2)');
title('Energy budget');
h = gca;
set(h,'YLim',EBax,'XLim',EBax);
grid on;zoom on;

%-----------------------------------------------
% Counter
%
fig = fig+1;figure(fig);clf;
plot(t,(30*60/0.13-nmbr_smpl_TOT));
h = gca;
set(h,'XLim',[st ed]);

grid on;zoom on;xlabel('Doy')
title('Counter')
ylabel('Missing samples of hhour')
zoom on;

childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=childn(:)';
    if i < 200 
        figure(i);
        if i ~= childn(N-1)                
            pause;    
        end
    end
end
