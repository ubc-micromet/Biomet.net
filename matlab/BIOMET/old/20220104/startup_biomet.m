%===================================================================
%
%               This is standard Startup.m file for BIOMET group
%
%===================================================================

%
% (c) Zoran Nesic           File created:               1995
%                           Last modification:  May 20, 2004

%
% Revisions:
%
%   May 20, 2004
%       - added path Trace_Analysys_FCRN_THIRDSTAGE
%   Apr 26, 2004
%       - added path SystemComparison
%   Apr 17, 2004
%       - added paths for new_eddy
%   May 30, 2001
%       - added paths for the Trace Analysis tools (FirstStage,SecondStage and Tools)
%   Dec  4, 2000
%       - added checking for run_matlab_1.m
%   Nov 30, 2000
%       - changed the old path to site_specific to:
%           c:\ubc_pc_setup\site_specific
%                          \pc_specific
%   Sep 25, 1998
%       -   changed of name: PAOA_001 -> PAOA001
%   Apr 24, 1998
%       -   removed the \\paoa_001\...\new_met\site_specific from the path list
%   Apr 20, 1998
%       -   added xxx\new_met\site_specific to the rest of the paths
%           This directory will hold information/files that are specific
%           for that particular computer so we don't overwrite them each
%           time xxx\new_met software is synchronized with PAOA_001 PC.
%

% Call the setup program for this machine (it sets user_dir
% and server variables)
user_set

%
% Biomet toolbox path (mirror copy of the server's toolbox is stored there)
%

if server == 1
    % set_all_biomet_paths('c:\biomet.net','c:\ubc_pc_setup')
    set_all_biomet_paths('c:\biomet.net\matlab','c:\ubc_pc_setup\site_specific','c:\ubc_pc_setup\pc_specific','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database','d:\');
else
    try
        %set_all_biomet_paths('\\paoa001\matlab','c:\ubc_pc_setup')
        set_all_biomet_paths('\\paoa001\matlab','c:\ubc_pc_setup\site_specific','c:\ubc_pc_setup\pc_specific','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database','d:\');
        disp(sprintf('\nBiomet network toolbox connected!\n'));
    catch
       disp(sprintf('\nBiomet network toolbox is off!\n'));
   end
end

%startnet;

%xxx = set_all_biomet_paths('c:\biomet.net\matlab','c:\ubc_pc_setup\site_specific','c:\ubc_pc_setup\pc_specific','d:\met-data\hhour','d:\met-data\hhour','d:\met-data\data','d:\met-data\csi_net','\\annex001\database','d:\nz\matlab');

% If at the site check if the daily matlab run is in order

if exist('run_matlab_1') ~= 0
    run_matlab_1
end

% If the user wants to customize his Matlab environment he may create
% the localrc.m file in Matlab's main directory

if exist('localrc') ~= 0
    localrc
end

system_dependent(14,'on')
clear server user_dir
