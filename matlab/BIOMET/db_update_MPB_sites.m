function db_update_MPB_sites(yearIn,sitenum)

% renames MPB logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sitenum (array containing any or all of 1, 2 or 3)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% 
% (c) Nick Grant        file created:   Oct 21, 2009        
%                       last modified:  Oct 15, 2022

% revisions:
%
% Oct 15, 2022 (Zoran)
%   - fixed a few bugs in paths and file names
% Oct 14, 2022 (Zoran)
%   - added processing of soil heatflux plates that were added on Oct 14,
%     2022 to EC logger.
%   - cleaned up some old comments and obsolete code
%
%   June 6, 2011
%       - added computation and db archiving of EC flux (Fc, H, LE, ustar)
%       calculation from raw logger covariances. These traces are useful
%       for e.g. gapfilling when HF data is lost (due to CF card format
%       errors).
%   June 2, 2010
%       - added extraction of covariance data and commented out db
%       extraction of flux calculations.  All daily flux files are now
%       extracted on Fluxnet02-- same procedure as the other flux sites.
%   Dec 14, 2009
%       - fixed an error with the parsing of the ClimatDatabase_Pth and
%         ECDatabase_Pth... wasn't using the /yyyy string so that
%         fr_site_met_database could not parse db pths for CSI files
%         containing data for two different years.
%   Oct 28, 2009 (Zoran)
%       - added flag for Eddy hhour data processing.  Default is OFF.
%         If flag is ON (~=0) then the program will run data base updates
%         on all files in hhour that match the yearIn and then moves each
%         file that it processes into ..\hhour\old folder
%


dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sitenum',[ 1 2 3]);
arg_default('do_eddy',0);

% Path used inside of eval statements
pth_db = db_pth_root; %#ok<NASGU>

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sitenum)              
        
        eval(['progressListMPB' num2str(sitenum(j)) '_30min_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['MPB' num2str(sitenum(j)) 'ClimatDatabase_Pth = [pth_db ''yyyy\mpb' num2str(sitenum(j))...
            '\Climate\''];']);
        eval(['progressListMPB' num2str(sitenum(j)) '_EC_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_EC_flux_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['MPB' num2str(sitenum(j)) 'ECDatabase_Pth = [pth_db ''yyyy\mpb'...
             num2str(sitenum(j)) '\Flux_Logger\''];']);

         % covariances pth and progress lists
        eval(['progressListMPB' num2str(sitenum(j)) '_ECcomp_cov_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_ECcomp_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['MPB' num2str(sitenum(j)) 'ECcompCov_Database_Pth = [pth_db ''yyyy\mpb'...
            num2str(sitenum(j)) '\Flux_Logger\''];']);
        
        eval(['progressListMPB' num2str(sitenum(j)) '_Tc_cov_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_Tc_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['MPB' num2str(sitenum(j)) 'TcCovDatabase_Pth = [pth_db ''yyyy\mpb'...
            num2str(sitenum(j)) '\Flux_Logger\''];']);
        
        eval(['progressListMPB' num2str(sitenum(j)) '_Ts_cov_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_Ts_Cov_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['MPB' num2str(sitenum(j)) 'TsCovDatabase_Pth = [pth_db ''yyyy\mpb'...
            num2str(sitenum(j)) '\Flux_Logger\''];']);
         
        eval(['progressListMPB' num2str(sitenum(j)) '_tblSHFP_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_tblSHFP_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(['MPB' num2str(sitenum(j)) 'tblSHFP_Pth = [pth_db ''yyyy\mpb'...
            num2str(sitenum(j)) '\Climate\SoilHeatflux\''];']);
       
        filePath = sprintf('d:\\sites\\MPB%d\\CSI_net\\old\\',sitenum(j));
       

        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt]);
            [Status1,Message1,~] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_Clim_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_30min_Pth,MPB' num2str(sitenum(j)) 'ClimatDatabase_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_Flux_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_EC_Pth,MPB' num2str(sitenum(j)) 'ECDatabase_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' EC:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

        % add the covariances for Andy
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_comp_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_ECcomp_cov_Pth,MPB' num2str(sitenum(j)) 'ECcompCov_Database_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' EC_comp_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_Tc_cov.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_Tc_cov_Pth,MPB' num2str(sitenum(j)) 'TcCovDatabase_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' Tc_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_Tscov.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_Ts_cov_Pth,MPB' num2str(sitenum(j)) 'TsCovDatabase_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' Ts_cov:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
 
        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_tblSHFP.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_tblSHFP_Pth,MPB' num2str(sitenum(j)) 'tblSHFP_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' tblSHFP:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
  
        % compute EC fluxes from raw covariances above and save to db
        
        siteId = ['MPB' num2str(sitenum(j))];
        if ismember(sitenum(j),[1 2 3])
           convert_raw_logger_covariances_to_fluxes(yearIn,siteId);
        end
        
   
    end %j 
    
end %k
