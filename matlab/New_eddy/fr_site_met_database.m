function [numOfFilesProcessed,numOfDataPointsProcessed] = ...
         fr_site_met_database(wildCardPath,chanInd,chanNames,tableID,...
         processProgressListPath,databasePath,fileType,time_shift,...
         timeUnit,structPrefix,missingPointValue,default_Csi_name,tv_input_format)
% fr_site_met_database - read CSI logger files and create/update 
%                        Biomet/Micromet climate data base
% 
%          fr_site_met_database(wildCardPath,chanInd,chanNames,tableID,...
%               processProgressListPath,databasePath,fileType,time_shift,...
%               timeUnit,structPrefix,missingPointValue,default_Csi_name,tv_input_format)
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
%       wildCardPath        - full file name including path. Wild cards accepted
%       chanInd             - channels to extract. [] extracts all
%       chanNames           - cell array of length = length(chanInd) with the
%                             channel (database file) names
%       tableID             - Table to be extracted
%       processProgressListPath - path where the progress list is kept
%       databasePath        - path to output location  (*** see the note above ***)
%       timeUnit            -  minutes in the sample period (spacing between two
%                              consecutive data points). Default 30 (hhour)
%       structPrefix        - used to add prefix to all database file names
%                             (structPrefix.TimeVector,...) so that multiple loggers
%                             can be stored in the same database folder
%       missingPointValue   - default 0 (Biomet legacy), all new non-Biomet sites should be NaN
%       default_Csi_name    - default [] (Biomet legacy)
%       tv_input_format     - default []; see: fr_read_csi()
%
% Zoran Nesic           File Created:      June 16, 2005
%                       Last modification: Oct   4, 2023  

%
% Revisions:
%
%   Oct 4, 2023 (Zoran)
%       - Added checking if db_new_eddy returned and error. The file progress list 
%         will now get updated only if errCode == 0.
%   May 25, 2023 (Zoran)
%     - added an option to load up a generic csv file using readtable
%       and to process it into database. The csv file must have "date" column
%       that can be converted to a proper datetime format.
%     - added more comments.
%   July 27, 2022 (Zoran)
%     - left a bug (parameter defaultSeparator was left in the program but
%     not defined). I removed it.
%   July 26, 2022 (Zoran)
%     - added input parameter default_Csi_name. When the replicating the
%       file outputs from the original dbase_update is needed (files name:
%       ubc.1, ubc.2... then set this parameter to 'ubc__'. The double
%       underline will be replaced at the end with a '.' creating file names
%       ubc.xxx.
%     - added input parameter tv_input_format. It works simillary to the
%       dbase_update ini files (see fr_read_csi.m).
%   Oct 26, 2020 (Zoran)
%       - added \n to error printing
%   June 8, 2020 (Zoran)
%       - converted 
%           - findstr() into strfind()
%           - & into &&
%           - | into ||
%          which can cause some funky bugs if not applied appropriatelly
%          (like in cases where & was used with vectors but Matlab editor
%           thought that it would be a good idea to replace it with &&)
%       - minor syntax changes
%       - fixed a bug where program called out db_new_eddy without first
%         checking if the input structure was empty (it caused "Could not
%         read TimeVector" error that was caught by try/catch)
%     
%   Oct 20, 2019 (Zoran)
%       - Added new flag: missingPointValue to db_new_eddy calls. missingPointValue is the number that
%       replaces the missing values in the data. Traditionally, this was a
%       zero so we'll use that as the default. Most likely the new
%       databases (starting with BB) will use NaN as the default.
%      
%   Aug 15, 2018 (Zoran)
%       - combined two different versions of this program (Gabriel's PC and Biomet.net)
%
%   Sep 27, 2017 (Zoran)
%       - moved data procesing to fr_read_TOA5_file()
%   Apr 4, 2017 (Zoran)
%       - Added ability to prefix database file names in case that multiple
%       logger files are stored in the same database
%       - cleaned up the syntah to make the file "green".
%   Aug 18, 2009 (Nick)
%       -added timeUnit default value of 30
%   Aug 12, 2009 (Zoran)
%       - added timeUnit option to be passed to db_new_eddy (see
%       db_new_eddy for details)
%   Aug 4, 2005
%       - added fileType
%       - created arg_defaults for fileType and verbose_flag
%

arg_default('fileType',0)       % default file type is 0 (which will cause an error)
arg_default('verbose_flag',0)
arg_default('time_shift',0);    % default is no time shift (use tv as-is)
arg_default('chanInd',[]);      % default is convert all chanels to database files
arg_default('chanNames',[]);    % default is no specific chanNames. Database files will be names c_1, c_2..
arg_default('timeUnit',30);     % default is 30 minutes
arg_default('structPrefix',[]); % default is that there is not prefix to database file names
arg_default('missingPointValue',0); % default is 0 (legacy issue with Biomet database files) 20191020
arg_default('default_Csi_name',[]); % default is [] (legacy issue with Biomet database files) 20220726
arg_default('tv_input_format',[]);  % default is [] (legacy issue with Biomet database files) 20220726

flagRefreshChan = 0;

h = dir(wildCardPath);
x = strfind(wildCardPath,'\');
y = strfind(wildCardPath,'.*');
pth = wildCardPath(1:x(end));

% find default file name in case user didn't supply channel names
if isempty(default_Csi_name)
    if y > 0 & x>0 %#ok<*AND2>
        csi_name = [wildCardPath(x(end)+1:y-1) '_'];
    else
        csi_name = 'c_';
    end    
else
    csi_name = default_Csi_name;
end

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
                    [tv,climateData] = fr_read_csi(fullfile(pth,h(i).name),[],chanInd,tableID,0,[],[],tv_input_format);
                    if ~isempty(chanInd) && flagRefreshChan == 0
                        climateData = climateData(:,chanInd);
                    else
                        chanInd = 1:size(climateData,2);
                        flagRefreshChan = 1;
                    end
                case 2
                    [climateData,Header,tv] = fr_read_TOA5_file(fullfile(pth,h(i).name));
                    if ~isempty(chanInd) && flagRefreshChan == 0
                        climateData = climateData(:,chanInd);
                    else
                        chanInd = 1:length(Header.var_names);
                        flagRefreshChan = 1;
                    end
                    if isempty(chanNames) || flagRefreshChan == 1
                        chanNames = Header.var_names(chanInd);
                    end
                case 3
                    % Read data using readtable function
                    % Assumptions:
                    %   - file can be read using readtable with no additional parameters
                    %   - contains column named "date"
                    opts = detectImportOptions(fullfile(pth,h(i).name));
                    for cntVars = 1:length(opts.VariableTypes)
                        % change variable types for all variables to 'double'
                        % except for the variable 'date'
                        varName = char(opts.VariableNames(cntVars));
                        if ~strcmpi(varName,'date')
                           opts = setvartype(opts,varName,{'double'});
                        end
                    end
                    if ~isempty(chanNames)
                        % add field 'date' to the list of chanNames to import
                        tmpChanNames = chanNames;
                        tmpChanNames{end+1} = 'date';
                        opts.SelectedVariableNames = tmpChanNames;                        
                    end
                    ClimateStats = readtable(fullfile(pth,h(i).name),opts);
                    tv = fr_round_time(datenum(ClimateStats.date(:)));                    
                    ClimateStats.date = [];                     % remove date field 
                    ClimateStats.TimeVector = tv + time_shift;  % Add TimeVector field (apply time shift if needed)
                    ClimateStats = table2struct(ClimateStats);  % ClimateStats is now a structure
                otherwise
                    fprintf('Wrong file type in fr_site_met_database.m');
            end
            
            if fileType ~= 3
                % do time shifting if needed
                tv = tv + time_shift;
                % Create a data structure from a data matrix
                % except for fileType=3 - that one is already data struct.
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
                for ind =1:size(climateData,1)
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
            end

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
                    one_year_ind = find(tv > datenum(year_ind,1,1) & tv <= datenum(year_ind+1,1,1));
                    if ~isempty(one_year_ind)
                        databasePathNew(ind_yyyy+1:ind_yyyy+4) = num2str(year_ind);
                        [~,~,~,~,errCode] = db_new_eddy(ClimateStats(one_year_ind),[],databasePathNew,0,[],timeUnit,missingPointValue); %#ok<*NASGU>
                    end
                end
            else
                [~,~,~,~,errCode] = db_new_eddy(ClimateStats,[],databasePath,0,[],timeUnit,missingPointValue);
            end
            % if there is no errors update records
            numOfFilesProcessed = numOfFilesProcessed + 1;
            numOfDataPointsProcessed = numOfDataPointsProcessed + length(tv);
            if errCode == 0
                % verify that the file was correctly processed by changing
                % its Modified data from 0 to the actual date.
                filesProcessProgressList(j).Modified = datenum(h(i).date); %#ok<*DATNM>
            end
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
