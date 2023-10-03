function [numOfFilesProcessed,numOfDataPointsProcessed] = fr_SoilFluxPro_database(...
                wildCardPath,processProgressListPath,databasePath,...
                timeUnit,structPrefix,missingPointValue)
% fr_LI8200_database - read LI8200 processed fluxes and create/update 
%                        Biomet/Micromet climate data base
% 
% [numOfFilesProcessed,numOfDataPointsProcessed] = fr_SoilFluxPro_database(...
%                 wildCardPath,...
%                 processProgressListPath,databasePath,...
%                 timeUnit,structPrefix,missingPointValue)
%
% Example:
%
%
% NOTE:
%       databasePath needs to include "\yyyy\" string if multiple years of
%       data are going to be found in the wildCardPath folder!
%
% Inputs:
%       wildCardPath        - full file name including path. Wild cards accepted
%       processProgressListPath - path where the progress list is kept
%       databasePath        - path to output location  (*** see the note above ***)
%       timeUnit            -  minutes in the sample period (spacing between two
%                              consecutive data points). Default 30 (hhour)
%       structPrefix        - used to add prefix to all database file names
%                             (structPrefix.TimeVector,...) so that multiple loggers
%                             can be stored in the same database folder
%       missingPointValue   - default 0 (Biomet legacy), all new non-Biomet sites should be NaN
%
% Zoran Nesic           File Created:      Sep  6, 2023
%                       Last modification: Sep 29, 2023  

%
% Revisions:
%
% Sep 29, 2023 (Zoran)
%   - replaced db_new_eddy with db_struct2database (using sparse instead of complete data base files)
%

arg_default('timeUnit',5);              % default is 5 minutes
arg_default('structPrefix',[]);         % default is that there is no prefix to database file names
arg_default('missingPointValue',0);     % default is 0, legacy issue. Use NaN for all non-Biomet-UBC databases 

h = dir(wildCardPath);
if isempty(h)
    error('File: %s not found\n',wildCardPath);
end

pth = h(1).folder;

if exist(processProgressListPath,'file')
    load(processProgressListPath,'filesProcessProgressList');
else
    filesProcessProgressList = [];
end

numOfFilesProcessed = 0;
numOfDataPointsProcessed = 0;
warning_state = warning;
warning('off')
hnd_wait = waitbar(0,'Updating site database...');

for i=1:length(h)
    try 
        waitbar(i/length(h),hnd_wait,{'Processing: %s ', ['...' pth(end-50:end)], h(i).name})
    catch 
        waitbar(i/length(h),hnd_wait)
    end

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
            % when a file is found that hasn't been processed
            % load it.
            fileName = fullfile(pth,h(i).name);
            [~,~,tv] = fr_read_SoilFluxPro_file(fileName,'caller','ClimateStats',timeUnit);
            
            % If required, add Prefix to the output structure.
            if ~isempty(structPrefix)
                temp = [];
                for k=1:length(ClimateStats)
                    temp(k).(structPrefix) = ClimateStats(k); %#ok<*AGROW>
                    temp(k).(structPrefix).TimeVector = [];
                    temp(k).TimeVector = ClimateStats(k).TimeVector;
                end
                ClimateStats = temp;
            end
            % if there were no errors try to update database
            % Save data belonging to different years to different folders
            % if databasePath contains "\yyyy\" string (replace it with
            % \2005\ for year 2005)
            yearVector = datevec(tv);
            yearVector = yearVector(:,1);
            years = unique(yearVector)';
            if ~isempty(strfind(databasePath,'\yyyy\')) %#ok<STREMP>
                ind_yyyy = strfind(databasePath,'\yyyy\');
                databasePathNew = databasePath;
                for year_ind = years
                    one_year_ind = find(tv > datenum(year_ind,1,1) & tv <= datenum(year_ind+1,1,1)); %#ok<*DATNM>
                    if ~isempty(one_year_ind)
                        databasePathNew(ind_yyyy+1:ind_yyyy+4) = num2str(year_ind);
                        for cntSamples = 1:length(one_year_ind)
                            %[k] = db_new_eddy(ClimateStats(one_year_ind(cntSamples)),[],databasePathNew,0,[],timeUnit,missingPointValue); %#ok<*NASGU>
                            db_struct2database(ClimateStats(one_year_ind(cntSamples)),...
                                               databasePathNew,[],[],...
                                               timeUnit,missingPointValue);
                        end
                    end
                end
            else
                %[k] = db_new_eddy(ClimateStats,[],databasePath,0,[],timeUnit,missingPointValue);
                db_struct2database(ClimateStats,...
                                   databasePath,[],[],...
                                   timeUnit,missingPointValue);
            end
            % if there is no errors update records
            numOfFilesProcessed = numOfFilesProcessed + 1;
            numOfDataPointsProcessed = numOfDataPointsProcessed + length(tv);
            filesProcessProgressList(j).Modified = datenum(h(i).date);
        catch
            fprintf('Error in processing of: %s\n',fullfile(pth,h(i).name));
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
catch
end

if ~isempty(processProgressListPath)
    try
        save(processProgressListPath,'filesProcessProgressList')
    catch
        error('Error while saving processProgressList\n');
    end
else
    fprintf('Data processed. \nprocessProgressList not saved per user''s request.\n\n');
end

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
