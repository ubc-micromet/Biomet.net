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
% May 5, 2011  - Nick - add MainEddy processing for HDF11
% Mar 22, 2011 - Nick -  added MainEddy processing for BS starting Mar 18,
%                       2011
% Jan 14, 2011 - Nick - added MainEddy processing for PA starting Jan 1,
%                       2011
% Jan  7, 2009 - Nick - added processing for below-canopy R.M. Young 81000
%                       sonic at CR
% Oct 15, 2008 - Nick - added processing for CR ACS system installed for
%                the NSERC Fertilization experiment at CR
% May 03, 2003 - kai* - Using \\paoa001 path name
% Dec 19, 2003 - kai* - Removed hardcoded 2003, disabled flux logger
% Nov 24, 2003 - kai* - Disables RMY calculations at the site and db update in the lab


% if ~exist('Sites') | isempty(Sites)
%    Sites     = {'BS' 'CR' 'HJP02' 'HJP75' 'JP' 'PA' 'OY' 'YF' 'HDF11'};
%    Site_name = {'PAOB' 'CR' 'HJP02' 'HJP75' 'PAOJ' 'PAOA' 'OY' 'YF' 'HDF11'};
%    Site_eddy = {'Eddy' 'Eddy' 'MainEddy' 'MainEddy' 'Eddy' 'Eddy' 'MainEddy' 'MainEddy' 'MainEddy'};
% end

% update current biomet site list, July 20, 2011
if ~exist('Sites') | isempty(Sites)
   Sites     = {'BS'  'PA'  'YF' 'HDF11'};
   Site_name = {'PAOB' 'PAOA' 'YF' 'HDF11'};
   Site_eddy = {'Eddy' 'Eddy' 'MainEddy' 'MainEddy'};
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
       case {'HDF11' 'HJP02' 'HJP75'}
           wc = ['*.h' SiteId '.mat'];
       case {'BS'}
           obs_new_eddy_flag = 1; % to re-extract DAQ_eddy data from 2011, this needs to be set temprorarily to zero
              if Year<2011 | (Year>=2011 & ~obs_new_eddy_flag)
                    wc = ['*.h' SiteId(1) '.mat'];
              elseif Year>=2011 & obs_new_eddy_flag
                    wc = ['*.h' SiteId '.mat']; % BS was changed from DAQEddy to NewEddy system Mar 17, 2011.
                    Site_eddy{i} = 'MainEddy';
              end
       case {'PA'}
           if Year<2011
               wc = ['*.h' SiteId(1) '.mat'];
           elseif Year>=2011
               wc = ['*.h' SiteId '.mat']; % PA was changed from DAQEddy to NewEddy system Jan 1, 2011.
               Site_eddy(i) = {'MainEddy'};
           end
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
   case {'BS' 'CR' 'JP'}
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
   
   case {'PA'} % PA became a next generation eddy system Jan 1, 2011; so treat the two cases here
    if ~strcmp(char(Site_eddy(i)),'MainEddy');
        %treat as one of the old DAQ sites above
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
      
      %------------------------------------------------------------------
      % ACS System added for NSERC Fertilization experiment (Nick, Oct 15,
      % 2008)
      %------------------------------------------------------------------
      
      sys = 'ACS-DC';
      wc = ['*.ACS_Flux_CR16.mat'];
      lst_old = dir(fullfile(pth_new_mat_files,wc));
      try
         db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      end
      
      %------------------------------------------------------------------
      % Below canopy R.M. Young 81000 sonic (Nick, Jan 7, 2009)
      %------------------------------------------------------------------
      
      sys = 'below_canopy_sonic';
      wc = ['*.RMYoung.mat'];
      lst_old = dir(fullfile(pth_new_mat_files,wc));
      try
         db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
      end
   case {'HDF11'}
      %------------------------------------------------------------------
      % Tall CR Tower Gill R3 sonic reactivated as part of HDF11, June 17,
      % 2011
      %------------------------------------------------------------------
      
      sys = 'tall_tower_sonic';
      wc = ['*.TallTowerSonic.mat'];
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

