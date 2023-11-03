function Biomet_Main_Scheduler
    %% Main script for all Matlab scheduled tasks
    % It runs every 10 minutes (at 2,12,22,32,42,52 min)from the Windows scheduler and
    % parses the tasks that need to be done.
    %
    % Each individual task is inside of a try-catch-end structure. Each task
    % adds to the report file.
    %


    [yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(now); %#ok<*ASGLU>

    % Start with the tasks that run most often

    fid = 1;  % for testing print logs on screen only

    % at 2 minutes and 32
    fprintf(fid,'================================\n');

    if minuteX == 2 || minuteX == 32
        Process_Climate_Station(fid);
        % If this is the first run in a new day then date-stamp the raw
        % file from the previous day
        if minuteX==2 && hourX == 0
            ClimateStation_movefile;
        end
    else
    end
end

%%
function Process_Climate_Station(fid)
    fprintf(fid,'======= Climate Station ========\n');
    try
        % Copy files from Sync.com folder. Force overwriting.
        [Success,Msg,MsgID] = copyfile('d:\Sites\Sync\Sync\ClimateStation_to_UBC\ubraw.dat',...
                                       'D:\SITES\ubc\CSI_NET\ubraw.dat',...
                                       'f');
        if ~Success
            fprintf('%s\n',Msg);
        end
        % Move CONFLICT files from Sync.com folder. Give them unique names
        sConflictFiles = dir('d:\Sites\Sync\Sync\ClimateStation_to_UBC\ubraw-CONFLICT*.dat');
        for cntFiles = 1:length(sConflictFiles)
            fileName = sConflictFiles(cntFiles).name;
            filePath = 'D:\Sites\ubc\CSI_NET';
            destinationPath = 'D:\SITES\ubc\CSI_NET\OLD';
            fileExt = datestr(now,30);
            fileExt = fileExt(1:8);

            sourceFile       = fullfile(filePath,fileName);
            destinationFile1 = fullfile(destinationPath,[fileName(1:end-3) fileExt]);
            [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
        end
         D:\SITES\ubc\CSI_NET\. 
        
        
        

    catch
        fprintf(fid,'Error while processing climate station data');
    end    
    % Copy climate station data
end
%%


% 
%     
%     
%     
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