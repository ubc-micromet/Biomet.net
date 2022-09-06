function pth = db_pth_root
% pth = db_pth_root
%
% Returns the database path that updates will be written to.

% Last modified: 
% Jan 21, 2009
%   -changed exist test to if exist('...') == 2 (Nick)
% Oct 16, 2008
%       -added biomet_database_default for updating/testing local dbase
%       updates (Nick)
% Dec 20, 2007
%      -changed back to network drive formulation after Annex001 replaced
%      with file server; permissions now determined by user (Nick)
% May 30, 2006: 
%      -changed to network drive formulation to allow recalc_create to run
%       from Fluxnet02
%                              

% [pc_name,loc] = fr_get_pc_name;
% 
% if strcmp(pc_name,'FLUXNET02') | strcmp(pc_name,'PAOA001')
%     pth = 'y:\';
% else

if exist('biomet_database_default') == 2
    pth = biomet_database_default;
else
    pth = '\\Annex001\database\';
end

