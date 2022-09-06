function trace_merged = merge_berms_dir(SiteId,clean_tv_in,trace_name,dir_lst)
%TRACE_MERGED = MERGE_BERMS_DIR(SITEID,TV,TRACE_NAME,DIR_LIST) Get best data from berms files
%
%   Reads TRACE_NAME from the SITEID\berms\DIR_LIST directories.
%   The data is read from the first directory and NaNs are replaced with data read 
%   from the second directory and so forth. That way the data in the first directory is 
%   preserved and it should therefore be the best available data. DIR_LIST has to 
%   be a cell array of strings.
%   TV is used to determine the year for which this is done. Only a single year of 
%   data can be replaced. 
%   The result is returned in TRACE_MERGED.
%
%   TRACE_MERGED = MERGE_BERMS_DIR(SITEID,TV,TRACE_NAME) assumes 
%   DIR_LIST = {'al3' 'al2' 'al1' 'all'}

% kai*, June 26, 2003

% Default 
if ~exist('dir_lst') | isempty(dir_lst)
   dir_lst = {'al3' 'al2' 'al1' 'all'};
end

[yy,mm,dd] = datevec(clean_tv_in);
% This is ugly but the same as in fr_get_al2;
Year_org = unique(yy);
Year = Year_org(1);
for i = 2:length(Year_org)
   if length(find(Year_org(i) == yy)) >1
      Year = [Year; Year_org(i)];
   end
end
   
   
pth_last = biomet_path('yyyy',SiteId,['berms\' char(dir_lst(end))]);
trace_tv = read_bor([pth_last 'clean_tv'],8,[],Year,[],1);
      
[tv_dum,ind_return] = intersect(round(trace_tv.*48)./48,round(clean_tv_in.*48)./48,'tv'); 

trace_empty = NaN .* trace_tv;
trace_merged = trace_empty;

for i = 1:length(dir_lst)
	dir_single = char(dir_lst(i));   
   % Create path
   eval(['pth_' dir_single ' = biomet_path(''yyyy'',SiteId,''berms\' dir_single ''');']);
   
   % Read data or create empty trace (in case data is not there yet)
   try
      eval(['trace_' dir_single ' = read_bor([pth_' dir_single ' trace_name],[],[],Year,[],1);']);
   catch
      eval(['trace_' dir_single ' = trace_empty;']);
   end
   
   % Do replacing
   ind_replace = find(isnan(trace_merged));
   eval(['trace_merged(ind_replace) = trace_' dir_single '(ind_replace);']);
end

trace_merged = trace_merged(ind_return);

return