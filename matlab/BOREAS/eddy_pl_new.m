function [] = eddy_pl_new(ind, year, SiteID, select)
%
% Revisions
%
%  Apr 24, 2021 (Z)
%   - fixed up bug where, when all the plots are selected, the pause
%   statement didn't cycle properly through all plots (it would just quit 
%   when any key was pressed)
%  Dec 30, 2020 (Z)
%   - Year for Rn_new2 (YF) was hardcoded to 2019. Fixed it to be yyyy.
%  May 24, 2020 (Z)
%   - uppercase/lowercase issues
%  Apr 17, 2020 (Z)
%   - cleaning up some syntax to get fewer of "orange" notitications in the
%   editor
%  May 6, 2018 (Z)
%   - skipped all plots with LI-7000 for >2018
%  June 2, 2015
%   -added wind direction comparison (sonic/RMY) for all surviving closed path sites:
%   BS, PA, YF (Nick)
%  Apr 26, 2012
%   -revisions to accomodate raw traces from BERMS MSC loggers.
%   -updated plot of H2O mixing ratio to correctly plot mixing ratio
%   calculated from HMP RH!
%   - YF RH gain set to 100 (RH range is from 0 to 1 from logger).
%  Oct 8, 2009
%   - added baseline delay times for YF to plot: [18 20] immediately
%   following filter change
%  Aug 31, 2009 (Zoran)
%   - Fixed a bug that caused the channel 5 of IRGA to be plotted
%     instead of Gill diagnostic flag.
%  Apr 6, 2009 (Zoran)
%   - cleaned up stuff so there is not much difference between OY and YF
%     plotting (made IRGAnum and SONICnum selection automatic and removed
%     some redundancies in the coding that this created)
%  Nov 2, 2007
%   -added delay times plots (Nick)
%  Oct 27, 2007
%   - added plotting of the number of samples collected by EC sensors
%     as well as the total number of points used by MainEddy
%  June 11, 2005
%   - changes to make it plot more than 6 days (zoran)
%
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

nMainEddy = 1;
IRGAnum = c.System(nMainEddy).Instrument(2);
SONICnum = c.System(nMainEddy).Instrument(1);


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
        
        SHFP3 = read_bor([fr_logger_to_db_fileName(ini_climMain, 'SHFP3_AVG', pthc)],[],[],year,ind); %#ok<*NBRAK>
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
        % From 2018 use System #2 (LI7200) as the main EC system
        if (st+startDate-1 >= datenum(2018,1,1,0,0,0))
            nMainEddy = 2;
            IRGAnum = c.System(nMainEddy).Instrument(2);
            SONICnum = c.System(nMainEddy).Instrument(1);
        end
        [pthc] = biomet_path(year,'yf','cl');
        ini_climMain = fr_get_logger_ini('yf',year,[],'yf_clim_60');   % main climate-logger array
        ini_clim2    = fr_get_logger_ini('yf',year,[],'yf_clim_61');   % secondary climate-logger array
        
        ini_climMain = rmfield(ini_climMain,'LoggerName');
        ini_clim2    = rmfield(ini_clim2,'LoggerName'); %#ok<*NASGU>
        
        fileName = fr_logger_to_db_fileName(ini_climMain, '_tv', pthc);
        tv       = read_bor(fileName,8);                       % get time vector from the data base
        
        tv  = tv - GMTshift;                                   % convert decimal time to
        % decimal DOY local time
        
        ind   = find( tv >= st & tv <= (ed +1));                    % extract the requested period
        tv    = tv(ind);
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'RAD_6_AVG', pthc));
        Rn = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'Net_cnr1_AVG', pthc));
        Rn_new = read_bor(trace_path,[],[],year,ind);
        if year>=2004
            Rn= Rn_new;
        end
        
        trace_path  = char('\\annex001\database\yyyy\Yf\Climate\YF_CR1000_1_MET_30\MET_CNR1_Net_Avg');
        Rn_new2 = read_bor(trace_path,[],[],year,ind);
        if year>=2018
            Rn= Rn_new2;
        end
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'SHFP1_AVG', pthc));
        SHFP1 = read_bor(trace_path,[],[],year,ind);
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'SHFP2_AVG', pthc));
        SHFP2 = read_bor(trace_path,[],[],year,ind);
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'SHFP3_AVG', pthc));
        SHFP3 = read_bor(trace_path,[],[],year,ind);
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'SHFP4_AVG', pthc));
        SHFP4 = read_bor(trace_path,[],[],year,ind);
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'SHFP5_AVG', pthc));
        SHFP5 = read_bor(trace_path,[],[],year,ind);
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'SHFP6_AVG', pthc));
        SHFP6 = read_bor(trace_path,[],[],year,ind);
        G     = mean([SHFP1 SHFP2 SHFP3 SHFP4 SHFP5 SHFP6],2);
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'WindSpeed_AVG', pthc));
        RMYu  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'WindDir_DU_WVT', pthc));
        RMYu_dir  = read_bor(trace_path,[],[],year,ind);
        
        
        trace_path = char(fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pthc));
        Pbar  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pthc));
        HMPT  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = char(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pthc));
        HMPRH = read_bor(trace_path,[],[],year,ind); HMPRH=100.*HMPRH;
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pthc));
        Pt_T  = read_bor(trace_path,[],[],year,ind);
        
        trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'GH_co2_AVG', pthc));
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
        %         trace_path = char(fr_logger_to_db_fileName(ini_climMain, 'Pbar_AVG', pthc));
        %         Pbar  = read_bor(trace_path,[],[],year,ind);
        %
        %         trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'HMP_T_1_AVG', pthc));
        %         HMPT  = read_bor(trace_path,[],[],year,ind);
        %
        %         trace_path  = char(  fr_logger_to_db_fileName(ini_climMain, 'HMP_RH_1_AVG', pthc));
        %         HMPRH = read_bor(trace_path,[],[],year,ind);
        %
        %         trace_path  = char(fr_logger_to_db_fileName(ini_climMain, 'Pt_1001_AVG', pthc));
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
        
    otherwise
        error 'Wrong SiteID'
end

instrumentString = sprintf('Instrument(%d).',IRGAnum);
sonicString =  sprintf('Instrument(%d).',SONICnum);

StatsX = [];
t      = [];
for i = 1:days
    
    filename_p = fr_DateToFileName(currentDate+.03);
    filename   = filename_p(1:6);
    
    pth_filename_ext = [pth filename ext];
    if ~exist([pth filename ext],'file')
        pth_filename_ext = [pth filename 's' ext];
    end
    
    if exist(pth_filename_ext,'file')
        try
            load(pth_filename_ext); %#ok<*LOAD>
            if i == 1
                StatsX = [Stats];
                t      = [currentDate+1/48:1/48:currentDate+1];
            else
                StatsX = [StatsX Stats]; %#ok<*AGROW>
                t      = [t currentDate+1/48:1/48:currentDate+1];
            end
            
        catch ME
            disp(ME.message);
        end
    end
    currentDate = currentDate + 1;
    
end

t        = t - GMTshift; %PST time
[C,IA,IB] = intersect(datestr(tv),datestr(t),'rows'); %#ok<*ASGLU>

%[Fc,Le,H,means,eta,theta,beta] = ugly_loop(StatsX);
[Fc]        = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
[Le]        = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
[H]         = get_stats_field(StatsX,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
[means]     = get_stats_field(StatsX,'MainEddy.Three_Rotations.Avg');
maxAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Max');
minAll      = get_stats_field(StatsX,'MainEddy.Three_Rotations.Min');
numOfSamplesEC = get_stats_field(StatsX,'MainEddy.MiscVariables.NumOfSamples');
align_calc1 = get_stats_field(StatsX,['MainEddy.MiscVariables.' instrumentString 'Alignment.del1']);
align_calc2 = get_stats_field(StatsX,['MainEddy.MiscVariables.' instrumentString 'Alignment.del2']);
Delays_calc       = get_stats_field(StatsX,'MainEddy.Delays.Calculated');
Delays_set        = get_stats_field(StatsX,'MainEddy.Delays.Implemented');

if strcmpi(SiteID,'YF') & st>=datenum(2015,7,9,18,0,0) %#ok<*AND2>
    encIRGAnum = c.System(2).Instrument(2);
    CSATnum    = c.System(2).Instrument(1);
    encIRGAString = sprintf('Instrument(%d).',encIRGAnum);
    CSATstring    =  sprintf('Instrument(%d).',CSATnum);
    [Fc_enc]        = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
    [Le_enc]        = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.AvgDtr.Fluxes.LE_L');
    [H_enc]         = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
    [means_enc]     = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.Avg');
    [std_enc]     = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.Std');
    maxAll_enc      = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.Max');
    minAll_enc      = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.Min');
    numOfSamplesEC_enc = get_stats_field(StatsX,'EnclosedPathEddy.MiscVariables.NumOfSamples');
    ustar          = get_stats_field(StatsX,'EnclosedPathEddy.Three_Rotations.AvgDtr.Fluxes.Ustar');
    
    [Dflag5_CSAT]    = get_stats_field(StatsX,[CSATstring 'Avg(5)']);
    [Dflag5_CSAT_Min]= get_stats_field(StatsX,[CSATstring 'Min(5)']);
    [Dflag5_CSAT_Max]= get_stats_field(StatsX,[CSATstring 'Max(5)']);
    
    diagFlag_encIRGA = 9;
    [Dflag6_encIRGA]    = get_stats_field(StatsX,[encIRGAString 'Avg(' num2str(diagFlag_encIRGA) ')']);
    [Dflag6_encIRGA_Min]= get_stats_field(StatsX,[encIRGAString 'Min(' num2str(diagFlag_encIRGA) ')']);
    [Dflag6_encIRGA_Max]= get_stats_field(StatsX,[encIRGAString 'Max(' num2str(diagFlag_encIRGA) ')']);
    
    [Tbench_in]    = get_stats_field(StatsX,[encIRGAString 'Avg(3)']);
    [Tbench_in_Min]= get_stats_field(StatsX,[encIRGAString 'Min(3)']);
    [Tbench_in_Max]= get_stats_field(StatsX,[encIRGAString 'Max(3)']);
    
    [Tbench_out]    = get_stats_field(StatsX,[encIRGAString 'Avg(4)']);
    [Tbench_out_Min]= get_stats_field(StatsX,[encIRGAString 'Min(4)']);
    [Tbench_out_Max]= get_stats_field(StatsX,[encIRGAString 'Max(4)']);
    
    [Ptot]    = get_stats_field(StatsX,[encIRGAString 'Avg(5)']);
    [Ptot_Min]= get_stats_field(StatsX,[encIRGAString 'Min(5)']);
    [Ptot_Max]= get_stats_field(StatsX,[encIRGAString 'Max(5)']);
    
    [Phead]    = get_stats_field(StatsX,[encIRGAString 'Avg(6)']);
    [Phead_Min]= get_stats_field(StatsX,[encIRGAString 'Min(6)']);
    [Phead_Max]= get_stats_field(StatsX,[encIRGAString 'Max(6)']);
    
    [SigStrenght]    = get_stats_field(StatsX,[encIRGAString 'Avg(7)']);
    
    [FlowDrv]    = get_stats_field(StatsX,[encIRGAString 'Avg(8)']);
    [FlowDrv_Min]= get_stats_field(StatsX,[encIRGAString 'Min(8)']);
    [FlowDrv_Max]= get_stats_field(StatsX,[encIRGAString 'Max(8)']);
    
    [FlowRate]    = get_stats_field(StatsX,[encIRGAString 'Avg(10)']);
    [FlowRate_Min]= get_stats_field(StatsX,[encIRGAString 'Min(10)']);
    [FlowRate_Max]= get_stats_field(StatsX,[encIRGAString 'Max(10)']);
    
    
    numOfSamples_encIRGA = get_stats_field(StatsX, [encIRGAString 'MiscVariables.NumOfSamples']);
    numOfSamples_CSAT = get_stats_field(StatsX,[CSATstring 'MiscVariables.NumOfSamples']);

    align_calc1 = get_stats_field(StatsX,['EnclosedPathEddy.MiscVariables.' instrumentString 'Alignment.del1']);
    align_calc2 = get_stats_field(StatsX,['EnclosedPathEddy.MiscVariables.' instrumentString 'Alignment.del2']);

    Delays_calc       = get_stats_field(StatsX,'EnclosedPathEddy.Delays.Calculated');
    Delays_set        = get_stats_field(StatsX,'EnclosedPathEddy.Delays.Implemented');
    
end

[Gill_wdir]        = get_stats_field(StatsX,[sonicString 'MiscVariables.WindDirection']);


% air temperature and pressure used in eddy flux calculations (Jan 25,
% 2010)
[Tair_calc]        = get_stats_field(StatsX,'MiscVariables.Tair');
[Pbar_calc]        = get_stats_field(StatsX,'MiscVariables.BarometricP');
%

[Tbench]    = get_stats_field(StatsX,[instrumentString 'Avg(3)']);
[Tbench_Min]= get_stats_field(StatsX,[instrumentString 'Min(3)']);
[Tbench_Max]= get_stats_field(StatsX,[instrumentString 'Max(3)']);

[Plicor]    = get_stats_field(StatsX,[instrumentString 'Avg(4)']);
[Plicor_Min]= get_stats_field(StatsX,[instrumentString 'Min(4)']);
[Plicor_Max]= get_stats_field(StatsX,[instrumentString 'Max(4)']);

[Pgauge]    = get_stats_field(StatsX,[instrumentString 'Avg(5)']);
[Pgauge_Min]= get_stats_field(StatsX,[instrumentString 'Min(5)']);
[Pgauge_Max]= get_stats_field(StatsX,[instrumentString 'Max(5)']);

[Dflag5]    = get_stats_field(StatsX,[sonicString 'Avg(5)']);
[Dflag5_Min]= get_stats_field(StatsX,[sonicString 'Min(5)']);
[Dflag5_Max]= get_stats_field(StatsX,[sonicString 'Max(5)']);

[Dflag6]    = get_stats_field(StatsX,[instrumentString 'Avg(' num2str(diagFlagIRGA) ')']);
[Dflag6_Min]= get_stats_field(StatsX,[instrumentString 'Min(' num2str(diagFlagIRGA) ')']);
[Dflag6_Max]= get_stats_field(StatsX,[instrumentString 'Max(' num2str(diagFlagIRGA) ')']);

irgaAlignCh = eval(['c.' instrumentString 'Alignment.ChanNum']);
irgaAlignChName = eval(['c.' instrumentString 'ChanNames(' num2str(irgaAlignCh) ')']);
sonicAlignCh = eval(['c.' sonicString 'Alignment.ChanNum']);
sonicAlignChName = eval(['c.' sonicString 'ChanNames(' num2str(sonicAlignCh) ')']);

[irgaAlCh_Avg]    = get_stats_field(StatsX,[instrumentString 'Avg(' num2str(irgaAlignCh) ')' ]);
[sonicAlCh_Avg]    = get_stats_field(StatsX,[sonicString 'Avg(' num2str(sonicAlignCh) ')' ]);


numOfSamplesIRGA = get_stats_field(StatsX, [instrumentString 'MiscVariables.NumOfSamples']);
numOfSamplesSonic = get_stats_field(StatsX,[sonicString 'MiscVariables.NumOfSamples']);



%figures
if now > datenum(year,4,15) & now < datenum(year,11,1)
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

% Skip  GillR3/LI-7000 plotting in 2018
if ~(strcmpi(SiteID,'YF') & st+startDate-1 >= datenum(2018,1,1,0,0,0))
    
    %-----------------------------------------------
    % Number of samples collected
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,numOfSamplesSonic,t,numOfSamplesIRGA,t,numOfSamplesEC);
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[35800 36800])
    title({'Eddy Correlation: ';'Number of samples collected'});
    set_figure_name(SiteID)
    ylabel('1')
    legend('Sonic','IRGA','EC')
    
    %-----------------------------------------------
    % Gill wind speed (after rotation)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,means(:,[1]),tv,RMYu);
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[0 10])
    title({'Eddy Correlation: ';'Gill Wind Speed (After Rotation)'});
    set_figure_name(SiteID)
    ylabel('U (m/s)')
    if ~strcmp(SiteID,'HDF11')
        legend('Sonic','RMYoung')
    else
        legend('Sonic','Tall Tower 2m RMYoung')
    end
    zoom on;
    
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
    
    %-----------------------------------------------
    % Air temperatures (Gill and 0.001" Tc)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,means(:,[4]),tv,HMPT,tv,Pt_T,t,Tair_calc);
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',Tax)
    
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'Air Temperatures (Sonic, HMP, Pt-100, EC-calc)'});
    set_figure_name(SiteID)
    ylabel('Temperature (\circC)')
    if ~strcmp(SiteID,'HDF11')
        legend('Sonic','HMP','Pt100','usedinfluxcalc','location','northeastoutside');
    else
        legend('Sonic','HMP','Tall Tower 2m Tc','usedinfluxcalc','location','northeastoutside');
    end
    zoom on;
    
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
    legend('Sonic','Pt100','location','northeastoutside');
    zoom on;
    
    %-----------------------------------------------
    % Barometric pressure
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(tv,Pbar,t,Pbar_calc);
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[90 102])
    
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'Barometric Pressure'})
    set_figure_name(SiteID)
    ylabel('Pressure (kPa)')
    legend('Pbar_{meas}','Pbar_{ECcalc}')
    
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
    a = legend('av','min','max','location','northeastoutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Temperature (\circC)')
    zoom on;
    
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
    a = legend('av','min','max','location','northeastoutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('?')
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
    a = legend('av','min','max','location','northeastoutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('?')
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
    a = legend('av','min','max','location','northeastoutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Pressure (kPa)')
    zoom on;
    
    %-----------------------------------------------
    %  Pgauge
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    
    plot(t,[Pgauge Pgauge_Min Pgauge_Max]);
    grid on;zoom on;xlabel('DOY')
    %h = gca;
    %set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation: ';'P_{gauge} '})
    set_figure_name(SiteID)
    a = legend('av','min','max','location','northeastoutside');
    set(a,'visible','on');zoom on;
    h = gca;
    ylabel('Pressure (kPa)')
    zoom on;
    
    
    %-----------------------------------------------
    % H_2O (mmol/mol of dry air)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    [e_H,ea_H] = vappress(HMPT, HMPRH);
    % Nick 4/26/12
    %tmp = (0.61365*exp((17.502*HMPT)./(240.97+HMPT)));  %HMP vapour pressure
    %HMP_mixratio = (1000.*tmp.*HMPRH)./(Pbar-HMPRH.*tmp); %mixing ratio
    HMP_mixratio = (1000.*e_H)./(Pbar-e_H); %mixing ratio
    
    plot(t,[means(:,[6]) maxAll(:,6) minAll(:,6)],tv,HMP_mixratio);
    grid on;zoom on;xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1], 'YLim',[-1 22])
    title({'Eddy Correlation: ';'H_2O '})
    set_figure_name(SiteID)
    ylabel('(mmol mol^{-1} of dry air)')
    
    legend('IRGA_{avg}','IRGA_{max}','IRGA_{min}','HMP','location','northeastoutside');
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
        
end
 

if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    
    maxAll_enc = NaN*zeros(length(maxAll),6);
    minAll_enc = NaN*zeros(length(maxAll),6);
    maxAll = NaN*zeros(length(maxAll),6);
    minAll = NaN*zeros(length(maxAll),6);
    means = NaN*zeros(length(maxAll),6);
    
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
    % Gill wind speed (after rotation)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    plot(t,means_enc(:,[1]),tv,RMYu);
    grid on;
    zoom on;
    xlabel('DOY')
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[0 10])
    title({'Eddy Correlation: ';'Gill Wind Speed (After Rotation)'});
    set_figure_name(SiteID)
    ylabel('U (m/s)')
    if ~strcmp(SiteID,'HDF11')
        legend('Sonic','RMYoung')
    else
        legend('Sonic','Tall Tower 2m RMYoung')
    end
    zoom on;
    
    %-----------------------------------------------
    % Gill wind direction (after rotation)
    %-----------------------------------------------
    if ismember(SiteID,{'BS' 'PA' 'YF'})
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
        zoom on;
    end
    
    %-----------------------------------------------
    % Ustar and sigma_w (after rotation)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    sigma_w = (std_enc(:,3));
    plot(t,[ustar sigma_w]);
    h = gca;
    set(h,'XLim',[st ed+1],'YLim',[0 1])
    grid on;zoom on;xlabel('DOY')
    title({'Eddy covariance: ';'Friction Velocity and \sigma_w'});
    set_figure_name(SiteID)
    ylabel('m/s');
    legend('ustar','\sigma_w');
    zoom on;

    %-----------------------------------------------
    % Ustar : sigma_w 1:1 (after rotation)
    %-----------------------------------------------
    fig = fig+1;figure(fig);clf;
    sigma_w = (std_enc(:,3));
    plot(ustar,sigma_w,'o');
    h = gca;
    %set(h,'XLim',[st ed+1],'YLim',[0 1])
    grid on;zoom on;xlabel('DOY')
    title({'Eddy covariance: ';'Friction Velocity and \sigma_w'});
    set_figure_name(SiteID)
    xlabel('ustar')
    ylabel('\sigma_w');
    zoom on;
    
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
    a = legend('av','min','max','location','northeastoutside');
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
    a = legend('av','min','max','location','northeastoutside');
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
    a = legend('T_{in} av','T_{in} min','T_{in} max','T_{out} avg','T_{out} min','T_{out} max','location','northeastoutside');
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
    %     a = legend('T_{out} avg','T_{out} min','T_{out} max','location','northeastoutside');
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
    a = legend('av','min','max','location','northeastoutside');
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
    a = legend('av','min','max','location','northeastoutside');
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
    a = legend('av','location','northeastoutside');
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
    a = legend('av','min','max','location','northeastoutside');
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
    a = legend('av','min','max','location','northeastoutside');
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

%===========================================
    %-----------------------------------------------
    % CO_2 & H_2O delay times
    %
    fig = fig+1;figure(fig);clf
    
    if ~strcmp(SiteID,'YF') | (strcmp(SiteID,'YF') & (st+startDate-1 >= datenum(2018,1,1,0,0,0))) %#ok<*OR2>
        plot(t,Delays_calc(:,1:2),'o');
    else
        plot(t,[-align_calc1 -align_calc2],'o');
    end
    if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
        h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2));
        set(h,'color','y','linewidth',1.5)
        h = line([t(1) t(end)],c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2));
        set(h,'color','m','linewidth',1.5)
    else
        if strcmpi(SiteID,'YF') % Nick added Oct 8, 2009
            h = line([t(1) t(end)],18*ones(1,2));
            set(h,'color','y','linewidth',1.5)
            h = line([t(1) t(end)],20*ones(1,2));
            set(h,'color','m','linewidth',1.5)
        end
    end
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'CO_2 & H_2O delay times'})
    set_figure_name(SiteID)
    ylabel('Samples')
    legend('CO_2','H_2O','CO_2 setup','H_2O setup','location','northeastoutside');
    if ~strcmp(SiteID,'YF')
        legend('CO_2','H_2O','CO_2 setup','H_2O setup','location','northeastoutside');
    else
        legend('align1','align2','location','northeastoutside');
    end
    
    %-----------------------------------------------
    % Delay Times (histogram)
    %-----------------------------------------------
    
    fig = fig+1;figure(fig);clf;
    subplot(2,1,1); hist(Delays_calc(:,1),200); %#ok<*HIST>
    if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
        ax=axis;
        h = line(c.Instrument(IRGAnum).Delays.Samples(1)*ones(1,2),ax(3:4));
        set(h,'color','y','linewidth',2)
    else
        if strcmpi(SiteID,'YF') % Nick added Oct 8, 2009
            ax=axis;
            h = line(18*ones(1,2),ax(3:4));
            set(h,'color','y','linewidth',2)
        end
    end
    ylabel('CO_2 delay times')
    subplot(2,1,2); hist(Delays_calc(:,2),200);
    if  ~isempty(c.Instrument(IRGAnum).Delays.Samples)
        ax=axis;
        h = line(c.Instrument(IRGAnum).Delays.Samples(2)*ones(1,2),ax(3:4));
        set(h,'color','y','linewidth',2)
    else
        if strcmpi(SiteID,'YF') % Nick added Oct 8, 2009
            ax=axis;
            h = line(20*ones(1,2),ax(3:4));
            set(h,'color','y','linewidth',2)
        end
    end
    title({'Eddy Correlation: ';'Delay times histogram'})
    set_figure_name(SiteID)
    ylabel('H_{2}O delay times')
%    zoom_together(gcf,'x','on')
%=====================================================



%-----------------------------------------------
% CO2 flux
%-----------------------------------------------

fig = fig+1;figure(fig);clf;
if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    plot(t,[Fc Fc_enc]);
    h = gca;
    set(h,'YLim',[-20 20],'XLim',[st ed+1]);
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'F_c'})
    set_figure_name(SiteID)
    ylabel('\mumol m^{-2} s^{-1}')
    legend('LI-7000','LI-7200','location','northeastoutside');
else
    plot(t,Fc);
    h = gca;
    set(h,'YLim',[-20 20],'XLim',[st ed+1]);
    
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'F_c'})
    set_figure_name(SiteID)
    ylabel('\mumol m^{-2} s^{-1}')
end



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

if ~(strcmpi(SiteID,'YF') & st+startDate-1 >= datenum(2018,1,1,0,0,0))
    %-----------------------------------------------
    % H_2O (mmol/mol of dry air) vs. HMP
    %
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
end
%-----------------------------------------------
% Sensible heat
%

fig = fig+1;figure(fig);clf;
if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    plot(t,[H H_enc]);
    h = gca;
    set(h,'YLim',[-200 600],'XLim',[st ed+1]);
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'Sensible Heat'})
    set_figure_name(SiteID)
    ylabel('(Wm^{-2})')
    legend('Gill','CSAT','location','northeastoutside');
    %legend('Gill','location','northeastoutside');
else
    plot(t,H);
    h = gca;
    set(h,'YLim',[-200 600],'XLim',[st ed+1]);
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'Sensible Heat'})
    set_figure_name(SiteID)
    ylabel('(Wm^{-2})')
    %legend('Gill','Tc1','Tc2','location','northeastoutside');
    legend('Gill','location','northeastoutside');
end

%-----------------------------------------------
% Latent heat
%
fig = fig+1;figure(fig);clf;
if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    plot(t,[Le Le_enc]);
    h = gca;
    set(h,'YLim',[-10 400],'XLim',[st ed+1]);
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'Latent Heat'})
    set_figure_name(SiteID)
    ylabel('(Wm^{-2})')
    legend('LI-7000','LI-7200','location','northeastoutside');
else
    plot(t,Le);
    h = gca;
    set(h,'YLim',[-10 400],'XLim',[st ed+1]);
    grid on;zoom on;xlabel('DOY')
    title({'Eddy Correlation: ';'Latent Heat'})
    set_figure_name(SiteID)
    ylabel('(Wm^{-2})')
end
%-----------------------------------------------
% Energy budget components
%
fig = fig+1;figure(fig);clf;
if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    plot(tv,Rn,t,Le_enc,t,H_enc,tv,G);
    ylabel('W/m2');
    title({'Eddy Correlation: ';'Energy budget'});
    set_figure_name(SiteID)
    legend('Rn','LE','H','G');
else
    plot(tv,Rn,t,Le,t,H,tv,G);
    ylabel('W/m2');
    title({'Eddy Correlation: ';'Energy budget'});
    set_figure_name(SiteID)
    legend('Rn','LE','H','G');
end
    
h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')

fig = fig+1;figure(fig);clf;
if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    plot(tv,Rn-G,t,H_enc+Le_enc);
    xlabel('DOY');
    ylabel('W m^{-2}');
    title({'Eddy Correlation: ';'Energy budget'});
    set_figure_name(SiteID)
    legend('Rn-G','H+LE');
else
    plot(tv,Rn-G,t,H+Le);
    xlabel('DOY');
    ylabel('W m^{-2}');
    title({'Eddy Correlation: ';'Energy budget'});
    set_figure_name(SiteID)
    legend('Rn-G','H+LE');
end

h = gca;
set(h,'YLim',EBax,'XLim',[st ed+1]);
grid on;zoom on;xlabel('DOY')

if strcmpi(SiteID,'YF') & datenum(year,1,st)>=datenum(2015,7,9,18,0,0)
    A = Rn-G;
    T = H_enc+Le_enc;
else
    A = Rn-G;
    T = H+Le;
end
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
for i=1:N

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
    try
        eval(['tmp = Stats(i).' field ';']);
        if length(size(tmp)) > 2
            [m,n] = size(squeeze(tmp));
            
            if m == 1
                x(i,:) = squeeze(tmp);
            else
                x(i,:) = squeeze(tmp)';
            end
        else
            [m,n] = size(tmp);
            if m == 1
                x(i,:) = tmp;
            else
                x(i,:) = tmp';
            end
        end
        
    catch 
        x(i,:) = NaN; 
    end
    try
        eval(['tv(i) = Stats(i).TimeVector;']); 
    catch 
        tv(i) = NaN; 
    end
end


function set_figure_name(SiteID)
title_string = get(get(gca,'title'),'string');
set(gcf,'Name',[ SiteID ': ' char(title_string(2))],'numbertitle','off')
