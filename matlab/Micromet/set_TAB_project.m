function structProject = set_TAB_project(projectPath,flagSetUserData)
% Entry point for all Trace Analysis Biomet (TAB) data projects
%
% 
% NOTE: This is the concept testing.  The actual values 
%       are hard coded here but the intention is to use YAML files 
%       for this. This code will only load 
%
% Zoran Nesic           File created:       May 15, 2024
%                       Last modification:  May 15, 2024

% Revisions
%

arg_default('flagSetUserData',0);
projectPath = fullfile(projectPath);

% projectPath must exist
if ~exist(projectPath,'dir')
    error('Folder: %s does not exist!',projectPath);
end

% ----------------------------------------
% load yaml file into structProject here
% ----------------------------------------
structProject = pretendYMLread(projectPath);
% readingYaml 
%yaml.dump(structProject)

% if required, save data under UserData so it's visible 
% to all Matlab functions.
if flagSetUserData == 1
    UserData = get(0,'UserData');
    UserData.structProject = structProject;
    set(0,"UserData",UserData)
end


function structProject = pretendYMLread(projectPath)

% Write a Matlab GUI to create the initial YAML than can then be
% edited by either the GUI or by the user
%-------- start yaml ---------------------
projectName = 'UQAM';
structProject.projectName   = projectName;
structProject.path          = fullfile(projectPath,structProject.projectName);
structProject.databasePath  = fullfile(structProject.path,'Database');
structProject.sitesPath     = fullfile(structProject.path,'Sites');
structProject.matlabPath    = fullfile(structProject.path,'Matlab');

siteID = 'UQAM_0';
structProject.sites.(siteID).siteID = siteID;

% Data logger tables
tableNum = 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_30m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 30;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = 'Met';
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'Met_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);
tableNum = tableNum + 1;
structProject.sites.(siteID).dataSources.met.table(tableNum).name              = 'RawData_05m';
structProject.sites.(siteID).dataSources.met.table(tableNum).source            = [siteID '_' structProject.sites.(siteID).dataSources.met.table(tableNum).name];
structProject.sites.(siteID).dataSources.met.table(tableNum).timeStepMin       = 5;
structProject.sites.(siteID).dataSources.met.table(tableNum).dbFolderName      = fullfile('Met',structProject.sites.(siteID).dataSources.met.table(tableNum).name);

% ECCC stations
structProject.sites.(siteID).dataSources.eccc(1).stationsID                    = 27646;
structProject.sites.(siteID).dataSources.eccc(1).stationsName                  = 'SHAWINIGAN';
structProject.sites.(siteID).dataSources.eccc(2).stationsID                    = 8321;
structProject.sites.(siteID).dataSources.eccc(2).stationsName                  = 'TROIS-RIVIERES';


%-------- end yaml ---------------------------

