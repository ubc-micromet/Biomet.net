function currentBiometPathsOut = set_all_biomet_paths(BiometNet_Pth, SiteSpecific_Pth, PCSpecific_Pth, hhour_Pth,calibrations_Pth, data_Pth, csi_net_Pth, database_Pth, userMatlab_Pth)
%
% This function sets up all UBC Biomet paths.  All other functions are obsolite.
%
% Usage:
% To set the paths and get the info what the paths are use:
% xxx = set_all_biomet_paths('c:\biomet.net\matlab','c:\ubc_pc_setup\site_specific','c:\ubc_pc_setup\pc_specific','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database','')
% xxx = set_all_biomet_paths('c:\biomet.net','c:\ubc_pc_setup\site_specific','c:\ubc_pc_setup\pc_specific','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database','d:\nz\matlab');
% xxx = set_all_biomet_paths('c:\biomet.net','c:\ubc_pc_setup\site_specific','c:\ubc_pc_setup\pc_specific','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database',{'d:\nz\matlab'});
% xxx = set_all_biomet_paths('c:\biomet.net','c:\ubc_pc_setup','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database',{'d:\nz\matlab','d:\nz\matlab\currentprojects'})
%
% To check the current setup use:
% yyy = set_all_biomet_paths
%
% Output:
% yyy = 
%       BIOMETNET: [1x1 struct]
%    UBC_PC_SETUP: [1x1 struct]
%         CSI_NET: [1x1 struct]
%           HHOUR: [1x1 struct]
%    CALIBRATIONS: [1x1 struct]
%            DATA: [1x1 struct]
%        DATABASE: [1x1 struct]
%      USERMATLAB: [1x1 struct]
%
% BiometNet and UBC_PC_SETUP have sub-structures .Root and .Path
% csi_net, hhour,calibrations,data,database have substructure .Root only
% userMatlab has a sub-structure .Path only.
% There is even a reason for the above but it may change later on if we feel like that.
%
% NOTE: If edditing this function please note that the edits will not be working until 
%       you use "munlock('set_all_biomet_paths')" at the Matlab prompt.  See "help
%       munlock" for more info.
%
% (c) Zoran Nesic       File created:       Feb  9, 2006
%                       Last modification:  Apr 16, 2006

% Revisions:
%  Apr 16, 2006 (Zoran)
%   - removed matlab\... from all the strBiometNet_Folders strings.
%     user now needs to add this to the calling function:
%     use:
%       set_all_biomet_paths('c:\biomet.net\matlab',...)
%     instead of:
%       set_all_biomet_paths('c:\biomet.net\',...)

persistent currentBiometPaths

if nargin == 0 
     if nargout > 0 
         currentBiometPathsOut = currentBiometPaths;
     end
     return
end

currentBiometPaths = [];

currentBiometPaths.USERMATLAB.Path = [];
currentBiometPaths.USERMATLAB.Root = [];
currentBiometPaths.PC_SPECIFIC.Root         = PCSpecific_Pth;
currentBiometPaths.SITE_SPECIFIC.Root       = SiteSpecific_Pth;
currentBiometPaths.BIOMETNET.Root           = BiometNet_Pth;
currentBiometPaths.CSI_NET.Root             = csi_net_Pth; 
currentBiometPaths.HHOUR.Root               = hhour_Pth;
currentBiometPaths.CALIBRATIONS.Root        = calibrations_Pth;
currentBiometPaths.DATA.Root                = data_Pth;
currentBiometPaths.DATABASE.Root            = database_Pth;

strBiometNet_Folders = { ...
                        'SystemComparison' ...
                        'new_eddy',...
                        'met',...
                        'new_met',...                        
                        'biomet',...
                        'boreas',...
                        'biomet',...
                        'soilchambers',...
                        'TraceAnalysis_FirstStage',...
                        'TraceAnalysis_SecondStage',...
                        'TraceAnalysis_Tools',...                        
                        'TraceAnalysis_FCRN_THIRDSTAGE', ...
                      };

path(pathdef);

for i=length(strBiometNet_Folders):-1:1
    addpath(fullfile(BiometNet_Pth,char(strBiometNet_Folders(i))));
    currentBiometPaths.BIOMETNET.Path{i} = fullfile(currentBiometPaths.BIOMETNET.Root,char(strBiometNet_Folders(i)));
end

addpath(char(currentBiometPaths.SITE_SPECIFIC.Root));
addpath(char(currentBiometPaths.PC_SPECIFIC.Root));

    
if iscell(userMatlab_Pth)
	for i=length(userMatlab_Pth):-1:1
        addpath(char(userMatlab_Pth(i)));
        currentBiometPaths.USERMATLAB = setfield(currentBiometPaths.USERMATLAB,{i},'Path',char(userMatlab_Pth(i)));
        currentBiometPaths.USERMATLAB = setfield(currentBiometPaths.USERMATLAB,{i},'Root',char(userMatlab_Pth(i)));
	end
else    
    addpath(userMatlab_Pth);
    currentBiometPaths.USERMATLAB = setfield(currentBiometPaths.USERMATLAB,{1},'Path',userMatlab_Pth);
    currentBiometPaths.USERMATLAB = setfield(currentBiometPaths.USERMATLAB,{1},'Root',userMatlab_Pth);    
end

if nargout > 0
    currentBiometPathsOut = currentBiometPaths;
end

mlock

