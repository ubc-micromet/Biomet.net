function tableOut = saveDatabaseToAmeriFluxCSV(siteID,yearIn,outputPath)
% tableOut = saveDatabaseToAmeriFluxCSV(siteID,yearIn)
%
% Create a table of all Ameriflux variables that exist under
% clean\SecondStage folder for one site and for one year.
% This table can then be saved as a csv file and uploaded to 
% Ameriflux database.
%
% Note: Only file names that follow standart Ameriflux naming convention
%       will be included. All other SecondStage variables will be skipped.
%
%  siteID       - a site ID using Biomet/Micromet naming convention ('YF','DSM'...)
%  yearIn       - a year for which the output will be generated
%  outputPath   - path where to save CSV file. If omitted, no file will be saved.
%
%
% Example call:
%  1. Load up 2022 DSM data into a table (without saving):
%       tableOut = saveDatabaseToAmeriFluxCSV('DSM',2022);
%  2. Save 2022 DSM data into a file with proper AF name under p:\test folder
%       saveDatabaseToAmeriFluxCSV('DSM',2022,'p:\test');
%
%
% Zoran Nesic               File created:       Oct 20, 2022
%                           Last modification:  Oct 20, 2022
%

%
% Revisions:
%

arg_default('outputPath',[]);
pthDatabase = biomet_path(yearIn,siteID);
% find the root path. Usually p:\Database.
ind = strfind(upper(pthDatabase),'DATABASE');
if isempty(ind)
    error('Data base path (%s) must include folder: "database" in it! Check your biomet_database_default.m file.',pthDatabase);
else
    % extract the root path
    pthRoot = pthDatabase(1:ind(1)+length('DATABASE'));    
end
pthDataIn = fullfile(pthDatabase,'Clean','SecondStage');

pthListOfVarNames = fullfile(pthRoot,'Calculation_Procedures','AmeriFlux');
afListOfVarNames = readtable(fullfile(pthListOfVarNames,'flux-met_processing_variables_20221020.csv'));

% create an empty output structure
structOut = struct;
% Add time stamps.
tv = datetime(read_bor(fullfile(pthDataIn,'clean_tv'),8),'convertfrom','datenum');
structOut.TIMESTAMP_START = datestr(tv-1/48,'yyyymmddhhMM');
structOut.TIMESTAMP_END = datestr(tv,'yyyymmddhhMM');
% cycle through all Ameriflux variable names
for cntVar = 1:size(afListOfVarNames,1)
    varType = char(afListOfVarNames.Type(cntVar));
    % skip time-keeping variables (we'll create our own)
    if ~strcmp(varType,'TIMEKEEPING')
        varName = char(afListOfVarNames.Variable(cntVar));
        % see if such a variable exists in the second stage
        if ~isempty(dir(fullfile(pthDataIn,varName))) ...
           || ~isempty(dir(fullfile(pthDataIn,[varName '_*'])))
           % get all the variables that match that wildcard
           allSecondStageVars = [dir(fullfile(pthDataIn,varName));...
                                 dir(fullfile(pthDataIn,[varName '_*']))];
           % load all SecondStage variables into structOut
           for cntSecStgVars = 1: length(allSecondStageVars)
               % get variable name
               ssVarName = char(allSecondStageVars(cntSecStgVars).name);
               % read data from database
               ssData = read_bor(fullfile(pthDataIn,ssVarName));
               % replace NaN-s with -9999
               ssData(isnan(ssData)) = -9999;
               % store output
               structOut.(ssVarName) = ssData;
           end
        end
    end
end

% Convert output structure to a table
tableOut = struct2table(structOut);

% if outputPath is given then save the table
if ~isempty(outputPath)
    % load the AF site names from a file.
    % ** this is just for testing***
    siteNameAF = 'CC-DSM';
    fileName = sprintf('%s_HH_%s_%s.csv',siteNameAF,...
                             datestr(tv(1)-1/48,'yyyymmdd0000'),...
                             datestr(tv(end),'yyyymmdd0000'));
    writetable(tableOut,fullfile(outputPath,fileName));
end

