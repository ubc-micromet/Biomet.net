function [precipOut , Precip_24h,tv,tv_GMT] = fr_YF_Daily_Precip(singleDay,standardTime)
%
% [precipOut , Precip_24h,tv,tv_GMT] = fr_YF_Daily_Precip(now,4)
%     will return total precip for for 4am local STANDARD time (4 am
%     yesterday to 4 am today)
%
% (c) Zoran Nesic           File created:       Feb 25, 2008
%                           Last modification:  Feb 25, 2008
%

% Revisions:


yearX = str2double(datestr(singleDay-1,'yyyy'));
pth = biomet_path(yearX,'yf','cl');

% There is two tipping buckets over there. One has a snow melting adapter
% (second one?)
Precip_24h(:,1) = read_bor(fullfile(pth,'YF_CLIM_60.33'));
Precip_24h(:,2) = read_bor(fullfile(pth,'YF_CLIM_60.34'));

tv_GMT = read_bor(fullfile(pth,'YF_Clim_60_tv'),8);

%save c:\ubc_flux\ftp\debug1

tv =  tv_GMT - 8/24;
lastDay = floor(singleDay)-1 + standardTime/24;            % data for period 4am - 4am
ind48 = find(tv > lastDay & tv <= lastDay+1);
tv = tv(ind48);
tv_GMT = tv_GMT(ind48);
Precip_24h = Precip_24h(ind48,:);
precipOut = sum(Precip_24h);
precipOut(precipOut < 0) = 0;

%save c:\ubc_flux\ftp\debug2
