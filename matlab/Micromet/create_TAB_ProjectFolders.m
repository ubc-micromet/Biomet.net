function create_TAB_ProjectFolders(projectPath,siteID)
% Create the directory structure for Trace Analysis Biomet (TAB) data projects
% create_TAB_ProjectFolders ('E:\Projects\My_MicrometSites','Site_1')
%                           - creates the data tree to be used with TAB projects
%                           - clones the common set of files from GigHub
%                           - follows the instructions given here: 
%                              (Point to pipeline-documentation GigHum)
%
%
% Inputs:
%   projectPath         - path to the main project folder (parent of Database and Sites folders)
%   siteID              - short Ameriflux site ID or your site ID. No spaces are allowed.
%
% Output:
%
%
% Zoran Nesic           File created:       Aug 23, 2024
%                       Last modification:  Aug 23, 2024

% Revisions
%

if ~exist('projectPath','var')
    error('Missing Project Path.')
end
if ~exist('siteID','var')
    error('Missing siteID.')
else
    siteID = upper(siteID);
end

if ~exist(projectPath,'dir')
    mkdir(projectPath);
end

if exist(fullfile(projectPath,'Database'),'dir') ...
   || exist(fullfile(projectPath,'Sites'),'dir') ...
   || exist(fullfile(projectPath,'Matlab'),'dir')
    fig = uifigure;
    selection = uiconfirm(fig, ...
    "Project folders already exist. Do you want to overwrite them?","Confirm Overwrite", ...
    "Options",["Overwrite","Cancel"], ...
    "Icon","warning",'CloseFcn',@(h,e) close(fig));
    if strcmpi(selection,'Cancel')
        return
    end
end

tmpPath = fullfile(projectPath,'Database');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end
tmpPath = fullfile(projectPath,'Database','Calculation_Procedures');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end

tmpPath = fullfile(projectPath,'Database','Calculation_Procedures','AmeriFlux');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
else
    % For repo to be downloaded the folder needs to be empty so first remove it
    rmdir(tmpPath,"s");
    mkdir(tmpPath);
end
url1 = 'https://github.com/CANFLUX/TAB_Ameriflux_variables.git';
gitclone(url1,tmpPath,Depth=1);

tmpPath = fullfile(projectPath,'Database','Calculation_Procedures','TraceAnalysis_ini');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end

tmpPath = fullfile(projectPath,'Database','Calculation_Procedures','TraceAnalysis_ini',siteID);
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end

tmpPath = fullfile(projectPath,'Database','Calculation_Procedures','TraceAnalysis_ini',siteID,'Derived_Variables');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end

tmpPath = fullfile(projectPath,'Database','Calculation_Procedures','TraceAnalysis_ini',siteID,'log');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end

tmpPath = fullfile(projectPath,'Sites');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end

tmpPath = fullfile(projectPath,'Sites',siteID);
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end


tmpPath = fullfile(projectPath,'Matlab');
if ~exist(tmpPath,'dir')
    mkdir(tmpPath);
end