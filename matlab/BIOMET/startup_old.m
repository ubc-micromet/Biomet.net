%===================================================================
%
%               This is standard Startup.m file for BIOMET group
%
%===================================================================

%
% (c) Zoran Nesic           File created:               1995
%                           Last modification:   Feb 3, 2017

%
% Revisions:
%
%   Feb 3, 2017 (Zoran)
%       - Added path to UTILS folder for the server (PAOA001) only
%         (this might be needed on other machines too)
%   Jan 18, 2006
%       - did the below for the \\paoa001 paths too.
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
path('c:\biomet.net\matlab\UTILS',path);
path('c:\biomet.net\matlab\TraceAnalysis_FCRN_THIRDSTAGE',path);
path('c:\biomet.net\matlab\TraceAnalysis_Tools',path);
path('c:\biomet.net\matlab\TraceAnalysis_SecondStage',path);
path('c:\biomet.net\matlab\TraceAnalysis_FirstStage',path);
path('c:\biomet.net\matlab\soilchambers',path);
path('c:\biomet.net\matlab\biomet',path);  
path('c:\biomet.net\matlab\boreas',path);
path('c:\biomet.net\matlab\biomet',path);      
path('c:\biomet.net\matlab\new_met',path);      
path('c:\biomet.net\matlab\met',path);    
path('c:\biomet.net\matlab\new_eddy',path); 
path('c:\biomet.net\MATLAB\SystemComparison',path);         % use this line on the workstations
if server == 1
    path('c:\biomet.net\matlab\utils',path);
end

path('c:\ubc_PC_setup\site_specific',path);      
path('c:\ubc_PC_setup\PC_specific',path);

while exist('startnet') ~= 2
end



%
% For the network users, the network path should be first (if the server 
% is connected).
%

if server ~= 1 
    if exist('\\PAOA001\MATLAB\BIOMET\startnet.m')        
        path('\\PAOA001\matlab\UTILS',path);
        path('\\PAOA001\matlab\TraceAnalysis_FCRN_THIRDSTAGE',path);
        path('\\PAOA001\matlab\TraceAnalysis_Tools',path);
        path('\\PAOA001\matlab\TraceAnalysis_SecondStage',path);
        path('\\PAOA001\matlab\TraceAnalysis_FirstStage',path);
        path('\\PAOA001\matlab\soilchambers',path);                   % use this line on the workstations        
        path('\\PAOA001\matlab\BIOMET',path);                   % use this line on the workstations
        path('\\PAOA001\MATLAB\BOREAS',path);                   % use this line on the workstations
        path('\\PAOA001\MATLAB\new_met',path);                  % use this line on the workstations       
        path('\\PAOA001\MATLAB\met',path);                      % use this line on the workstations       
        path('\\PAOA001\MATLAB\new_eddy',path);                 % use this line on the workstations               
        path('\\PAOA001\MATLAB\SystemComparison',path);         % use this line on the workstations
        while exist('startnet') ~= 2
        end
        disp(sprintf('\nBiomet network toolbox connected!\n'));
    else
        disp(sprintf('\nBiomet network toolbox is off!\n'));
    end
end

path(user_dir,path);


startnet;

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
