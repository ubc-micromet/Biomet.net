function create_TAB_ProjectFolders(projectPath)

if ~exist(projectPath,'var')
    error('Missing required input.')
end

if ~exist("projectPath",'dir')
    mkdir(projectPath);
end

if exist(fullfile(projectPath,'Database'),'dir') ...
   | exist(fullfile(projectPath,'Sites'),'dir') ...
   | exist(fullfile(projectPath,'Matlab'),'dir')
    fig = uifigure;
    selection = uiconfirm(fig, ...
    "Project folders already exist. Do you want to overwrite them?","Confirm Overwrite", ...
    "Options",["Overwrite","Cancel"], ...
    "Icon","warning");
    if strcmpi(selection,'Cancel')
        return
    end
end
mkdir(fullfile(projectPath,'Database'));
mkdir(fullfile(projectPath,'Database','Calculation_Procedures'));
pathAF = fullfile(projectPath,'Database','Calculation_Procedures','AmeriFLux');
mkdir(pathAF);
url1 = 'https://github.com/CANFLUX/TAB_Ameriflux_variables.git';

repo = gitclone(url1,pathAF,Depth=1);
mkdir(fullfile(projectPath,'Database','Calculation_Procedures','TraceAnalysis_ini'));


mkdir(fullfile(projectPath,'Sites'));