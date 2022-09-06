%% Main script for all Matlab scheduled tasks
% It runs every 10 minutes (at 2,12,22,32,42,52 min)from the Windows scheduler and
% parses the tasks that need to be done.
%
% Each individual task is inside of a try-catch-end structure. Each task
% adds to the report file.
%


[yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(now);

% Start with the tasks that run most often

% at 2 minutes and 32
fprintf('================================\n');

if minuteX == 2 || minuteX == 32
    fprintf('======= Climate Station ========\n');
    % Climate station
    % Convert csv to database
    try
each system() run should call a batch file that"
  - deletes semaphor file
  - runs a program
  - creates semaphor file
Matlab runs the batch file and then waits until it either time outs or it sees 
the semaphor file appear. If the timeout happens first - that's an error. If
the semaphor file appers first, than the processing was OK.
  
        fprintf('%s Climate station: converting csv to database... ',datestr(now));
        [status,result] = system('"C:\Ubc_flux\dbase_update\UseMatlabToRunDbase_update-bat.lnk"');
        if status == 0
            fprintf(' Done (%s)\n',datestr(now));
        else
            fprintf(' Failed (%s)\n',datestr(now));
        end
    catch
        fprinf('Error:%s (%s)\n',result,datestr(now));
    end
    % Clean and export climate data
    try
        fprintf('%s Climate station: Cleaning and Exporting... ',datestr(now));
        db_clean_Totem;
        Export_Totem_One_Year;
        Export_for_Tin;
        fprintf(' Done (%s)\n',datestr(now));
    catch
        fprinf('Error:%s (%s)\n',result,datestr(now));
    end        
end

            
    