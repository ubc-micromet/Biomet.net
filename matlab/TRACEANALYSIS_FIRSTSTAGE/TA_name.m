function filename = ta_name(year,site,level)
% filename = ta_name(year,site,level)
%
% Traceanalysis support function
% For a given site, year and stage (level) filename contains the path and name of the 
% inifile at the proper database location.
%
% kai* May 30, 2001

if ~exist('site') | isempty(site)
    site = fr_current_siteID;
end

if ~exist('year') | isempty(year)
    [year,mm,dd,hh,mm,ss] = datevec(now);
end

if ~exist('level') | isempty(level)
    level = 1;
end

if ~ischar(year)
    year = num2str(year);
end

if ischar(level)
    stage = level;
else
    switch level
    case 1
        stage = '_FirstStage';
    case 2
        stage = '_SecondStage';
    otherwise
        disp('Please give stage (1 or 2) of cleaning');
        return
    end
end
    
filename = [biomet_path(year,site,'ta') site '_' year stage];