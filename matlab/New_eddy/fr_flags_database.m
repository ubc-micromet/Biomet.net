function dataOut = db_update_flags_files(siteID, yearIn, sitesPathRoot, databasePathRoot,timeUnit,missingPointValue)
% fr_flags_database - reads an xlsx or a csv file containing data-exclusion flags and exports those flags into database format
%                     Multiple flags can be created this way
%
% dataOut = fr_flags_database(siteID, yearIn,sitesPathRoot,databasePathRoot,timeUnit,missingPointValue)
%
% Example:
%    dataOut = fr_flags_database('DSM', 2022,'p:/Sites','p:/database') 
%    reads input file p:/Sites/DSM/MET/DSM_flags_2022.xlxs and
%    updates or creates data base files under p:/database
%
%
% Inputs:
%       siteID          - site ID ('DSM', 'RBM'...)
%       yearIn          - year to process. Default current year
%       databasePath    - path to database (usually p:/database)
%       timeShift       - time offset to be added to the tv vector (in tv
%                         units, 0 if datebase is in GMT)
%       timeUnit        - minutes in the sample period (spacing between two
%                         consecutive data points). Default 30 (hhour)
%
%
% Notes:
%    - the input file should be located under p:/Sites/siteID/MET folder.
%    - program works on one year of data only. The file name for each year
%      is named: siteID_flags_yyyy.xlsx or .csv.
%    - use this template for the input file
% ------------ start of the template ------------------------------------------------
%          Header line 1
%          Header line 2
%          Header line 3
%          Header line 4
%          StartDate	      EndDate           flagDO_1_1_1    flag_pH_1_1_1   Notes
%          2022-06-25 09:30	2022-06-25 10:30    1                               Service 1
%          2022-08-30 10:15	2022-08-30 12:30	1                               Service 2
%          2022-09-15 08:50	2022-09-19 13:30    1                               Service 3
%          2022-09-30 10:30	2022-09-30 11:30	1                               Service 4
%          2022-04-23 15:30	2022-06-25 16:00                    1               Bad data
%          2022-07-02 20:00	2022-07-27 13:30                    1               Bad data
%          2022-07-29 10:00	2022-08-30 13:00                    1               Bad data
%          2022-09-09 00:00	2022-09-19 12:30                    1               Bad data
%-------------------------------------------------------------------------------------------
%   - The number of header lines needs to be 4
%   - Any number of columns for flags can be used (min=1)
%   - Flag names have to be valid Matlab variable names and valid Windows file names
%     (suggestion: use Ameriflux convention as in the template above)
%   - The column titles: StartDate, EndDate and Notes should not be changed
%
%
% Zoran Nesic           File Created:      Nov 15, 2022
%                       Last modification: Nov 18, 2022

%
% Revisions:
%
% Nov 18, 2022 (Zoran)
%  - Added comments
%

[yearNow,~,~] = datevec(now); 
arg_default('time_shift',0);
arg_default('timeUnit',30); %
arg_default('yearIn',yearNow)
arg_default('missingPointValue',NaN); %   % default missing point code is 0
dataOut = [];

if length(yearIn) > 1
    error('Year has to be a single!\n')
end

% the source file is an xlxs or csv file that's under the site's MET folder.
% Here is it's path
filePath = fullfile(sitesPathRoot,siteID,'MET');

% Check if the file exists. Quit if the file does not exist. Not all sites
% will have such a file.
fileName = fullfile(filePath,sprintf('%s_flags_%d.xlsx',siteID,yearIn));
if ~exist(fileName,'file')
    return
end

tableIn = readtable(fileName,"NumHeaderLines",4);

% create a time vector for the entire year
dataOut.TimeVector = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1))';

flagNum = 0;
varNames = {};
for cntVars = 1:length(tableIn.Properties.VariableNames)
    varNameTmp = tableIn.Properties.VariableNames(cntVars);
    % find flag columns (all columns that are not in the list below)
    if ~ismember(varNameTmp,{'StartDate','EndDate','Notes'}) 
        % set all values in varName to 0
        dataOut.(char(varNameTmp)) = zeros(size(dataOut.TimeVector));
        flagNum = flagNum + 1;
        varNames(flagNum) = varNameTmp; %#ok<*AGROW>
    end
end

% Find periods for each variable that need to be "flagged" (set to 1)
% and flag them
for cntVars = 1:length(varNames)
    currVar = char(varNames(cntVars));
    flagVar = tableIn.(currVar);
    indVar  = find(~isnan(flagVar));
    for cntPeriods = 1:length(indVar)
        % find a time period for the current flag
        startPeriod = datenum(tableIn.StartDate(indVar(cntPeriods)));
        endPeriod   = datenum(tableIn.EndDate(indVar(cntPeriods)));
        % flag that period
        indData2Flag = find(dataOut.TimeVector > startPeriod ...
                          & dataOut.TimeVector <=fr_round_time(endPeriod,[],2) ); 
        dataOut.(currVar)(indData2Flag) = 1; %#ok<FNDSB>
    end
end

% convert dataOut to Stats structure
Stats = struct([]);
N = length(dataOut.TimeVector);
allFields = fieldnames(dataOut);
for cntFields = 1:length(allFields)
    fieldName = char(allFields(cntFields));
    for cnt = 1:N
        Stats(cnt).(fieldName) = dataOut.(fieldName)(cnt);
    end
end
        
        
   
% full path (Example: p:\database\2022\DSM\Flags)
databasePath = fullfile(databasePathRoot,num2str(yearIn),siteID,'Flags');
% save traces into database
db_new_eddy(Stats,[],databasePath,0,[],timeUnit,missingPointValue);

