function db_update_HP_sites(yearIn,sites);

% renames HP logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array containing site suffixes)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created: June 1, 2010        last modified: June 1, 2010
% (c) Nick Grant

% function based on db_update_mpb_sites for the new Alberta hybrid poplar sites

% revisions:
% June 6, 2011
%   - added computation and db archiving of EC flux (Fc, H, LE, ustar)
%       calculation from raw logger covariances. These traces are useful
%       for e.g. gapfilling when HF data is lost (due to CF card format
%       errors).

dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'09'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)

        eval(['progressListHP' char(sites(j)) '_30min_Pth = fullfile(pth_db,''HP' char(sites(j))...
            '_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['HP' char(sites(j)) 'ClimatDatabase_Pth = [pth_db ''yyyy\hp' char(sites(j))...
            '\Climate\''];']);
        eval(['progressListHP' char(sites(j)) '_EC_Pth = fullfile(pth_db,''HP' char(sites(j))...
            '_EC_flux_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['HP' char(sites(j)) 'ECDatabase_Pth = [pth_db ''yyyy\hp'...
            char(sites(j)) '\Flux_Logger\''];']);
        
        % covariances pth and progress lists
        eval(['progressListHP' char(sites(j)) '_ECcomp_cov_Pth = fullfile(pth_db,''HP' char(sites(j))...
            '_ECcomp_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['HP' char(sites(j)) 'ECcompCov_Database_Pth = [pth_db ''yyyy\hp'...
            char(sites(j)) '\Flux_Logger\''];']);
        
        eval(['progressListHP' char(sites(j)) '_Tc_cov_Pth = fullfile(pth_db,''HP' char(sites(j))...
            '_Tc_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['HP' char(sites(j)) 'TcCovDatabase_Pth = [pth_db ''yyyy\hp'...
            char(sites(j)) '\Flux_Logger\''];']);
        
        eval(['progressListHP' char(sites(j)) '_Ts_cov_Pth = fullfile(pth_db,''HP' char(sites(j))...
            '_Ts_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['HP' char(sites(j)) 'TsCovDatabase_Pth = [pth_db ''yyyy\hp'...
            char(sites(j)) '\Flux_Logger\''];']);
        

       filePath = sprintf('d:\\sites\\HP%s\\CSI_net\\old\\',char(sites(j)));
        % filePath = sprintf('D:\\Nick_Share\\tmp_nick\\sites_tst\\HP%s\\CSI_net\\',char(sites(j))); % for testing on Nick's PC

        
        % move .DAT files from /old  to  old/yyyy  ; remove .DAT extension
        % and add date .yyyymmdd
        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt]);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        %for testing on Nick's PC
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_clim_Radiation.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_30min_Pth,HP' char(sites(j)) 'ClimatDatabase_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_flux_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_EC_Pth,HP' char(sites(j)) 'ECDatabase_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' EC_flux:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%         % add the covariances for Andy
%         
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_comp_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_ECcomp_cov_Pth,HP' char(sites(j)) 'ECcompCov_Database_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' EC_comp_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_Tc_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_Tc_cov_Pth,HP' char(sites(j)) 'TcCovDatabase_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' Tc_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_Tscov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_Ts_cov_Pth,HP' char(sites(j)) 'TsCovDatabase_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' Ts_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_clim_Radiation.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_30min_Pth,HP' char(sites(j)) 'ClimatDatabase_Pth,2);'])
        eval(['disp(sprintf(''HP' char(sites(j)) ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_flux_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_EC_Pth,HP' char(sites(j)) 'ECDatabase_Pth,2);'])
        eval(['disp(sprintf(''HP' char(sites(j)) ' EC_flux:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        % add the covariances for Andy
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_comp_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_ECcomp_cov_Pth,HP' char(sites(j)) 'ECcompCov_Database_Pth,2);'])
        eval(['disp(sprintf(''HP' char(sites(j)) ' EC_comp_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_Tc_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_Tc_cov_Pth,HP' char(sites(j)) 'TcCovDatabase_Pth,2);'])
        eval(['disp(sprintf(''HP' char(sites(j)) ' Tc_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_Tscov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_Ts_cov_Pth,HP' char(sites(j)) 'TsCovDatabase_Pth,2);'])
        eval(['disp(sprintf(''HP' char(sites(j)) ' Ts_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
    
        siteId = ['HP' char(sites(j))];
        convert_raw_logger_covariances_to_fluxes(yearIn,siteId);
    
    end %j
    
end %k
