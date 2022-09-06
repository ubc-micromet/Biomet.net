function filename = ta_file(year,site,level)
%
% Create paths for different sites/years/stage of analysis.
%
% inputs
%       Year            
%       SiteID          'XX'    where xx stands for 'CR', 'JP', 'BS', 'PA' sites
%                               default is obtained by running FR_current_site_id.m
%       level           1 or 2  for first or second level cleaning
%
% (c) kai*                      File created:             2001
%

if ~exist('year') | isempty(year)
    [year,mm,dd,hh,mm,ss] = datevec(now);
end

if ~ischar(year)
    year = num2str(year);
end

if ~exist('site') | isempty(site)
    site = fr_current_siteID;
end

if ~exist('level') | isempty(level)
    level = 1;
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

dbase_path = biomet_path(year,site,'cl');
ind_slash = find(dbase_path == '\');
    
filename = [dbase_path(1:ind_slash(end-1)) 'TraceAnalysis\' site '_' year stage];