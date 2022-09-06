% This is a sample script to run from xx_init_all to create a database of important climate
% traces at each site.  The script will not run if database_path points to
% \\annex001 to avoid overwriting of the third stage cleaned data
% This help can be used in addition to fr_site_met_database.m's help lines
% to clarify its use.

% the fr_site_met_database will create all the necessary folders, work
% through multiple years of data stored in one of more files in pthIn as
% long as 'yyyy' parameter is used when calling the biomet_path function.
% Channel names should be chosen to match whatever Biomet uses in the third
% stage cleaning to enable us to run re-calculations at home as well as at
% the sites.  File specified under pthProgressList needs to be deleted if
% re-run of al pthIn files is needed otherwise only the files whose
% modification data change since the last run will be processed.  At the
% site the biomet_database_default_path.m should look like this:
% --------------- start --------------------------
% function pthDatabase = biomet_database_default()
%     pthDatabase = 'd:\met-data\Database';
% --------------- end ----------------------------
% If that is not the case and biomet_database_default_path is missing the
% biomet_path() call below may not return the right (desired) path!
%
pthOut = biomet_path('yyyy','cr','HIGH_LEVEL');
if findstr(pthOut,'\\annex001') | findstr(pthOut,'y:\')
    error('Cannot write to Biomet main data base!')
end    
pthIn = 'd:\met-data\csi_net\fr_clim1.*';
%pthIn = 'Z:\Sites\CR\CSI_net\old\fr_clim1.*';
pthProgressList = 'd:\met-data\Database\fr_clim_progressList.mat';
channelsIn = [23 28 53 77 78 45];
channelNames = {'wind_speed_cup_main','wind_direction_main','barometric_pressure_main', ...
                'air_temperature_main','relative_humidity_main','precipitation'};
TableID = 105;

[nFiles,nHHours]=fr_site_met_database(pthIn,channelsIn,channelNames,TableID,pthProgressList,pthOut);
