function db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days)
%db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days)
%
% Inputs:
%
% pth_new_mat_files     - path for the mat files to be used in update
% pth_db                - databasepth
% pth_update_lst        - path where the list of old files resides
% wc                    - wild card for files to be used in update
% sys                   - name of structure element to be used in update
% SiteId                - the usual
% no_days               - no of days before today to be used in update (default 0 - no restriction)

%Revisions:
% Nov 09, 2004 - kai* & Joe fixed concatenation of dissimilar structures error (copied solution 
%                from db_new_eddy
% Sep 07, 2004 - Paul, Christopher, kai* fixed bug that used db_new_eddy with old mat files
% Feb 12, 2004 - kai* used fullfile to generate diary.log file

if ~exist('no_days') | isempty(no_days)
   no_days = 0;
end

switch upper(SiteId)
case {'BS'}
   SiteName = 'PAOB';
case {'JP'}
   SiteName = 'PAOJ';
case {'PA'}
   SiteName = 'PAOA';
otherwise
   SiteName = SiteId;
end

if exist(fullfile(pth_update_lst,['lst_old_' SiteId '_' sys '.mat']));
   load(fullfile(pth_update_lst,['lst_old_' SiteId '_' sys '.mat']))
else
   lst_old = [];
end

lst_new = dir(fullfile(pth_new_mat_files,wc));

if isempty(lst_new)
   disp([upper(SiteId) ' - ' upper(sys) ' - No files ' fullfile(pth_new_mat_files,wc) ' found. Have a nice day!']);
   return
end

names   = char({lst_new(:).name}');
tv_new  = datenum( mod(2000+str2num(names(:,1:2)),2050),str2num(names(:,3:4)),str2num(names(:,5:6)));

if no_days > 0
   lst_new = lst_new(find( tv_new>=floor(now-no_days) ));
end

lst_diff = find_new_files(lst_old,lst_new);

if isempty(lst_diff)
   disp([upper(SiteId) ' - ' upper(sys) ' - No new files found. Have a nice day!']);
   return
end

names   = char({lst_diff(:).name}');
yy_all = mod(2000+str2num(names(:,1:2)),2050);
yy_unique = unique(yy_all);
if length(yy_unique)>1
   names   = char({lst_new(:).name}');
   yy_all = mod(2000+str2num(names(:,1:2)),2050);
   lst_new = lst_new(find(yy_all==yy_unique(1)));
   lst_diff = find_new_files(lst_old,lst_new);
end

if isempty(lst_diff)
   disp([upper(SiteId) ' - ' upper(sys) ' - No new files found. Have a nice day!']);
   return
end

Year = yy_unique(1);
Year_str = num2str(Year);
if strcmp(upper(SiteId),'OY') & Year<2004 & strcmp(lower(sys),'flux')
   pth_db = [pth_db Year_str '\' SiteId '\flux\pc'];
elseif strcmp(upper(SiteId),'CR') & strcmp(lower(sys),'chamber_paul')
   pth_db = [pth_db Year_str '\' SiteId '\Chambers'];
elseif strcmp(lower(sys),'eddy') | strcmp(lower(sys),'maineddy')
   pth_db = [pth_db Year_str '\' SiteId '\Flux'];
elseif strcmp(lower(sys),'cal_stats')
   pth_db = [pth_db Year_str '\' SiteId '\'];
else
   pth_db = [pth_db Year_str '\' SiteId '\' sys];
end

diary(fullfile(pth_update_lst,['dbase_' sys '.log']))
disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('Variables: '));
disp(sprintf('pthIn = %s',pth_new_mat_files));
disp(sprintf('wildcard = %s',wc));
disp(sprintf('pthOut = %s',pth_db));
disp(sprintf('system_fieldname = %s',sys));
if length(unique(yy_all))>1
   disp([upper(SiteId) ' - ' upper(sys) ' - more than one year needs updating. Only ' num2str(yy_unique(1)) ' done.']);
   disp(['Run again to complete.']);
end

k = 0;
tic;
% Do only 10 days at a time
for n_beg = 1:10:length(lst_diff)
   n_end = min(n_beg+9,length(lst_diff));
   try
      % One block of 10 days
      StatsAll = [];
      for i = n_beg:n_end
         fileName = char(lst_diff(i).name);
         disp(['Processing: ' SiteId ' - ' fileName]);
         x = load(fullfile(pth_new_mat_files,fileName));
         if strcmp(sys,'MainEddy')
            out = db_update_neweddy(x.Stats,pth_db,sys);
            % Concatenate Stats structures
            if length(StatsAll) == 0
               StatsAll = x.Stats;
               StatsAll = ubc_orderfields(StatsAll);
            else
               try
                  Stats = x.Stats;
                  % Test for differences in field names
                  fieldsStats = fieldnames(Stats);
                  fieldsStatsAll = fieldnames(StatsAll);
                  diff1 = setdiff(fieldsStats,fieldsStatsAll);
                  diff2 = setdiff(fieldsStatsAll,fieldsStats);
                  
                  % Fix differences
                  if ~isempty(diff1)
                     for l = 1:length(diff1)
                        eval(['StatsAll(1).' char(diff1(l)) ' = [];']);
                     end
                     StatsAll = ubc_orderfields(StatsAll);
                  end
                  
                  if ~isempty(diff2)
                     for l = 1:length(diff2)
                        eval(['Stats(1).' char(diff2(l)) ' = [];']);
                     end
                  end               
                  Stats = ubc_orderfields(Stats);
                  
                  % Assemble structure
                  StatsAll(length(StatsAll)+1:length(StatsAll)+length(Stats)) = Stats;
               catch
                  disp(lasterr);
               end
            end
         else
            eval(['out = db_update_' sys '(x.stats,pth_db);']);
         end
         
         k = k+1;
      end
      
      if ~isempty(StatsAll)
         % Update database for new_eddy mat files
         db_new_eddy(StatsAll,[],pth_db);
      end
      
      disp(sprintf(['%d ' upper(SiteId) ' files processed in %d seconds.'],round([k toc])))
      
      % Sort the list according to names
      lst_old = [lst_old;lst_diff(n_beg:n_end)];
      [dum,ind] = sort({lst_old(:).name}');
      lst_old = lst_old(ind);
      save(fullfile(pth_update_lst,['lst_old_'  SiteId '_' sys ]),'lst_old');
   catch
      disp('Could not finish processing');
      disp(lasterr);
   end
end

disp(sprintf('Number of files processed = %d',k));
disp(sprintf('==============  End    ========================================='));
disp(sprintf(''));
diary off
