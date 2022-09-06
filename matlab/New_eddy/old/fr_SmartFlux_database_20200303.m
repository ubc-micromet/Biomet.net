function [numOfFilesProcessed,numOfDataPointsProcessed] = fr_SmartFlux_database(wildCardPath,processProgressListPath,databasePath,time_shift,timeUnit)
% fr_SmartFlux_database - read SmartFlux summary files and create a Flux data base
% 
% fr_SmartFlux_database(wildCardPath,processProgressListPath,databasePath,time_shift,timeUnit)
%
% Example:
% [nFiles,nHHours]=fr_SmartFlux_database('d:\Sites\HH\SmartFlux\*_EP-Summary.txt', ...
%                                  '\\annex001\database\fr_clim_progressList.mat','\\annex001\database\yyyy\');
% Updates or Creates data base under \\annex001\database
%
% NOTE:
%       databasePath needs to include "\yyyy\" string if multiple years of
%       data are going to be found in the wildCardPath folder!
%
% Inputs:
%       wildCardPath - full SmartFlux summary file name, including path. Wild cards accepted
%       processProgressListPath - path where the progress list is kept
%       databasePath - path to output location  (*** see the note above ***)
%       timeShift    - time offset to be added to the tv vector (in tv
%                      units, 0 if datebase is in GMT)
%       timeUnit     -  minutes in the sample period (spacing between two
%                     consecutive data points). Default 30 (hhour)
%
% Zoran Nesic           File Created:      July 14, 2018
%                       Last modification: July 14, 2018

% Created based on fr_site_met_database

%
% Revisions:
%   Sep 27, 2017 (Zoran)
%       - moved data procesing to fr_read_TOA5_file()
%   Aug 18, 2009 (Nick)
%       -added timeUnit default value of 30
%   Aug 12, 2009 (Zoran)
%       - added timeUnit option to be passed to db_new_eddy (see
%       db_new_eddy for details)
%   Aug 4, 2005
%       - added fileType
%       - created arg_defaults for fileType and verbose_flag
%

arg_default('time_shift',0);
arg_default('timeUnit',30); %

flagRefreshChan = 0;

h = dir(wildCardPath);
x = strfind(wildCardPath,'\');
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
            % to load it using fr_read_SmartFlux_file
            [junk, junk,tv] = fr_read_SmartFlux_file(fullfile(pth,h(i).name),'caller','Stats');
            tv = tv + time_shift;
            
            % if there were no errors try to update database
            % Save data belonging to different years to different folders
            % if databasePath contains "\yyyy\" string (replace it with
            % \2005\ for year 2005)
            yearVector = datevec(tv);
            yearVector = yearVector(:,1);
            years = unique(yearVector)';
            if ~isempty(strfind(databasePath,'\yyyy\'))
                ind_yyyy = strfind(databasePath,'\yyyy\');
                databasePathNew = databasePath;
                for year_ind = years
                    one_year_ind = find(tv > datenum(year_ind,1,1) & tv <= datenum(year_ind+1,1,1));
                    databasePathNew(ind_yyyy+1:ind_yyyy+4) = num2str(year_ind);
                    [k] = db_new_eddy(Stats(one_year_ind),[],databasePathNew,0,[],timeUnit); %#ok<*FNDSB>
                end
            else
                [k] = db_new_eddy(Stats,[],databasePath,0,[],timeUnit);
            end
            % if there is no errors update records
            numOfFilesProcessed = numOfFilesProcessed + 1;
            numOfDataPointsProcessed = numOfDataPointsProcessed + length(tv);
            filesProcessProgressList(j).Modified = datenum(h(i).date);
        catch
            fprintf('Error in processing of: %s\n',fullfile(pth,h(i).name))
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
