function [] = eddy_pl_LGR(ind, year, SiteID, select)
%
% Revisions 
%  Sep 25, 2017 (Pat and Zoran)
%    - Started the program using eddy_pl_new as the starting point
%  Dec 12, 2017 (Pat)
%    - Added plots
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
    case 'OY'
        % load in climate variables
        % Find logger ini files
                                   % offset to convert GMT to PST
        [pthc] = biomet_path(year,'oy','cl');                % get the climate data path
        ini_climMain = fr_get_logger_ini('oy',year,[],'oy_clim1');   % main climate-logger array
        ini_clim2    = fr_get_logger_ini('oy',year,[],'oy_clim2');   % secondary climate-logger array

        ini_climMain = rmfield(ini_climMain,'LoggerName');
        ini_clim2    = rmfield(ini_clim2,'LoggerName');

        fileName = fr_logger_to_db_fileName(ini_climMain, '_tv', pthc);
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);

        Rn    = read_bor([fr_logger_to_db_fileName(ini_climMain, 'Rad2_3_AVG', pthc)],[],[],year,ind);
        Rn_new= read_bor([fr_logger_to_db_fileName(ini_climMain, 'Rad2_4_AVG', pthc)],[],[],year,ind);
        if year>=2004
            Rn= read_bor([pthc 'OY_ClimT\NetCNR_AVG'],[],[],year,ind);
        end

        SHFP3 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP3_AVG', pthc)],[],[],year,ind);
        SHFP4 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP4_AVG', pthc)],[],[],year,ind);
        SHFP5 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP5_AVG', pthc)],[],[],year,ind);
        SHFP6 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP6_AVG', pthc)],[],[],year,ind);
        G     = mean([SHFP3 SHFP4 SHFP5 SHFP6],2);
        RMYu  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_AVG', pthc)],[],[],year,ind);
        Pbar  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pthc)],[],[],year,ind);
        HMPT  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'HMP_temp_AVG', pthc)],[],[],year,ind);
        HMPRH = read_bor([fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_AVG', pthc)],[],[],year,ind);
        Pt_T  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pthc)],[],[],year,ind);
        co2_GH= read_bor([fr_logger_to_db_fileName(ini_climMain, 'GHco2_AVG', pthc)],[],[],year,ind);
       
        diagFlagIRGA = 6;
    case 'YF'
        [pthc] = biomet_path(year,'yf','cl');
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
        RMYu_dir  = read_bor(trace_path,[],[],year,ind);
        
        
        trace_path = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pthc));
        Pbar  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pthc));
        HMPT  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pthc));
        HMPRH = read_bor(trace_path,[],[],year,ind); HMPRH=100.*HMPRH;
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pthc));
        Pt_T  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'GH_co2_AVG', pthc));
		  co2_GH= read_bor(trace_path,[],[],year,ind);
        diagFlagIRGA = 7;
        
       

    case 'HJP02'
        pth = '\\PAOA001\SITES\HJP02\hhour\';
        ext         = '.hjp02.mat';
    case 'PA'
        pth = '\\PAOA001\SITES\PAOA\hhour\';
        ext         = '.hPA.mat';
        GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path(year,'PA'),'Flux\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
        
        pth_BERMS = fullfile(biomet_path(year,'PA'),'BERMS\al1');
%         RMYu  = read_bor(trace_path,[],[],year,ind);
%         
%         trace_path = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pthc));
%         Pbar  = read_bor(trace_path,[],[],year,ind);
%         
%         trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pthc));
%         HMPT  = read_bor(trace_path,[],[],year,ind);
%         
%         trace_path  = str2mat(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pthc));
%         HMPRH = read_bor(trace_path,[],[],year,ind);
%         
%         trace_path  = str2mat(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pthc));
%         Pt_T  = read_bor(trace_path,[],[],year,ind);
        
        if year<=2012
           RMYu  = read_bor(fullfile(pth_BERMS,'Wind_Spd_AbvCnpy_38m')); RMYu=RMYu(ind);
           RMYu_dir  = read_bor(fullfile(pth_BERMS,'Wind_Dir_AbvCnpy_38m')); RMYu_dir=RMYu_dir(ind);
           Pbar  = read_bor(fullfile(pth_BERMS,'Surf_Press')); Pbar=Pbar(ind);
           HMPT  = read_bor(fullfile(pth_BERMS,'Air_Temp_AbvCnpy_37m')); HMPT=HMPT(ind);
           HMPRH = read_bor(fullfile(pth_BERMS,'Rel_Hum_AbvCnpy_37m')); HMPRH=HMPRH(ind);
           Pt_T  = read_bor(fullfile(pth_BERMS,'MetOnePRTAir_Temp_AbvCnpy_36m')); Pt_T=Pt_T(ind);
           Rn = read_bor(fullfile(pth_BERMS,'Net_Rad_AbvCnpy_31m')); Rn=Rn(ind);
           G1 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_N_3cm_No1')); 
           G2 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_N_3cm_No2'));
           G3 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_N_3cm_No3'));
           G4 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_N_3cm_No4'));
           G  = mean([G1 G2 G3 G4 ],2); G=G(ind);
        else
           pth_BERMS = biomet_path(year,'PA','cl');
           RMYu  = read_bor(fullfile(pth_BERMS,'bonet_new\bntn.48')); RMYu=RMYu(ind);
           RMYu_dir  = read_bor(fullfile(pth_BERMS,'bonet_new\bntn.49')); RMYu_dir=RMYu_dir(ind);
           Pbar  = read_bor(fullfile(pth_BERMS,'PCCTRL2\pcct.5')); Pbar=Pbar(ind);
           HMPT  = read_bor(fullfile(pth_BERMS,'bonet_new\bntn.24')); HMPT=HMPT(ind);
           HMPRH = read_bor(fullfile(pth_BERMS,'bonet_new\bntn.29')); HMPRH=HMPRH(ind);
           Pt_T  = read_bor(fullfile(pth_BERMS,'bonet_new\bntn.37')); Pt_T=Pt_T(ind);
           %Rn = read_bor(fullfile(pth_BERMS,'Net_Rad_AbvCnpy_31m')); Rn=Rn(ind);
           swd = read_bor(fullfile(pth_BERMS,'OAN\OAN.9'));
           swu = read_bor(fullfile(pth_BERMS,'OAN\OAN.10'));
           lwd = read_bor(fullfile(pth_BERMS,'OAN\OAN.11'));
           lwu = read_bor(fullfile(pth_BERMS,'OAN\OAN.12'));
           Rn  = swd-swu + lwd-lwu; Rn=Rn(ind);
           G1 = read_bor(fullfile(pth_BERMS,'aessoil\soil.21')); 
           G2 = read_bor(fullfile(pth_BERMS,'aessoil\soil.22'));
           G3 = read_bor(fullfile(pth_BERMS,'aessoil\soil.23'));
           G4 = read_bor(fullfile(pth_BERMS,'aessoil\soil.24'));
           G  = mean([G1 G2 G3 G4 ],2); G=G(ind);
        end
        diagFlagIRGA = 7;
      case 'BS'
        pth = '\\PAOA001\SITES\PAOB\hhour\';
        ext         = '.hBS.mat';
        GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path(year,'BS'),'Flux\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
        
        if year<=2011
            pth_BERMS = fullfile(biomet_path(year,'BS'),'BERMS\al1');
            RMYu  = read_bor(fullfile(pth_BERMS,'Wind_Spd_AbvCnpy_26m')); RMYu=RMYu(ind);
            RMYu_dir  = read_bor(fullfile(pth_BERMS,'Wind_Dir_AbvCnpy_26m')); RMYu_dir=RMYu_dir(ind);
            Pbar  = read_bor(fullfile(pth_BERMS,'Surf_Press')); Pbar=Pbar(ind);
            HMPT  = read_bor(fullfile(pth_BERMS,'Air_Temp_AbvCnpy_25m')); HMPT=HMPT(ind);
            HMPRH = read_bor(fullfile(pth_BERMS,'Rel_Hum_AbvCnpy_25m')); HMPRH=HMPRH(ind);
            Pt_T  = read_bor(fullfile(pth_BERMS,'MetOnePRTAir_Temp_AbvCnpy_24m')); Pt_T=Pt_T(ind);
            Rn = read_bor(fullfile(pth_BERMS,'Net_Rad_AbvCnpy_20m')); Rn=Rn(ind);
            G1 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_NE_10cm_No1'));
            G2 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_NE_10cm_No2'));
            G3 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_NW_10cm_No1'));
            G4 = read_bor(fullfile(pth_BERMS,'Soil_HeatFlux_NW_10cm_No2'));
            G  = mean([G1 G2 G3 G4 ],2); G=G(ind);
        else
            pth_BERMS = biomet_path(year,'BS','cl');
            RMYu  = read_bor(fullfile(pth_BERMS,'BS_cr7_3\BS_3.51')); RMYu=RMYu(ind);
            RMYu_dir  = read_bor(fullfile(pth_BERMS,'BS_cr7_3\BS_3.52')); RMYu_dir=RMYu_dir(ind);
            Pbar  = read_bor(fullfile(pth_BERMS,'OBT\OBT.74')); Pbar=Pbar./10;Pbar=Pbar(ind);
            HMPT  = read_bor(fullfile(pth_BERMS,'BS_cr7_3\BS_3.22')); HMPT=HMPT(ind);
            HMPRH = read_bor(fullfile(pth_BERMS,'BS_cr7_3\BS_3.26')); HMPRH=HMPRH(ind);
            Pt_T  = read_bor(fullfile(pth_BERMS,'BS_cr7_3\BS_3.33')); Pt_T=Pt_T(ind);
            swd = read_bor(fullfile(pth_BERMS,'OBN\OBN.8'));
            swu = read_bor(fullfile(pth_BERMS,'OBN\OBN.9'));
            lwd = read_bor(fullfile(pth_BERMS,'OBN\OBN.12'));
            lwu = read_bor(fullfile(pth_BERMS,'OBN\OBN.13'));
            Rn  = swd-swu + lwd-lwu; Rn=Rn(ind);
            G1 = read_bor(fullfile(pth_BERMS,'OBT\OBT.54'));
            G2 = read_bor(fullfile(pth_BERMS,'OBT\OBT.55'));
            G3 = read_bor(fullfile(pth_BERMS,'OBT\OBT.56'));
            G4 = read_bor(fullfile(pth_BERMS,'OBT\OBT.57'));
            G  = mean([G1 G2 G3 G4 ],2); G=G(ind);
        end
        diagFlagIRGA = 7;
        
    case 'HDF11'
        [pthc] = biomet_path(year,'HDF11','cl');
        ini_climMain = fr_get_logger_ini('HDF11',year,[],'FR_Clim\fr_clim_105');   % main climate-logger array
		ini_clim2    = fr_get_logger_ini('HDF11',year,[],'FR_Clim\fr_clim_106');
        pth = '\\PAOA001\SITES\HDF11\hhour\';
        ext         = '.hHDF11.mat';
        GMTshift = -c.gmt_to_local;
        fileName = fullfile(biomet_path(year,'HDF11'),'Flux\clean_tv');
        tv       = read_bor(fileName,8);                       % get time vector from the data base

        tv  = tv - GMTshift;                                   % convert decimal time to
                                                       % decimal DOY local time

        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
        
         
        
%         Rn= read_bor([pthc 'OY_ClimT\NetCNR_AVG'],[],[],year,ind);
         
         T_CNR1 = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','cnr1_Temp_Avg'),[],[],year,ind);
         LongWaveOffset =(5.67E-8*(273.15+T_CNR1).^4);
         S_upper_AVG = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','swd_Avg'),[],[],year,ind);
         S_lower_AVG = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','swu_Avg'),[],[],year,ind);
         lwu = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','lwu_Avg'),[],[],year,ind);
         lwd = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','lwd_Avg'),[],[],year,ind);
         
         L_upper_AVG = lwd + LongWaveOffset;
         L_lower_AVG = lwu + LongWaveOffset;
         
         Rn = L_upper_AVG - L_lower_AVG  + S_upper_AVG - S_lower_AVG;
         
%          figure(99)
%          plot([L_upper_AVG L_lower_AVG  S_upper_AVG S_lower_AVG T_CNR1 ])
%          legend('L_upper_AVG','L_lower_AVG','S_upper_AVG','S_lower_AVG');
%          zoom on; pause;

          SHFP1 = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','Sheat_flux1_Avg'),[],[],year,ind);
          SHFP2 = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','Sheat_flux2_Avg'),[],[],year,ind);
          SHFP3 = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','Sheat_flux3_Avg'),[],[],year,ind);
          SHFP4 = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','Sheat_flux4_Avg'),[],[],year,ind);
%         SHFP4 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP4_AVG', pthc)],[],[],year,ind);
%         SHFP5 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP5_AVG', pthc)],[],[],year,ind);
%         SHFP6 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP6_AVG', pthc)],[],[],year,ind);
          G     = mean([SHFP1 SHFP2 SHFP3 SHFP4],2);
          
          % RMYoung is 3.5 m on the tall tower for now (May 6/11)
          % this should be changed
          RMYu  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'WSpd_3m_AVG', pthc)],[],[],year,ind);
          Pbar  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'Pbarometr_AVG', pthc)],[],[],year,ind);
          HMPT = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','HMP_T_Avg'),[],[],year,ind);
          HMPRH = read_bor(fullfile(biomet_path('yyyy','HDF11'),'Climate\FR_Clearcut','HMP_RH_Avg'),[],[],year,ind);
%         HMPT  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'HMP_temp_AVG', pthc)],[],[],year,ind);
%         HMPRH = read_bor([fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_AVG', pthc)],[],[],year,ind);

          % no Pt100 on HDF11 scaffold tower, use 2 m from Tall Tower
          Pt_T  = read_bor([fr_logger_to_db_fileName(ini_climMain, 'TC_2m_AVG', pthc)],[],[],year,ind);
%        
         diagFlagIRGA = 7;
         nMainEddy = 1;
        
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
        
         diagFlagIRGA = 7;
         nMainEddy = 1;

         % Load diagnostic climate data
         
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
        Rainfall_cum_clean = Rainfall_cum-1.3131;
        Rainfall_cum_clean(Rainfall_cum_clean<0) = 0;
        
        HMP_T = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Avg'),[],[],year,ind);
        HMP_T_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Min'),[],[],year,ind);
        HMP_T_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Max'),[],[],year,ind);
        HMP_T_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_T_Std'),[],[],year,ind);
        
        HMP_RH = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Avg'),[],[],year,ind);
        HMP_RH_min = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Min'),[],[],year,ind);
        HMP_RH_max = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Max'),[],[],year,ind);
        HMP_RH_std = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','HMP_RH_Std'),[],[],year,ind);
        
        %leaf_wet = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Leaf_R'),[],[],year,ind);
        %leaf_wet_hist = read_bor(fullfile(biomet_path('yyyy',SiteID),'Climate\LGR1_AGGP_Clim\','Leaf_R_Hst'),[],[],year,ind);
        
    otherwise
        error 'Wrong SiteID'
end

instrumentLI7000 = sprintf('Instrument(%d).',IRGAnum);
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
[means]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
maxAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Max');
minAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Min');
numOfSamplesEC = get_stats_field(StatsX,'MainEddy.MiscVariables.NumOfSamples');

[Gill_wdir]        = get_stats_field(StatsX,[instrumentGillR3 'MiscVariables.WindDirection']);
[WindDirection_Histogram] = get_stats_field(StatsX, [instrumentGillR3 'Misc.Variables.WindDirection_Histogram']);

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
    
% LI-7000 diagnostics
 
    [Tbench]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(3)']);
    [Tbench_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(3)']);
    [Tbench_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(3)']);

    [Plicor]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(4)']);
    [Plicor_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(4)']);
    [Plicor_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(4)']);
    
    [Pgauge]    = get_stats_field(StatsX,[instrumentLI7000 'Avg(5)']);
    [Pgauge_Min]= get_stats_field(StatsX,[instrumentLI7000 'Min(5)']);
    [Pgauge_Max]= get_stats_field(StatsX,[instrumentLI7000 'Max(5)']);
    
    [Dflag5]    = get_stats_field(StatsX,[instrumentGillR3 'Avg(5)']);
    [Dflag5_Min]= get_stats_field(StatsX,[instrumentGillR3 'Min(5)']);
    [Dflag5_Max]= get_stats_field(StatsX,[instrumentGillR3 'Max(5)']);
    
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
title({'Eddy Correlation: ';'Number of samples collected'});
set_figure_name(SiteID)
ylabel('n')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Sonic','IRGA','EC','LGR','location','northwest')

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
set(h,'XLim',[st ed+1],'YLim',[48 49])
title({'LGR: ';'T_{ambient}'});
set_figure_name(SiteID)
ylabel('LGR Ambient Temp (\circC)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% LGR Hut temperatures and Fan on time
%-----------------------------------------------
fig = fig+1;figure(fig);clf;

plotyy([tv], [T_Hut_fan, T_Hut_fan+T_Hut_fan_std, T_Hut_fan-T_Hut_fan_std], tv, Fan_Status, 'plot', 'bar');
grid on;
zoom on;
xlabel('DOY')
h = gca;
%set(h,'XLim',[st ed+1],'YLim',[10 35])
title({'LGR: ';'Hut Temperatures'});
%legend('LGR Fan outlet')
set_figure_name(SiteID)
ylabel('LGR Fan outlet (\circC)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

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
set(h,'XLim',[st ed+1],'YLim',[20 70])
title({'LGR: ';'Pump Temperatures'});
set_figure_name(SiteID)
ylabel('\circC')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('LGR Pump','','','LI7000 Pump','location','northwest') 

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
set(h,'XLim',[st ed+1],'YLim',[-5 30])
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
set(h,'XLim',[st ed+1],'YLim',[-0.07 -0.03])
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
set(h,'XLim',[st ed+1],'YLim',[44.5 45.5])
title({'LGR: ';'Gas Pressure_{Torr}'});
set_figure_name(SiteID)
ylabel('Torr')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Gas Pressure') 

%-----------------------------------------------
%  Tbench
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Tbench Tbench_Min Tbench_Max]);
grid on;zoom on;xlabel('DOY')
%h = gca;
%set(h,'XLim',[st ed+1], 'YLim',[-1 22])
title({'Eddy Correlation: ';'T_{bench}'});
set_figure_name(SiteID)
a = legend('av','min','max','location','northwest');
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
title({'Eddy Correlation: ';'Diagnostic Flag, GillR3, Channel 5'});
set_figure_name(SiteID)
a = legend('av','min','max' ,'location','northwest');
set(a,'visible','on');zoom on;
h = gca;
ylabel('?')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
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
title({'Eddy Correlation: ';'P_{Licor} '})
set_figure_name(SiteID)
a = legend('av','min','max','location','northwest');
set(a,'visible','on');zoom on;
h = gca;
ylabel('Pressure (kPa)')
zoom on;
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% CO_2 & H_2O delay times
%-----------------------------------------------
fig = fig+1;figure(fig);clf

if ~strcmp(SiteID,'YF')
  plot(t,Delays_calc(:,1:2),'o');
else
  plot(t,[-align_calc1 -align_calc2],'o');
end
if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2));
    set(h,'color','b','linewidth',1.5)
    h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2));
    set(h,'color','g','linewidth',1.5)
else
    if strcmp(upper(SiteID),'YF') % Nick added Oct 8, 2009
        h = line([t(1) t(end)],18*ones(1,2));
        set(h,'color','b','linewidth',1.5)
        h = line([t(1) t(end)],20*ones(1,2));
        set(h,'color','g','linewidth',1.5)
    end
end
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'CO_2 & H_2O delay times'})
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
title({'Eddy Correlation: ';'Delay times histogram'})
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
title({'Eddy Correlation: ';'LGR Delay times histograms'})
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
% Air temperatures (Gill and 0.001" Tc)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,means(:,[4]));   % ,tv,HMPT,tv,Pt_T,t,Tair_calc);
h = gca;
set(h,'XLim',[st ed+1],'YLim',Tax)

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Air Temperature (Sonic)'});
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
title({'Eddy Correlation: ';'Gill Wind Speed (After Rotation)'});
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
% Gill wind direction (after rotation)
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,Gill_wdir);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 360])
title({'Eddy correlation: ';'Wind Direction'});
set_figure_name(SiteID)
ylabel('\circ');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% Gill wind direction (after rotation)
%-----------------------------------------------
if ismember(SiteID,{'BS' 'PA' 'YF'})
    fig = fig+1;figure(fig);clf;
    plot(t,Gill_wdir,tv,RMYu_dir);
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[0 360])
    title({'Eddy correlation: ';'Wind Direction'});
    set_figure_name(SiteID)
    ylabel('\circ');
    if ~strcmp(SiteID,'HDF11')
        legend('Sonic','RMYoung')
    else
        legend('Sonic','Tall Tower 2m RMYoung')
    end
    zoom on;
end
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% Barometric pressure
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv,Pbar,t,Pbar_calc);
h = gca;
set(h,'XLim',[st ed+1],'YLim',[95 105])

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Barometric Pressure'})
set_figure_name(SiteID)
ylabel('Pressure (kPa)')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Pbar_{meas}','Pbar_{ECcalc}','location','northwest')

%-----------------------------------------------
% LI7000 CO2 dry umol/mol
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t, [CO2_IRGA CO2_IRGA+CO2_std_IRGA CO2_IRGA-CO2_std_IRGA])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[350 500])
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
set(h,'XLim',[st ed+1],'YLim',[1.75 3.5])
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
set(h,'XLim',[st ed+1],'YLim',[0 15])
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
set(h,'YLim',[-200 600],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Sensible Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Gill','CSAT',-1)
%legend('Gill',-1)

%-----------------------------------------------
% Latent heat
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(t,[Le Le_LGR]);
h = gca;
set(h,'YLim',[-20 150],'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'Latent Heat'})
set_figure_name(SiteID)
ylabel('(Wm^{-2})')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('LI-7000','LGR','location','northwest')

%-----------------------------------------------
% CO2 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(t,Fc);
h = gca;
set(h,'YLim',[-20 20],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_c'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% N2O flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(t,F_n2o);
h = gca;
set(h,'YLim',[-0.005 0.005],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_{n2o}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);


%-----------------------------------------------
% CH4 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
plot(t,F_ch4);
h = gca;
set(h,'YLim',[-0.1 0.1],'XLim',[st ed+1]);

grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'F_{ch4}'})
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

%-----------------------------------------------
% HMP Air Temp and Humidity
%-----------------------------------------------

fig = fig+1;figure(fig);clf;

[ax,h1,h2] = PLOTYY(tv,HMP_T, tv, HMP_RH);
set(get(ax(1), 'YLabel'), 'String', 'T \circC')
ylim(ax(1),[-5 20])
set(get(ax(2), 'YLabel'), 'String', 'RH %')
ylim(ax(2),[50 100])
xlim([st ed+1]);
grid on;zoom on;xlabel('DOY')
title({'Eddy Correlation: ';'HMP_{T} and HMP_{RH}'})
set_figure_name(SiteID)
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);

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
% Soil Tension
%-----------------------------------------------    
fig = fig+1;figure(fig);clf;    
plot(tv, [MPS_5 MPS_10 MPS_30 MPS_60])
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[-15 -5]);
title({'LGR: ';'Soil Tension'});
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
title({'LGR: ';'Soil Moisture'});
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
set(h,'XLim',[st ed+1],'YLim',[0 20]);
title({'LGR: ';'Soil Temperature'});
set_figure_name(SiteID)
ylabel('\circC')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Row_{5}', 'Row_{10}','Row_{30}','Row_{60}','Grass_{5}', 'Grass_{10}', 'Grass_{30}', 'Grass_{60}','location','northwest'); 

%-----------------------------------------------
% Energy Balance
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, Rn, t, H, t, Le, t, Le_LGR, tv, G, t, sum([H (sum([Le Le_LGR],2)/2)],2));
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[-50 100])
title({'LGR: ';'Energy Balance'});
set_figure_name(SiteID)
ylabel('W m^{-2} s^{-1}')
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('Rn','Sensible','Latent','Latent_LGR','Ground','Balance','location','northwest') 

%-----------------------------------------------
% PAR and SWD
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(tv, (PAR_in./4.6), tv, swd);
grid on;
zoom on;
xlabel('DOY')
h = gca;
set(h,'XLim',[st ed+1],'YLim',[0 250])
title({'LGR: ';'PAR and Rn'});
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
title({'LGR: ';'Rainfall'});
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
set(h,'YLim',[5 20])
title({'LGR: ';'Soil Water Tension'});
set_figure_name(SiteID)
ylabel('\psi')
xlim([0.2 0.7]);
legend('Row_{5}', 'Row_{10}','Row_{30}','Row_{60}', 'location','northwest') 

%-----------------------------------------------
% Wind Direction and GHG Concentration
%-----------------------------------------------
fig = fig+1;figure(fig);clf;
plot(Gill_wdir, CO2_IRGA, 'o', Gill_wdir, N2Od_LGR.*1000, 'o', Gill_wdir, CH4d_LGR.*100, 'o');
grid on;
zoom on;
xlabel('Degrees')
h = gca;
set(h,'XLim',[0 360],'YLim',[0 600])
title({'Eddy correlation: ';'Wind Direction'});
set_figure_name(SiteID)
ylabel('\mumol m^{-2} s^{-1}');
ax = axis; line([ed ed],ax(3:4),'color','y','linewidth',5);
legend('CO_{2}', 'N_{2}O', 'CH_{4}','location', 'northwest');

%-----------------------------------------------
% WindRose
%-----------------------------------------------
[h,count,speeds,directions,Table] = WindRose(Gill_wdir,means(:,1),'anglenorth',0,'angleeast',90,'freqlabelangle',45);
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
legend('Sonic','Pt100',-1)
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
    a = legend('av','min','max', -1);
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
    a = legend('av','min','max', -1);
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
    a = legend('T_{in} av','T_{in} min','T_{in} max','T_{out} avg','T_{out} min','T_{out} max', -1);
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
%     a = legend('T_{out} avg','T_{out} min','T_{out} max', -1);
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
    a = legend('av','min','max', -1);
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
    a = legend('av','min','max', -1);
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
    a = legend('av', -1);
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
    a = legend('av','min','max', -1);
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
    a = legend('av','min','max', -1);
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
    legend('LI-7000','LI-7200',-1)
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
