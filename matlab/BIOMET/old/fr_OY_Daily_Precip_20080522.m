function [precipOut , Pgeonor,tv,tv_GMT] = fr_OY_Daily_Precip(singleDay,standardTime)
%
% [precipOut , Pgeonor,tv,tv_GMT] = fr_OY_Daily_Precip(now,4)
%     will return total precip for for 4am local STANDARD time (4 am
%     yesterday to 4 am today)
%
% (c) Zoran Nesic           File created:       Feb  2, 2008
%                           Last modification:  Apr 21, 2008
%

% Revisions:
%   Apr 21, 2008
%     - added Kai's processing of Geonor from plt_oy.m and then made the 
%       the trace monotonicaly raise to reomove the daily variations.
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

Pgeonor_old = Pgeonor;
Pgeonor = geonor_fix(Pgeonor);

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

function cumprecip = geonor_fix(P_cum_all)

% Find index of bucket emptying, i.e. exclude events when
% data is dropping and coming back up again
P_cum_diff = diff(P_cum_all);
ind_neg = find(P_cum_diff<-50);
ind_neg = ind_neg(1:end-1); % Last drop is always there
ind_pos = find(P_cum_diff>50);
ind_pair = [];
for i = 1:length(ind_pos)
    ind_pair_tmp = find(ind_pos(i)-ind_neg<3*48 & ind_pos(i)-ind_neg>0); % Find jump up within 3 days
    ind_pair = [ind_pair ; ind_pair_tmp];
end
ind_pair = unique(ind_pair);
ind_neg = ind_neg(setdiff(1:length(ind_neg),ind_pair));

cumprecip = P_cum_all;
for i  = 1:length(ind_neg)
    cumprecip(ind_neg(i)+1:end) = cumprecip(ind_neg(i)+1:end)-P_cum_diff(ind_neg(i));
end
cumprecip = cumprecip - P_cum_all(1);

for i=2:length(cumprecip)
    if cumprecip(i-1)>=cumprecip(i) || cumprecip(i) ==0
        cumprecip(i)=cumprecip(i-1);
    else
        %        Pgeonor1(i) = Pgeonor1(i-1) + (Pgeonor1(i)-Pgeonor1(i-1));
    end
end
