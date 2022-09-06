%===============================================================
function [dataPth, hhourPth] = FR_get_local_path
%===============================================================
%
% (c) Zoran Nesic           File created:       Mar 26, 1998
%                           Last modification:  Apr 20, 1998
%

%
%   Revisions:
%

dataPth  = fullfile(pwd,'..','DATA',filesep);
hhourPth = fullfile(pwd,'HHOUR',filesep);
