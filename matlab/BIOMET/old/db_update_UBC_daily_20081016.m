function db_update_UBC_daily(Sites,Site_name,Site_eddy,no_days_back)
% db_update_UBC_daily(Sites,Site_name,Site_eddy) Run all database updates for UBC systems
%
% e.g. db_update_UBC_daily({'CR'},{'CR'},{'Eddy'}) updates the Eddy database with any new
% short files from the last 20 days.
% 
% Updates the database for
% 1) Fluxes
% 2) Calibration files
% 3) Calibrations from mat files
% 4) Profile systems
% 5) RMY array

% Revisions:
% May 03, 2003 - kai* - Using \\paoa001 path name
% Dec 19, 2003 - kai* - Removed hardcoded 2003, disabled flux logger
% Nov 24, 2003 - kai* - Disables RMY calculations at the site and db update in the lab


if ~exist('Sites') | isempty(Sites)
   Sites     = {'BS' 'CR' 'HJP02' 'HJP75' 'JP' 'PA' 'OY' 'YF'};
   Site_name = {'PAOB' 'CR' 'HJP02' 'HJP75' 'PAOJ' 'PAOA' 'OY' 'YF'};
   Site_eddy = {'Eddy' 'Eddy' 'MainEddy' 'MainEddy' 'Eddy' 'Eddy' 'MainEddy' 'MainEddy'};
end

% No of days before today that will be checked for new mat-files
arg_default('no_days_back',20);

Year = datevec(now);
Year = Year(1);
Year_str = num2str(Year);
pth_db = fullfile(db_pth_root,'');

for i = 1:length(Sites)
   SiteId = char(Sites(i));
   SiteNm = char(Site_name(i));
   fr_set_site(SiteId,'n');
   
   %------------------------------------------------------------------
   % Path definitions
   %------------------------------------------------------------------
   pth_new_mat_files = ['\\paoa001\Sites\' SiteNm '\HHour'];
   pth_cal_files = pth_new_mat_files;
   pth_update_lst = fullfile(db_pth_root,num2str(Year),SiteId,'');
   
   %------------------------------------------------------------------
   % Updating the Eddy data
   %------------------------------------------------------------------
   switch upper(SiteId)
   case {'OY'}
      wc = ['*s.h' SiteId '.mat'];
   case {'HJP02' 'HJP75'}
      wc = ['*.h' SiteId '.mat'];
   case {'PA','BS'}
      wc = ['*.h' SiteId(1) '.mat'];
   otherwise
      wc = ['*s.h' SiteId(1) '.mat'];
   end
   try
      db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,char(Site_eddy(i)),SiteId,no_days_back);
   catch
      lasterr   
   end
   
   %------------------------------------------------------------------
   % Updateing the chamber system data - same wc as above!
   switch upper(SiteId)
   case {'BS' 'PA' 'YF'}
      sys = 'Chambers';
      wc = ['*s.h' SiteId(1) '_ch.mat'];
      try
         db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      catch
         lasterr   
      end
   end   
   
   %------------------------------------------------------------------
   % Stuff particular to the main sites
   switch upper(SiteId)
   case {'BS' 'CR' 'JP' 'PA'}
      %------------------------------------------------------------------
      % Licor calibrations - cal file info
      %------------------------------------------------------------------
      pth_db_cal = [pth_db Year_str '\' SiteId];
      try
         db_main_cal_file(SiteId,pth_cal_files,pth_db_cal,Year);
      catch
         lasterr   
      end
      
      %------------------------------------------------------------------
      % Licor calibrations - stats file info
      %------------------------------------------------------------------
      sys = 'cal_stats';
      wc = ['*s.h' SiteId(1) '.mat'];
      try
         db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      catch
         lasterr   
      end
      
      %------------------------------------------------------------------
      % Profile System
      %------------------------------------------------------------------
      sys = 'profile';
      wc = ['*s.h' SiteId(1) '.mat'];
      try
         db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      catch
         lasterr   
      end
   end
   
   %------------------------------------------------------------------
   % Stuff particular to one site
   switch upper(SiteId)
   case {'CR'}
      %------------------------------------------------------------------
      % RMY Array
      %------------------------------------------------------------------
      % Disables RMY calculations at the site and db update in the lab on Nov 24, 2003
      % sys = 'rmy';
      % pth_db = ['Y:\DataBase\' Year_str '\' SiteId '\TurbulenceProfile'];
      % wc = ['*s.h' SiteId(1) '_rmy.mat'];
      % lst_old = dir(fullfile(pth_new_mat_files,wc));
      % db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      %------------------------------------------------------------------
      % Paul's chamber
      %------------------------------------------------------------------
      sys = 'chamber_paul';
      wc = ['*s.h' SiteId(1) '_ch.mat'];
      lst_old = dir(fullfile(pth_new_mat_files,wc));
      try
         db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      end
   case {'OY'}
      %------------------------------------------------------------------
      % Updating the original OY database from logger files
      %------------------------------------------------------------------
      % try
      %   oy_db_update('OY',1:floor(now-1),Year,'y:\');
      % catch
      %   lasterr   
      %end
   end
   
end

