function [numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(wildCardPath,chanInd,chanNames,tableID,processProgressListPath,databasePath,fileType,time_shift,timeUnit)
% fr_site_met_database - read CSI logger files and create a climate data base
% 
% fr_site_met_database(wildCardPath,chanInd,chanNames,processProgressListPath,databasePath)
%
% Example:
% [nFiles,nHHours]=fr_site_met_database('d:\met-data\csi_net\fr_clim1.*', ...
%                                  [23 28 53 77 78],{'WindSpeed','WindDirection','Pair','Tair','RH'},105, ...
%                                  'd:\met-data\Database\fr_clim_progressList.mat','d:\met-data\database\');
% Updates or Creates data base under d:\met-data\database\ by extracting 5
% [23 28 53 77 78] columns from fr_clim1.DOY logger files, TableID = 105 and storing them under names:
% {'WindSpeed','WindDirection','Pair','Tair','RH'}
%
% NOTE:
%       databasePath needs to include "\yyyy\" string if multiple years of
%       data are going to be found in the wildCardPath folder!
%
% Inputs:
%       wildCardPath - full file name including path. Wild cards accepted
%       chanInd      - channels to extract. [] extracts all
%       chanNames    - cell array of length = length(chanInd) with the
%                      channel (database file) names
%       tableID      - Table to be extracted
%       processProgressListPath - path where the progress list is kept
%       databasePath - path to output location  (*** see the note above ***)
%       timeUnit     -  minutes in the sample period (spacing between two
%                     consecutive data points). Default 30 (hhour)
%
% Zoran Nesic           File Created:      June 16, 2005
%                       Last modification: Sep  27, 2017

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

arg_default('fileType',0)
arg_default('verbose_flag',0)
arg_default('time_shift',0);
arg_default('chanInd',[]);
arg_default('chanNames',[]);
arg_default('timeUnit',30); %

flagRefreshChan = 0;

h = dir(wildCardPath);
x = findstr('\',wildCardPath);
y = findstr('.*',wildCardPath);
% find default file name in case user didn't supply channel names
if y > 0 & x > 0
    csi_name = [wildCardPath(x(end)+1:y-1) '_'];
else
    csi_name = 'c_';
end    
pth = wildCardPath(1:x(end));

if exist(processProgressListPath)
    load(processProgressListPath,'filesProcessProgressList');
else
    filesProcessProgressList = [];
end

filesToProcess = [];                % list of files that have not been processed or
                                    % that have been modified since the last processing
indFilesToProcess = [];             % index of the file that needs to be process in the 
                                    % filesProcessProgressList
numOfFilesProcessed = 0;
numOfDataPointsProcessed = 0;
warning_state = warning;
warning('off')
hnd_wait = waitbar(0,'Updating site database...');

for i=1:length(h)
    try 
        waitbar(i/length(h),hnd_wait,sprintf('Processing: %s ', [pth h(i).name]))
    catch 
        waitbar(i/length(h),hnd_wait)
    end

%    if verbose_flag,fprintf(1,'Checking: %s. ', [pth h(i).name]);end
    % Find the current file in the fileProcessProgressList
    j = findFileInProgressList(h(i).name, filesProcessProgressList);
    % if it doesn't exist add a new value
    if j > length(filesProcessProgressList)
        filesProcessProgressList(j).Name = h(i).name;
        filesProcessProgressList(j).Modified = 0;      % datenum(h(i).date);
    end
    % if the file modification data change since the last processing then
    % reprocess it
    if filesProcessProgressList(j).Modified < datenum(h(i).date)
        try
            % when a file is found that hasn't been processed try
            % to load it using fr_read_csi
            switch fileType
                case 1
                    [tv,climateData] = fr_read_csi(fullfile(pth,h(i).name),[],chanInd,tableID,0);
                case 2
                    [climateData,Header,tv] = fr_read_TOA5_file(fullfile(pth,h(i).name));
                    if ~isempty(chanInd) & flagRefreshChan == 0
                        climateData = climateData(:,chanInd);
                    else
                        chanInd = 1:length(Header.var_names);
                        flagRefreshChan = 1;
                    end
                    if isempty(chanNames) | flagRefreshChan == 1
                        chanNames = Header.var_names(chanInd);
                    end
                otherwise
                    fprintf(3,'Wrong file type in fr_site_met_database.m')
            end
            tv = tv + time_shift;
            % Create a data structure from a data matrix
            % First pre-alocate space for the output structure ClimateStats
            ClimateStats = [];
            for indChannels = 1:length(chanInd)
                if indChannels > length(chanNames)
                    % if more channels than names use default name
                    chName = [csi_name num2str(indChannels)];
                else
                    chName = char(chanNames(indChannels));
                end
                ClimateStats = setfield(ClimateStats,{size(climateData,1)},chName,[]);
            end
            
            % Cycle through every half hour and fill in the data
            hnd_wait2 = waitbar(0,'Processing hhours...');
            for ind =1:size(climateData,1);
                waitbar(ind/size(climateData,1),hnd_wait2)
                ClimateStats(ind).TimeVector = tv(ind);
                for indChannels = 1:length(chanInd)
                    if indChannels > length(chanNames)
                        % if more channels than names use default name
                        chName = [csi_name num2str(indChannels)];
                    else
                        chName = char(chanNames(indChannels));
                    end
                    strX = sprintf('ClimateStats(%d).%s = %f;',ind,chName,climateData(ind,indChannels));
                    eval(strX)
                    %ClimateStats = setfield(ClimateStats,{ind},chName,climateData(ind,indChannels));
                end
            end
            close (hnd_wait2)
            % if there were no errors try to update database
            % Save data belonging to different years to different folders
            % if databasePath contains "\yyyy\" string (replace it with
            % \2005\ for year 2005)
            yearVector = datevec(tv);
            yearVector = yearVector(:,1);
            years = unique(yearVector)';
            if ~isempty(findstr(databasePath,'\yyyy\'))
                ind_yyyy = findstr(databasePath,'\yyyy\');
                databasePathNew = databasePath;
                for year_ind = years
                    one_year_ind = find(tv > datenum(year_ind,1,1) & tv <= datenum(year_ind+1,1,1));
                    databasePathNew(ind_yyyy+1:ind_yyyy+4) = num2str(year_ind);
                    [k] = db_new_eddy(ClimateStats(one_year_ind),[],databasePathNew,0,[],timeUnit);
                end
            else
                [k] = db_new_eddy(ClimateStats,[],databasePath,0,[],timeUnit);
            end
            % if there is no errors update records
            numOfFilesProcessed = numOfFilesProcessed + 1;
            numOfDataPointsProcessed = numOfDataPointsProcessed + length(tv);
            filesProcessProgressList(j).Modified = datenum(h(i).date);
        catch
            disp(sprintf('Error in processing of: %s',fullfile(pth,h(i).name)))
        end % of try
    end %  if filesProcessProgressList(j).Modified < datenum(h(i).date)
end % for i=1:length(h)
% Close progress bar
close(hnd_wait)
% Return warning state 
try 
   for i = 1:length(warning_state)
      warning(warning_state(i).identifier,warning_state(i).state)
   end
end

save(processProgressListPath,'filesProcessProgressList')

% this function returns and index pointing to where fileName is in the 
% fileProcessProgressList.  If fileName doesn't exist in the list
% the output is list length + 1
function ind = findFileInProgressList(fileName, filesProcessProgressList);

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
