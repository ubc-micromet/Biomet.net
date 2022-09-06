function db_update_YF_met(yearIn,sites)
% renames YF_CR1000_met logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database
%
% user can input yearIn, sites (cellstr array containing site suffixes)
%
%                                       file created:  Mar 20, 2018        
%                                       last modified: Mar 20, 2018
%

% function based on db_update_mpb_sites for the new Alberta hybrid poplar sites

% Revisions:
%



dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'YF'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)

        % Progress list for YF_CR1000_1_MET_30 (CR1000) logger
        eval(['progressList' char(sites(j)) '_30min_Pth = fullfile(pth_db,''' char(sites(j))...
            '_CR1000_1_MET_30_progressList_' num2str(yearIn(k)) '.mat'');']);
        % Progress list for YF_CR1000_1_MET_30 (CR1000) logger
        eval(['progressList' char(sites(j)) '_RAW_Pth = fullfile(pth_db,''' char(sites(j))...
            '_CR1000_1_RAW_progressList_' num2str(yearIn(k)) '.mat'');']);
        
        % Climate database path
        eval([char(sites(j)) '_ClimateDatabase_Pth = [pth_db ''yyyy\' char(sites(j))...
            '\Climate\''];']);
        
        % move YF_CR1000_1_RAW.* files from csi_net/old  to  csi_net/old/yyyy
        % (those should be already in YF_CR1000_1_RAW).yyyymmdd format, renamed at the
        % site already)
        filePath = sprintf('d:\\sites\\%s\\CSI_net\\old\\',char(sites(j)));        
        datFiles = dir(fullfile(filePath,'YF_CR1000_1_RAW.*'));
        for i=1:length(datFiles)
            if  ~datFiles(i).isdir 
                sourceFile      = fullfile(filePath,datFiles(i).name);
                destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),datFiles(i).name);
                [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
                if Status1 ~= 1
                    uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
                        Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
                end %if
            end
        end %i
        
         % move YF_CR1000_1_MET_30.* files from csi_net/old  to  csi_net/old/yyyy
        % (those should be already in YF_CR1000_1_MET_#).yyyymmdd format, renamed at the
        % site already)
        datFiles = dir(fullfile(filePath,'YF_CR1000_1_MET_30.*'));
        for i=1:length(datFiles)
            if  ~datFiles(i).isdir 
                sourceFile      = fullfile(filePath,datFiles(i).name);
                destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),datFiles(i).name);
                [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
                if Status1 ~= 1
                    uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
                        Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
                end %if
            end
        end %i        
        
        switch char(sites(j))
            
            case 'YF'
                % Process YF_CR1000_1_MET_30 (CR1000) logger
                outputPath = fullfile(eval([char(sites(j)) '_ClimateDatabase_Pth']),'YF_CR1000_1_MET_30');
                eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                    '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_CR1000_1_MET_30.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                    char(sites(j)) '_30min_Pth,outputPath,2);'])             
                eval(['disp(sprintf(''' char(sites(j)) ...
                    ' YF_CR1000_1_MET_30:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
                % Process YF_CR1000_RAW data
                % *** ... ,outputPath,2,0,5) indicates 5 min data samples,
                % NOT the usual 30 min ****
                outputPath = fullfile(eval([char(sites(j)) '_ClimateDatabase_Pth']),'YF_CR1000_1_RAW');
                eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                    '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_CR1000_1_RAW.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                    char(sites(j)) '_RAW_Pth,outputPath,2,0,5);'])             
                eval(['disp(sprintf(''' char(sites(j)) ...
                    ' YF_CR1000_1_RAW:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
       

        end % case
    end %j
    
end %k
