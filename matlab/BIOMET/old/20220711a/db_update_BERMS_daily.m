function db_update_BERMS_daily(Sites,Years,extensions)
% db_update_BEMRS_daily - Run updates for BERMS climate data
%
% db_update_BEMRS_daily(Sites,Years) runs specific sites and years
% 
% db_update_BEMRS_daily(Sites,Years,{'.vw2'}) runs update of *.vw2 files
% for specific sites and years. List of extenstions must be a cell array 
% and must include the dot!
%
% db_update_BEMRS_daily([],Years) runs all site for specific years
%
% db_update_BEMRS_daily updates ALL sites for all years available for each site


% Revisions:
% Dec 20, 2007
%   -updated db path for new Annex001 file server (Nick)
% May 23, 2006 - Nick fixed incorrect parsing of msc directory (had to
%                 remove "\" before appending "_msc".
% May 03, 2006 - kai*: using function db_pth_root
% Apr 21, 2004 - kai*: Included the use of extensions
% Feb  9, 2004 - kai* & Joe: Added Year to the list of arguments

Sites_all = {'BS' 'HJP02' 'HJP75' 'JP' 'PA'};
Year_start = [1999 2003 2004 1999 1996];

if ~exist('Sites') | isempty(Sites)
   Sites = Sites_all;
end

if ~iscellstr(Sites)
    Sites = cellstr(Sites);
end
Sites = upper(Sites);

if ~exist('Years') | isempty(Years)
   Year_current = datevec(now);
   Year_current = Year_current(1);

   [SiteId_dum,ind_sites_all,ind_sites] = intersect(Sites_all,Sites);
   Year_start(ind_sites) = Year_start(ind_sites_all);
else

end

if ~exist('extensions') | isempty(extensions)
    extensions = [];
end

%------------------------------------------------------------------
% Updating BERMS climate data
%------------------------------------------------------------------
% pth_db_msc = [db_pth_root '_msc'];
pth_db     = db_pth_root;
pth_db_msc = [pth_db(1:end-1) '_MSC\'];  % Nick fixed bug with parsing of database_msc directory
for j = 1:length(Sites)
   if exist('Year_current')
        Years = Year_start(j):Year_current;
   end
   for i = 1:length(Years)
      db_update_berms (pth_db_msc,pth_db,Years(i),char(Sites(j)),extensions);
   end
end

