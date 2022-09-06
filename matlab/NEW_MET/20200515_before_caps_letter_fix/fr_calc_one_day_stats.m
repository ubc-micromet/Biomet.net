function stats = fr_calc_one_day_stats(SiteFlag,year,month,day,LocalTime)
%
% For the given year, month and day this function calculates
% fluxes for 24h day (LOCAL TIME by default (0 - 24h) use LocalTime flag
% for GMT time).
%
%
% (c) Zoran Nesic           File created:       Jan  3, 1998
%                           Last modification:  May  6, 1998
%

%
% Revisions:
%
%   May  6, 1998
%       -   changed startDate and endDate from structures to date/time format
%   Feb 25, 1998
%       -   introduced LocalTime flag. When LocalTime == 1 (default)
%           one day is calculated using local time. When LocalTime ~= 1
%           one day is GMT time.
%
%   Feb 10, 1998
%       -   changed the program so it reflectes the changes in FR_calc_main.m
%       -   output is now a structure (stats). See FR_calc_main.m for details.
%       -   created new function (FR_get_offsetGMT) that calculates GMT offset
%           for the given site ID

if ~(exist('LocalTime')== 1)
    LocalTime = 1;
end

if LocalTime == 1
   offsetGMT       = FR_get_offsetGMT(SiteFlag);
else
   offsetGMT       = 0;
end

startDate   = datenum(year,month,day,0.5+offsetGMT, 0,0);
endDate     = datenum(year,month,day,24 +offsetGMT, 0,0);
                        
stats = fr_calc_main(SiteFlag,startDate,endDate);
