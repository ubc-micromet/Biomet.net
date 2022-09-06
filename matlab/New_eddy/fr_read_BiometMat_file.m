function [EngUnits,Header] = fr_read_BiometMat_file(fileName) %#ok<STOUT,STOUT>
%
% (c) Zoran Nesic               File created:      May   3, 2012
%                               Last modification: May   3, 2012
%
% Revisions:
%

% The following line will load up EngUnits and Header from 
% the file.
load(fileName,'-mat');