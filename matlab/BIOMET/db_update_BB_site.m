function db_update_BB_site(yearIn,sites,skipWebUpdates)
%
% NOTE: Pass sites as a cell array {'BB'}

% renames Burns Bog logger files, moves them from CSI_NET\old on PAOA001 to
% CSI_NET\old\yyyy, updates the annex001 database

% user can input yearIn, sites (cellstr array containing site suffixes)
% use do_eddy = 1, to turn on dbase updates using calculated daily flux
% files

% file created:  June 24, 2019        
% last modified: June  2, 2021 (Zoran)
%

% function based on db_update_HH_sites

% Revisions:
%
% June 2, 2021 (Zoran and Nick)
%   - modifications to make the program work for Manitoba sites.
% Nov 12, 2019 (Zoran)
%   - remove >> null from: dos('start /MIN C:\Ubc_flux\BiometFTPsite\BB_Web_Update.bat>>null');
%     It used to work when I used the old Matlab but it stopped now (Message "Access denied".  Must
%     be that the null file was being written somewhere where it shouldn't.
%     
% Nov  9, 2019 (Zoran)
%   - added BB2 site
% Oct 27, 2019 (Zoran)
%   - Added skipWebUpdates update flag that has to be set to 0 if user
%   wants to update the web page too. Used to speed up the debugging


dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites','BB');
arg_default('skipWebUpdates',1);   % skip web plot updates by default

missingPointValue = NaN;        % For BB sites we'll use NaN to indicate missing values (new feature since Oct 20, 2019)

% Add file renaming + copying to \\paoa001
pth_db = db_pth_root;

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

for k=1:length(yearIn)
    for j=1:length(sites)
        siteID = char(sites(j));
        fprintf('\n**** Processing Year: %d, Site: %s   *************\n',yearIn(k),siteID);
        
        % Progress list for BBx_MET (CR1000) logger
        cmdTMP = (['progressList' siteID '_30min_Pth = fullfile(pth_db,''' siteID...
            '_30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(cmdTMP);
        
        % Progress list for BBx_RAW (CR1000) logger
        cmdTMP = (['progressList' siteID '_RAW30min_Pth = fullfile(pth_db,''' siteID...
            '_RAW30min_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(cmdTMP);
        
        % Path to Climate Database: HHClimatDatabase_Pth
        if strcmp(siteID,'BB')
            % Special processing for 5-min BB site data files'
            cmdTMP = ([siteID 'ClimatDatabase_Pth = [pth_db ''yyyy\' siteID...
                '\Met\5min''];']);
        else
            cmdTMP = ([siteID 'ClimatDatabase_Pth = [pth_db ''yyyy\' siteID...
                '\Met''];']);
        end
        eval(cmdTMP);

        % Progress list for SmartFlux files: progressListHH_SmartFlux_Pth =
        % \\annex001\database\HH_SmartFlux_ProgressList
        cmdTMP = (['progressList' siteID '_SmartFlux_Pth = fullfile(pth_db,''' siteID...
            '_SmartFlux_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(cmdTMP);

        % Path to Flux Database: HHFluxDataBase_Pth
        cmdTMP = ([siteID 'FluxDatabase_Pth = [pth_db ''yyyy\' siteID...
            '\Flux\''];']);
        eval(cmdTMP);
             

        % Processing of MET data
        outputPath = fullfile(eval([siteID 'ClimatDatabase_Pth'])); %#ok<*NASGU>
        if strcmp(siteID,'BB')
            % Special processing for 5-min BB site data files'
            %=================================        
            % Process BB_MET (CR1000) logger
            % its table is updated in 5-minute intervals so I needed to add
            % "_30min_Pth,outputPath,2,0,5" to the end of cmdTMP (see below)
            % (Zoran 20190624)
            %=================================
            cmdTMP = (['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''p:\sites\' siteID ...
                '\MET\BB_MET.*''' ',[],[],[],progressList' ...
                siteID '_30min_Pth,outputPath,2,0,5,[],missingPointValue);']);
            eval(cmdTMP);
            eval(['disp(sprintf(''' siteID ...
                ' BB_MET:  Number of files processed = %d, Number of 5-minute periods = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
                    
            % convert 5-minute files into 30-min files
            foo = BB_5min_2_30min(yearIn(k), siteID);

        elseif strcmp(siteID,'BB2')
            cmdTMP = (['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''p:\sites\' siteID ...
                '\MET\' siteID '_MET.*''' ',[],[],[],progressList' ...
                siteID '_30min_Pth,outputPath,2,0,30,[],missingPointValue);']);
            eval(cmdTMP);
            eval(['disp(sprintf(''' siteID ...
                ' BB_MET:  Number of files processed = %d, Number of 30-minute periods = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
            
       elseif strcmp(siteID,'DSM')||strcmp(siteID,'RBM')
            % RAW Table
            cmdTMP = (['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''p:\sites\' siteID ...
                '\MET\' siteID '_RAW.*''' ',[],[],[],progressList' ...
                siteID '_RAW30min_Pth,outputPath,2,0,30,[],missingPointValue);']);
            eval(cmdTMP);
            eval(['disp(sprintf(''' siteID ...
                '_RAW:  Number of files processed = %d, Number of 30-minute periods = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
            % MET Table
            cmdTMP = (['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''p:\sites\' siteID ...
                '\MET\' siteID '_MET.*''' ',[],[],[],progressList' ...
                siteID '_30min_Pth,outputPath,2,0,30,[],missingPointValue);']);
            eval(cmdTMP);
            eval(['disp(sprintf(''' siteID ...
                '_MET:  Number of files processed = %d, Number of 30-minute periods = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);
        end

%         %=====================================
%         % Process SmartFlux EP-summary files 
%         %======================================
%         if strcmp(siteID,'BB')        
%             % First synchronize the old BB SmartFlux download folder with the 
%             % new one.
%             fprintf('Synchronizing vmicromet.geog.ubc.ca SmartFlux folder with P:\\Sites\\BB\\Flux folder ...'); 
%             dos('robocopy    \\vmicromet.geog.ubc.ca\sftptransfer\SmartFlux_Data  P:\Sites\BB\Flux /R:3 /W:10 /REG /NDL /NFL /NJH /log+:P:\Sites\Log_files\SmartFlux_sync.log');
%         else
%             % For all the other BB sites the data is already on this
%             % server.
%         end
        
        % Then process the new files
        outputPathStr = [siteID 'FluxDatabase_Pth'];
        eval(['outputPath = ' outputPathStr ';']);
        inputPath = ['p:\sites\' siteID '\Flux\' num2str(yearIn(k)) '*_EP-Summary*.txt'];
        cmdTMP = ['progressList = progressList' siteID '_SmartFlux_Pth;'];  
        eval(cmdTMP);
        [numOfFilesProcessed,numOfDataPointsProcessed]= fr_SmartFlux_database(inputPath,progressList,outputPath,[],[],missingPointValue);           
        fprintf('%s  HH_SmartFlux:  Number of files processed = %d, Number of HHours = %d\n',siteID,numOfFilesProcessed,numOfDataPointsProcessed);

    end %j  site counter
    
end %k   year counter

if skipWebUpdates ==0
    % create CSV files for the web server
    fprintf('\nWeb updates for all sites and all years...');
    tic;
    for j=1:length(sites)
        % make sure that a bug in one site processing does not crash all
        % updates. Do it one site at the time
        try
            BB_webupdate(sites(j),'P:\Micromet_web\www\webdata\resources\csv\');
        catch
        end
    end
    fprintf(' Finished in: %5.1f seconds.\n',toc);

    % Upload CSV files to the web server
    system('start /MIN C:\Ubc_flux\BiometFTPsite\BB_Web_Update.bat');
else
    fprintf('*** Web-plot update skipped. Use flag skipWebUpdates=0 to do the updates.\n\n');
end
