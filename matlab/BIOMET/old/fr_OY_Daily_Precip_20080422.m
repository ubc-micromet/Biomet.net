function [precipOut , Pgeonor,tv,tv_GMT] = fr_OY_Daily_Precip(singleDay,standardTime)
%
% [precipOut , Pgeonor,tv,tv_GMT] = fr_OY_Daily_Precip(now,4)
%     will return total precip for for 4am local STANDARD time (4 am
%     yesterday to 4 am today)
%
% (c) Zoran Nesic           File created:       Feb  2, 2008
%                           Last modification:  Apr  6, 2008
%

% Revisions:
%   Apr 6, 2008
%     - changed precip calculations from Pgeonor(end)-Pgeonor(1) to
%     max(Pgeonor)-min(Pgeonor) because of a possibility that the if the
%     data hasn't been downloaded for the last half hour Pgeonor(end)=0.
%   Feb 25, 2008
%       - added standardTime variable as an input parameter (they want data at
%       4am local time, they don't care about GMT or standard time so this needs to be an input)
%   Feb 23, 2008
%       - made it year independent

% pth = biomet_path('yyyy','oy','cl');        % find data base path for year = 'yyyy' 
%                                             % and fill in the defaults (site name, data type)
% Year = ???

pth = biomet_path('yyyy','oy','cl');
yearX = str2double(datestr(singleDay-1,'yyyy'));

Pgeonor = read_bor(fullfile(pth,'oy_climt\pre_avg'),[],yearX);
%Pgeonor = read_bor('\\annex001\database\2008\oy\climate\oy_climt\pre_avg');

tv_GMT = read_bor(fullfile(pth,'oy_climt\oy_climt_tv'),8,yearX);
%tv_GMT = read_bor('\\annex001\database\2008\oy\climate\oy_climt\oy_climt_tv',8);

tv =  tv_GMT - 8/24;
lastDay = floor(singleDay)-1 + standardTime/24;            % data for period 4am - 4am
ind48 = find(tv > lastDay & tv <= lastDay+1);
tv = tv(ind48);
tv_GMT = tv_GMT(ind48);
Pgeonor = Pgeonor(ind48);
Pgeonor = Pgeonor(Pgeonor>0);
precipOut = max(Pgeonor) - min(Pgeonor);
if precipOut < 0
    precipOut = 0;
end

%plot(tv,Pgeonor);datetick('x')

