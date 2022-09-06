function pth = db_pth_root
% pth = db_pth_root
%
% Returns the database path that updates will be written to.

% Last modified: May 30, 2006: 
%      -changed to network drive formulation to allow recalc_create to run
%       from Fluxnet02
%                              

[pc_name,loc] = fr_get_pc_name;

if strcmp(pc_name,'FLUXNET02') | strcmp(pc_name,'PAOA001')
    pth = 'y:\';
else
    pth = '\\Annex001\database\';
end
