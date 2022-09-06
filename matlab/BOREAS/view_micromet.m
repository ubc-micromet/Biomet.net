function view_micromet(dateRange,siteIDs,flgPause)
% view_micromet(dateRange,siteIDs)
%
% "view_sites" for Micromet sites
%
% Zoran Nesic           File created:       Jan 19, 2022
%                       Last modification:  Jan 19, 2022

% Revisions
%
%

arg_default('dateRange',now-10:now)
arg_default('siteIDs',{'BB1','BB2','DSM','RBM','Hogg','Young'})
arg_default('flgPause',1)

% get the year and the index. The index is DOY+1 to match
% view_sites indexing.
[yearX,~] = datevec(dateRange(end));
indDataRange = dateRange - datenum(yearX,1,1);

% cycle through the sites
close all
for cntSite = 1:length(siteIDs)
    siteID = char(siteIDs{cntSite});
    BB_pl(indDataRange,yearX,siteID,flgPause);
    if flgPause == 1
        runAndWait
    end
end
     
    
function runAndWait    %(sFunction)

% evalin('caller',sFunction);   
title_figure('Close all?')
pause
close all

%------------------------------

function title_figure(title_1)
    figure
    axes
    set(gca,'box','off','position',[0 0 1 1])
    text(0.1,0.5,title_1,'fontsize',28)
    drawnow
    