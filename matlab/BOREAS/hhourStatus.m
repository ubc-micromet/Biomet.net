function [hhourOK] = testHhour (sites)
% testHhour: hhour file status on \\PAOA001
%
%   Input: sites[], string vector with the acronym of each site
%           eg. sites=['CR   '; 'OY   '; 'YF   '; 'PAOA '; 'PAOB '; 'HJP02'; 'HJP75'; 'PAOJ ']
%   Output: hhourOK[], numeric vector with binary data showing the
%   presence or absence of the site CSI_net files.
%
%               1 - the hhour file is present for that site
%               2 - the hhour file is absent for that site
%
%           eg. hhourOK=[1 1 1 1 1 0 1 1]
%               would show the hhour file for each site is present but
%               the hhour file for HJP02 is absent
%
%   Note: The sites with chambers (CR, PAOA, and PAOB) have short hhour
%   files for current day in addition to the full files for the previous
%   day. Currently this function only looks for the full files for the
%   previous day.

% yesterday's date in 'yymmdd' format
yesterdayDate = strcat(datestr(datenum(now),'yy'),datestr(datenum(now),'mm'),datestr(datenum(now-1),'dd'));

for i=1:1:size(sites,1)  
    if sites(i,:) == 'HJP75' % HJP75 is the only site that does not use the short hhour files for plotting
        % set the first part of the path to \\PAOA001\SITES\HJP75\hhour\"yymmdd".h
        pathTemp=strcat('\\PAOA001\SITES\',sites(i,:),'\hhour\',yesterdayDate,'.h');
    else
        % set the first part of the path to \\PAOA001\SITES\"SITE"\hhour\"yymmdd".sh
        pathTemp=strcat('\\PAOA001\SITES\',sites(i,:),'\hhour\',yesterdayDate,'s.h');
    end
        
    if sites(i,:) == 'CR   '
        hhourPath=strcat(pathTemp(1,:),'c.mat');    % eg. \\PAOA001\SITES\CR\hhour\041214s.hc.mat
    elseif sites(i,:) == 'OY   '
        hhourPath=strcat(pathTemp(1,:),'OY.mat');   % eg. \\PAOA001\SITES\OY\hhour\041214s.hOY.mat
    elseif sites(i,:) == 'YF   '
        hhourPath=strcat(pathTemp(1,:),'y.mat');    % eg. \\PAOA001\SITES\YF\hhour\041214s.hy.mat
    elseif sites(i,:) == 'PAOA '
        hhourPath=strcat(pathTemp(1,:),'p.mat');    % eg. \\PAOA001\SITES\PAOA\hhour\041214s.hp.mat
    elseif sites(i,:) == 'PAOB '
        hhourPath=strcat(pathTemp(1,:),'b.mat');    % eg. \\PAOA001\SITES\PAOB\hhour\041214s.hb.mat
    elseif sites(i,:) == 'HJP02'
        hhourPath=strcat(pathTemp(1,:),'HJP02.mat');    % eg. \\PAOA001\SITES\HJP02\hhour\041214s.hHJP02.mat
    elseif sites(i,:) == 'HJP75'
        hhourPath=strcat(pathTemp(1,:),'HJP75.mat');    % eg. \\PAOA001\SITES\HJP75\hhour\041214s.hHJP75.mat
    elseif sites(i,:) == 'PAOJ '
        hhourPath=strcat(pathTemp(1,:),'j.mat');        % eg. \\PAOA001\SITES\PAOJ\hhour\041214s.hj.mat
    else
        
    end
    
    if exist (hhourPath) == 2 % MATLAB built in function exist returns 2 if the file is present
        hhourOK(i) = 1;  %set the appropriate cell of the vector high if the file is present
    else
        hhourOK(i) = 0;  %else set it low
    end  
end