function db_update_FAIP_sites(yearIn,sites)
% renames FAIP logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array containing site suffixes)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created: Oct 5, 2015        last modified: Oct 19, 2016 (H.Jones)
% (c) Zoran

% function based on db_update_mpb_sites for the new Alberta hybrid poplar sites


dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites',{'FAIP_MC' 'FAIP_UBC_FARM' 'FAIP_UBC_MULCH' 'FAIP_CT' 'FAIP_UBC_Farm_PP'});

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)

        eval(['progressList' char(sites(j)) '_30min_Pth = fullfile(pth_db,''' char(sites(j))...
            '_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
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

        switch char(sites(j))
            
          case 'FAIP_MC'
              
            eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

            case  'FAIP_UBC_MULCH'
                
             eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
            
            case 'FAIP_CT'
                
             eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
           
         case  'FAIP_UBC_FARM'
            eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim_1.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim_1:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

            eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim_2.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim_2:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
            
        case  'FAIP_UBC_Farm_PP'
            eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim_1.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim_1:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

            eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' char(sites(j)) ...
                '\CSI_net\old\' num2str(yearIn(k)) '\' char(sites(j)) '_Clim_2.' num2str(yearIn(k)) '*'',[],[],[],progressList' ...
                char(sites(j)) '_30min_Pth,' char(sites(j)) 'ClimatDatabase_Pth,2);'])
            eval(['disp(sprintf(''' char(sites(j)) ...
                ' Clim_2:  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        end % case
    end %j
    
end %k
