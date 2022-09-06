function x = DB_create_cal_stats(pth,Year)
%
% based on db_create_eddy   File created:       Aug  1, 2003
%                           Last modification:  Aug  1, 2003
 
%
% Revisions:
%

%
%pth = 'c:\cd-rom\CR_DBASE\_' num2str(rmy_no) ];
%siteID = 'CR_' num2str(rmy_no) ];

if exist('Year') ~= 1 | isempty(Year)
   Year = datevec(now);
   Year = Year(1);
end

hhours_per_hour = 2;
st = datenum(Year,1,1,0.5,0,0);
ed = datenum(Year+1,1,1,0,0,0);

maxFiles = 6;
% Channels are
% co2_span co2_off h2o_span h2o_off licorNum span_conc
% Create the files
fileName = ['cal_stats' ];
[x] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

