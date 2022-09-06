function fr_ON_GR_DataBase(wildCard,progressListFileName)
[dataPth, hhourPth, pthOut] = FR_get_local_path;
pthOut = fullfile(pthOut,'2005\ON_GR\clean\ThirdStage');
if findstr(pthOut,'\\annex001') | findstr(pthOut,'y:\')
    error('Cannot write to Biomet main data base!')
end    
ind = findstr(pthOut,'\');
pthIn = fullfile(pthOut(1:ind(end-4)),'csi_net\',wildCard);
%pthIn = 'Z:\Sites\CR\CSI_net\old\fr_clim1.*';
pthProgressList = fullfile(pthOut,progressListFileName);
channelsIn = [34 59 60]-1;
%channelNames = {'wind_speed_cup_main','wind_direction_main','barometric_pressure_main', ...
%                'air_temperature_main','relative_humidity_main','precipitation'};
channelNames = {'barometric_pressure_main', 'rho_v',...
                        'air_temperature_main'};
TableID = [];

[nFiles,nHHours]=fr_site_met_database(pthIn,channelsIn,channelNames,TableID,pthProgressList,pthOut,2);
