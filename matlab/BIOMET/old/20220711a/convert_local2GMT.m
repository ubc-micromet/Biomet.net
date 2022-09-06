function [tv_GMT,GMToffset] = convert_local2GMT(tv_local,GMToffset,reverseConversion)
% [tv_GMT,GMToffset] = convert_local2GMT(tv_local,GMToffset)
%
% Inputs:
%   tv_local        - local time (matlab datenum format is used)
%   GTMoffset       - GMT offset for that location (8 hours for Pacific time, 6 hours for
%                     Central (integer).
%   reverseConversion - if different from 0, convert GMT to local time
%
% Outputs:
%   tv_GMT          - GMT time (Universal time, matlab datenum format is used)
%   GMToffset       - GMToffset used for conversion (integer)
%
%
% Conversion of local time to GMT time taking in account daylight saving time
% Currently works only for USA/Canada 
% DST is from 2am second Sunday in March until 2 am first Sunday in
% November.
%
% NOTE: USE ONLY WITH SITES WHERE DST IS OBSERVED.  DO NOT USE IN SASKATCHEWAN!
% Note: for converting of large arrays of tv_local, use 
%
% References:
% http://www.timeanddate.com/news/time/us-daylight-saving-starts-march-9-2008.html
%
% (c) Zoran Nesic                   File created:       July 8, 2008
%                                   Last modification:  July 8, 2008

% Revisions:


% convert time vector to date vector
dv = datevec(tv_local);

% Check if all data belongs to the same year
if size(dv,2) > 1
    if dv(1,1) ~= dv(end,1)
        error('Entire time vector must belong to one year!');
    end
end

% find DST start
yearX = dv(1);
tv = datenum(yearX,3,1:31);
indStart = (strfind(reshape(datestr(tv,8)',1, length(tv)*3),'Sun')-1)/3+1;
indStart = indStart(2);datestr(datenum(yearX,3,indStart));
% find DST end
tv = datenum(yearX,11,1:30);
indEnd = (strfind(reshape(datestr(tv,8)',1, length(tv)*3),'Sun')-1)/3+1;
indEnd = indEnd(1);datestr(datenum(yearX,11,indEnd));

DSTstart = datenum(yearX,3,indStart,2,0,0);
DSTend = datenum(yearX,11,indEnd,2,0,0);
%datestr([DSTstart DSTend]);
indDaylightSaving = find(tv_local>= DSTstart & tv_local<= DSTend);
GMToffset = GMToffset*ones(size(tv_local));
GMToffset(indDaylightSaving) = GMToffset(indDaylightSaving) - 1;

if reverseConversion == 0
    tv_GMT = tv_local + GMToffset/24;
else
    tv_GMT = tv_local - GMToffset/24;
end

