function check_daily_updates
%CHECK_DAILY_UPDATES Find missing updates from log-file

days_HF = 5;  % days back to check to see if any long files have been copied over
              % to Annex001

pth_log = db_pth_root;
yy = datevec(now);
yy_str = num2str(yy(1));

% Sites     = {'BS' 'CR' 'HJP02' 'JP' 'PA' 'OY' 'YF'};
% hhour_new = {'BS' 'CR' 'HJP02' 'PA' 'OY' 'YF'}; % sites for which we receive HF data
% Site_name = {'PAOB' 'CR' 'HJP02' 'PAOJ' 'PAOA' 'OY' 'YF'};
% Site_eddy = {'Eddy' 'Eddy' 'MainEddy' 'Eddy' 'Eddy' 'MainEddy' 'MainEddy'};

% Aug 20, 2008: removed HJP02 after eddy system was moved to HJP94
Sites     = {'BS' 'PA' 'HDF11' 'YF' 'MPB1' 'HP09' 'HP11'};
hhour_new = {'BS' 'PA' 'HDF11' 'YF' 'MPB1' 'HP09' 'HP11'}; % sites for which we receive HF data
Site_name = {'BS' 'PA' 'HDF11' 'YF' 'MPB1' 'HP09' 'HP11'};
%Site_eddy = {'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy'};
numtest   = [ 4 4 4 4 2 2 2];

% update site list
%Sites     = {'BS' 'PA' 'HDF11' 'YF'};
%hhour_new = {'BS' 'PA' 'HDF11' 'YF'}; % sites for which we receive HF data
%Site_name = {'PAOB' 'PAOA' 'HDF11' 'YF'};
%Site_eddy = {'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy'};
%numtest   = [ 4  4  4];

lst_no_update = [];
new_hhour_files = [];

for i = 1:length(Sites)
    SiteId = char(Sites(i));
    SiteNm = char(Site_name(i));
    
    lst_log = dir(fullfile(pth_log,yy_str,SiteId,'dbase*.log'));
    lst_cln = dir(fullfile(pth_log,yy_str,SiteId,'automated_cleaning.log'));
    lst_mat = dir(fullfile(pth_log,yy_str,SiteId,'*.mat'));
    
    % commented out--looking in the wrong directory  NG May 23, 2007
    %lst_cp  = dir(fullfile(pth_log,yy_str,SiteId,'hhour_copy.log'));
    
    if ismember(Sites(i),hhour_new)  % JP hhour database is no longer updated at UBC
        lst_cp  = dir(fullfile(pth_log,yy_str,SiteId,'hhour_database','hhour_copy.log'));  
    else
        lst_cp = [];
    end
    lst_all = [lst_log; lst_cln; lst_mat; lst_cp];
    
    tv_last_update = datenum(char({lst_all(:).date}'));
    ind_no_update = find(tv_last_update < floor(now));
    
    if ~isempty(ind_no_update)
        for j = 1:length(ind_no_update), lst_all(ind_no_update(j)).site = SiteId; end
        
        lst_no_update = [lst_no_update; lst_all(ind_no_update)];
    end
    
%    if ~isempty(lst_cp) & [lst_cp.bytes]>30
%         new_hhour_files = [new_hhour_files ' ' SiteId];
%    end
    
    % Nick changed the test criteria for new HF data--now any data that is
   % copied over to Annex001 in the last 3 days will show up
   
   if ismember(Sites(i),hhour_new) & now-datenum(yy(1),1,0) > days_HF % only applies to sites we get HF data from
       fn_cp  = fullfile(pth_log,yy_str,SiteId,'hhour_database','hhour_copy.log');
       
       %read in the first character of each line of the log file
       try
           [numfiles]=textread(fn_cp,'%c%*[^\n]');
           ind_eql = find( numfiles == '='); % find the separator for the log entries
           %if length(numfiles)- ind_eql(end-(days_HF-1)) > days_HF*4-1
           %if length(numfiles) - ind_eql(end-(days_HF-1)) > days_HF*numtest(i)-1
           if length(numfiles) - (ind_eql(end)-ind_eql(days_HF-1)) > days_HF*numtest(i)-1 % Nick, Jan 5, 2011
               new_hhour_files = [new_hhour_files ' ' SiteId];
           end
       catch
           new_hhour_files = '';
       end
   else
       new_hhour_files = '';
   end
end

n = length(lst_no_update);
if n>0
    report_log = [char({lst_no_update(:).site}') ones(n,1)*' ' ...
            char({lst_no_update(:).name}') ones(n,1)*' ' ...
            char({lst_no_update(:).date}') ones(n,1)*13];
    subject_line = [];
else
    report_log = 'All database updates done!';
end
if isempty(new_hhour_files)
    new_hhour_files = 'none';
end

message = [];   
message = [message sprintf('Update status at %s:\n',datestr(now))];
message = [message sprintf('%s\n',report_log')];
message = [message sprintf('\n')];
message = [message sprintf(['Sites with new hhour files copied to hhour_database in the last ' num2str(days_HF) ' days:\n'])];
message = [message sprintf('%s\n',new_hhour_files)];

fileName = fullfile(db_pth_root,'report.log');
fid = fopen(fileName,'w');
fprintf(fid,'%s\n',message);
fclose(fid);

if n==5
    subject_line = ' - all updates done';
else
    subject_line = [];
end
subject_line = ['Daily update' subject_line ' - new HF data: ' char(new_hhour_files)];

setpref('Internet',{'SMTP_Server','E_mail'},...
    {'smtp.interchange.ubc.ca','nesic'});
message = char(message)';
[n,m] = size(message');
message = [message; ' '.*ones(75-m,n)];

sendmail('zoran.nesic@ubc.ca',subject_line,message(:)');
sendmail('nick.grant@ubc.ca',subject_line,message(:)');
return
