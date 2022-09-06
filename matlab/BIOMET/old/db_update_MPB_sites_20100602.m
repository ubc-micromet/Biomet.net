function db_update_MPB_sites(yearIn,sitenum,fluxDbase);

% renames MPB logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sitenum (array containing any or all of 1, 2 or 3)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created: Oct 21, 2009        last modified: Oct 28, 2009
% (c) Nick Grant

% revisions:
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
dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sitenum',[ 1 2 3]);
arg_default('do_eddy',0);
arg_default('fluxDbase',0);

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sitenum)

        %disp(['progressListMPB' num2str(sitenum(j)) '_30min_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j)) '_30min_progressList_' num2str(yearIn(k)) '.mat'')']);
        eval(['progressListMPB' num2str(sitenum(j)) '_30min_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        %disp(['MPB' num2str(sitenum(j)) 'ClimatDatabase_Pth = [pth_db ''yyyy\mpb' num2str(sitenum(j)) '\Climate\'']']);
        eval(['MPB' num2str(sitenum(j)) 'ClimatDatabase_Pth = [pth_db ''yyyy\mpb' num2str(sitenum(j))...
            '\Climate\''];']);
        %disp(['progressListMPB' num2str(sitenum(j)) '_EC_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j)) '_EC_flux_30m_progressList_' num2str(yearIn(k)) '.mat'')']);
        eval(['progressListMPB' num2str(sitenum(j)) '_EC_Pth = fullfile(pth_db,''MPB' num2str(sitenum(j))...
            '_EC_flux_30m_progressList_' num2str(yearIn(k)) '.mat'');']);
        %disp(['MPB' num2str(sitenum(j)) 'ECDatabase_Pth = [pth_db ''yyyy\mpb' num2str(sitenum(j)) '\Flux_Logger\'']']);
        eval(['MPB' num2str(sitenum(j)) 'ECDatabase_Pth = [pth_db ''yyyy\mpb'...
             num2str(sitenum(j)) '\Flux_Logger\''];']);

       filePath = sprintf('d:\\sites\\MPB%d\\CSI_net\\old\\',sitenum(j));
       %filePath = sprintf('D:\\Nick_Share\\tmp_nick\\sites_tst\\MPB%d\\CSI_net\\old\\',sitenum(j)); % for testing on Nick's PC

        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt]);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_Clim_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_30min_Pth,MPB' num2str(sitenum(j)) 'ClimatDatabase_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

        eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''d:\sites\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_Flux_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_EC_Pth,MPB' num2str(sitenum(j)) 'ECDatabase_Pth,2);'])
        eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' EC:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

%           for testing on Nick's PC
%             eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_Clim_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_30min_Pth,MPB' num2str(sitenum(j)) 'ClimatDatabase_Pth,2);'])
%             eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%         
%             eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\Nick_Share\tmp_nick\sites_tst\MPB' num2str(sitenum(j)) '\CSI_net\old\' num2str(yearIn(k)) '\mpb' num2str(sitenum(j)) '_EC_Flux_30m.' num2str(yearIn(k)) '*'',[],[],[],progressListMPB' num2str(sitenum(j)) '_30min_Pth,MPB' num2str(sitenum(j)) 'ECDatabase_Pth,2);'])
%             eval(['disp(sprintf(''MPB' num2str(sitenum(j)) ' EC:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
%     
    end %j 
    
    if fluxDbase > 0
%        \\Fluxnet02\HFREQ_MPB1\MET-DATA\hhour
        ECfilePath = fullfile('\\Fluxnet02', ['HFREQ_MPB' num2str(sitenum(j))],'met-data\hhour')
        ECfilePathOld = fullfile(ECfilePath,'old')
        wildcardMAT = sprintf('%02d*.hmpb%d.mat',yearIn-2000,sitenum(j))
        dbECpath = fullfile(pth_db,num2str(yearIn),['MPB' num2str(sitenum(j))],'Flux\above_canopy')
        [k,StatsAll,dbFileNames, dbFieldNames] = db_new_eddy(ECfilePath,wildcardMAT,dbECpath);
%        movefile(fullfile(ECfilePath,'*.mat'),ECfilePathOld)  have no
%        write permission for Fluxnet02.
    end
end %k
