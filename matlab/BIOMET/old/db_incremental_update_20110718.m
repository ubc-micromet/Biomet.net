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

% last modified: May 21, 2010

%Revisions:
% May 21, 2010
%   - removed db_update_neweddy function call on line 194: totally obselete
%   and only applied to OY and YF in order to create "old eddy" style trace
%   names from new eddy style. Assumed obselete Stats structure and was
%   crashing. (Nick)
% May 19, 2010
%   - added check for 'datenum' field in lst_new structure; this field is
%   returned in the structure variable produced from the "dir" command in
%   matlab 7.5.
% May 17, 2010
%   - added MPB1, MPB2 and MPB3 db updating for above canopy EC systems
%   (Nick)
% Oct 14, 2008
%   - added update for ACS system at CR (Nick)
% Sep 14, 2007 (Zoran & Nick)
%   - changed:
%       ind_long = sort([ind_0; setdiff(ind_1,ind_s); setdiff(ind_2,ind_s)]);
%     to:
%       if isempty(ind_s)
%           ind_long = ind_0;
%       else
%           ind_long = sort([ind_0; setdiff(ind_1,ind_s); setdiff(ind_2,ind_s)]);
%       end    
%    to avoid issues of doubling file names when there is no short files
%    (ind_s = [])
% Dec 21, 2005 - kai* put db_update_new_eddy into a try statement
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

% matlab 7.5 adds datenum field: added check to preserve backwards
% compatibility: May 19, 2010
if isfield(lst_new,'datenum') 
    lst_new = rmfield(lst_new,'datenum');
end

if ~isempty(lst_new)
    names   = char({lst_new(:).name}');
    tv_new  = datenum( mod(2000+str2num(names(:,1:2)),2050),str2num(names(:,3:4)),str2num(names(:,5:6)));
else
    names = [];
    tv_new = [];
end


% Find days for which both long and short files are present
%These are all the days for which there is at least one datafile
[tv_unique,ind_1] = unique(tv_new);
ind_diff = setdiff([1:length(tv_new)]',ind_1);
[tv_dum,ind_2] = intersect(tv_new(ind_diff),tv_new); 
%These are all the days for which there are two data files,
% however we do not know if the shortfile is ind_2 or ind_1
ind_2 = ind_diff(ind_2);
[tv_one,ind_0] = setdiff(tv_new,tv_new(ind_2));

% Find short files in doubles and discard
if ~isempty(names)
    ind_s = find(names(:,7) == 's');
else
    ind_s = [];
end


%-----Sep 14, 2007 (Zoran & Nick)----------
if isempty(ind_s)
    ind_long = ind_0;
else
    ind_long = sort([ind_0; setdiff(ind_1,ind_s); setdiff(ind_2,ind_s)]);
end    
%------------------------------------------

if ~isempty(ind_long)
    lst_new = lst_new(ind_long);
end
     

if isempty(lst_new)
   disp([upper(SiteId) ' - ' upper(sys) ' - No files ' fullfile(pth_new_mat_files,wc) ' found. Have a nice day!']);
   return
else
    names   = char({lst_new(:).name}');
    tv_new  = datenum( mod(2000+str2num(names(:,1:2)),2050),str2num(names(:,3:4)),str2num(names(:,5:6)));
end

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
%******* added 5/17/2010 *****************
elseif strcmp(lower(sys),'mpb_eddy')
   pth_db = [pth_db Year_str '\' SiteId '\Flux\Above_Canopy'];  
%*****************************************
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
         if (strcmp(sys,'MainEddy') | strcmp(sys,'MPB_Eddy'))
             % commented out May 21, 2010: obselete
%              if ~ismember(SiteId,{'MPB1','MPB2','MPB3'})
%                  try
%                      out = db_update_neweddy(x.Stats,pth_db,sys);
%                  catch
%                      disp('Could not update old database - but who cares, really?');
%                  end
%              end
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
        elseif strcmp(sys,'Chambers')
            eval(['out = db_update_' sys '(x.Stats,pth_db);']);
        
        % -- Oct 15/08: new option to handle automated chamber systems ----
        elseif strcmp(sys,'ACS-DC')
             db_new_eddy(x.HHour,[],pth_db,[],'DataHF');
        %------------------------------------------------------------------
        
        % ---- Jan 7, 2009: added below canopy sonic at CR ----------------
         elseif strcmp(sys,'below_canopy_sonic')
             db_new_eddy(x.Stats,[],pth_db,[],[]);
        % -----------------------------------------------------------------
        
%          % ---- May 17, 2010: added above-canopy EC at MPB1, MPB2 MPB3 ----
%          elseif strcmp(sys,'MPB_Eddy')
%              db_new_eddy(x.Stats,[],pth_db,[],[]);
%         % -----------------------------------------------------------------
         
         % ---- June 17, 2011: Gill R3 at the top of CR tower reactivated
         % as part of HDF11.
         elseif strcmp(sys,'tall_tower_sonic')
             db_new_eddy(x.Stats,[],pth_db,[],[]);


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
