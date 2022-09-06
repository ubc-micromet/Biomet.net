%% Script for doing local data cleaning (works only in Windows, for now)
%  Step by step process of using fr_automated_cleaning on a computer that 
%  does not have remote write priviledges for P: drive.
%  This is the recommended way of doing the testing of the ini files
%  before they are deployed on vinimet.

% On your PC create a folder for the testing
% (suggestion: c:/user_name/Matlab/datacleaning, for user zoran this would
%  read c:/zoran/Matlab/datacleaning)

% A copy of this script should be saved there

%% Edit the lines below to work on your PC

% in Matlab, change the default folder to the datacleaning folder
cd C:\Zoran\Matlab\datacleaning


%% Copy one year of data for one site in the target folder
% NOTE: all vinimet users have read-only access to P:\database folder

% the folowing folder paths use Windows naming convenction
%
micrometDatabaseFolder = '\\vinimet.geog.ubc.ca\database';  
localDatabaseFolder = 'e:/junk/database';

siteID = 'DSM';
yearToCopy = 2022;
folderToCopy = fullfile(micrometDatabaseFolder,num2str(yearToCopy),siteID);
destinationFolder = fullfile(localDatabaseFolder,num2str(yearToCopy),siteID);
cmdStr = sprintf('robocopy %s %s /R:3 /W:10 /REG /MIR /NDL /NFL /NJH',folderToCopy,destinationFolder); 
[status,result] = system(cmdStr); 

% Make sure there are "..\Calculation_Procedures\TraceAnalysis_ini\siteID"
%                 and "..\Calculation_Procedures\TraceAnalysis_ini\siteID\Derived_Variables"
% folder under localDatabaseFolder
iniFilePath = fullfile(localDatabaseFolder,'Calculation_Procedures','TraceAnalysis_ini',siteID); 
derivedVariablesPath = fullfile(iniFilePath,'Derived_Variables');
if ~exist(derivedVariablesPath,'dir')
    mkdir(derivedVariablesPath);
end

% IMPORTANT: 
%       Put your siteID_FirstStage.ini, siteID_SecondStage.ini, siteID_ThirdStage.ini files
%       in the folder: "..\Calculation_Procedures\TraceAnalysis_ini\siteID".
%       The next steps below will try to remind you to do so
firstStageIniPath = fullfile(iniFilePath,[siteID '_FirstStage.ini']);
if ~exist(firstStageIniPath,'file')
    error('Missing file:\nThis file is needed:\n%s',firstStageIniPath);
end

% Create biomet_database_default that points to the target folder
fid = fopen('biomet_database_default.m','wt');
if fid <0
    error('Could not create biomet_database_default.m in the folder: %s',pwd);
end
fprintf(fid,'function x = biomet_database_default\n');
fprintf(fid,'x = ''%s'';\n',localDatabaseFolder);
fclose(fid);

%% Now run fr_automated cleaning
% It will use local database (because of biomet_database_default.m file in the current folder)
% and it will use the ini files from the local folder because of localDatabaseFolder used
% as an input to fr_automated_cleaning

% Run cleaning
fr_automated_cleaning(yearToCopy,siteID,1:2,[],localDatabaseFolder)




