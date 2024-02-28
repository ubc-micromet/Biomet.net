function [numOfFilesProcessed,numOfDataPointsProcessed] = fr_EddyPro_database(wildCardPath,processProgressListPath,databasePath,time_shift,timeUnit,missingPointValue)
% fr_EddyPro_database - reads EddyPro full_output, _biomet_ or the summary files and puts data into data base
% 
% fr_EddyPro_database(wildCardPath,processProgressListPath,databasePath,time_shift,timeUnit,missingPointValue)
%
% Example:
% [nFiles,nHHours]=fr_EddyPro_database('d:\Sites\HH\SmartFlux\*_EP-Summary.txt', ...
%                                  '\\annex001\database\HH\2024\HH_EddyPro_progressList.mat','\\annex001\database\yyyy\');
%       This updates or creates data base under \\annex001\database folder.
%
%
%
% NOTE1:
%       databasePath needs to include "\yyyy\" string if multiple years of
%       data are going to be found in the wildCardPath folder!
% NOTE2:
%       To speed up reprocessing of multipe EddyPro files that are found in wildCardPath,
%       see if it can be changed to load up all the data first and 
%       only then run db_struct2database. Some careful error handling when appending Structures
%       to each other will be needed. Some fields may appear or disapear,...
%
% Inputs:
%       wildCardPath            - full SmartFlux summary file name, including path. Wild cards accepted
%       processProgressListPath - path where the progress list is kept
%       databasePath            - path to output location  (*** see the note1 above ***)
%       timeShift               - time offset to be added to the tv vector (in tv
%                                 units, 0 if datebase is in GMT)
%       timeUnit                -  minutes in the sample period (spacing between two
%                                  consecutive data points). Default '30min' (hhour)
%       missingPointValue       - Values that indicate missing data (default = NaN)
%
% Zoran Nesic                   File Created:      Feb  16, 2024
%                               Last modification: Feb  16, 2024

% Created based on fr_SmartFlux_database.m

%
% Revisions:
%


arg_default('time_shift',0);
arg_default('timeUnit','30MIN'); %
arg_default('missingPointValue',0); %   % default missing point code is 0

flagRefreshChan = 0;

h = dir(wildCardPath);
x = strfind(wildCardPath,filesep);
y = strfind(wildCardPath,'.*');

pth = wildCardPath(1:x(end));

if exist(processProgressListPath) %#ok<*EXIST> * do not use 'var' option  here. It does not work correctly
    load(processProgressListPath,'filesProcessProgressList');
else
    filesProcessProgressList = [];
end

filesToProcess = [];                %#ok<*NASGU> % list of files that have not been processed or
                                    % that have been modified since the last processing
indFilesToProcess = [];             % index of the file that needs to be process in the 
                                    % filesProcessProgressList
numOfFilesProcessed = 0;
numOfDataPointsProcessed = 0;
warning_state = warning;
warning('off') %#ok<*WNOFF>
hnd_wait = waitbar(0,'Updating database...');

for i=1:length(h)
    try 
        waitbar(i/length(h),hnd_wait,sprintf('Processing: %s ', [pth h(i).name]))
    catch  %#ok<*CTCH>
        waitbar(i/length(h),hnd_wait)
    end

    % Find the current file in the fileProcessProgressList
    j = findFileInProgressList(h(i).name, filesProcessProgressList);
    % if it doesn't exist add a new value
    if j > length(filesProcessProgressList)
        filesProcessProgressList(j).Name = h(i).name; %#ok<*AGROW>
        filesProcessProgressList(j).Modified = 0;      % datenum(h(i).date);
    end
    % if the file modification data change since the last processing then
    % reprocess it
    if filesProcessProgressList(j).Modified < datenum(h(i).date)
        try
            % when a file is found that hasn't been processed try
            % to load it. fr_read_EddyPro_file is able to read
            % full_output, _biomet_ and EP-Summary files
            fileName = fullfile(pth,h(i).name);
            [~, ~,tv,Stats] = fr_read_EddyPro_file(fileName);
            tv = tv + time_shift;
            structType = 1;
            db_struct2database(Stats,databasePath,0,[],timeUnit,missingPointValue,structType,1);         

            % if there is no errors update records
            numOfFilesProcessed = numOfFilesProcessed + 1;
            numOfDataPointsProcessed = numOfDataPointsProcessed + length(tv);
            filesProcessProgressList(j).Modified = datenum(h(i).date);

        catch ME
            fprintf(2,'\nError processing file: %s. \n',fileName);
            fprintf(2,'%s\n',ME.message);
            fprintf(2,'Error on line: %d in %s\n\n',ME.stack(1).line,ME.stack(1).file);
        end % of try

    end %  if filesProcessProgressList(j).Modified < datenum(h(i).date)
end % for i=1:length(h)
% Close progress bar
close(hnd_wait)
% Return warning state 
try  %#ok<TRYNC>
   for i = 1:length(warning_state)
      warning(warning_state(i).identifier,warning_state(i).state)
   end
end

save(processProgressListPath,'filesProcessProgressList')

% this function returns and index pointing to where fileName is in the 
% fileProcessProgressList.  If fileName doesn't exist in the list
% the output is list length + 1
function ind = findFileInProgressList(fileName, filesProcessProgressList)

    ind = [];
    for j = 1:length(filesProcessProgressList)
        if strcmp(fileName,filesProcessProgressList(j).Name)
            ind = j;
            break
        end %  if strcmp(fileName,filesProcessProgressList(j).Name)
    end % for j = 1:length(filesProcessProgressList)
    if isempty(ind)
        ind = length(filesProcessProgressList)+1;
    end 