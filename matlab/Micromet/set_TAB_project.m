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

% Make sure the file separators are set properly for 
% Windows and macOS
projectPath = fullfile(projectPath);

% projectPath must exist
if ~exist(projectPath,'dir')
    error('Folder: %s does not exist!',projectPath);
end

% set the Matlab current path to projectPath
cd(projectPath)

% ----------------------------------------
% load yaml file into structProject here
% ----------------------------------------
structProject = pretend_configYAML(projectPath);

% if required, save data under UserData so it's visible 
% to all Matlab functions.
if flagSetUserData == 1
    UserData = get(0,'UserData');
    UserData.structProject = structProject;
    set(0,"UserData",UserData)
end

% to keep compatibility with the legacy code, this function
% will now create the following Matlab functions in the projectPath folder:
% - biomet_database_default.m
% - biomet_sites_default.m
% and then setup the 

