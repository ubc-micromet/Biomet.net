function Biomet_Main_Scheduler
    %% Main script for all Matlab scheduled tasks
    % It runs every 10 minutes (at 2,12,22,32,42,52 min)from the Windows scheduler and
    % parses the tasks that need to be done.
    %
    % Each individual task is inside of a try-catch-end structure. Each task
    % adds to the report file.
    %

%% Missing tasks:
%   - update_annex001_db_and_clean (db_update_all(1,0))
%   - db_update_MPB_sites
%   - db_update_YF_met

%%

    [yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(now); %#ok<*ASGLU>

    % Start with the tasks that run most often

    fid = 1;  % for testing print logs on screen only
  
    fprintf(fid,'============== Biomet_Main_Scheduler.m ==================\n');
    fprintf(fid,'%s\n',datestr(now))
    
    %----------------------------------
    % Climate station data processing
    if minuteX == 2 || minuteX == 32
        % at 2 minutes and 32 minutes every hour
        % Process CR21x files
        Process_Climate_Station(fid);
        % Proces CR1000 files
        db_update_Totem(yearX)
        % Do only if the first run in that hour
        if minuteX==2 
            % Clean Totem data once per hourdb_
            % clean last and the current year
            fr_automated_cleaning(yearX-1:yearX,'UBC_Totem',[1 2 3 ]);
            Export_Totem_One_Year;
            Export_for_Tin;
            % If this is the first run in a new day then date-stamp the raw
            % file from the previous day
            if hourX == 0
                % Replaces a Task Scheduler task:
                % ClimateStation_daily_file_rename
                ClimateStation_movefile;
            end
        end
    elseif minuteX == 12 || minuteX == 42
        % move files from d:\Sites\TEMP folder to database Raw folders
        fprintf(fid,'======= Moving Sites\TEMP data to RAW (%s)========\n',datestr(now));
        [status,result] = system('"c:\ubc_flux\Move_CSI_net_files.exe c:\ubc_flux\Move_CSI_net_files.ini"');
        fprintf(fid,'======= End of Moving Sites\TEMP data (%s)========\n',datestr(now));
    end
    
    %------------------------
    % File unzipping for YF site
    if ismember(hourX,14:17) && minuteX == 2
        fprintf(fid,'======= Moving and Unzipping YF DailyZip files (%s) ========\n', datestr(now));
        [status,result] = system('"C:\Ubc_flux\Move_DailyZipFiles_from_Public_to_Sites.bat"');
        fprintf(fid,'------- Unzipping ... (%s) -------\n', datestr(now));
        % *** Note: UBC_ZIP.exe has a one minute wait period before it returns control to 
        %           Matlab. Use "&" to avoid waiting for it to return
        %           control to Matlab but be aware that the unzipping may
        %           not be finshed yet. Alternatively, bypass this program
        %           by writing a Matlab native version of UBC_ZIP.
        % ***           
        [status,result] = system('C:\Ubc_flux\UBC_ZIP.exe C:\Ubc_flux\ubc_unzip.ini &');
        fprintf(fid,'======= End of Moving and Unzipping (%s)    ========\n', datestr(now));
    end
    
    %--------------------------
    % Picarro data processing
    if hhourX == 1 && ismember(minuteX,[22 52]) ...
            || hhourX == 2 && ismember(minuteX,[22])
        fprintf(fid,'======= Picarro processing ========\n');
        [status,result] = system('"C:\Ubc_flux\Move_DailyZipFiles_from_Public_to_Sites.bat"');
        % *** Note: UBC_ZIP.exe has a one minute wait period before it returns control to 
        %           Matlab. Use "&" to avoid waiting for it to return
        %           control to Matlab but be aware that the unzipping may
        %           not be finshed yet. 
        %           In this case the proper thing to do is to wait for
        %           UBC_ZIP to finish 60s wait.
        % ***           
        [status,result] = system('C:\Ubc_flux\UBC_ZIP.exe C:\Ubc_flux\ubc_unzip.ini');        
        [status,result] = system('"C:\Ubc_flux\PicarroMove.bat"');
        process_Picarro_AGGP_data;
        fprintf(fid,'======= End of Picarro processing (%s) ========\n',datestr(now));
    end
    
    % ---------------------------
    % Morning db_update_all
    % 4:02am GMT
    % Replaces Task Scheduler task: update_annex001_db_and_clean
    if hhourX == 4 && ismember(minuteX,[2])
        fprintf(fid,'======= Morning db_update_all ========\n');
        db_update_all(1,0);
        fprintf(fid,'======= End of db_update_all processing (%s) ========\n',datestr(now));
    end
    
end

%%
function Process_Climate_Station(fid)
    fprintf(fid,'======= Climate Station (%s) ========\n',datestr(now));
    try        
        % Copy files from Sync.com folder. Force overwriting.
        % Replaces a Task Scheduler task: ClimateStation_Data_Copy
        filePath = 'd:\Sites\Sync\Sync\ClimateStation_to_UBC';
        destinationPath = 'D:\SITES\ubc\CSI_NET';
        [Success,Msg,MsgID] = copyfile(fullfile(filePath,'ubraw.dat'),...
                                       fullfile(destinationPath,'ubraw.dat'),...
                                       'f');
        if ~Success
            fprintf('%s\n',Msg);
        end
        % Move CONFLICT files from csi_net to csi_net\old folder. Give them unique names
        % using the file time stamp              
        sConflictFiles = dir(fullfile(filePath,'ubraw-CONFLICT*.dat'));
        for cntFiles = 1:length(sConflictFiles)
            fileName         = sConflictFiles(cntFiles).name;
            sourceFile       = fullfile(filePath,fileName);
            fileExt          = datestr(sConflictFiles(cntFiles).datenum,30);
            destinationFile1 = fullfile(destinationPath,[fileName(1:end-3) fileExt]);
            %[Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
        end
        if ~Status1
            fprintf('%s\n',Msg);
        end        
 
    catch
        fprintf(fid,'Error while processing climate station data');
    end    
    % Process climate station data. 
    % Replaces Task Scheduler event: dbase_update
    % Use a dummy Task Scheduler event called by a batch link below
    % C:\Windows\System32\schtasks.exe /RUN /TN "Biomet\Database_updates\Run dbase_update from Matlab"
    % This task looks like this: C:\Ubc_flux\dbase_update\dbase_update.exe c:\ubc_flux\dbase_update.ini
    % Running a Task Scheduler even is a workaround for Windows asking
    % about admin permissions to run this program
    fprintf(fid,'%s Climate station: converting csv to database... ',datestr(now));
    [status,result] = system('"C:\Ubc_flux\dbase_update\UseMatlabToRunDbase_update-bat.lnk"');
    fprintf(fid,'======= End of Climate Station processing (%s) ========\n',datestr(now));
end
%%


% Testing if dbase_update.exe is running:
%     status1,result1] = system('tasklist /FI "imagename eq dbase_update.exe" /fo table /nh')
% Return PID for the current Matlab session:
%     feature('getpid')
%     
%     try
% each system() run should call a batch file that"
%   - deletes semaphor file
%   - runs a program
%   - creates semaphor file
% Matlab runs the batch file and then waits until it either time outs or it sees 
% the semaphor file appear. If the timeout happens first - that's an error. If
% the semaphor file appers first, than the processing was OK.
%   
%         fprintf('%s Climate station: converting csv to database... ',datestr(now));
%         [status,result] = system('"C:\Ubc_flux\dbase_update\UseMatlabToRunDbase_update-bat.lnk"');
%         if status == 0
%             fprintf(' Done (%s)\n',datestr(now));
%         else
%             fprintf(' Failed (%s)\n',datestr(now));
%         end
%     catch
%         fprinf('Error:%s (%s)\n',result,datestr(now));
%     end
%     % Clean and export climate data
%     try
%         fprintf('%s Climate station: Cleaning and Exporting... ',datestr(now));
%         db_clean_Totem;
%         Export_Totem_One_Year;
%         Export_for_Tin;
%         fprintf(' Done (%s)\n',datestr(now));
%     catch
%         fprinf('Error:%s (%s)\n',result,datestr(now));
%     end        
% end
% 
%             
%     