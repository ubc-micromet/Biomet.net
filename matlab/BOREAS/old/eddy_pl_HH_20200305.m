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
         CO2_mixing_ratio = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','co2_mixing_ratio'),[],[],year,ind);
         VWC_1_Avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_1_VWC_Avg'),[],[],year,ind);
         VWC_1_Max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_1_VWC_Max'),[],[],year,ind);
         VWC_2_Avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_2_VWC_Avg'),[],[],year,ind);
         VWC_2_Max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_2_VWC_Max'),[],[],year,ind);
         VWC_3_Avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_3_VWC_Avg'),[],[],year,ind);
         VWC_3_Max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_3_VWC_Max'),[],[],year,ind);
         Raw_LWIN = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RAW_LWIN_6_14_Avg'),[],[],year,ind);
         Raw_LWOUT = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RAW_LWOUT_6_15_Avg'),[],[],year,ind);
         H2O_flux = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','h2o_flux'),[],[],year,ind);
         H2O_conc = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','h2o_mixing_ratio'),[],[],year,ind);
         wind_speed_csat = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','wind_speed'),[],[],year,ind);
         wind_dir_csat = read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','wind_dir'),[],[],year,ind);
         Net_LWIN= LWIN-LWOUT;
         Net_SWIN=SWIN-SWOUT;
         gs3_1_temp= read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_1_Temp_Avg'),[],[],year,ind);
         ustar= read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','us'),[],[],year,ind);
         SHF1= read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','SHF_6_37_1_Avg'),[],[],year,ind);
         SHF2= read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','SHF_6_37_2_Avg'),[],[],year,ind);
         LE= read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','LE'),[],[],year,ind);
         x_peak=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','x_peak'),[],[],year,ind);
         x_70p=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','x_70p'),[],[],year,ind);
         file_records=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','file_records'),[],[],year,ind);
         used_records=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','used_records'),[],[],year,ind);
         discontinuities_hf=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','discontinuities_hf'),[],[],year,ind);
         RN_6_5_Avg=read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','RN_6_5_Avg'),[],[],year,ind);
         Mean_flowrate=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','flowrate_mean'),[],[],year,ind);
         H2O_delaytime=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','h2o_time_lag'),[],[],year,ind);
         CO2_delaytime=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','co2_time_lag'),[],[],year,ind);
         air_temperature=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','air_temperature'),[],[],year,ind);
         GS3_1_Temp_Avg=read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_1_Temp_Avg'),[],[],year,ind);
         GS3_2_Temp_Avg=read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_2_Temp_Avg'),[],[],year,ind);
         GS3_3_Temp_Avg=read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','GS3_3_Temp_Avg'),[],[],year,ind);
         delta_P_LI_7200=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','delta_p_LI_7200'),[],[],year,ind);
         air_pressure=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','air_pressure'),[],[],year,ind);
         chopper_motor_LI7200=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','chopper_LI_7200'),[],[],year,ind);
         bowen_ratio=read_bor(fullfile(biomet_path('yyyy',SiteID),'Flux\','bowen_ratio'),[],[],year,ind);
         SolarBatt_Volt=read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\HH_CR1000_Biomet\','SolarBatt_Volt'),[],[],year,ind);
    
    otherwise
        error 'Wrong SiteID'
end

%          sigma=5.670367e-8;
%          T_surf=(LWOUT/sigma)^0.25;
%          SHC=theta*rho_w*c_w + phi_m*rho_m*c_m;
Soil_temp=(GS3_1_Temp_Avg+GS3_2_Temp_Avg+GS3_3_Temp_Avg)/3;
VWC_Avg=(VWC_1_Avg+VWC_2_Avg+VWC_3_Avg)/3;
VWC_Max=(VWC_1_Max+VWC_2_Max+VWC_3_Max)/3;

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
title({'DataLogger: ';'HMP_{T}'})
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
title({'DataLogger: ';'HMP_{RH}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Solar battery voltage
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SolarBatt_Volt,'b-');
ylabel(' V ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Climate: ';'SolarBatt_Volt'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


% 
%-----------------------------------------------
% Bowen ratio
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,bowen_ratio);
ylabel( '%')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Bowen ratio'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% BVolt_min
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Batt_logger_min);
ylabel('V')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Battery Voltage Minimum'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% 

%-----------------------------------------------
% Air_Temp
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,air_temperature);
ylabel( 'Air Temperature (\circC) ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Air Temperature'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Air_Pressure
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,air_pressure/1000);
ylabel( 'kPa')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Air Pressure'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% P_Temp
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,P_Temp);
ylabel( 'Panel Temperature (\circC) ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Panel Temperature'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Precipitation
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Precip);
ylabel( 'mm/half hour')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Precipitation '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Cumulative Precipitation
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,cumsum(Precip));
ylabel( 'mm')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Cumulative Precipitation '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% File records
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,file_records);
ylabel('number')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy covariance: ';'File records '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% Used records
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,used_records);
ylabel('number')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Used records'})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% Discontinuities hf
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,discontinuities_hf);
ylabel( 'number')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Discontinuities hf '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Mean_flowrate
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Mean_flowrate*60000);
ylabel( 'number')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Mean flowrate '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% delta_P_LI_7200
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,delta_P_LI_7200);
ylabel( 'number')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Diagnostic flag: ';'Delta P LI7200 '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% H2O_delaytime
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,H2O_delaytime);
ylabel( 's')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'H2O delaytime '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% CO2_delaytime
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CO2_delaytime);
ylabel( 's')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CO2 delaytime '})

set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% LWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,LWIN);
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'LWIN'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LWOUT
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,LWOUT);
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'LWOUT'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SWIN);
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'SWIN'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% SWOUT
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SWOUT);
ylabel( 'W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'SWOUT'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% Net LWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Net_LWIN);
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Net LWIN'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% Net SWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Net_SWIN);
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Net SWIN'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Net Radiation
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,Net_SWIN+Net_LWIN);
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'Net Radiation'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% CH4 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CH4_flux);
ylabel('µmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CH_{4} Flux'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% CO2 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CO2_flux);
ylabel('µmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CO_{2} Flux'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% H
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,H);
ylabel('W/m^{-2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Sensible Heat'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% CH4 mixing ratio
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CH4_mixing_ratio);
ylabel('ppm')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CH_{4} Mixing ratio'})
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



%-----------------------------------------------
% CO2 mixing ratio
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,CO2_mixing_ratio);
ylabel('ppm')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CO_{2} Mixing ratio'})
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
title({'Eddy Covariance: ';'H2O flux'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% H2O conc
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,H2O_conc);
ylabel('mmol/mol')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'H_{2}O mixing ratio'})
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
title({'Eddy Covariance: ';'Wind Speed csat3b'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% VWC Avg
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,VWC_Avg);
% ylabel('percentage')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Average Volumetric Water Content'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% VWC Max
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,VWC_Max);
% ylabel('ms^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Maximum Volumetric Water Content'})
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
title({'Eddy Covariance: ';'Wind Direction csat3b'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
%-----------------------------------------------
% ch4 flux_winddir_ustar_filt
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
[a,b]=size(ustar);
flag_ustar=ones(a,b);
flag_dir=ones(a,b);
ch4_reqd=CH4_flux;
ch4_notreqd=CH4_flux;
tv_reqd=tv;
tv_notreqd=tv;
for i=1:a
    if ustar(i)<0.1
        flag_ustar(i)=0;
    end
    if (wind_dir_csat(i)<180)||(wind_dir_csat(i)>270) 
        flag_dir(i)=0;
    end
end
for i=1:a
    if (flag_ustar(i)==0)||(flag_dir(i)==0)
        ch4_reqd(i)=NaN;
        tv_reqd(i)=NaN;
    else 
        ch4_notreqd(i)=NaN;
        tv_notreqd(i)=NaN;
    end
end
plot(tv_reqd,ch4_reqd,'r-')
hold on
plot(tv_notreqd,ch4_notreqd,'c-')
legend('good points','bad points')
ylabel('µmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CH_{4} flux filtered for ustar and wind direction (SW)'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% ch4 flux winddir filter only
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
ch4_reqd1=CH4_flux;
ch4_notreqd1=CH4_flux;
tv_reqd1=tv;
tv_notreqd1=tv;

for i=1:a
    if (flag_dir(i)==0)
        ch4_reqd1(i)=NaN;
        tv_reqd1(i)=NaN;
    else 
        ch4_notreqd1(i)=NaN;
        tv_notreqd1(i)=NaN;
    end
end
plot(tv_reqd,ch4_reqd,'r-')
hold on
plot(tv_notreqd,ch4_notreqd,'c-')
legend('good points','bad points')
ylabel('µmol m^{-2} s^{-1}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CH_{4} flux filtered just for wind direction (SW)'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
        



%-----------------------------------------------
% wind direction csat vs sonic?
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,wind_dir_csat,'r*-');
hold on
plot(tv, WindDir_D1,'b*-');
ylabel('(\circ) from North')
xlim([st ed+1]);
legend ('CSAT 3B','Wind Sonic')
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Wind Direction Comparison'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

% %-----------------------------------------------
% % gs3_1_temp
% %-----------------------------------------------
% 
% fig = fig+1;figure(fig);clf;
% 
% plot(tv,gs3_1_temp,'b-');
% ylabel('(\circC) ')
% xlim([st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title('GS3-1-temperature')
% set_figure_name(SiteID)
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% ustar
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,ustar,'b-');
ylabel('m/s')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'U-star'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% ustar vs wind speed
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(ustar,wind_speed_csat,'b*');
xlabel('ustar (m/s)')
ylabel('wind speed (m/s)')
% xlim([st ed+1]);
grid on;zoom on
title({'Eddy Covariance: ';'U-star vs wind speed'})
set_figure_name(SiteID)
ax = axis; %line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SHF1
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SHF1,'b-');
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'SHF1'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SHF2
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,SHF2,'b-');
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'SHF2'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SHF_avg
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,(SHF1+SHF2)/2,'b-');
ylabel('W/m^{2}')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'DataLogger: ';'SHF_{Avg}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LE
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,LE,'b-');
ylabel(' W/m^{2} ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'LE'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% x_peak
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,x_peak,'b-');
ylabel(' m ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'x peak'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% x_70p
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(tv,x_70p,'b-');
ylabel(' m ')
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'x-70p'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Calc for Energy Balance Closure
%-----------------------------------------------
for i=1:a
    G_5(i)=(SHF1(i)+SHF2(i))/2;
end
for i=1:a
    Cc(i)=(2.1*10^6)*(1-0.6)+(4.18*10^6)*VWC_Avg(i);
end
S=zeros(a,1);
for i=2:(a-1)
    S(i)=Cc(i)*0.05*(Soil_temp(i+1)-Soil_temp(i-1))/(3600);
end
G=zeros(a,1);
for i=1:a
    G(i)=G_5(i)+S(i);
end

ebc1=Net_LWIN+Net_SWIN-G;
ebc2=(H+LE);

%-----------------------------------------------
% Energy Balance Closure 
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

plot(ebc1,ebc2,'b*');
xlabel('Rn-G')
ylabel('H+LE')
% xlim([st ed+1]);
grid on;zoom on
title({'Eddy Covariance: ';'Energy Balance Closure: Short Equation'})
set_figure_name(SiteID)
ax = axis; %line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% windrose
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

speed=wind_speed_csat;
direction=wind_dir_csat;
[figure_handle,count,speeds,directions,Table]=WindRose(direction,speed, 'anglenorth',0, 'angleeast',90,'freqlabelangle',45);
title({'Eddy Covariance: ';'Windrose'})
set_figure_name(SiteID)





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
