function [zipOK] = testZip (sites)
% testZip: zip file status on \\PAOA001
%
%   Input: sites[], string vector with the acronym of each site
%           eg. sites=['CR   '; 'OY   '; 'YF   '; 'PAOA '; 'PAOB '; 'HJP02'; 'HJP75'; 'PAOJ ']
%   Output: zipOK[], numeric vector with binary data showing the
%   presence or absence of the site zip files.
%
%               1 - the zip file is present for that site
%               2 - the zip file is absent for that site
%
%           eg. zipOK=[1 1 1 1 1 0 1 1]
%               would show the zip file for each site is present but
%               the hhour file for HJP02 is absent

CScurrentDOY = num2str(floor(fr_get_DOY(datenum(now), 0))); %Campbell Scientif DOY
currentDOY = num2str(floor(fr_get_DOY(datenum(now), 1))); %normal DOY
currentYear = datestr(datenum(now),'yyyy'); %current Year

for i=1:1:(size(sites,1)) % number of rows = number of sites  
    % for all sites but PAOJ the path follows this example \\PAOA001\SITES\CR\dailyZip\old\CR_2004_350.zip
    path=strcat('\\PAOA001\SITES\',sites(i,:),'\dailyZip\old\',sites(i,:),'_',currentYear,'_',CScurrentDOY,'.zip');

    if exist (path) == 2    % MATLAB built in function exist returns 2 if the file is present
        zipOK(i) = 1;        %set the appropriate cell of the vector high if the file is present
    else
        zipOK(i) = 0;        %else set it low
    end  
end

% PAOJ example path is \\PAOA001\SITES\PAOJ\dailyZip\old\349_2004.zip
PAOJZip=strcat('\\PAOA001\SITES\PAOJ\dailyZip\old\',currentDOY,'_',currentYear,'.zip');

if exist(PAOJZip) == 2      % MATLAB built in function exist returns 2 if the file is present
    zipOK(size(sites,1))=1;  %set the appropriate cell of the vector high if the file is present
else
    zipOK(size(sites,1))=0;  %else set it low
end