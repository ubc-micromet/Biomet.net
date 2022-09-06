function [] = eddy_pl_HH(ind, year, SiteID, select)
%
% Revisions
%
%  July 10, 2018 (Zoran)
%   - created file based on eddy_pl_LGR2
%

colordef 'white'
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


%load in fluxes
switch upper(SiteID)
    case 'HH'
        [pthc] = biomet_path(year,'HH','cl');
        pth = '\\PAOA001\SITES\HH\hhour\';
        ext         = '.hHH.mat';
%         GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
%         
%          nMainEddy = 1;

         % Load diagnostic climate data        
         Batt_logger_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','Batt_Volt_99_99_Min'),[],[],year,ind);
         Ptemp_logger = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','PTemp_2_1'),[],[],year,ind);
         HMP_RH = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RH_19_3_Avg'),[],[],year,ind);
         HMP_T = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','TA_2_1_Avg'),[],[],year,ind);
         LWIN = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','LWIN_6_14_Avg'),[],[],year,ind);
         B_Volt = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','Batt_Volt_99_99_Min'),[],[],year,ind);
         Precip = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','P_rain_8_19_Tot'),[],[],year,ind);
         P_Temp = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','PTemp_2_1'),[],[],year,ind);
         LWOUT = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','LWOUT_6_15_Avg'),[],[],year,ind);
         WD_AVG = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','WD_20_35_1_Avg'),[],[],year,ind);
         WindDir_D1 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','WindDir_D1_WVT'),[],[],year,ind);
         WindDir_SD1 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','WindDir_SD1_WVT'),[],[],year,ind);
         SWIN = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','SWIN_6_10_Avg'),[],[],year,ind);
         SWOUT = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','SWOUT_6_11_Avg'),[],[],year,ind);
         CH4_flux = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','ch4_flux'),[],[],year,ind);
         CO2_flux = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','co2_flux'),[],[],year,ind);
         H = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','H'),[],[],year,ind);
         CH4_mixing_ratio = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','ch4_mixing_ratio'),[],[],year,ind);
         VWC = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_3_VWC_Avg'),[],[],year,ind);
         Raw_LWIN = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RAW_LWIN_6_14_Avg'),[],[],year,ind);
         Raw_LWOUT = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RAW_LWOUT_6_15_Avg'),[],[],year,ind);
         H2O_flux = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','h2o_flux'),[],[],year,ind);
         H2O_conc = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','h2o_mixing_ratio'),[],[],year,ind);
         wind_speed_csat = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','wind_speed'),[],[],year,ind);
         wind_dir_csat = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','wind_dir'),[],[],year,ind);
         Net_LWIN= LWIN-LWOUT;
         Net_SWIN=SWIN-SWOUT;
         
    otherwise
        error 'Wrong SiteID'
end

     


%reset time vector to doy
tv   = tv - startDate + 1;
st   = st - startDate + 1;
ed   = ed - startDate + 1;

fig = 0;



%-----------------------------------------------
% HMP Air Temp 
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,HMP_T);
ylabel( 'T \circC')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'HMP_{T}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% HMP RH
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,HMP_RH);
ylabel( '%')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'HMP_{RH}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% BVolt
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,B_Volt);
ylabel( 'Battery Voltage')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Battery Voltage')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% P_Temp
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,P_Temp-273);
ylabel( 'Panel Temperature (\circC) ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Panel Temperature')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Precipitation
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Precip);
ylabel( 'Precipitation')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Precipitation (mm/half hour)')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);



%-----------------------------------------------
% LWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,LWIN);
ylabel('LWIN (W/m^{2})')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('LWIN')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LWOUT
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,LWOUT);
ylabel('LWOUT (W/m^{2})')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('LWOUT')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SWIN);
ylabel('SWIN (W/m^{2})')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('SWIN')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% SWOUT
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SWOUT);
ylabel( 'SWOUT (W/m^{2})')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'SWOUT'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% CH4 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CH4_flux);
ylabel('CH4_flux in µmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CH4 flux'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% CO2 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CO2_flux);
ylabel( 'CO2_flux in µmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CO2 flux'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% H
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,H);
ylabel('H')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Sensible heat')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% CH4 mixing ratio
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CH4_mixing_ratio);
ylabel( 'ppm')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CH4 mixing ratio'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Net LWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Net_LWIN);
ylabel('Net LWIN')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Net LWIN')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% Net SWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Net_SWIN);
ylabel('Net SWIN')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Net SWIN')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% H2O flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,H2O_flux);
ylabel('mmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('H2O flux')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% H2O conc
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,H2O_conc);
ylabel('mmol+1mol_d-1 or 10^{-3}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('H2O mixing ratio')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% wind speed csat
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,wind_speed_csat);
ylabel('ms^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Wind speed-csat3b')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% wind direction csat
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,wind_dir_csat);
ylabel('(\circ) from North')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title('Wind direction-csat3b')
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);



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
%-----------------------------------------------




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

function set_figure_name(SiteID)
     title_string = get(get(gca,'title'),'string');
     set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'number','off')
