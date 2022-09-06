function [] = eddy_pl_LGR(ind, year, SiteID, select)
%
% Revisions
%
% 20200404 (Zoran)
%   - Changed the axes for LGR pressure
%   - changed the location of the legend in the box temperature plot
% 20200402 (Pat)
%   - Added ustar_threshold calculation based off Kai 2002
% 20200201 (Pat)
%   - Added u* and threshold plots
% 20190802 (Pat)
%   - Program updated following site relocation from Westham Island to
%   Agassiz, including a change from using a LI7000 to a LI7200
% 20180802 (Pat)
%   - Added Ustar flags and WindDirection flags for filtering of
%   Ustar(<0.2) and accepted WindDirections (90 - 350, more than 80% of the
%   half hour)
%   - Plotting now indicates Flagged WindDirection and Ustar with red
%   circles
% 20180705 (Pat)
%   - Changed axis limits for sample tube temp, h2o signal, soil tension,
%   soil temp, net radiation
%   - Split up subplots of wind direction vs concentration
%   - Added plots of wind direction vs flux
% 20180504 (Pat)
%   - Added pressure transducers for reference gas left/right, calibration gas,
%   and CTD-10 measurements (water_table, temp, EC), changed scale with
%   warming temperatures
% 20180404 (Pat)
%   - Added H2O, N2O, CH4 Delay time plot
% 20171212 (Pat)
%   - Added plots
% 20170925 (Pat and Zoran)
%   - Started the program using eddy_pl_new as the starting point

colordef 'black'
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
LGRnum =  c.System(1).Instrument(3);  %<=== This will have to change once we have EC program that can do LI-7000 and LGR in one go
nMainEddy = 1;

%load in fluxes
switch upper(SiteID)
    
    case 'LGR1'
        [pthc] = biomet_path(year,'LGR1','cl');
        pth = '\\PAOA001\SITES\LGR1\hhour\';
        ext         = '.hLGR1.mat';
        GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path(year,'LGR1'),'Flux\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base
        
        tv  = tv - GMTshift;                                   % convert decimal time to
        % decimal DOY local time
        
        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
        nMainEddy = 1;
        CO2_channel = 1;
        H2O_channel = 2;
        
        LGR_CH4avg_channel = 1;         LGR_CH4std_channel = 2;
        LGR_H2Oavg_channel = 3;         LGR_H2Ostd_channel = 4;
        LGR_N2Oavg_channel = 5;         LGR_N2Ostd_channel = 6;
        LGR_N2Odavg_channel = 7;        LGR_N2Odstd_channel = 8;
        LGR_CH4davg_channel = 9;        LGR_CH4dstd_channel = 10;
        LGR_GasP_channel = 11;          LGR_GasPstd_channel = 12;
        LGR_GasT_channel = 13;          LGR_GasTstd_channel = 14;
        LGR_ambt_channel = 15;          LGR_ambtstd_channel = 16;
        LGR_LTC0_channel = 17;          LGR_LTC0std_channel = 18;
        LGR_AIN5_channel = 19;          LGR_AIN5std_channel = 20;
        LGR_AIN6_channel = 21;          LGR_AIN6std_channel = 22;
        LGR_Detoff_channel = 23;        LGR_Detoffstd_channel = 24;
        LGR_fitflag_channel = 25;       LGR_miuvalve_channel = 26;
        LGR_miudisc_channel = 27;       LGR_tv_channel = 28;
        
        if year <= 2018
            IRGACO2_channel = 1;
            IRGAH2O_channel = 2;
            IRGAtemp_channel = 3;
            IRGApressure_channel = 4;
            IRGAaux1_channel = 5;
            IRGAaux2_channel = 6;
            diagFlagIRGA_channel = 7;
            [accepted_wind_vector] = [0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0];
            WindDirection_threshold = 0.8;
            Ustar_threshold = 0.15;
            
        elseif year >= 2019
            IRGACO2_channel = 1;
            IRGAH2O_channel = 2;
            IRGATin_channel = 3;
            IRGATout_channel = 4;
            IRGAPtotal_channel = 5;
            IRGAPhead_channel = 6;
            SignalStrength_channel = 7;
            IRGAflowdrive_channel = 8;
            diagFlagIRGA_channel = 9;
            IRGAflowrate_channel = 10;
            [accepted_wind_vector] = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
            WindDirection_threshold = 0.8;
            Ustar_threshold = 0.15;
        end
        
        %         % Load diagnostic climate data
        if year <= 2018 %hut temperature was measured on CR3000 climate logger
            site_latitude = 49.07825;
            site_longitude = -123.155;
            Batt_logger = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','BattV_Avg'),[],[],year,ind);
            Batt_logger_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','BattV_Min'),[],[],year,ind);
            Batt_logger_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','BattV_Max'),[],[],year,ind);
            Batt_logger_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','BattV_Std'),[],[],year,ind);
            
            Ptemp_logger = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','PTemp_Avg'),[],[],year,ind);
            Ptemp_logger_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','PTemp_Std'),[],[],year,ind);
            
            T_BigPump_fan = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_BigPump_fan_Avg'),[],[],year,ind);
            T_BigPump_fan_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_BigPump_fan_Std'),[],[],year,ind);
            
            T_SmallPump_fan = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_SmallPump_fan_Avg'),[],[],year,ind);
            T_SmallPump_fan_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_SmallPump_fan_Std'),[],[],year,ind);
            
            T_Hut_fan = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_Fan_Avg'),[],[],year,ind);
            T_Hut_fan_std= read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_Fan_Std'),[],[],year,ind);
            
            T_LGR_fan = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_LGR_fan_Avg'),[],[],year,ind);
            T_LGR_fan_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','TC_LGR_fan_Std'),[],[],year,ind);
            
            Fan_Status = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_Hut_Temp\','FanPortStatus_Avg'),[],[],year,ind);
            
        elseif year >=2019 %box temperature was measured on CR1000 CTRL logger
            site_latitude =  49.246806;
            site_longitude = -121.763622;
            % TC glued onto Edwards Pump
            T_BigPump_fan = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_BigPump_Avg'),[],[],year,ind);
            T_BigPump_fan_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_BigPump_Max'),[],[],year,ind);
            T_BigPump_fan_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_BigPump_Min'),[],[],year,ind);
            % LGR exhaust
            T_LGR_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Avg'),[],[],year,ind);
            T_LGR_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Max'),[],[],year,ind);
            T_LGR_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Min'),[],[],year,ind);
            % Box intake
            T_LGR_intake_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_intake_Avg'),[],[],year,ind);
            T_LGR_intake_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_intake_Max'),[],[],year,ind);
            T_LGR_intake_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_intake_Min'),[],[],year,ind);
            % LGR instrument intake
            T_LGR_Front_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Front_Avg'),[],[],year,ind);
            T_LGR_Front_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Front_Max'),[],[],year,ind);
            T_LGR_Front_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Front_Min'),[],[],year,ind);
            % Box pump-side intake intake
            T_Pump_Intake_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_Pump_Intake_Avg'),[],[],year,ind);
            T_Pump_Intake_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_Pump_Intake_Max'),[],[],year,ind);
            T_Pump_Intake_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_Pump_Intake_Min'),[],[],year,ind);
            % Pump intake
            T_UPS_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_UPS_Avg'),[],[],year,ind);
            T_UPS_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_UPS_Max'),[],[],year,ind);
            T_UPS_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_UPS_Min'),[],[],year,ind);
            
            % Fan Duty-Cycle, 1 = OFF, 0 = ON
            Fan_1_OFF_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_1_OFF_Avg'),[],[],year,ind);
            Fan_2_OFF_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_2_OFF_Avg'),[],[],year,ind);
            Fan_3_OFF_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_3_OFF_Avg'),[],[],year,ind);
            Fan_4_OFF_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_4_OFF_Avg'),[],[],year,ind);
            
            % LGR and Pump emergency shutoff
            EmergencyShutoff_LGR_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','EmergencyShutoff_LGR_Avg'),[],[],year,ind);
            EmergencyShutoff_Pump_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','EmergencyShutoff_Pump_Avg'),[],[],year,ind);
            
            % LGR Pressure Gauge
            Pgauge_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Pgauge_avg'),[],[],year,ind);
            Pgauge_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Pgauge_max'),[],[],year,ind);
            Pgauge_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Pgauge_min'),[],[],year,ind);
        end
        
        
        Pbar = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Pbar_Avg'),[],[],year,ind);
        
        Sample_intake_temp = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Intake_Avg'),[],[],year,ind);
        Sample_intake_temp_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Intake_Min'),[],[],year,ind);
        Sample_intake_temp_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Intake_Max'),[],[],year,ind);
        Sample_intake_temp_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Intake_Std'),[],[],year,ind);
        
        Sample_mid_temp = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Middle_Avg'),[],[],year,ind);
        Sample_mid_temp_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Middle_Min'),[],[],year,ind);
        Sample_mid_temp_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Middle_Max'),[],[],year,ind);
        Sample_mid_temp_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_Middle_Std'),[],[],year,ind);
        
        Sample_end_temp = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_End_Avg'),[],[],year,ind);
        Sample_end_temp_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_End_Min'),[],[],year,ind);
        Sample_end_temp_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_End_Max'),[],[],year,ind);
        Sample_end_temp_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Sample_TC_End_Std'),[],[],year,ind);
        
        Sample_heater_status = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SampleHeaterPortStatus_Avg'),[],[],year,ind);
        
        TC_Outside = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','TC_Outside_Avg'),[],[],year,ind);
        TC_Outside_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','TC_Outside_Min'),[],[],year,ind);
        TC_Outside_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','TC_Outside_Max'),[],[],year,ind);
        TC_Outside_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','TC_Outside_Std'),[],[],year,ind);
        
        cal_1_pressure_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Cal_1_Pressure_Avg'),[],[],year,ind);
        cal_1_pressure_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Cal_1_Pressure_Max'),[],[],year,ind);
        cal_1_pressure_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Cal_1_Pressure_Min'),[],[],year,ind);
        cal_1_pressure_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Cal_1_Pressure_Std'),[],[],year,ind);
        
        ref_right_pressure_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_1_Avg'),[],[],year,ind);
        ref_right_pressure_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_1_Max'),[],[],year,ind);
        ref_right_pressure_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_1_Min'),[],[],year,ind);
        ref_right_pressure_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_1_Std'),[],[],year,ind);
        
        ref_left_pressure_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_2_Avg'),[],[],year,ind);
        ref_left_pressure_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_2_Max'),[],[],year,ind);
        ref_left_pressure_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_2_Min'),[],[],year,ind);
        ref_left_pressure_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Ref_Pressure_2_Std'),[],[],year,ind);
        
        % Load climate data
        
        swd = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swd_Avg'),[],[],year,ind);
        swd_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swd_Min'),[],[],year,ind);
        swd_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swd_Max'),[],[],year,ind);
        swd_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swd_Std'),[],[],year,ind);
        
        swu = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swu_Avg'),[],[],year,ind);
        swu_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swu_Min'),[],[],year,ind);
        swu_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swu_Max'),[],[],year,ind);
        swu_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','swu_Std'),[],[],year,ind);
        
        lwd_corr = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwd_corr_Avg'),[],[],year,ind);
        lwd_corr_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwd_corr_Min'),[],[],year,ind);
        lwd_corr_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwd_corr_Max'),[],[],year,ind);
        lwd_corr_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwd_corr_Std'),[],[],year,ind);
        
        lwu_corr = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwu_corr_Avg'),[],[],year,ind);
        lwu_corr_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwu_corr_Min'),[],[],year,ind);
        lwu_corr_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwu_corr_Max'),[],[],year,ind);
        lwu_corr_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','lwu_corr_Std'),[],[],year,ind);
        
        Rn = swd-swu + lwd_corr-lwu_corr;
        
        PAR_in = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','PAR_in_Avg'),[],[],year,ind);
        PAR_in_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','PAR_in_Min'),[],[],year,ind);
        PAR_in_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','PAR_in_Max'),[],[],year,ind);
        PAR_in_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','PAR_in_Std'),[],[],year,ind);
        
        SHFP_grass_1 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_1_Avg'),[],[],year,ind);
        SHFP_grass_1_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_1_Min'),[],[],year,ind);
        SHFP_grass_1_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_1_Max'),[],[],year,ind);
        SHFP_grass_1_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_1_Std'),[],[],year,ind);
        
        SHFP_grass_2 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_2_Avg'),[],[],year,ind);
        SHFP_grass_2_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_2_Min'),[],[],year,ind);
        SHFP_grass_2_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_2_Max'),[],[],year,ind);
        SHFP_grass_2_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_2_Std'),[],[],year,ind);
        
        SHFP_grass_3 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_3_Avg'),[],[],year,ind);
        SHFP_grass_3_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_3_Min'),[],[],year,ind);
        SHFP_grass_3_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_3_Max'),[],[],year,ind);
        SHFP_grass_3_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_grass_3_Std'),[],[],year,ind);
        
        SHFP_sawdust_1 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_1_Avg'),[],[],year,ind);
        SHFP_sawdust_1_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_1_Min'),[],[],year,ind);
        SHFP_sawdust_1_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_1_Max'),[],[],year,ind);
        SHFP_sawdust_1_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_1_Std'),[],[],year,ind);
        
        SHFP_sawdust_2 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_2_Avg'),[],[],year,ind);
        SHFP_sawdust_2_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_2_Min'),[],[],year,ind);
        SHFP_sawdust_2_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_2_Max'),[],[],year,ind);
        SHFP_sawdust_2_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_2_Std'),[],[],year,ind);
        
        SHFP_sawdust_3 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_3_Avg'),[],[],year,ind);
        SHFP_sawdust_3_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_3_Min'),[],[],year,ind);
        SHFP_sawdust_3_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_3_Max'),[],[],year,ind);
        SHFP_sawdust_3_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','SHFP_sawdust_3_Std'),[],[],year,ind);
        
        G  = mean([SHFP_grass_1 SHFP_grass_2 SHFP_grass_3 SHFP_sawdust_1 SHFP_sawdust_2 SHFP_sawdust_3],2);
        
        VWC_grass_5 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_grass_Avg'),[],[],year,ind);
        VWC_grass_5_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_grass_Min'),[],[],year,ind);
        VWC_grass_5_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_grass_Max'),[],[],year,ind);
        VWC_grass_5_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_grass_Std'),[],[],year,ind);
        
        VWC_grass_10 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_grass_Avg'),[],[],year,ind);
        VWC_grass_10_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_grass_Min'),[],[],year,ind);
        VWC_grass_10_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_grass_Max'),[],[],year,ind);
        VWC_grass_10_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_grass_Std'),[],[],year,ind);
        
        VWC_grass_30 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_grass_Avg'),[],[],year,ind);
        VWC_grass_30_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_grass_Min'),[],[],year,ind);
        VWC_grass_30_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_grass_Max'),[],[],year,ind);
        VWC_grass_30_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_grass_Std'),[],[],year,ind);
        
        VWC_grass_60 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_grass_Avg'),[],[],year,ind);
        VWC_grass_60_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_grass_Min'),[],[],year,ind);
        VWC_grass_60_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_grass_Max'),[],[],year,ind);
        VWC_grass_60_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_grass_Std'),[],[],year,ind);
        
        VWC_row_5 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_row_Avg'),[],[],year,ind);
        VWC_row_5_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_row_Min'),[],[],year,ind);
        VWC_row_5_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_row_Max'),[],[],year,ind);
        VWC_row_5_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_5cm_row_Std'),[],[],year,ind);
        
        VWC_row_10 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_row_Avg'),[],[],year,ind);
        VWC_row_10_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_row_Min'),[],[],year,ind);
        VWC_row_10_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_row_Max'),[],[],year,ind);
        VWC_row_10_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_10cm_row_Std'),[],[],year,ind);
        
        VWC_row_30 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_row_Avg'),[],[],year,ind);
        VWC_row_30_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_row_Min'),[],[],year,ind);
        VWC_row_30_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_row_Max'),[],[],year,ind);
        VWC_row_30_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_30cm_row_Std'),[],[],year,ind);
        
        VWC_row_60 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_row_Avg'),[],[],year,ind);
        VWC_row_60_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_row_Min'),[],[],year,ind);
        VWC_row_60_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_row_Max'),[],[],year,ind);
        VWC_row_60_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','VWC_70cm_row_Std'),[],[],year,ind);
        
        MPS_5 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_5cm_Avg'),[],[],year,ind);
        MPS_5_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_5cm_Min'),[],[],year,ind);
        MPS_5_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_5cm_Max'),[],[],year,ind);
        MPS_5_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_5cm_Std'),[],[],year,ind);
        
        MPS_10 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_10cm_Avg'),[],[],year,ind);
        MPS_10_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_10cm_Min'),[],[],year,ind);
        MPS_10_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_10cm_Max'),[],[],year,ind);
        MPS_10_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_10cm_Std'),[],[],year,ind);
        
        MPS_30 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_30cm_Avg'),[],[],year,ind);
        MPS_30_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_30cm_Min'),[],[],year,ind);
        MPS_30_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_30cm_Max'),[],[],year,ind);
        MPS_30_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_30cm_Std'),[],[],year,ind);
        
        MPS_60 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_70cm_Avg'),[],[],year,ind);
        MPS_60_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_70cm_Min'),[],[],year,ind);
        MPS_60_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_70cm_Max'),[],[],year,ind);
        MPS_60_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','MPS_70cm_Std'),[],[],year,ind);
        
        Rainfall = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Rainfall'),[],[],year,ind);
        Rainfall_total = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Rainfall_Tot'),[],[],year,ind);
        
        Soil_T_grass_5 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_alley_Avg'),[],[],year,ind);
        Soil_T_grass_5_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_alley_Min'),[],[],year,ind);
        Soil_T_grass_5_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_alley_Max'),[],[],year,ind);
        Soil_T_grass_5_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_alley_Std'),[],[],year,ind);
        
        Soil_T_grass_10 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_alley_Avg'),[],[],year,ind);
        Soil_T_grass_10_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_alley_Min'),[],[],year,ind);
        Soil_T_grass_10_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_alley_Max'),[],[],year,ind);
        Soil_T_grass_10_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_alley_Std'),[],[],year,ind);
        
        Soil_T_grass_30 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_alley_Avg'),[],[],year,ind);
        Soil_T_grass_30_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_alley_Min'),[],[],year,ind);
        Soil_T_grass_30_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_alley_Max'),[],[],year,ind);
        Soil_T_grass_30_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_alley_Std'),[],[],year,ind);
        
        Soil_T_grass_60 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_alley_Avg'),[],[],year,ind);
        Soil_T_grass_60_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_alley_Min'),[],[],year,ind);
        Soil_T_grass_60_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_alley_Max'),[],[],year,ind);
        Soil_T_grass_60_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_alley_Std'),[],[],year,ind);
        
        Soil_T_row_5 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_row_Avg'),[],[],year,ind);
        Soil_T_row_5_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_row_Min'),[],[],year,ind);
        Soil_T_row_5_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_row_Max'),[],[],year,ind);
        Soil_T_row_5_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_5cm_row_Std'),[],[],year,ind);
        
        Soil_T_row_10 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_row_Avg'),[],[],year,ind);
        Soil_T_row_10_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_row_Min'),[],[],year,ind);
        Soil_T_row_10_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_row_Max'),[],[],year,ind);
        Soil_T_row_10_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_10cm_row_Std'),[],[],year,ind);
        
        Soil_T_row_30 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_row_Avg'),[],[],year,ind);
        Soil_T_row_30_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_row_Min'),[],[],year,ind);
        Soil_T_row_30_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_row_Max'),[],[],year,ind);
        Soil_T_row_30_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_30cm_row_Std'),[],[],year,ind);
        
        Soil_T_row_60 = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_row_Avg'),[],[],year,ind);
        Soil_T_row_60_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_row_Min'),[],[],year,ind);
        Soil_T_row_60_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_row_Max'),[],[],year,ind);
        Soil_T_row_60_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Soil_T_70cm_row_Std'),[],[],year,ind);
        
        Rainfall = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Rainfall_Tot'),[],[],year,ind);
        Rainfall_cum = cumsum(Rainfall);
        Rainfall_cum_clean = Rainfall_cum;
        if year == 2018
            Rainfall_cum_clean = Rainfall_cum-1.3131;
        end
        Rainfall_cum_clean(Rainfall_cum_clean<0) = 0;
        
        HMP_T = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Avg'),[],[],year,ind);
        HMP_T_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Min'),[],[],year,ind);
        HMP_T_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Max'),[],[],year,ind);
        HMP_T_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Std'),[],[],year,ind);
        
        HMP_RH = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Avg'),[],[],year,ind);
        HMP_RH_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Min'),[],[],year,ind);
        HMP_RH_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Max'),[],[],year,ind);
        HMP_RH_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Std'),[],[],year,ind);
        
        water_table_drain_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_1_Avg'),[],[],year,ind);
        water_table_drain_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_1_Max'),[],[],year,ind);
        water_table_drain_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_1_Min'),[],[],year,ind);
        water_table_drain_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_1_Std'),[],[],year,ind);
        
        water_table_drain_temp_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_1_Avg'),[],[],year,ind);
        water_table_drain_temp_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_1_Max'),[],[],year,ind);
        water_table_drain_temp_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_1_Min'),[],[],year,ind);
        water_table_drain_temp_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_1_Std'),[],[],year,ind);
        
        water_table_drain_EC_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_1_Avg'),[],[],year,ind);
        water_table_drain_EC_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_1_Max'),[],[],year,ind);
        water_table_drain_EC_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_1_Min'),[],[],year,ind);
        water_table_drain_EC_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_1_Std'),[],[],year,ind);
        
        water_table_btwn_drain_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_2_Avg'),[],[],year,ind);
        water_table_btwn_drain_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_2_Max'),[],[],year,ind);
        water_table_btwn_drain_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_2_Min'),[],[],year,ind);
        water_table_btwn_drain_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_level_2_Std'),[],[],year,ind);
        
        water_table_btwn_drain_temp_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_2_Avg'),[],[],year,ind);
        water_table_btwn_drain_temp_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_2_Max'),[],[],year,ind);
        water_table_btwn_drain_temp_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_2_Min'),[],[],year,ind);
        water_table_btwn_drain_temp_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_temp_2_Std'),[],[],year,ind);
        
        water_table_btwn_drain_EC_avg = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_2_Avg'),[],[],year,ind);
        water_table_btwn_drain_EC_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_2_Max'),[],[],year,ind);
        water_table_btwn_drain_EC_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_2_Min'),[],[],year,ind);
        water_table_btwn_drain_EC_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Water_table_EC_2_Std'),[],[],year,ind);
        
        %leaf_wet = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Leaf_R'),[],[],year,ind);
        %leaf_wet_hist = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Leaf_R_Hst'),[],[],year,ind);
        
    otherwise
        error 'Wrong SiteID'
end

if year <= 2018
    instrumentLI7000 = sprintf('Instrument(%d).',IRGAnum);
elseif year >=2019
    instrumentLI7200 = sprintf('Instrument(%d).',IRGAnum);
end

instrumentGillR3 =  sprintf('Instrument(%d).',SONICnum);
instrumentLGR =  sprintf('Instrument(%d).',LGRnum);

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
[F_ch4]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.F_ch4');
[F_n2o]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.F_n2o');
[Le]        = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
[Le_LGR]    = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_LGR');
[H]         = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
[Ustar]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');
[means]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
maxAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Max');
minAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Min');
numOfSamplesEC = get_stats_field(StatsX,'MainEddy.MiscVariables.NumOfSamples');

[Gill_wdir]        = get_stats_field(StatsX,[instrumentGillR3 'MiscVariables.WindDirection']);
[WindDirection_Histogram] = get_stats_field(StatsX, [instrumentGillR3 'MiscVariables.WindDirection_Histogram']);

% WindDirection Filtering and Flag
WindDirection_Histogram(:,37) = [];
WindDirection_fraction = zeros(size(WindDirection_Histogram,1),1);

for i = 1:size(WindDirection_Histogram,1)
    WindDirection_accepted = WindDirection_Histogram(i,:).*accepted_wind_vector;
    row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted = nansum(WindDirection_accepted);
    WindDirection_fraction(i) = row_sum_accepted./row_total;
end

WindDirection_Flag_ind = find(WindDirection_fraction<WindDirection_threshold);
Ustar_Flag_ind = find(Ustar<Ustar_threshold);
Flagged_ind = unique([WindDirection_Flag_ind; Ustar_Flag_ind]);
Good_ind = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind);

% air temperature and pressure used in eddy flux calculations (Jan 25,
% 2010)
[Tair_calc]        = get_stats_field(StatsX,'MiscVariables.Tair');
[Pbar_calc]        = get_stats_field(StatsX,'MiscVariables.BarometricP');
%
% LGR diagnostics
[T_LGR_gas]         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_GasT_channel) ')']);
[T_LGR_gas_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_GasT_channel) ')']);

[GasP_LGR]         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_GasP_channel) ')']);
[GasP_LGR_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_GasP_channel) ')']);

[T_LGR_amb]         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_ambt_channel) ')']);
[T_LGR_amb_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_ambt_channel) ')']);

[Laser_A_V]         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_LTC0_channel) ')']);
[Laser_A_V_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_LTC0_channel) ')']);

% LI-7000 diagnostics
if year <= 2018
    [Tbench]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(IRGAtemp_channel) ')']);
    [Tbench_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(' num2str(IRGAtemp_channel) ')']);
    [Tbench_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(' num2str(IRGAtemp_channel) ')']);
    
    [Plicor]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(IRGApressure_channel) ')']);
    [Plicor_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(' num2str(IRGApressure_channel) ')']);
    [Plicor_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(' num2str(IRGApressure_channel) ')']);
    
    [Pgauge]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(IRGAaux1_channel) ')']);
    [Pgauge_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(' num2str(IRGAaux1_channel) ')']);
    [Pgauge_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(' num2str(IRGAaux1_channel) ')']);
    
    [Dflag5]    = get_stats_field(StatsX,[instrumentGillR3 'Avg(' num2str(IRGAaux2_channel) ')']);
    [Dflag5_Min]= get_stats_field(StatsX,[instrumentGillR3 'Min(' num2str(IRGAaux2_channel) ')']);
    [Dflag5_Max]= get_stats_field(StatsX,[instrumentGillR3 'Max(' num2str(IRGAaux2_channel) ')']);
    
    [Dflag6]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(diagFlagIRGA) ')']);
    [Dflag6_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(' num2str(diagFlagIRGA) ')']);
    [Dflag6_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(' num2str(diagFlagIRGA) ')']);
    
    %     irgaAlignCh = eval(['c.' instrumentLI7000 'Alignment.ChanNum']);
    %     irgaAlignChName = eval(['c.' instrumentLI7000 'ChanNames(' num2str(irgaAlignCh) ')']);
    %     sonicAlignCh = eval(['c.' instrumentGillR3 'Alignment.ChanNum']);
    %     sonicAlignChName = eval(['c.' instrumentGillR3 'ChanNames(' num2str(sonicAlignCh) ')']);
    %
    %     [irgaAlCh_Avg]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(irgaAlignCh) ')' ]);
    %     [sonicAlCh_Avg]    = get_stats_field(StatsX,[instrumentGillR3 'Avg(' num2str(sonicAlignCh) ')' ]);
    %
    %     align_calc1 = get_stats_field(StatsX,['MainEddy.MiscVariables.' instrumentLI7000 'Alignment.del1']);
    %     align_calc2 = get_stats_field(StatsX,['MainEddy.MiscVariables.' instrumentLI7000 'Alignment.del2']);
    
    % Load LI7000 gas concentration data
    
    CO2_IRGA         = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(IRGACO2_channel) ')']);
    CO2_std_IRGA     = get_stats_field(StatsX,[instrumentLI7000 'Std(' num2str(IRGACO2_channel) ')']);
    H2O_IRGA         = get_stats_field(StatsX,[instrumentLI7000 'Avg(' num2str(IRGAH2O_channel) ')']);
    H2O_std_IRGA     = get_stats_field(StatsX,[instrumentLI7000 'Std(' num2str(IRGAH2O_channel) ')']);
    
    % LI-7200 diagnostics
elseif year >=2019
    [Tbench_In]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGATin_channel) ')']);
    [Tbench_In_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(IRGATin_channel) ')']);
    [Tbench_In_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(IRGATin_channel) ')']);
    
    [Tbench_Out]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGATout_channel) ')']);
    [Tbench_Out_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(IRGATout_channel) ')']);
    [Tbench_Out_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(IRGATout_channel) ')']);
    
    [P_tot]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGAPtotal_channel) ')']);
    [P_tot_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(IRGAPtotal_channel) ')']);
    [P_tot_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(IRGAPtotal_channel) ')']);
    
    [P_head]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGAPhead_channel) ')']);
    [P_head_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(IRGAPhead_channel) ')']);
    [P_head_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(IRGAPhead_channel) ')']);
    
    [Signal_Strength]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(SignalStrength_channel) ')']);
    [Signal_Strength_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(SignalStrength_channel) ')']);
    [Signal_Strength_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(SignalStrength_channel) ')']);
    
    [Motor_Duty]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGAflowdrive_channel) ')']);
    [Motor_Duty_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(IRGAflowdrive_channel) ')']);
    [Motor_Duty_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(IRGAflowdrive_channel) ')']);
    
    [IRGA_diag]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(diagFlagIRGA_channel) ')']);
    [IRGA_diag_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(diagFlagIRGA_channel) ')']);
    [IRGA_diag_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(diagFlagIRGA_channel) ')']);
    
    [IRGA_flow]    = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGAflowrate_channel) ')']);
    [IRGA_flow_Min]= get_stats_field(StatsX,[instrumentLI7200 'Min(' num2str(IRGAflowrate_channel) ')']);
    [IRGA_flow_Max]= get_stats_field(StatsX,[instrumentLI7200 'Max(' num2str(IRGAflowrate_channel) ')']);
    
    % Load LI7200 gas concentration data
    
    CO2_IRGA         = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGACO2_channel) ')']);
    CO2_std_IRGA     = get_stats_field(StatsX,[instrumentLI7200 'Std(' num2str(IRGACO2_channel) ')']);
    H2O_IRGA         = get_stats_field(StatsX,[instrumentLI7200 'Avg(' num2str(IRGAH2O_channel) ')']);
    H2O_std_IRGA     = get_stats_field(StatsX,[instrumentLI7200 'Std(' num2str(IRGAH2O_channel) ')']);
end

% Load LGR1 gas concentration data

CH4_LGR         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_CH4avg_channel) ')']);
CH4_std_LGR     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_CH4avg_channel) ')']);
CH4d_LGR        = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_CH4davg_channel) ')']);
CH4d_std_LGR    = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_CH4davg_channel) ')']);
N2O_LGR         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_N2Oavg_channel) ')']);
N2O_std_LGR     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_N2Oavg_channel) ')']);
N2Od_LGR        = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_N2Odavg_channel) ')']);
N2Od_std_LGR    = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_N2Odavg_channel) ')']);
H2O_LGR         = get_stats_field(StatsX,[instrumentLGR 'Avg(' num2str(LGR_H2Oavg_channel) ')']);
H2O_std_LGR     = get_stats_field(StatsX,[instrumentLGR 'Std(' num2str(LGR_H2Oavg_channel) ')']);

% Load MiSC
if year <= 2018
    numOfSamplesIRGA = get_stats_field(StatsX, [instrumentLI7000 'MiscVariables.NumOfSamples']);
elseif year >=2019
    numOfSamplesIRGA = get_stats_field(StatsX, [instrumentLI7200 'MiscVariables.NumOfSamples']);
    numOfSamplesSonic = get_stats_field(StatsX,[instrumentGillR3 'MiscVariables.NumOfSamples']);
    numOfSamplesLGR = get_stats_field(StatsX,[instrumentLGR 'MiscVariables.NumOfSamples']);
end
Delays_calc       = get_stats_field(StatsX,'MainEddy.Delays.Calculated');
Delays_set        = get_stats_field(StatsX,'MainEddy.Delays.Implemented');

%figures
if now > datenum(year,4,15) & now < datenum(year,11,1);
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

fig = 0;

% UI control positions
pushbuttonPosition1 = [200 12 70 30];
pushbuttonPosition2 = [300 12 120 30];
pushbuttonPosition3 = [450 12 200 30];
fontSize = 11;

% Calculate u_star_threshold from find_ustar_threshold by kai Dec 12, 2002

radiation_downwelling_potential = potential_radiation(t-GMTshift,site_latitude,site_longitude);%global radiation for nighttime
ind_night = find(radiation_downwelling_potential==0); %from global radiation = 0
[fc_dum,ind_sort] = sort(Fc(ind_night));
% Remove outliers (0.5% percentile highest and lowest CO2 fluxes
ind_sort = ind_sort(1+ceil(length(Ustar(ind_sort))*1e-3/2):end-floor(length(ind_sort)*1e-3/2));
% Bin average data according to USTAR in 10 bins with equal no. of points
[ustar_bin, fc_bin] = bin_avg(Ustar(ind_night(ind_sort)), Fc(ind_night(ind_sort)), floor(length(ind_sort)/10),[1 2]);
% Calculate threshold as 80% of the average CO2 flux of the last three bins
fc_max = mean(fc_bin(end-2:end,1));
fc_threshold = 0.80 * fc_max;
ind_ust = max(find(fc_bin(:,1)<fc_threshold));
ust_threshold = interp1(fc_bin(ind_ust:ind_ust+1,1),ustar_bin(ind_ust:ind_ust+1),fc_threshold);
%round to nearest 0.05 m/s
ustar_threshold_calculated = ceil(ust_threshold*20)./20;

%-----------------------------------------------
% Number of samples collected
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,numOfSamplesSonic,t,numOfSamplesIRGA,t,numOfSamplesEC,t,numOfSamplesLGR);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[20000 37000])
title({'Eddy Covariance: ';'Number of samples collected'});
set_figure_name(SiteID)
ylabel('n')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Sonic','IRGA','EC','LGR','location','northwest')

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
% LGR Gas Temperature
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, T_LGR_gas,t, T_LGR_gas-T_LGR_gas_std,t, T_LGR_gas+T_LGR_gas_std)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[43.5 45.5])
title({'LGR: ';'T_{gas}'});
set_figure_name(SiteID)
ylabel('\circC')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

if year <= 2018
    %-----------------------------------------------
    % LGR Ambient Temperature
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t, T_LGR_amb,t, T_LGR_amb-T_LGR_amb_std,t, T_LGR_amb+T_LGR_amb_std,...
        tv, T_LGR_fan, tv, T_LGR_fan-T_LGR_fan_std, tv, T_LGR_fan+T_LGR_fan_std)
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[47 49])
    title({'LGR: ';'T_{ambient}'});
    set_figure_name(SiteID)
    ylabel('LGR Ambient Temp (\circC)')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    % LGR Hut temperatures and Fan on time
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(tv, [T_Hut_fan, T_Hut_fan+T_Hut_fan_std, T_Hut_fan-T_Hut_fan_std])
    %legend('LGR Fan outlet')
    title({'LGR: ';'Hut Temperatures'});
    set_figure_name(SiteID)
    ylabel('LGR Fan outlet (\circC)')
    ax=axis;
    grid on;
    zoom on;
    
    %-----------------------------------------------
    % Pump Temperatures
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(tv, T_BigPump_fan,'r', tv, T_BigPump_fan-T_BigPump_fan_std,':r', tv, T_BigPump_fan+T_BigPump_fan_std,':r',...
        tv, T_SmallPump_fan,'b', tv, T_SmallPump_fan-T_SmallPump_fan_std, ':b', tv, T_SmallPump_fan+T_SmallPump_fan_std, ':b')
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[0 70])
    title({'LGR: ';'Pump Temperatures'});
    set_figure_name(SiteID)
    ylabel('\circC')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    legend('LGR Pump','','','LI7000 Pump','location','northwest')
    
elseif year >=2019
    %-----------------------------------------------
    % LGR Ambient Temperature
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t, T_LGR_amb,t, T_LGR_amb-T_LGR_amb_std,t, T_LGR_amb+T_LGR_amb_std)
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[47 49])
    title({'LGR: ';'T_{ambient}'});
    set_figure_name(SiteID)
    ylabel('LGR Ambient Temp (\circC)')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    %-----------------------------------------------
    % Box Temperatures
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(tv, T_BigPump_fan, 'r', tv, T_BigPump_fan_max ,'r:', tv, T_BigPump_fan_min ,'r:',...
        tv, T_LGR_avg, 'b', tv, T_LGR_max, 'b:', tv, T_LGR_min, 'b:',...
        tv, T_LGR_intake_avg, 'm', tv, T_LGR_intake_max, 'm:', tv, T_LGR_intake_min, 'm:',...
        tv, T_LGR_Front_avg, 'g', tv, T_LGR_Front_max, 'g:', tv, T_LGR_Front_min, 'g:',...
        tv, T_Pump_Intake_avg, 'k', tv, T_Pump_Intake_max, 'k:', tv, T_Pump_Intake_min, 'k:',...
        tv, T_UPS_avg, 'c', tv, T_UPS_max, 'c:', tv, T_UPS_min, 'c:')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    hold on
    h = zeros(6, 1);
    h(1) = plot(NaN,NaN,'-r');
    h(2) = plot(NaN,NaN,'-b');
    h(3) = plot(NaN,NaN,'-m');
    h(4) = plot(NaN,NaN,'-g');
    h(5) = plot(NaN,NaN,'-k');
    h(6) = plot(NaN,NaN,'-c');
    legend(h, 'Pump','LGR exhaust','Box LGR intake','LGR intake','Box Pump intake','Pump intake','location','northwest');
    hold off
    %legend('LGR Fan outlet')
    title({'LGR: ';'Hut Temperatures'});
    set_figure_name(SiteID)
    ylabel('Temperatures (\circC)')
    ax=axis;
    grid on;
    zoom on;
    %
    %     subplot(2,1,2)
    %     bar(tv, [Fan_1_OFF_avg,Fan_2_OFF_avg, tv, Fan_3_OFF_avg, tv, Fan_4_OFF_avg]);
    %     grid on;
    %     zoom on;
    %     xlabel('DOY')
    %     h = gca;
    %     set(h,'ylim',[0,1])
    %     ylabel('Fan duty cycle (0-1)')
    %     %set(h,'XLim',[st ed+1],'YLim',[10 35])
    %
    %-----------------------------------------------
    % Emergency Shutoff Pump/LGR
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(tv, EmergencyShutoff_LGR_avg, tv,EmergencyShutoff_Pump_avg);
    h = gca;
    set(h,'ylim',[0,1])
    grid on;
    zoom on;
    xlabel('DOY')
    ylabel('Shutoff Cycle (0-1)')
    
    
end

%-----------------------------------------------
% Sample Tube Temperatures
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, Sample_intake_temp,'r',...
    tv, Sample_end_temp,'b',...
    tv, Sample_mid_temp, 'g',...
    tv, TC_Outside, 'k');
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 40])
title({'LGR: ';'Sample Tube Temperatures'});
set_figure_name(SiteID)
ylabel('\circC')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Intake','End','Middle','Ambient','location','northwest')

%-----------------------------------------------
% LGR Laser A Voltage
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, Laser_A_V,t, Laser_A_V-Laser_A_V_std,t, Laser_A_V+Laser_A_V_std)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[-0.2 0.2])
title({'LGR: ';'Laser A_{volt}'});
set_figure_name(SiteID)
ylabel('V')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Laser A Voltage')


%-----------------------------------------------
% LGR Gas Pressure
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, GasP_LGR,t, GasP_LGR-GasP_LGR_std,t, GasP_LGR+GasP_LGR_std)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[43 46])
title({'LGR: ';'Gas Pressure_{Torr}'});
set_figure_name(SiteID)
ylabel('Torr')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Gas Pressure')

if year>=2019
    %-----------------------------------------------
    % LGR Pressure Gauge
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(tv, [Pgauge_avg Pgauge_max Pgauge_min]);
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1])
    title({'LGR: ';'Gas Pressure_{kpa}'});
    set_figure_name(SiteID)
    ylabel('kPa')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    legend('Gas Pressure')
end



if year <= 2018
    
    %-----------------------------------------------
    %  Diagnostic Flag, GillR3, Channel #5
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Dflag5 Dflag5_Min Dflag5_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'Diagnostic Flag, GillR3, Channel 5'});
    set_figure_name(SiteID)
    a = legend('av','min','max' ,'location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('?')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    zoom on;
    
    %-----------------------------------------------
    %  Tbench
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Tbench Tbench_Min Tbench_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'T_{bench}'});
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Temperature (\circC)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    %  Diagnostic Flag, Li-7000
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Dflag6 Dflag6_Min Dflag6_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'Diagnostic Flag, Li-7000, Channel 6'});
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('?')
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    zoom on;
    
    %-----------------------------------------------
    %  Plicor
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    
    plot(t,[Plicor Plicor_Min Plicor_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'P_{Licor} '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Pressure (kPa)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    %  Licor pressure drop
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    ind = find(tv(1)<=t);
    plot(t(ind),[Pbar(1:length(ind))-Plicor(ind)]);
    %plot(tv(ind),[Pbar(ind)-Plicor(1:length(ind))]);
    grid on;zoom on;xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation: ';'Licor Pressure Drop '})
    set_figure_name(SiteID)
    
    ylabel('Pressure drop (kPa)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
elseif year>=2019
    %-----------------------------------------------
    %  Tbench
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Tbench_In Tbench_In_Min Tbench_In_Max Tbench_Out Tbench_Out_Min Tbench_Out_Max]);
    line(t,[Tbench_In Tbench_Out],'linewidth',2)
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'T_{bench}'});
    set_figure_name(SiteID)
    %a = legend('In_av','In_min','In_max','Out_av','Out_min','Out_max','location','northwest');
    a = legend('T_{In}','T_{Out}','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Temperature (\circC)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    %  Diagnostic Flag, Li-7200
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[IRGA_diag IRGA_diag_Min IRGA_diag_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'Diagnostic Flag, Li-7000, Channel 6'});
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    zoom on;
    
    %-----------------------------------------------
    %  P total
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[P_tot P_tot_Min P_tot_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'P_{Total} '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Total Pressure (kPa)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    %  P_Head
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[P_head P_head_Min P_head_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'P_{Head} '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Head Pressure (kPa)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    %  Flow_rate
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[IRGA_flow IRGA_flow_Min IRGA_flow_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'IRGA Flow rate '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Flow rate (L/min)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    
    %-----------------------------------------------
    %  Flow_drive
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Motor_Duty Motor_Duty_Min Motor_Duty_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'IRGA Flow drive '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Flow drive (%)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
    
    %-----------------------------------------------
    %  IRGA Signal Strength
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Signal_Strength Signal_Strength_Min Signal_Strength_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Covariance: ';'IRGA Signal Strength '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northwest');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Signal Strength (%)')
    zoom on;
    ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
end
%-----------------------------------------------
% Gas Pressures (Cal_1, Ref_right, Ref_left)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

subplot(2,1,1);

plot(tv,cal_1_pressure_avg./(HMP_T+273.15).*298.15)
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[0 2500])
title({'LGR: ';'Gas Tank Pressures '})
set_figure_name(SiteID)
h = gca;
ylabel('Cal_1 Tank Pressure(Psi)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

subplot(2,1,2);
plot(tv,[ref_left_pressure_avg./(HMP_T+273.15).*298.15 ...
    ref_right_pressure_avg./(HMP_T+273.15).*298.15])
grid on;zoom on;xlabel('DOY')
set(h,'XLim',[st ed+1], 'YLim',[0 2500])
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
h = gca;
ylabel('Ref Tank Pressure(Psi)')
zoom on;
legend('Ref_{Left}','Ref_{Right}')


%-----------------------------------------------
% CO_2 & H_2O delay times
%-----------------------------------------------
fig = fig+1;figure(fig);clf

plot(t,Delays_calc(:,1:2),'o');
%     plot(t,[-align_calc1 -align_calc2],'o');
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2));
    set(h,'color','b','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2));
    set(h,'color','g','linewidth',1.5)
else
end
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'CO_2 & H_2O delay times'})
set_figure_name(SiteID)
ylabel('Samples')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('CO_2','H_2O','CO_2 setup','H_2O setup','location','northwest')

%-----------------------------------------------
% CO_2 & H_2O Delay Times (histogram)
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
subplot(2,1,1); hist(Delays_calc(:,1),200);
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2),ax(3:4));
    set(h,'color','r','linewidth',2)
end
ylabel('CO_2 delay times')
title({'Eddy Covariance: ';'Delay times histogram'})
set_figure_name(SiteID)

subplot(2,1,2); hist(Delays_calc(:,2),200);
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2),ax(3:4));
    set(h,'color','r','linewidth',2)
end
ylabel('H_{2}O delay times')
%zoom_together(gcf,'x','on')

%-----------------------------------------------
% LGR H2O N2O CH4 delay times
%-----------------------------------------------
fig = fig+1;figure(fig);clf

if ~strcmp(SiteID,'YF')
    plot(t,Delays_calc(:,3:5),'o');
else
    plot(t,[-align_calc1 -align_calc2 -align_calc3],'o');
end
if  ~isempty(c.Instrument(LGRnum).Delays.Samples)
    h = line([t(1) t(end)],c.Instrument(LGRnum).Delays.Samples(1)*ones(1,2));
    set(h,'color','b','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(LGRnum).Delays.Samples(2)*ones(1,2));
    set(h,'color','g','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(LGRnum).Delays.Samples(3)*ones(1,2));
    set(h,'color','r','linewidth',1.5)
else
    if strcmp(upper(SiteID),'YF') % Nick added Oct 8, 2009
        h = line([t(1) t(end)],18*ones(1,2));
        set(h,'color','b','linewidth',1.5)
        h = line([t(1) t(end)],20*ones(1,2));
        set(h,'color','g','linewidth',1.5)
    end
end
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'H_2O, N_2O & CH_4 delay times'})
set_figure_name(SiteID)
ylabel('Samples')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('H_2O','N_2O','CH_4','H_2O setup','N_2O setup','CH_4 setup','location','northwest')

%-----------------------------------------------
% LGR Delay Times (histogram)
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
subplot(3,1,1); hist(Delays_calc(:,3),200);
if  ~isempty(c.Instrument(LGRnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(LGRnum).Delays.Samples(1)*ones(1,2),ax(3:4));
    set(h,'color','r','linewidth',2)
end
ylabel('H2O (samples)')
title({'Eddy Covariance: ';'LGR Delay times histograms'})
set_figure_name(SiteID)

subplot(3,1,2); hist(Delays_calc(:,4),200);
if  ~isempty(c.Instrument(LGRnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(LGRnum).Delays.Samples(2)*ones(1,2),ax(3:4));
    set(h,'color','r','linewidth',2)
end
ylabel('N_2O (samples)')

subplot(3,1,3); hist(Delays_calc(:,5),200);
if  ~isempty(c.Instrument(LGRnum).Delays.Samples)
    ax=axis;
    h = line(c.Instrument(LGRnum).Delays.Samples(3)*ones(1,2),ax(3:4));
    set(h,'color','r','linewidth',2)
end
ylabel('CH_4 (samples)')

%-----------------------------------------------
% Air temperatures (Gill, HMP and 0.001" Tc)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,means(:,[4]),tv,HMP_T);   % ,tv,HMPT,tv,Pt_T,t,Tair_calc);
h = gca;
set(h,'XLim',[st ed+1],'YLim',Tax)
legend('Gill R3','HMP');
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Air Temperatures (Sonic & HMP)'});
set_figure_name(SiteID)
ylabel('Temperature (\circC)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Gill wind speed (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
if strcmp(SiteID,'LGR1')
    plot(t,means(:,1)); %  ,tv,RMYu);
else
    plot(t,means(:,1),tv,RMYu);
end
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 10])
title({'Eddy Covariance: ';'Gill Wind Speed (After Rotation)'});
set_figure_name(SiteID)
ylabel('U (m/s)')
if strcmp(SiteID,'LGR1')
    %legend('Sonic')
elseif ~strcmp(SiteID,'HDF11')
    legend('Sonic','RMYoung')
else
    legend('Sonic','Tall Tower 2m RMYoung')
end
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Gill ustar (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
hold on
plot(t,Ustar);
grid on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
line(ax(1:2),[Ustar_threshold Ustar_threshold],'color','r','linestyle','--')
line(ax(1:2),[ustar_threshold_calculated ustar_threshold_calculated ],'color','b','linestyle','--')
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1])
title({'Eddy Covariance: ';'u_*'});
set_figure_name(SiteID)
ylabel('m s^{-1}');
hold off
%-----------------------------------------------
% Gill wind direction (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
hold on
plot(t,Gill_wdir);
indFull = ones(size(t));
indNew = indFull;indNew(Flagged_ind)=0;
plot(t(indNew==1),Gill_wdir(indNew==1),'color',[0.75 0.75 0.75]);
%plot(t(Flagged_ind),Gill_wdir(Flagged_ind),'ro');
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 360])
title({'Eddy Covariance: ';'Wind Direction'});
set_figure_name(SiteID)
ylabel('\circ');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
hold off




%-----------------------------------------------
% Barometric pressure
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv,Pbar,t,Pbar_calc);
h = gca;
set(h,'XLim',[st ed+1],'YLim',[95 105])

grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Barometric Pressure'})
set_figure_name(SiteID)
ylabel('Pressure (kPa)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Pbar_{meas}','Pbar_{ECcalc}','location','northwest')

%-----------------------------------------------
% IRGA CO2 dry umol/mol
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
hold on
plot(t, [CO2_IRGA CO2_IRGA+CO2_std_IRGA CO2_IRGA-CO2_std_IRGA])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[350 550])
title({'LGR: ';'CO_2'});
set_figure_name(SiteID)
ylabel('(umol mol^{-1} of dry air)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
hold off

%-----------------------------------------------
% LGR N2O dry umol/mol
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, [N2Od_LGR N2Od_LGR+N2Od_std_LGR N2Od_LGR-N2Od_std_LGR])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0.30 0.38])
title({'LGR: ';'N_2O'});
set_figure_name(SiteID)
ylabel('(umol mol^{-1} of dry air)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LGR CH4 dry umol/mol
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, [CH4d_LGR CH4d_LGR+CH4d_std_LGR  CH4d_LGR-CH4d_std_LGR])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[1.75 5])
title({'LGR: ';'CH_4'});
set_figure_name(SiteID)
ylabel('(umol mol^{-1} of dry air)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% LGR H2O umol/mol
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, [H2O_LGR H2O_IRGA],'linewidth',3)
legend('LGR','LI7000','location','northwest')
hold on
plot(t, [ H2O_LGR+H2O_std_LGR H2O_LGR-H2O_std_LGR],t,[ H2O_IRGA+H2O_std_IRGA H2O_IRGA-H2O_std_IRGA])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 20])
title({'LGR: ';'H_2O'});
set_figure_name(SiteID)
ylabel('(mmol mol^{-1})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
hold off
%-----------------------------------------------
% Sensible heat
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
hold on
plot(t,H);
% plot(t(Flagged_ind),H(Flagged_ind),'ro');
h = gca;
set(h,'YLim',[-200 500],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Sensible Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Gill','CSAT','location','NorthEastOutside')
hold off
%legend('Gill',-1)


%-----------------------------------------------
% Latent heat
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
hold on
plot(t,[Le Le_LGR]);
% plot(t(Flagged_ind),[Le(Flagged_ind) Le_LGR(Flagged_ind)],'ro');
h = gca;
set(h,'YLim',[-20 300],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Latent Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('LI-7000','LGR','location','northwest')
hold off
%-----------------------------------------------
% CO2 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(t,Fc);
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'F_c'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

x.data = t;
y.data = Fc;
x_ustar = t;
x_ustar(Ustar_Flag_ind) = NaN;
x.ustar = x_ustar;
y_ustar = Fc;
y_ustar(Ustar_Flag_ind) = NaN;
y.ustar = y_ustar;
x_winddir = t;
x_winddir(WindDirection_Flag_ind) = NaN;
x.winddir = x_winddir;
y_winddir = Fc;
y_winddir(WindDirection_Flag_ind) = NaN;
y.winddir = y_winddir;
x_both = t;
x_both(Flagged_ind) = NaN;
x.both = x_both;
y_both = Fc;
y_both(Flagged_ind) = NaN;
y.both = y_both;
set(gcf,'userdata',[x y]);

btn1 = uicontrol('Style', 'checkbox', 'String', 'U_star',...
    'Position', pushbuttonPosition1,...
    'FontSize',fontSize,...
    'Callback', @radiobutton1_Callback);
btn2 = uicontrol('Style', 'checkbox', 'String', 'Wind Direction',...
    'Position', pushbuttonPosition2,...
    'FontSize',fontSize,...
    'Callback', @radiobutton2_Callback);
btn3 = uicontrol('Style', 'checkbox', 'String', 'U_star and Wind Direction',...
    'Position', pushbuttonPosition3,...
    'FontSize',fontSize,...
    'Callback', @radiobutton3_Callback);
f = gcf;

% fig = fig+1;figure(fig);clf;
% hold on
% plot(t,Fc);
% plot(t(Flagged_ind),Fc(Flagged_ind),'ro')
% h = gca;
% set(h,'YLim',[-20 20],'XLim',[st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title({'Eddy Covariance: ';'F_c'})
% set_figure_name(SiteID)
% ylabel('\mumol m^{-2} s^{-1}')
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% hold off
%-----------------------------------------------
% N2O flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(t,F_n2o);
h = gca;
set(h,'YLim',[-0.005 0.005],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'F_{n2o}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
f = gcf;

x.data = t;
y.data = F_n2o;
x_ustar = t;
x_ustar(Ustar_Flag_ind) = NaN;
x.ustar = x_ustar;
y_ustar = F_n2o;
y_ustar(Ustar_Flag_ind) = NaN;
y.ustar = y_ustar;
x_winddir = t;
x_winddir(WindDirection_Flag_ind) = NaN;
x.winddir = x_winddir;
y_winddir = F_n2o;
y_winddir(WindDirection_Flag_ind) = NaN;
y.winddir = y_winddir;
x_both = t;
x_both(Flagged_ind) = NaN;
x.both = x_both;
y_both = F_n2o;
y_both(Flagged_ind) = NaN;
y.both = y_both;

set(gcf,'userdata',[x y]);

btn1 = uicontrol('Style', 'checkbox', 'String', 'U_star',...
    'Position', pushbuttonPosition1,...
    'FontSize',fontSize,...
    'Callback', @radiobutton1_Callback);
btn2 = uicontrol('Style', 'checkbox', 'String', 'Wind Direction',...
    'Position', pushbuttonPosition2,...
    'FontSize',fontSize,...
    'Callback', @radiobutton2_Callback);
btn3 = uicontrol('Style', 'checkbox', 'String', 'U_star and Wind Direction',...
    'Position', pushbuttonPosition3,...
    'FontSize',fontSize,...
    'Callback', @radiobutton3_Callback);

% fig = fig+1;figure(fig);clf;
% hold on
% plot(t,F_n2o);
% plot(t(Flagged_ind),F_n2o(Flagged_ind),'ro');
% h = gca;
% set(h,'YLim',[-0.005 0.005],'XLim',[st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title({'Eddy Covariance: ';'F_{n2o}'})
% set_figure_name(SiteID)
% ylabel('\mumol m^{-2} s^{-1}')
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% hold off
%-----------------------------------------------
% CH4 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(t,F_ch4);
h = gca;
set(h,'YLim',[-0.1 0.1],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'F_{ch4}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
f = gcf;

x.data = t;
y.data = F_ch4;
x_ustar = t;
x_ustar(Ustar_Flag_ind) = NaN;
x.ustar = x_ustar;
y_ustar = F_ch4;
y_ustar(Ustar_Flag_ind) = NaN;
y.ustar = y_ustar;
x_winddir = t;
x_winddir(WindDirection_Flag_ind) = NaN;
x.winddir = x_winddir;
y_winddir = F_ch4;
y_winddir(WindDirection_Flag_ind) = NaN;
y.winddir = y_winddir;
x_both = t;
x_both(Flagged_ind) = NaN;
x.both = x_both;
y_both = F_ch4;
y_both(Flagged_ind) = NaN;
y.both = y_both;

set(gcf,'userdata',[x y]);

btn1 = uicontrol('Style', 'checkbox', 'String', 'U_star',...
    'Position', pushbuttonPosition1,...
    'FontSize',fontSize,...
    'Callback', @radiobutton1_Callback);
btn2 = uicontrol('Style', 'checkbox', 'String', 'Wind Direction',...
    'Position', pushbuttonPosition2,...
    'FontSize',fontSize,...
    'Callback', @radiobutton2_Callback);
btn3 = uicontrol('Style', 'checkbox', 'String', 'U_star and Wind Direction',...
    'Position', pushbuttonPosition3,...
    'FontSize',fontSize,...
    'Callback', @radiobutton3_Callback);

% fig = fig+1;figure(fig);clf;
% hold on
% plot(t,F_ch4);
% plot(t(Flagged_ind),F_ch4(Flagged_ind),'ro');
% h = gca;
% set(h,'YLim',[-0.1 0.1],'XLim',[st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title({'Eddy Covariance: ';'F_{ch4}'})
% set_figure_name(SiteID)
% ylabel('\mumol m^{-2} s^{-1}')
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

% % -----------------------------------------------
% % Leaf Wetness
% % -----------------------------------------------
% %
% % fig = fig+1;figure(fig);clf;
% %
% % plot(tv,leaf_wet_hist);
% % h = gca;
% % set(h,'YLim',[-0.1 0.1],'XLim',[st ed+1]);
% %
% % grid on;zoom on;xlabel('DOY')
% % title({'Eddy Correlation: ';'F_{ch4}'})
% % set_figure_name(SiteID)
% % ylabel('\mumol m^{-2} s^{-1}')
% % ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%------------------------------------------
if select == 1 %diagnostics only
    childn = get(0,'children');
    childn = sort(childn);
    N = length(childn);
    for i=1:N
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
% Soil Tension
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, [MPS_5 MPS_10 MPS_30 MPS_60])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[-125 0]);
title({'Clim: ';'Soil Tension'});
set_figure_name(SiteID)
ylabel('\psi')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Row_{5}', 'Row_{10}','Row_{30}','Row_{60}', 'location','northwest')

%-----------------------------------------------
% Soil Moisture
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, [VWC_grass_5 VWC_grass_10 VWC_grass_30 VWC_grass_60],'x',...
    tv, [VWC_row_5 VWC_row_10 VWC_row_30 VWC_row_60], '.')

grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0.20 0.70]);
title({'Clim: ';'Soil Moisture'});
set_figure_name(SiteID)
ylabel('\Theta_V')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Grass_{5}', 'Grass_{10}', 'Grass_{30}', 'Grass_{60}','Row_{5}', 'Row_{10}','Row_{30}','Row_{60}', 'location','southwest')

%-----------------------------------------------
% Soil Temperature
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, [Soil_T_row_5 Soil_T_row_10 Soil_T_row_30 Soil_T_row_60],...
    tv, [Soil_T_grass_5 Soil_T_grass_10 Soil_T_grass_30 Soil_T_grass_60]);

grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[5 30]);
title({'Clim: ';'Soil Temperature'});
set_figure_name(SiteID)
ylabel('\circC')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Row_{5}', 'Row_{10}','Row_{30}','Row_{60}','Grass_{5}', 'Grass_{10}', 'Grass_{30}', 'Grass_{60}','location','northwest');

% %-----------------------------------------------
% % Energy Balance
% %-----------------------------------------------
% fig = fig+1;figure(fig);clf;
% plot(tv, Rn, t, H, t, Le, t, Le_LGR, tv, G, t, sum([H (sum([Le Le_LGR],2)/2)],2));
% grid on;
% zoom on;
% xlabel('DOY')
% h = gca;
% set(h,'XLim',[st ed+1],'YLim',[-50 100])
% title({'LGR: ';'Energy Balance'});
% set_figure_name(SiteID)
% ylabel('W m^{-2} s^{-1}')
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% legend('Rn','Sensible','Latent','Latent_LGR','Ground','Balance','location','northwest')

%-----------------------------------------------
% Energy budget components
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv,Rn,t,Le,t,Le_LGR,t,H,tv,G);
ylabel('W/m2');
title({'Eddy Covariance: ';'Energy budget'});
set_figure_name(SiteID)
legend('Rn','LE','LE_LGR','H','G');

h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')

fig = fig+1;figure(fig);clf;
subplot(2,1,1)
plot(tv,Rn-G,t,H+Le);
xlabel('DOY');
ylabel('W m^{-2}');
title({'Eddy Correlation: ';'Energy budget'});
set_figure_name(SiteID)
legend('Rn-G','H+LE');

h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')

A = Rn-G;
T = H+Le;
[C,IA,IB] = intersect(datestr(tv),datestr(t),'rows'); %#ok<*ASGLU>
A = A(IA);
T = T(IB);
cut = find(isnan(A) | isnan(T) | A > 700 | A < -200 | T >700 | T < -200 |...
    H(IB) == 0 | Le(IB) == 0 | Rn(IA) == 0 );
A = clean(A,1,cut);
T = clean(T,1,cut);
[p, R2, sigma, s, Y_hat] = polyfit1(A,T,1);

subplot(2,1,2)
plot(Rn(IA)-G(IA),H(IB)+Le(IB),'.',...
    A,T,'o',...
    EBax,EBax,...
    EBax,polyval(p,EBax),'--');
text(-100, 400, sprintf('T = %2.3fA + %2.3f, R2 = %2.3f',p,R2));
xlabel('Ra (W/m2)');
ylabel('H+LE (W/m2)');
title({'Eddy Covariance: ';'Energy budget'});
set_figure_name(SiteID)
h = gca;
set(h,'YLim',EBax,'XLim',EBax);
grid on;zoom on;

%-----------------------------------------------
% PAR and SWD
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, (PAR_in./4.6), tv, swd);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 1000])
title({'Clim: ';'PAR and Rn'});
set_figure_name(SiteID)
ylabel('(W m^{-2} s^{-1})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Precip and Cumulative Precipitation
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, Rainfall, tv, Rainfall_cum_clean);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 250])
title({'Clim: ';'Rainfall'});
set_figure_name(SiteID)
ylabel('mm')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Rainfall', 'Cumulative', 'location', 'northwest');
%[ax,h1,h2] = plotyy(tv, Rainfall, tv, Rainfall_cum_clean);
% set(get(ax(1), 'YLabel'), 'String', 'mm')
% ylim(ax(1),[0 5])
% set(get(ax(2), 'YLabel'), 'String', 'mm_{cumulative}')
% ylim(ax(2),[0 200])
% xlim([st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title({'Eddy Correlation: ';'Rainfall'})
% set_figure_name(SiteID)
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% Soil Tension and Moisture
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

semilogy(VWC_row_5, abs(MPS_5),'.', VWC_row_10, abs(MPS_10),'.', VWC_row_30, abs(MPS_30),'.', VWC_row_60, abs(MPS_60),'.');
grid on;
zoom on;
xlabel('\theta_{V}')
h = gca;
set(h,'YLim',[5 150])
title({'Clim: ';'Soil Water Tension'});
set_figure_name(SiteID)
ylabel('\psi')
xlim([0.2 0.7]);
legend('Row_{5}', 'Row_{10}','Row_{30}','Row_{60}', 'location','northwest')

%---------------------------------------------------
% Water Table, Temperature, Electrical Conductivity
%---------------------------------------------------
fig = fig+1;figure(fig);clf;
subplot(3,1,1);
plot(tv, [water_table_drain_avg water_table_btwn_drain_avg],'o');
grid on;
zoom on;
h = gca;
set(h,'YLim',[1000 1900])
title({'Clim: ';'Water Table'});
set_figure_name(SiteID)
ylabel('Water Table Height (mm)')
% legend('Drain', 'Between Drain');

subplot(3,1,2);
plot(tv, [water_table_drain_temp_avg water_table_btwn_drain_temp_avg],'o');
grid on;
zoom on;
h = gca;
set(h,'YLim',[0 15])
ylabel('Water Table Temp (\circC)')
% legend('Drain', 'Between Drain');

subplot(3,1,3);
plot(tv, [water_table_drain_EC_avg water_table_btwn_drain_EC_avg],'o');
grid on;
zoom on;
h = gca;
set(h,'YLim',[0 1500])
ylabel('Water Table EC (\circC)')
legend('Drain', 'Between Drain');


%-----------------------------------------------
% Wind Direction and GHG Concentration
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(Gill_wdir, CO2_IRGA, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[375 550])
title({'Eddy Covariance: ';'Wind Direction vs [CO_2]'});
set_figure_name(SiteID)
ylabel('umol CO_2 mol^{-1} of dry air');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on

fig = fig+1;figure(fig);clf;
plot(Gill_wdir, N2Od_LGR, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[0.3 0.45])
ylabel('umol N_2O mol^{-1} of dry air');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
title({'Eddy Covariance: ';'Wind Direction vs [N_2O]'});
set_figure_name(SiteID)
grid on;

fig = fig+1;figure(fig);clf;
plot(Gill_wdir, CH4d_LGR, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[1 4])
ylabel('umol CH_4 mol^{-1} of dry air');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
title({'Eddy Covariance: ';'Wind Direction vs [CH_4]'});
set_figure_name(SiteID)
grid on;

%-----------------------------------------------
% Wind Direction and Flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(Gill_wdir, Fc, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[-25 25])
title({'Eddy Covariance: ';'Wind Direction vs F_c'});
set_figure_name(SiteID)
ylabel('CO_2 \mumol m^{-2} s^{-1}');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on

fig = fig+1;figure(fig);clf;
plot(Gill_wdir, F_n2o, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[-5e-3  5e-3])
title({'Eddy Covariance: ';'Wind Direction vs F_{N_2O}'});
set_figure_name(SiteID)
ylabel('N_2O \mumol m^{-2} s^{-1}');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on;

fig = fig+1;figure(fig);clf;
plot(Gill_wdir, F_ch4, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[-0.2 0.2])
ylabel('CH_4 \mumol m^{-2} s^{-1}');
title({'Eddy Covariance: ';'Wind Direction vs F_{CH_4}'});
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on;


%-----------------------------------------------
% WindRose
%-----------------------------------------------
[h,count,speeds,directions,Table] = WindRose(Gill_wdir,means(:,1),'anglenorth',0,'angleeast',90,'freqlabelangle',45);
title({'Eddy Covariance: ';'WindRose'});
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

%-----------------------------------------------
% Air temperatures (Sonic and Pt-100)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(HMPT(IA), means(IB,[4]),'.',...
    HMPT(IA),Pt_T(IA),'.',...
    Tax,Tax);
h = gca;
set(h,'XLim',Tax,'YLim',Tax)
grid on;zoom on;ylabel('Sonic')
title({'Eddy Correlation: ';'Air Temperatures'})
set_figure_name(SiteID)
xlabel('Temperature (\circC)')
legend('Sonic','Pt100','location','northeastoutside')
zoom on;

%-----------------------------------------------
% CO_2 (\mumol mol^-1 of dry air)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
%plot(t,[means(:,[5]) maxAll(:,5) minAll(:,5)],tv,co2_GH);
plot(t,[means(:,[5]) maxAll(:,5) minAll(:,5)]);
legend('IRGA_{avg}','IRGA_{max}','IRGA_{min}','LI800');
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[300 500])
title({'Eddy Correlation: ';'CO_2'})
set_figure_name(SiteID)
ylabel('\mumol mol^{-1} of dry air')

%------------------------------------------------
% Irga and sonic Alignment channels
%------------------------------------------------
try
    fig = fig+1;figure(fig);clf;
    plot(t,[irgaAlCh_Avg sonicAlCh_Avg]);
    legend(['IRGA channel ' num2str(irgaAlignCh) ' ' char(irgaAlignChName)],['Sonic channel ' num2str(sonicAlignCh) ' ' char(sonicAlignChName)]);
    grid on;zoom on;xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1], 'YLim',[-1 1])
    title({'Eddy Correlation: ';'Alignment Channels'})
    set_figure_name(SiteID)
    ylabel('?')
catch
    disp('Plotting of Alignment channels failed');
end



if strcmp(upper(SiteID),'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0);
    
    %-----------------------------------------------
    % Number of samples collected
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,numOfSamples_CSAT,t,numOfSamples_encIRGA,t,numOfSamplesEC_enc);
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[35800 36800])
    title({'Eddy Correlation LI-7200: ';'Number of samples collected'});
    set_figure_name(SiteID)
    ylabel('1')
    legend('Sonic','IRGA','EC')
    
    %-----------------------------------------------
    %  Diagnostic Flag, CSAT-3, Channel #5
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Dflag5_CSAT Dflag5_CSAT_Min Dflag5_CSAT_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'Diagnostic Flag, CSAT-3, Channel 5'});
    set_figure_name(SiteID)
    a = legend('av','min','max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('?')
    zoom on;
    
    %-----------------------------------------------
    %  Diagnostic Flag, Li-7200
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Dflag6_encIRGA Dflag6_encIRGA_Min Dflag6_encIRGA_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'Diagnostic Flag, Channel 9'});
    set_figure_name(SiteID)
    a = legend('av','min','max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('?')
    zoom on;
    
    %-----------------------------------------------
    %  Tbench IN
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,[Tbench_in Tbench_in_Min Tbench_in_Max Tbench_out Tbench_out_Min Tbench_out_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'T_{bench} IN'});
    set_figure_name(SiteID)
    a = legend('T_{in} av','T_{in} min','T_{in} max','T_{out} avg','T_{out} min','T_{out} max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Temperature (\circC)')
    zoom on;
    
    %-----------------------------------------------
    %  Tbench OUT
    %-----------------------------------------------
    %     fig = fig+1;figure(fig);clf;
    %     plot(t,[Tbench_out Tbench_out_Min Tbench_out_Max]);
    %     grid on;zoom on;xlabel('DOY')
    %     %h = gca;
    %     %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    %     title({'Eddy Correlation LI-7200: ';'T_{bench} OUT'});
    %     set_figure_name(SiteID)
    %     a = legend('T_{out} avg','T_{out} min','T_{out} max','location','NorthEastOutside');
    %     set(a,'visible','on');zoom on;
    %     h = gca;
    %     ylabel('Temperature (\circC)')
    %     zoom on;
    
    %-----------------------------------------------
    %  Plicor
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    
    plot(t,[Ptot Ptot_Min Ptot_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'P_{tot}'})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Pressure (kPa)')
    zoom on;
    
    fig = fig+1;figure(fig);clf;
    plot(t,[Phead Phead_Min Phead_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'P_{head}'})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Pressure (kPa)')
    zoom on;
    
    
    %-----------------------------------------------
    %  LI7200 signal strength
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    
    plot(t,[SigStrenght]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'Signal Strenght'})
    set_figure_name(SiteID)
    a = legend('av','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Signal Strength (%)')
    zoom on;
    
    %-----------------------------------------------
    %  LI7200 flow rates
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    
    plot(t,[FlowDrv FlowDrv_Min FlowDrv_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'Motor Duty Cycle'})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Duty cycle (%)')
    zoom on;
    
    fig = fig+1;figure(fig);clf;
    
    plot(t,[FlowRate FlowRate_Min FlowRate_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7200: ';'FlowRate'})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','NorthEastOutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Flow rate (LPM)')
    zoom on;
    
    
    %-----------------------------------------------
    % H_2O (mmol/mol of dry air)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    
    
    plot(t,[maxAll(:,6) minAll(:,6) ],':y');
    line(t,[maxAll_enc(:,6) minAll_enc(:,6)],'color','r','linestyle',':');
    line(t,[means(:,[6]) means_enc(:,[6])],'linewidth',2);
    grid on;zoom on;xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation LI-7000 vs LI-7200: ';'H_2O '})
    set_figure_name(SiteID)
    ylabel('(mmol mol^{-1} of dry air)')
    
    legend('LI7000_{max}','LI7000_{min}','LI7200_{max}','LI7200_{min}','LI7000_{avg}','LI7200_{avg}');
    zoom on;
    
    %-----------------------------------------------
    % CO_2 (\mumol mol^-1 of dry air)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    %plot(t,[means(:,[5]) maxAll(:,5) minAll(:,5)],tv,co2_GH);
    plot(t,[maxAll(:,5) minAll(:,5) ],':y');
    line(t,[maxAll_enc(:,5) minAll_enc(:,5)],'color','r','linestyle',':');
    line(t,[means(:,[5]) means_enc(:,[5])],'linewidth',2);
    legend('LI7000_{max}','LI7000_{min}','LI7200_{max}','LI7200_{min}','LI7000_{avg}','LI7200_{avg}');
    grid on;zoom on;xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1], 'YLim',[300 500])
    title({'Eddy Correlation LI-7000 vs LI-7200: ';'CO_2'})
    set_figure_name(SiteID)
    ylabel('\mumol mol^{-1} of dry air')
    
end

%-----------------------------------------------
% CO2 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
if strcmp(upper(SiteID),'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0);
    plot(t,[Fc Fc_enc]);
    h = gca;
    set(h,'YLim',[-20 20],'XLim',[st ed+1]);
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'F_c'})
    set_figure_name(SiteID)
    ylabel('\mumol m^{-2} s^{-1}')
    legend('LI-7000','LI-7200','location','NorthEastOutside')
else
    plot(t,Fc);
    h = gca;
    set(h,'YLim',[-20 20],'XLim',[st ed+1]);
    
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'F_c'})
    set_figure_name(SiteID)
    ylabel('\mumol m^{-2} s^{-1}')
end

%-----------------------------------------------
% H_2O (mmol/mol of dry air) vs. HMP
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(means(IB,[6]),HMP_mixratio(IA),'.',...
    [-1 22],[-1 22]);
grid on;zoom on;
ylabel('HMP Mixing Ratio (mmol/mol)')
h = gca;
set(h,'XLim',[-1 22], 'YLim',[-1 22]);
title({'Eddy Correlation: ';'H_2O'});
set_figure_name(SiteID)
xlabel('irga (mmol mol^{-1} of dry air)');
zoom on;

%-----------------------------------------------
% Energy budget components
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv,Rn,t,Le,t,H,tv,G);
ylabel('W/m2');
title({'Eddy Correlation: ';'Energy budget'});
set_figure_name(SiteID)
legend('Rn','LE','H','G');

h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')

fig = fig+1;figure(fig);clf;
plot(tv,Rn-G,t,H+Le);
xlabel('DOY');
ylabel('W m^{-2}');
title({'Eddy Correlation: ';'Energy budget'});
set_figure_name(SiteID)
legend('Rn-G','H+LE');

h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
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
title({'Eddy Correlation: ';'Energy budget'});
set_figure_name(SiteID)
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
end

function set_figure_name(SiteID)
title_string = get(get(gca,'title'),'string');
set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'numbertitle','off')
end



function radiobutton1_Callback(btn1, eventdata, f)
if (get(btn1,'Value') == get(btn1,'Max'))
    data = get(gcf, 'userdata');
    xdata = data(1).data;
    ydata = data(2).data;
    hold on
    ustar_x = data(1).ustar;
    ustar_y = data(2).ustar;
    plot(xdata,ydata,'r')
    plot(ustar_x,ustar_y,'b')
    hold off
else
    hold on
    data = get(gcf, 'userdata');
    xdata = data(1).data;
    ydata = data(2).data;
    plot(xdata,ydata,'b')
    hold off
end
end

function radiobutton2_Callback(btn2, eventdata, f)
if (get(btn2,'Value') == get(btn2,'Max'))
    data = get(gcf, 'userdata');
    xdata = data(1).winddir;
    ydata = data(2).winddir;
    hold on
    winddir_x = data(1).winddir;
    winddir_y = data(2).winddir;
    plot(xdata,ydata,'r')
    plot(winddir_x,winddir_y,'color', [1 0 0.5])
    hold off
else
    hold on
    data = get(gcf, 'userdata');
    xdata = data(1).data;
    ydata = data(2).data;
    plot(xdata,ydata,'b')
    hold off
end
end

function radiobutton3_Callback(btn3, eventdata, f)
if (get(btn3,'Value') == get(btn3,'Max'))
    data = get(gcf, 'userdata');
    xdata = data(1).data;
    ydata = data(2).data;
    both_x = data(1).both;
    both_y = data(2).both;
    hold on
    plot(xdata,ydata,'r')
    plot(both_x,both_y,'color','b')
    hold off
else
    hold on
    data = get(gcf, 'userdata');
    xdata = data(1).data;
    ydata = data(2).data;
    plot(xdata,ydata,'b')
    hold off
end
end

