function db_update_Shell_sites(yearIn,sites);

% renames Shell logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array)

% file created: Nov 25, 2010       last modified:  July 15, 2014
% (c) Nick Grant

% revisions:
%
%
dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'SQM'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)
        
        siteId = char(sites{j});
        eval(['progressListShell_' siteId '_Clim_30min_Pth = fullfile(pth_db,''' siteId ...
            '_Clim_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_ClimatDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Climate\''];']);
        eval(['progressListShell_' siteId '_EC_Pth = fullfile(pth_db,''' siteId ...
            '_EC_flux_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_ECDatabase_Pth = [pth_db ''\yyyy\' siteId...
              '\Flux_Logger\''];']);

         % covariances pth and progress lists
        eval(['progressListShell_' siteId '_ECcomp_cov_Pth = fullfile(pth_db,''' siteId ...
            '_ECcomp_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_ECcompCov_Database_Pth = [pth_db ''yyyy\' siteId...
             '\Flux_Logger\''];']);
        
        eval(['progressListShell_' siteId '_Tc_cov_Pth = fullfile(pth_db,''' siteId ...
            '_Tc_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_TcCovDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Flux_Logger\''];']);
        
        eval(['progressListShell_' siteId '_Ts_cov_Pth = fullfile(pth_db,''' siteId ...
            '_Ts_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['Shell_' siteId '_TsCovDatabase_Pth = [pth_db ''yyyy\' siteId...
            '\Flux_Logger\''];']);
         
         
        filePath = sprintf('d:\\sites\\%s\\CSI_net\\old\\',siteId);

        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt]);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_Clim_30m.*'',[],[],[],progressListShell_' siteId '_Clim_30min_Pth,Shell_' siteId '_ClimatDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Clim:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_flux_30m.*'',[],[],[],progressListShell_' siteId '_EC_Pth,Shell_' siteId '_ECDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s EC:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
       
	   % covariances
       
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_comp_cov.*'',[],[],[],progressListShell_' siteId '_ECcomp_cov_Pth,Shell_' siteId '_ECcompCov_Database_Pth,2);'])
        eval(['disp(sprintf('' %s EC_comp_cov:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
 
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_Tc_cov.*'',[],[],[],progressListShell_' siteId '_Tc_cov_Pth,Shell_' siteId '_TcCovDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Tc_cov:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
     
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(yearIn(k)) '\' siteId '_Tscov.*'',[],[],[],progressListShell_' siteId '_Ts_cov_Pth,Shell_' siteId '_TsCovDatabase_Pth,2);'])
        eval(['disp(sprintf('' %s Ts_cov:  Number of files processed = %d, Number of HHours = %d'',siteId,numOfFilesProcessed,numOfDataPointsProcessed))']);
        
		convert_raw_logger_covariances_to_fluxes(yearIn,siteId);
		
    end %j 
    
end %k
