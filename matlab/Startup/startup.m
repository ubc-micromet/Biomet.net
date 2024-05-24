function startup
%===================================================================
%
%        This is the standard startup.m file for Biomet.net
%
%===================================================================
%
%
% (c) Zoran Nesic           File created:        May 24, 2024
%                           Last modification:   May 24, 2024


fPath = mfilename('fullpath');
fPath = fileparts(fPath);
ind = find(fPath==filesep);
bnFolder = fPath(1:ind(end)); 

addpath(fullfile(bnFolder,'TraceAnalysis_FCRN_THIRDSTAGE'));
addpath(fullfile(bnFolder,'TraceAnalysis_Tools'));
addpath(fullfile(bnFolder,'TraceAnalysis_SecondStage'));
addpath(fullfile(bnFolder,'TraceAnalysis_FirstStage'));
addpath(fullfile(bnFolder,'soilchambers')); 
addpath(fullfile(bnFolder,'BOREAS'));
addpath(fullfile(bnFolder,'BIOMET'));      
addpath(fullfile(bnFolder,'new_met'));      
addpath(fullfile(bnFolder,'met'));    
addpath(fullfile(bnFolder,'new_eddy')); 
addpath(fullfile(bnFolder,'SystemComparison'));         % use this line on the workstations
addpath(fullfile(bnFolder,'Micromet'));


% add legacy paths if they exist
if exist('c:\UBC_PC_Setup\Site_specific','dir')
    path('c:\UBC_PC_Setup\Site_specific',path);      
end
if exist('c:\UBC_PC_Setup\PC_specific','dir')
    path('c:\UBC_PC_Setup\PC_specific',path);
end
% Run diarylog if available
if exist('diarylog','file')
    diarylog
end

% If the user wants to customize his Matlab environment he may create
% the localrc.m file in Matlab's main directory
if exist('localrc','file') ~= 0
    localrc
end

