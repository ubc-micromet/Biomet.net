function [DecDOY,year] = fr_get_doy(dateIN,formatFlag)
%
%   This procedure calculates decimal time and year for the given
%   vector/scalar dateIN. dateIN is a DATE variable as used by
%   Windows/Matlab 5.x (see datestr,datevec,datenum Matlab functions)
%
%   if formatFlag=1 or not used the program defaults to calculating
%   decimal time (Jan 1, 1998 at 12noon => DecDOY = 0.5, year = 1998)
%   else if formatFlag == 0 then program calculates Julian day the
%   way the Campbell Sci. does it: (Jan 1, 1998 at 12noon => DecDOY = 1.5,
%   year = 1998)
%   
% (c) Zoran Nesic           File created:       Jan 3, 1998
%                           Last modification:  Mar 6, 2000

%
% Revisions:
%
%   Mar 6, 2000
%       - changed the algorithm. Speed increase of 13x for a 4-year
%         trace on a P166/64MB
%

if ~exist('formatFlag')
    formatFlag = 1;                             % assume decimal time 
end

% Removed Mar 6, 2000
%[year m]    = datevec(dateIN);                  % find the year
% Replaced with:
i1 = datevec(dateIN(1));
i2 = datevec(dateIN(end));
year = zeros(size(dateIN));
TimeOffset = zeros(size(dateIN));
for i=i1:i2;
    st = datenum(i,1,1);
    ed=datenum(i+1,1,1);
    ind = find(dateIN >= st & dateIN < ed);
    year(ind) = i;
    TimeOffset(ind) = datenum(i,1,1,0,0,0);
end;
% ---- end of new stuff ---------

% removed Mar 6, 2000
%TimeOffset  = datenum(year,1,1,0,0,0);          % date serial corresponding to Jan 1, year

DecDOY      = dateIN - TimeOffset;              % calculate decimal time

if formatFlag == 0                              % if DOY is requested
    DecDOY      = DecDOY + 1;                   % DOY = dec.time + 1
end                                                