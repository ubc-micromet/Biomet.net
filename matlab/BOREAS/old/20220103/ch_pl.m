function [chamber_data] = ch_pl(dateString,SiteID);
% Program that allows a quick look at the chamber fluxes
%
% input structure: ch_pl('011118','PA');
%
% Created by Zoran Nesic
%
% revisions:
%  - Aug. 12, 2002, created a new program (ch_pl_hhour_new (called within ch_pl)) to allow plotting of JP 
%  system. Needed this because of the new data structure (David)
%  - Nov. 19, 2001, added effective volume figure (David)
%  - Nov. 19, 2001, added possibility to work with SiteID (David) 
% -------------------------------------------------------------------

warning off;

if upper(SiteID) == 'PA'
   FolderName = 'paoa';
   Extension = 's.hp';
elseif upper(SiteID) == 'BS'
   FolderName = 'paob';
   Extension = 's.hb';
else
   FolderName = 'paoj';
   Extension = 's.hj';
end

fr_set_site(SiteID,'n');

c = ['load \\paoa001\sites\' FolderName '\hhour\' dateString Extension '.mat'];
eval(c);

if upper(SiteID) == 'JP'
   ch_pl_hhour_new(stats,SiteID);
else
   ch_pl_hhour(stats,SiteID);
end

close all;


