function [] = eddy_pl_LGR2_temp(ind, year, SiteID, select)
%
% Revisions
%
%  June 25, 2018 (Zoran)
%   - created file based on eddy_pl_LGR1
%  Jan 27, 2019 (Ningyu)
%   - load air temperature profile data from CR1000 datalogger and plot
%  Jan 31, 2019 (Ningyu)
%   - calibrate the rainfall and add cum rainfall
%  Feb 21, 2019 (Ningyu)
%   - change colors of the points in wind direction filtering to avoid
%   confusion of solid circles and hollow ones in the same color;
%   LGR/Li-7200 in the title line
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
c = fr_get_init(SiteID,currentDate);
ext         = c.hhour_ext;
IRGAnum = c.System(1).Instrument(2);
SONICnum = c.System(1).Instrument(1);
LGRnum =  c.System(1).Instrument(3);  %<=== This will have to change once we have EC program that can do LI-7000 and LGR in one go
nMainEddy = 1;

%load in fluxes
switch upper(SiteID)
    case 'LGR2'
        [pthc] = biomet_path(year,'LGR2','cl');
        pth = '\\PAOA001\SITES\LGR2\hhour\';
        ext         = '.hLGR2.mat';
        GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path(year,'LGR2'),'Flux\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
        
         diagFlagIRGA = 7;
         nMainEddy = 1;
         [accepted_wind_vector_east_crop] = [0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
         [accepted_wind_vector_east_potato] = [0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
         [accepted_wind_vector_east_bean] = [0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
         [accepted_wind_vector_west_potato] = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0];
         [accepted_wind_vector_ditch] = [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
         [accepted_wind_vector_potato] = [0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0];
         WindDirection_threshold = 0.8;
         Ustar_threshold = 0.15;
         ml2mm = 1/32.429;
         % Load diagnostic climate data        
         Batt_logger = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Batt_volt_Avg'),[],[],year,ind);
         Batt_logger_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Batt_volt_Min'),[],[],year,ind);
         Batt_logger_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Batt_volt_Max'),[],[],year,ind);
         
         Ptemp_logger = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','PTemp_Avg'),[],[],year,ind);
         Ptemp_logger_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','PTemp_Min'),[],[],year,ind);
         Ptemp_logger_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','PTemp_Max'),[],[],year,ind);

         T_BigPump = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_BigPump_Avg'),[],[],year,ind);
         T_BigPump_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_BigPump_Min'),[],[],year,ind);
         T_BigPump_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_BigPump_Max'),[],[],year,ind);

         T_LGR = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Avg'),[],[],year,ind);
         T_LGR_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Min'),[],[],year,ind);         
         T_LGR_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_Max'),[],[],year,ind);         
         T_LGR_front = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_front_Avg'),[],[],year,ind);         
         T_LGR_intake = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_LGR_intake_Avg'),[],[],year,ind);
         T_Pump_intake = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_Pump_intake_Avg'),[],[],year,ind);
         T_UPS = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','T_UPS_Avg'),[],[],year,ind);

         Fan1_dutycycle = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_1_power_Avg'),[],[],year,ind);
         Fan2_dutycycle = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_2_power_Avg'),[],[],year,ind);
         Fan3_dutycycle = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_3_power_Avg'),[],[],year,ind);
         Fan4_dutycycle = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_4_power_Avg'),[],[],year,ind);
%         Fan_Power_Level = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CTRL_CR1000_BoxStatusSlow\','Fan_power_level_Avg'),[],[],year,ind);

         
         % Load air temperature profile data from CR1000 logger
%          
%          Air_TC_High = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_High_Avg'),[],[],year,ind);
%          Air_TC_High_Max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_High_Max'),[],[],year,ind);
%          Air_TC_High_Min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_High_Min'),[],[],year,ind);
%          Air_TC_High_Std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_High_Std'),[],[],year,ind);
%          
%          Air_TC_Middle = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Middle_Avg'),[],[],year,ind);
%          Air_TC_Middle_Max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Middle_Max'),[],[],year,ind);
%          Air_TC_Middle_Min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Middle_Min'),[],[],year,ind);
%          Air_TC_Middle_Std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Middle_Std'),[],[],year,ind);
%          
%          Air_TC_Low = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Low_Avg'),[],[],year,ind);
%          Air_TC_Low_Max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Low_Max'),[],[],year,ind);
%          Air_TC_Low_Min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Low_Min'),[],[],year,ind);
%          Air_TC_Low_Std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\CR1000_AGGP_Temp_Profile\','Air_TC_Low_Std'),[],[],year,ind);
    otherwise
        error 'Wrong SiteID'
end

instrumentLI7000 = sprintf('Instrument(%d).',IRGAnum);
instrumentGillR3 =  sprintf('Instrument(%d).',SONICnum);
instrumentLGR =  sprintf('Instrument(%d).',LGRnum);

StatsX = [];
t      = [];
for i = 1:days
    
    filename_p = fr_DateToFileName(currentDate+.03);
    filename   = filename_p(1:6);
    
    pth_filename_ext = [pth filename ext];
    if ~exist([pth filename ext])
        pth_filename_ext = [pth filename 's' ext];
    end
    
    if exist(pth_filename_ext) %#ok<*EXIST>
       try
          load(pth_filename_ext);
          if i == 1
             StatsX = [Stats];
             t      = [currentDate+1/48:1/48:currentDate+1];
          else
             StatsX = [StatsX Stats]; %#ok<*AGROW>
             t      = [t currentDate+1/48:1/48:currentDate+1];
          end
          
       catch %#ok<*CTCH>
          disp(lasterr);     %#ok<*LERR>
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
[Dflag5]    = get_stats_field(StatsX,[instrumentGillR3 'Avg(5)']);
[Dflag5_Min]= get_stats_field(StatsX,[instrumentGillR3 'Min(5)']);
[Dflag5_Max]= get_stats_field(StatsX,[instrumentGillR3 'Max(5)']);

% WindDirection Filtering and Flag
% Seprate into 5 different wind direction groups
% (1)East crop
% (2)East potato
% (3)East bean
% (4)West potato
% (5)Ditch
%--needed(6)East potato+ West potato
WindDirection_Histogram(:,37) = [];
WindDirection_fraction_east_crop = zeros(size(WindDirection_Histogram,1),1);
WindDirection_fraction_east_potato = zeros(size(WindDirection_Histogram,1),1);
WindDirection_fraction_east_bean = zeros(size(WindDirection_Histogram,1),1);
WindDirection_fraction_west_potato = zeros(size(WindDirection_Histogram,1),1);
WindDirection_fraction_ditch = zeros(size(WindDirection_Histogram,1),1);
WindDirection_fraction_potato = zeros(size(WindDirection_Histogram,1),1);
for i = 1:size(WindDirection_Histogram,1)
 	WindDirection_accepted_east_crop = WindDirection_Histogram(i,:).*accepted_wind_vector_east_crop;
 	row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted_east_crop = nansum(WindDirection_accepted_east_crop);	
 	WindDirection_fraction_east_crop(i) = row_sum_accepted_east_crop./row_total;
end

for i = 1:size(WindDirection_Histogram,1)
 	WindDirection_accepted_east_potato = WindDirection_Histogram(i,:).*accepted_wind_vector_east_potato;
 	row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted_east_potato = nansum(WindDirection_accepted_east_potato);	
 	WindDirection_fraction_east_potato(i) = row_sum_accepted_east_potato./row_total;
end
for i = 1:size(WindDirection_Histogram,1)
 	WindDirection_accepted_east_bean = WindDirection_Histogram(i,:).*accepted_wind_vector_east_bean;
 	row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted_east_bean = nansum(WindDirection_accepted_east_bean);	
 	WindDirection_fraction_east_bean(i) = row_sum_accepted_east_bean./row_total;
end
for i = 1:size(WindDirection_Histogram,1)
 	WindDirection_accepted_west_potato = WindDirection_Histogram(i,:).*accepted_wind_vector_west_potato;
 	row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted_west_potato = nansum(WindDirection_accepted_west_potato);	
 	WindDirection_fraction_west_potato(i) = row_sum_accepted_west_potato./row_total;
end
for i = 1:size(WindDirection_Histogram,1)
 	WindDirection_accepted_ditch = WindDirection_Histogram(i,:).*accepted_wind_vector_ditch;
 	row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted_ditch = nansum(WindDirection_accepted_ditch);	
 	WindDirection_fraction_ditch(i) = row_sum_accepted_ditch./row_total;
end
for i = 1:size(WindDirection_Histogram,1)
 	WindDirection_accepted_potato = WindDirection_Histogram(i,:).*accepted_wind_vector_potato;
 	row_total = nansum(WindDirection_Histogram(i,:));
    row_sum_accepted_potato = nansum(WindDirection_accepted_potato);	
 	WindDirection_fraction_potato(i) = row_sum_accepted_potato./row_total;
end
    
WindDirection_Flag_ind_east_crop = find(WindDirection_fraction_east_crop<WindDirection_threshold);
Ustar_Flag_ind_east_crop = find(Ustar<Ustar_threshold);
Flagged_ind_east_crop = unique([WindDirection_Flag_ind_east_crop; Ustar_Flag_ind_east_crop]);
Good_ind_east_crop = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind_east_crop);

WindDirection_Flag_ind_east_potato = find(WindDirection_fraction_east_potato<WindDirection_threshold);
Ustar_Flag_ind_east_potato = find(Ustar<Ustar_threshold);
Flagged_ind_east_potato = unique([WindDirection_Flag_ind_east_potato; Ustar_Flag_ind_east_potato]);
Good_ind_east_potato = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind_east_potato);

WindDirection_Flag_ind_east_bean = find(WindDirection_fraction_east_bean<WindDirection_threshold);
Ustar_Flag_ind_east_bean = find(Ustar<Ustar_threshold);
Flagged_ind_east_bean = unique([WindDirection_Flag_ind_east_bean; Ustar_Flag_ind_east_bean]);
Good_ind_east_bean = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind_east_bean);

WindDirection_Flag_ind_west_potato = find(WindDirection_fraction_west_potato<WindDirection_threshold);
Ustar_Flag_ind_west_potato = find(Ustar<Ustar_threshold);
Flagged_ind_west_potato = unique([WindDirection_Flag_ind_west_potato; Ustar_Flag_ind_west_potato]);
Good_ind_west_potato = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind_west_potato);

WindDirection_Flag_ind_ditch = find(WindDirection_fraction_ditch<WindDirection_threshold);
Ustar_Flag_ind_ditch = find(Ustar<Ustar_threshold);
Flagged_ind_ditch = unique([WindDirection_Flag_ind_ditch; Ustar_Flag_ind_ditch]);
Good_ind_ditch = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind_ditch);

WindDirection_Flag_ind_potato = find(WindDirection_fraction_potato<WindDirection_threshold);
Ustar_Flag_ind_potato = find(Ustar<Ustar_threshold);
Flagged_ind_potato = unique([WindDirection_Flag_ind_potato; Ustar_Flag_ind_potato]);
Good_ind_potato = setdiff(1:size(WindDirection_Histogram,1),Flagged_ind_potato);

% air temperature and pressure used in eddy flux calculations (Jan 25,
% 2010)
[Tair_calc]        = get_stats_field(StatsX,'MiscVariables.Tair');
[Pbar_calc]        = get_stats_field(StatsX,'MiscVariables.BarometricP');
%
% LGR diagnostics
    [T_LGR_gas]         = get_stats_field(StatsX,[instrumentLGR 'Avg(13)']);
    [T_LGR_gas_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(13)']);
  
    [GasP_LGR]         = get_stats_field(StatsX,[instrumentLGR 'Avg(11)']);
    [GasP_LGR_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(11)']);
    
    [T_LGR_amb]         = get_stats_field(StatsX,[instrumentLGR 'Avg(15)']);
    [T_LGR_amb_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(15)']);
    
    [Laser_A_V]         = get_stats_field(StatsX,[instrumentLGR 'Avg(17)']);
    [Laser_A_V_std]     = get_stats_field(StatsX,[instrumentLGR 'Std(17)']);
    
% LI-7200 diagnostics
 
    [Tbench_In]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(3)']);
    [Tbench_In_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(3)']);
    [Tbench_In_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(3)']);

    [Tbench_Out]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(4)']);
    [Tbench_Out_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(4)']);
    [Tbench_Out_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(4)']);

    [P_tot]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(5)']);
    [P_tot_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(5)']);
    [P_tot_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(5)']);
    
    [P_head]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(6)']);
    [P_head_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(6)']);
    [P_head_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(6)']);

    [Signal_Strength]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(7)']);
    [Signal_Strength_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(7)']);
    [Signal_Strength_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(7)']);
    
    [Motor_Duty]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(8)']);
    [Motor_Duty_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(8)']);
    [Motor_Duty_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(8)']);
    
    [IRGA_diag]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(9)']);
    [IRGA_diag_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(9)']);
    [IRGA_diag_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(9)']);
    
    [IRGA_flow]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(10)']);
    [IRGA_flow_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(10)']);
    [IRGA_flow_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(10)']);
    
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
       
    numOfSamplesIRGA = get_stats_field(StatsX, [instrumentLI7000 'MiscVariables.NumOfSamples']);
    numOfSamplesSonic = get_stats_field(StatsX,[instrumentGillR3 'MiscVariables.NumOfSamples']);
    numOfSamplesLGR = get_stats_field(StatsX,[instrumentLGR 'MiscVariables.NumOfSamples']);

    Delays_calc       = get_stats_field(StatsX,'MainEddy.Delays.Calculated');
    Delays_set        = get_stats_field(StatsX,'MainEddy.Delays.Implemented');
    
% Load LGR1 gas concentration data
         
     CH4_LGR         = get_stats_field(StatsX,[instrumentLGR 'Avg(1)']);
     CH4_std_LGR     = get_stats_field(StatsX,[instrumentLGR 'Std(1)']);
     CH4d_LGR        = get_stats_field(StatsX,[instrumentLGR 'Avg(9)']);
     CH4d_std_LGR    = get_stats_field(StatsX,[instrumentLGR 'Std(9)']);
     N2O_LGR         = get_stats_field(StatsX,[instrumentLGR 'Avg(5)']);
     N2O_std_LGR     = get_stats_field(StatsX,[instrumentLGR 'Std(5)']);
     N2Od_LGR        = get_stats_field(StatsX,[instrumentLGR 'Avg(7)']);
     N2Od_std_LGR    = get_stats_field(StatsX,[instrumentLGR 'Std(7)']);
     H2O_LGR         = get_stats_field(StatsX,[instrumentLGR 'Avg(3)']);
     H2O_std_LGR     = get_stats_field(StatsX,[instrumentLGR 'Std(3)']);

% Load LI7000 gas concentration data
         
     CO2_IRGA         = get_stats_field(StatsX,[instrumentLI7000 'Avg(1)']);
     CO2_std_IRGA     = get_stats_field(StatsX,[instrumentLI7000 'Std(1)']);
     H2O_IRGA         = get_stats_field(StatsX,[instrumentLI7000 'Avg(2)']);
     H2O_std_IRGA     = get_stats_field(StatsX,[instrumentLI7000 'Std(2)']);
     
     
%figures
if now > datenum(year,4,15) & now < datenum(year,11,1); %#ok<*AND2>
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

% %-----------------------------------------------
% % HMP Air Temp 
% %-----------------------------------------------
% 
% fig = fig+1;figure(fig);clf;
% 
% plot(tv,HMP_T);
% ylabel( 'T \circC')
% xlim([st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title({'Eddy Covariance: ';'HMP_{T}'})
% set_figure_name(SiteID)
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% 
% %-----------------------------------------------
% % HMP RH
% %-----------------------------------------------
% 
% fig = fig+1;figure(fig);clf;
% 
% plot(tv,HMP_RH);
% ylabel( '%')
% xlim([st ed+1]);
% grid on;zoom on;xlabel('DOY')
% title({'Eddy Covariance: ';'HMP_{RH}'})
% set_figure_name(SiteID)
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% 


%-----------------------------------------------
% Trailer Temperatures
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, [Ptemp_logger T_UPS T_Pump_intake T_LGR T_LGR_intake T_LGR_front T_BigPump],'linewidth',2)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1]); %,'YLim',[43.5 45.5])
title({'LGR: ';'LGR:Trailer Temperatures'});
set_figure_name(SiteID)
ylabel('\circC')
legend('Logger', 'UPS','Pump_{intake}','LGR','LGR_{intake}','LGR_{front}','BigPump','Location','NorthWest')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LGR Temperatures
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, [T_LGR T_LGR_min T_LGR_max],'linewidth',2)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1]); %,'YLim',[43.5 45.5])
title({'LGR: ';'LGR:Trailer Temperatures'});
set_figure_name(SiteID)
ylabel('\circC')
legend('LGR','LGR_{min}','LGR_{max}','Location','NorthWest')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% Fan duty cycles
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, [Fan1_dutycycle Fan2_dutycycle Fan3_dutycycle Fan4_dutycycle ]*100,'linewidth',2)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 100])
title({'LGR: ';'Trailer:Fan dutycycles'});
set_figure_name(SiteID)
ylabel('%')
legend('Fan 1','Fan 2','Fan 3','Fan 4','Location','NorthWest')
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
title({'LGR: ';'LGR:T_{gas}'});
set_figure_name(SiteID)
ylabel('\circC')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


% %-----------------------------------------------
% % LGR Ambient Temperature
% %-----------------------------------------------
% fig = fig+1;figure(fig);clf;
% plot(t, T_LGR_amb,t, T_LGR_amb-T_LGR_amb_std,t, T_LGR_amb+T_LGR_amb_std,... 
%      tv, T_LGR_fan, tv, T_LGR_fan-T_LGR_fan_std, tv, T_LGR_fan+T_LGR_fan_std)
% grid on;
% zoom on;
% xlabel('DOY')
% h = gca;
% set(h,'XLim',[st ed+1],'YLim',[47 49])
% title({'LGR: ';'T_{ambient}'});
% set_figure_name(SiteID)
% ylabel('LGR Ambient Temp (\circC)')
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% 
% %-----------------------------------------------
% % LGR Hut temperatures and Fan on time
% %-----------------------------------------------
% fig = fig+1;figure(fig);clf;
% subplot(2,1,1)
% plot([tv], [T_Hut_fan, T_Hut_fan+T_Hut_fan_std, T_Hut_fan-T_Hut_fan_std])
% %legend('LGR Fan outlet')
% title({'LGR: ';'Hut Temperatures'});
% set_figure_name(SiteID)
% ylabel('LGR Fan outlet (\circC)')
% ax=axis;
% grid on;
% zoom on;
% 
% subplot(2,1,2)
% bar( tv, Fan_Status);
% axis([ax(1:2) 0 1])
% grid on;
% zoom on;
% xlabel('DOY')
% h = gca;
% ylabel('Fan duty cycle (0-1)')
% %set(h,'XLim',[st ed+1],'YLim',[10 35])
% 
% 
% %-----------------------------------------------
% % Pump Temperatures
% %-----------------------------------------------
% fig = fig+1;figure(fig);clf;
% plot(tv, T_BigPump_fan,'r', tv, T_BigPump_fan-T_BigPump_fan_std,':r', tv, T_BigPump_fan+T_BigPump_fan_std,':r',...
%      tv, T_SmallPump_fan,'b', tv, T_SmallPump_fan-T_SmallPump_fan_std, ':b', tv, T_SmallPump_fan+T_SmallPump_fan_std, ':b')
% grid on;
% zoom on;
% xlabel('DOY')
% h = gca;
% set(h,'XLim',[st ed+1],'YLim',[0 70])
% title({'LGR: ';'Pump Temperatures'});
% set_figure_name(SiteID)
% ylabel('\circC')
% ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
% legend('LGR Pump','','','LI7000 Pump','location','northwest') 
% 


%-----------------------------------------------
% LGR Laser A Voltage
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, Laser_A_V,t, Laser_A_V-Laser_A_V_std,t, Laser_A_V+Laser_A_V_std)
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1]); %,'YLim',[-0.2 0.2])
title({'LGR: ';'LGR:Laser A_{volt}'});
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
set(h,'XLim',[st ed+1],'YLim',[44.5 45.5])
title({'LGR: ';'LGR:Gas Pressure_{Torr}'});
set_figure_name(SiteID)
ylabel('Torr')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Gas Pressure') 

%-----------------------------------------------
%  Tbench
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Tbench_In Tbench_In_Min Tbench_In_Max Tbench_Out Tbench_Out_Min Tbench_Out_Max]);
line(t,[Tbench_In Tbench_Out],'linewidth',2)
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Covariance: ';'Li-7200:T_{bench}'});
set_figure_name(SiteID)
%a = legend('In_av','In_min','In_max','Out_av','Out_min','Out_max','location','northwest');
a = legend('T_{In}','T_{Out}','location','northwest');
set(a,'visible','on');zoom on;
h = gca;
ylabel('Temperature (\circC)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

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
%  Diagnostic Flag, Li-7200
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[IRGA_diag IRGA_diag_Min IRGA_diag_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Covariance: ';'Diagnostic Flag, Li-7200, Channel 6'});
set_figure_name(SiteID)
a = legend('av','min','max','location','northwest');
set(a,'visible','on');zoom on;
h = gca;
ylabel('?')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
zoom on;

%-----------------------------------------------
%  LI7200 flow rates
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,[Motor_Duty Motor_Duty_Min Motor_Duty_Max]);
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[75 100])
title({'Eddy Correlation LI-7200: ';'Li-7200:Motor Duty Cycle'})
set_figure_name(SiteID)
a = legend('av','min','max', 'northeast');
set(a,'visible','on');zoom on;
ylabel('Motor Duty cycle (%)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

fig = fig+1;figure(fig);clf;

plot(t,[IRGA_flow IRGA_flow_Min IRGA_flow_Max]);
grid on;zoom on;xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1], 'YLim',[10 18])
title({'Eddy Correlation LI-7200: ';'Li-7200:FlowRate'})
set_figure_name(SiteID)
a = legend('av','min','max', 'northeast');
set(a,'visible','on');zoom on;
ylabel('Flow rate (LPM)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
%  P total
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,[P_tot P_tot_Min P_tot_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Covariance: ';'Li-7200:P_{Total} '})
set_figure_name(SiteID)
a = legend('av','min','max','location','northwest');
set(a,'visible','on');zoom on;
h = gca;
ylabel('Total Pressure (kPa)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
%  P head
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plot(t,[P_head P_head_Min P_head_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Covariance: ';'Li-7200:P_{Head} '})
set_figure_name(SiteID)
a = legend('av','min','max','location','northwest');
set(a,'visible','on');zoom on;
h = gca;
ylabel('Head Pressure (kPa)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% Gill wind speed (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,means(:,1)); %  ,tv,RMYu);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 10])
title({'Eddy Covariance: ';'Gill Wind Speed (After Rotation)'});
set_figure_name(SiteID)
ylabel('U (m/s)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Gill wind direction_filtered by Ustar and wind directions (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
hold on
plot(t,Gill_wdir);
plot(t(Good_ind_east_crop),Gill_wdir(Good_ind_east_crop),'o','MarkerEdgeColor','r','MarkerFaceColor','r');
plot(t(Good_ind_east_potato),Gill_wdir(Good_ind_east_potato),'o','MarkerEdgeColor','y','MarkerFaceColor','y');
plot(t(Good_ind_east_bean),Gill_wdir(Good_ind_east_bean),'o','MarkerEdgeColor','g','MarkerFaceColor','g');
plot(t(Good_ind_west_potato),Gill_wdir(Good_ind_west_potato),'o','MarkerEdgeColor','c','MarkerFaceColor','c');
plot(t(Good_ind_ditch),Gill_wdir(Good_ind_ditch),'o','MarkerEdgeColor','k','MarkerFaceColor','k');
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 360])
title({'Eddy Covariance: ';'Wind Direction_Ustar&Winddir'});
set_figure_name(SiteID)
ylabel('\circ');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('all','north to the east potato','east potato','east bean','west potato','ditch','location','northwest')
hold off


%-----------------------------------------------
% LI7200 CO2 dry umol/mol
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
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
hold off
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 25])
title({'LGR: ';'H_2O'});
set_figure_name(SiteID)
ylabel('(mmol mol^{-1})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Sensible heat
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,H);
h = gca;
set(h,'YLim',[-200 500],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Sensible Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Gill','CSAT','northeast')
%legend('Gill',-1)

%-----------------------------------------------
% Latent heat
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Le Le_LGR]);
h = gca;
set(h,'YLim',[-20 300],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'Latent Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('LI-7000','LGR','location','northwest')

%-----------------------------------------------
% Latent heat comparison between Li-7200 and LGR
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(Le,Le_LGR,'o');
h = gca;
set(h,'YLim',[-20 300]);
%'XLim',[st ed+1])
grid on;zoom on;xlabel('Li-7200')
title({'Eddy Covariance: ';'LE comparison between Li-7200 and LGR'})
set_figure_name(SiteID)
ylabel('LGR')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

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

fig = fig+1;figure(fig);clf;
hold on
plot(t,Fc);
plot(t(Good_ind_east_crop),Fc(Good_ind_east_crop),'o','MarkerEdgeColor','r','MarkerFaceColor','r');
plot(t(Good_ind_east_potato),Fc(Good_ind_east_potato),'o','MarkerEdgeColor','y','MarkerFaceColor','y');
plot(t(Good_ind_east_bean),Fc(Good_ind_east_bean),'o','MarkerEdgeColor','g','MarkerFaceColor','g');
plot(t(Good_ind_west_potato),Fc(Good_ind_west_potato),'o','MarkerEdgeColor','c','MarkerFaceColor','c');
plot(t(Good_ind_ditch),Fc(Good_ind_ditch),'o','MarkerEdgeColor','k','MarkerFaceColor','k');
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'F_c_{Ustar&Winddir}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('all','north to the east potato','east potato','east bean','west potato','ditch','location','northwest')
hold off



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

fig = fig+1;figure(fig);clf;
hold on
plot(t,F_n2o);
plot(t(Good_ind_east_crop),F_n2o(Good_ind_east_crop),'o','MarkerEdgeColor','r','MarkerFaceColor','r');
plot(t(Good_ind_east_potato),F_n2o(Good_ind_east_potato),'o','MarkerEdgeColor','y','MarkerFaceColor','y');
plot(t(Good_ind_east_bean),F_n2o(Good_ind_east_bean),'o','MarkerEdgeColor','g','MarkerFaceColor','g');
plot(t(Good_ind_west_potato),F_n2o(Good_ind_west_potato),'o','MarkerEdgeColor','c','MarkerFaceColor','c');
plot(t(Good_ind_ditch),F_n2o(Good_ind_ditch),'o','MarkerEdgeColor','k','MarkerFaceColor','k');
h = gca;
set(h,'YLim',[-0.005 0.005],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'F_{n2o}_{Ustar&Winddir}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('all','north to the east potato','east potato','east bean','west potato','ditch','location','northwest')
hold off



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

fig = fig+1;figure(fig);clf;
hold on
plot(t,F_ch4);
plot(t(Good_ind_east_crop),F_ch4(Good_ind_east_crop),'o','MarkerEdgeColor','r','MarkerFaceColor','r');
plot(t(Good_ind_east_potato),F_ch4(Good_ind_east_potato),'o','MarkerEdgeColor','y','MarkerFaceColor','y');
plot(t(Good_ind_east_bean),F_ch4(Good_ind_east_bean),'o','MarkerEdgeColor','g','MarkerFaceColor','g');
plot(t(Good_ind_west_potato),F_ch4(Good_ind_west_potato),'o','MarkerEdgeColor','c','MarkerFaceColor','c');
plot(t(Good_ind_ditch),F_ch4(Good_ind_ditch),'o','MarkerEdgeColor','k','MarkerFaceColor','k');
h = gca;
set(h,'YLim',[-0.1 0.1],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Covariance: ';'F_{ch4}_{Ustar&Winddir}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('all','north to the east potato','east potato','east bean','west potato','ditch','location','northwest')
hold off

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
% PAR
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, (PAR./4.6));
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 1])
title({'Clim: ';'PAR'});
set_figure_name(SiteID)
ylabel('(W m^{-2} )')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Albedo
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(tv,Albedo);
h = gca;
set(h,'YLim',[0 1],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'LGR2 Clim: ';'Albedo'})
set_figure_name(SiteID)
ylabel('Albedo')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(tv,LWIN);
h = gca;
set(h,'YLim',[0 450],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'LGR2 Clim: ';'Longwave Upwelling'})
set_figure_name(SiteID)
ylabel('(W m^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LWOUT
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(tv,LWOUT);
h = gca;
set(h,'YLim',[0 400],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'LGR2 Clim: ';'Longwave Downwelling'})
set_figure_name(SiteID)
ylabel('(W m^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SWIN
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(tv,SWIN);
h = gca;
set(h,'YLim',[-20 150],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'LGR2 Clim: ';'Shortwave Upwelling'})
set_figure_name(SiteID)
ylabel('(W m^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SWOUT
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(tv,SWOUT);
h = gca;
set(h,'YLim',[-20 600],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'LGR2 Clim: ';'Shortwave Downwelling'})
set_figure_name(SiteID)
ylabel('(W m^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Net radiation
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(tv,Rn);
h = gca;
set(h,'YLim',[-200 400],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'LGR2 Clim: ';'Net radiation'})
set_figure_name(SiteID)
ylabel('(W m^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% SHFP_3cm
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, SHFP_3cm_North,'r',...
     tv, SHFP_3cm_Middle,'b',...
     tv, SHFP_3cm_South, 'k');
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[-100 100])
title({'LGR2 Clim: ';'Soil heat flux'});
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('North','Middle','South') 

%-----------------------------------------------
% Soil Moisture (Volumetric water content)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, Soil_Moisture_3cm,'r',...
     tv, Soil_Moisture_20cm,'b',...
     tv, Soil_Moisture_60cm, 'k');
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 0.35])
title({'LGR2 Clim: ';'Volumetric water content'});
set_figure_name(SiteID)
ylabel('(m^3/m^3)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('3cm','20cm','60cm') 

%-----------------------------------------------
% Soil Temperature
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, Soil_T_5cm,'r',...
     tv, Soil_T_20cm,'b',...
     tv, Soil_T_60cm, 'k');
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 20])
title({'LGR2 Clim: ';'Soil temperature'});
set_figure_name(SiteID)
ylabel('(\circC)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('5cm','20cm','60cm') 

%-----------------------------------------------
% Wind Direction and GHG Concentration
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
subplot(3,1,1)
plot(Gill_wdir, CO2_IRGA, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[300 500])
title({'Eddy Covariance: ';'Concentration vs Wind direction'});
set_figure_name(SiteID)
ylabel('CO_2 \mumol m^{-2} s^{-1}');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on

subplot(3,1,2)
plot(Gill_wdir, N2Od_LGR, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[0.1 0.4])
ylabel('N_2O \mumol m^{-2} s^{-1}');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on;

subplot(3,1,3)
plot(Gill_wdir, CH4d_LGR, 'o')
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[1 4])
ylabel('CH_4 \mumol m^{-2} s^{-1}');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
grid on;

%-----------------------------------------------
% WindRose
%-----------------------------------------------
[h,count,speeds,directions,Table] = WindRose(Gill_wdir,means(:,1),'anglenorth',0,'angleeast',90,'freqlabelangle',45); %#ok<*NASGU>
title({'LGR2 Clim: ';'Wind Rose'});
set_figure_name(SiteID)


childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=1:N
    if i < 200 
        figure(i);
%        if i ~= childn(N-1)                
            pause;    
%        end
    end
end  


function set_figure_name(SiteID)
     title_string = get(get(gca,'title'),'string');
%     set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'number','off')
