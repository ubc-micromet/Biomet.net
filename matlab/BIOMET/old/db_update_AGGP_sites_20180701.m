function db_update_AGGP_sites(yearIn,sites)
% renames AGGP logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array containing site suffixes)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created: Sep 27, 2017        last modified: Sep 27, 2017 (Zoran)
%

% function based on db_update_mpb_sites for the new Alberta hybrid poplar sites

% Revisions:
%
% Jan 26, 2018 (Zoran)
%   - corrected bug where the progress list for the Clim logger was the
%   same as for the Temp logger.  Added "_Clim" to the clim list.  This bug
%   was not causing any issues but I thought I should correct it because it
%   was distracting when program was being troubleshooted.


dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'LGR1'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)

        % Progress list for LGR1_Hut_Temp (CR1000) logger
        eval(['progressList' char(sites(j)) '_30min_Pth = fullfile(pth_db,''' char(sites(j))...
            '_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        % Progress list for LGR1_AGGP_Clim (CR3000) logger
        eval(['progressList' char(sites(j)) '_30min_Pth2 = fullfile(pth_db,''' char(sites(j))...
            '_30min_progressList_' num2str(yearIn(k)) '_Clim.mat'');']);
        eval([char(sites(j)) 'ClimatDatabase_Pth = [pth_db ''yyyy\' char(sites(j))...
            '\Climate\''];']);
                
        filePath = sprintf('d:\\sites\\%s\\CSI_net\\old\\',char(sites(j)));
         
        % move .DAT files from /old  to  old/yyyy  ; remove .DAT extension
        % and add date .yyyymmdd
        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile(filePath,num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt]);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
                    Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        % move .DAT files from csi_net  to  csi_net/old/yyyy  ; remove .DAT extension
        % and add date .yyyymmdd_a
        filePath = sprintf('d:\\sites\\%s\\CSI_net\\',char(sites(j)));        
        datFiles = dir(fullfile(filePath,'*.dat'));
        for i=1:length(datFiles)
            sourceFile      = fullfile(filePath,datFiles(i).name);
            destinationFile1 = fullfile(fullfile([filePath 'old\\'],num2str(yearIn(k))),[datFiles(i).name(1:end-3) fileExt '_a']);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
            if Status1 ~= 1
                uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
                    Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
            end %if
        end %i

        % lastly, move *.* files from csi_net  to  csi_net/old/yyyy
        % (those should be already in LGR1*.yyyymmdd format, renamed at the
        % site already)
        filePath = sprintf('d:\\sites\\%s\\CSI_net\\',char(sites(j)));        
        datFiles = dir(fullfile(filePath,'*.*'));
        for i=1:length(datFiles)
            if  ~datFiles(i).isdir 
                sourceFile      = fullfile(filePath,datFiles(i).name);
                destinationFile1 = fullfile(fullfile([filePath 'old\\'],num2str(yearIn(k))),datFiles(i).name);
                [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
                if Status1 ~= 1
                    uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
                        Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
                end %if
            end
        end %i
        
        switch char(sites(j))
            
            case 'LGR1'
                % Process LGR_Hut_Temp (CR1000) logger
                outputPath = fullfile(eval([char(sites(j)) 'ClimatDatabase_Pth']),'LGR1_Hut_Temp');
                eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                    '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Hut_Temp.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                    char(sites(j)) '_30min_Pth,outputPath,2);'])             
                eval(['disp(sprintf(''' char(sites(j)) ...
                    ' Hut_Temp:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

                % Process LGR_AGGP_Clim (CR3000) logger
                outputPath = fullfile(eval([char(sites(j)) 'ClimatDatabase_Pth']),'LGR1_AGGP_Clim');
                eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                    '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim_AGGP_Clim_30m.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                    char(sites(j)) '_30min_Pth2,outputPath,2);'])
                eval(['disp(sprintf(''' char(sites(j)) ...
                    ' AGGP_Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
                
        end % case
    end %j
    
end %k
