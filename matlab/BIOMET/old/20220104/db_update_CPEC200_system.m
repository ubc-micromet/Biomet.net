function db_update_CPEC200_system(yearIn,sites);

% renames HP logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array containing site suffixes)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created: Dec 12, 2011        last modified: Dec 13, 2011
% (c) Nick Grant

% function based on db_update_mpb_sites for the new Alberta hybrid poplar sites

% revisions:
% Dec 12, 2011
%	-used file as a template for extracting data from CSI EC system test deployment at YF
% July 18, 2011
%   -added extractions for HP11 (extra "Flux" file for the LI-7200 containing mixing ratios (i.e. WPL-corrected))
% June 6, 2011
%   - added computation and db archiving of EC flux (Fc, H, LE, ustar)
%       calculation from raw logger covariances. These traces are useful
%       for e.g. gapfilling when HF data is lost (due to CF card format
%       errors).

dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'200'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)

        eval(['progressListCPEC' char(sites(j)) '_Cal_Pth = fullfile(pth_db,''CPEC' char(sites(j))...
            '_onlincal_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['CPEC' char(sites(j)) 'Cal_Pth = [pth_db ''yyyy\yf\CPEC200\onlincal\''];']);
        eval(['progressListCPEC' char(sites(j)) '_Flux_Pth = fullfile(pth_db,''CPEC' char(sites(j))...
            '_Flux_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['CPEC' char(sites(j)) 'Flux_Pth = [pth_db ''yyyy\yf\CPEC200\Flux_Logger\''];']);
        
       filePath = sprintf('d:\\sites\\YF\\CSI_net\\old\\');
       %filePath = sprintf('D:\\Nick\\UBC-Biomet\\db_2012\\CPEC_db'); % for testing on Nick's PC

        
        % move .DAT files from /old  to  old/yyyy  ; remove .DAT extension
        % and add date .yyyymmdd
        datFiles = dir(fullfile(filePath,'CPEC200*.*'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),datFiles(i).name);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        %for testing on Nick's PC
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick\UBC-Biomet\db_2012\CPEC_db\' num2str(yearIn(k)) '\CPEC' char(sites(j)) '_onlincal.' num2str(yearIn(k)) '*'',[],[],[],progressListCPEC' char(sites(j)) '_Cal_Pth,CPEC' char(sites(j)) 'Cal_Pth,2);'])
%         eval(['disp(sprintf(''CPEC' char(sites(j)) ' Cal:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick\UBC-Biomet\db_2012\CPEC_db\' num2str(yearIn(k)) '\CPEC' char(sites(j)) '_flux.' num2str(yearIn(k)) '*'',[],[],[],progressListCPEC' char(sites(j)) '_Flux_Pth,CPEC' char(sites(j)) 'Flux_Pth,2);'])
%         eval(['disp(sprintf(''CPEC' char(sites(j)) ' Flux:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
 
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\yf\CSI_net\old\' num2str(yearIn(k)) '\CPEC' char(sites(j)) '_onlincal.' num2str(yearIn(k)) '*'',[],[],[],progressListCPEC' char(sites(j)) '_Cal_Pth,CPEC' char(sites(j)) 'Cal_Pth,2);'])
        eval(['disp(sprintf(''CPEC' char(sites(j)) ' Cal:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\yf\CSI_net\old\' num2str(yearIn(k)) '\CPEC' char(sites(j)) '_flux.' num2str(yearIn(k)) '*'',[],[],[],progressListCPEC' char(sites(j)) '_Flux_Pth,CPEC' char(sites(j)) 'Flux_Pth,2);'])
        eval(['disp(sprintf(''CPEC' char(sites(j)) ' Flux:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        
        
%       
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_comp_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_ECcomp_cov_Pth,HP' char(sites(j)) 'ECcompCov_Database_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' EC_comp_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%         eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\HP' char(sites(j)) '\CSI_net\old\' num2str(yearIn(k)) '\hp' char(sites(j)) '_eddy_Tc_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListHP' char(sites(j)) '_Tc_cov_Pth,HP' char(sites(j)) 'TcCovDatabase_Pth,2);'])
%         eval(['disp(sprintf(''HP' char(sites(j)) ' Tc_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         

       % siteId = ['HP' char(sites(j))];
       % convert_raw_logger_covariances_to_fluxes(yearIn,siteId);
    
    end %j
    
end %k
