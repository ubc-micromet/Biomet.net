function db_update_hhour_database(Years,Sites)
% db_update_hhour_database(Years,Sites) Run database updates on long files
%
% Runs the database update using all new files in hhour_database directory for
% that site and year. If all files (not just new ones in that directory) are to
% be used the hhour_database\lst_old_*.mat files need to be deleted.
%
% Updates the database for
% 1) Fluxes
% 2) Calibrations from mat files
% 3) Profile systems

% last revision: July 19, 2011

% revision history:
% July 19, 2011
%   - added HP11 (Manitoba Hybrid Poplar site)
% June 9, 2011
%   - modified for HDF11 (CR clearcut)
% March 17, 2011
%   - modified for MainEddy extraction at BS: next generation eddy system
% Jan 14, 2011
%   - modified for MainEddy extraction at PA: next generation eddy system
%   as of Jan 1, 2011. 
% Oct 26, 2010
%   -added MPB4, HP09 to site list
% May 17, 2010
%   -added MPB1, MPB2 and MPB3 to site list
% Feb 10, 2010
%   -added YF to the chamber update (it was already included in
%   db_update_UBC_daily for short files). (Nick)
% Jan 26, 2009
%   -Nick commented out older chamber wc; chamber daily .mat files do 
%    NOT have the same wc as the eddy system (see db_update_UBC_daily). 
%    db updates for chamberrecalcs were failing.
% Jan 22, 2009
%   -deleted stray references to "no_days_back" which snuck in to the code
%   from snippets taken from db_update_UBC_daily and was preventing updates
%   of long files from the Annex001 hhour_database directory (Nick)
% Oct 15, 2008: Nick added updates for ACS chamber system at CR
% June 5, 2007: Nick fixed typo 'pth_db' (should be db_pth) in chamber
%   updating sections


All_Sites     = {'BS' 'CR' 'FEN' 'HJP02' 'HJP75' 'HJP94' 'JP' 'PA' 'OY' 'YF' ...
                    'MPB1' 'MPB2' 'MPB3' 'MPB4' 'HP09' 'HP11' 'HDF11' 'SQT' 'SQM'};

if ~exist('Sites') | isempty(Sites)
    Sites = All_Sites;
end

if ~exist('Years') | isempty(Years)
    dv_now = datevec(now);
    Years = dv_now(1);
end

All_Site_name = {'PAOB' 'CR' 'FEN' 'HJP02' 'HJP75' 'HJP94' 'PAOJ' 'PAOA' 'OY' 'YF' ...
                 'MPB1' 'MPB2' 'MPB3' 'MPB4' 'HP09' 'HP11' 'HDF11' 'SQT' 'SQM'};
All_Site_eddy = {'Eddy' 'Eddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy' 'Eddy' 'Eddy' 'MainEddy' 'MainEddy'...
                  'MPB_Eddy' 'MPB_Eddy' 'MPB_Eddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy' 'MainEddy'};

[SiteDum,ind_all] = intersect(All_Sites,upper(Sites));
Sites     = All_Sites(ind_all);
Site_name = All_Site_name(ind_all);
Site_eddy = All_Site_eddy(ind_all);

db_pth = db_pth_root;

m = length(Years);
n = length(Sites);

for i = 1:n

    SiteId = upper(char(Sites(i)));
    fr_set_site(SiteId,'n');

    for j = 1:m
        year = Years(j);
        yy_str = num2str(year);

        %------------------------------------------------------------------
        % Path definitions
        %------------------------------------------------------------------
        pth_new_mat_files = fullfile(db_pth,yy_str,SiteId,'hhour_database','');
        pth_cal_files     = pth_new_mat_files;
        pth_update_lst    = fullfile(db_pth,yy_str,SiteId,'hhour_database','');

        %------------------------------------------------------------------
        % Updating the Eddy data
        %------------------------------------------------------------------
        switch upper(SiteId)
            case {'FEN' 'HJP02' 'HJP75'  'HJP94' 'OY' 'MPB1' 'MPB2' 'MPB3' 'MPB4' 'HP09' 'HP11' 'HDF11' 'SQT' 'SQM' }
                wc = ['*.h' SiteId '.mat'];
            case {'PA'}
                if year<2011 
                    wc = ['*.h' SiteId(1) '.mat'];
                elseif year>=2011 
                    wc = ['*.h' SiteId '.mat']; % PA was changed from DAQEddy to NewEddy system Jan 1, 2011.
                    Site_eddy{i} = 'MainEddy';
                end
            case {'BS'}
              obs_new_eddy_flag = 1; % to re-extract DAQ_eddy data from 2011, this needs to be set temprorarily to zero
              if year<2011 | (year>=2011 & ~obs_new_eddy_flag)
                    wc = ['*.h' SiteId(1) '.mat'];
              elseif year>=2011 & obs_new_eddy_flag
                    wc = ['*.h' SiteId '.mat']; % BS was changed from DAQEddy to NewEddy system Mar 17, 2011.
                    Site_eddy{i} = 'MainEddy';
              end
            otherwise
                wc = ['*.h' SiteId(1) '.mat'];
        end
        try
            db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,char(Site_eddy(i)),SiteId);
        catch
            disp(lasterr)
        end

        %------------------------------------------------------------------
        % Updateing the chamber system data - same wc as above!
        %------------------------------------------------------------------
        switch upper(SiteId)
            case {'YF' 'BS' 'PA'} % Nick added YF 2/10/2010
                sys = 'Chambers'; 
                %wc = ['*.h' SiteId(1) '.mat']; ***Nick commented out Jan 26,
                % 2009: chamber daily .mat files do NOT have the same wc as
                % eddy (see db_update_UBC_daily). db updates for chamber
                % recalcs were failing.
                wc = ['*s.h' SiteId(1) '_ch.mat'];
                try
                    %db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId); % June 5, 2007: Nick fixed 'pth_db' typo
                catch
                    lasterr
                end
        end

        %------------------------------------------------------------------
        % Stuff particular to the main sites
        %------------------------------------------------------------------
        switch upper(SiteId)
            case {'BS' 'CR' 'JP' }
                %------------------------------------------------------------------
                % Licor calibrations - stats file info
                %------------------------------------------------------------------
                sys = 'cal_stats';
                db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);

                %------------------------------------------------------------------
                % Profile System
                %------------------------------------------------------------------
                sys = 'profile';
                wc = ['*.h' SiteId(1) '.mat'];
                db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);
        end
        switch upper(SiteId)
            case {'PA'}
                if ~strcmp(char(Site_eddy(i)),'MainEddy');
                    %------------------------------------------------------------------
                    % Licor calibrations - stats file info
                    %------------------------------------------------------------------
                    sys = 'cal_stats';
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);

                    %------------------------------------------------------------------
                    % Profile System
                    %------------------------------------------------------------------
                    sys = 'profile';
                    wc = ['*.h' SiteId(1) '.mat'];
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);
                end


            case {'CR'}
                %------------------------------------------------------------------
                % Paul's chamber
                %------------------------------------------------------------------
                sys = 'chamber_paul';
                wc = ['*s.h' SiteId(1) '_ch.mat'];
                lst_old = dir(fullfile(pth_new_mat_files,wc));
                try
                    %db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId); % June 5, 2007: Nick fixed pth_db typo
                end
                %------------------------------------------------------------------
                % ACS System added for NSERC Fertilization experiment (Nick, Oct 15,
                % 2008)
                %------------------------------------------------------------------
                sys = 'ACS-DC';
                wc = ['*.ACS_Flux_CR16.mat'];
                lst_old = dir(fullfile(pth_new_mat_files,wc));
                try
                    %db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId,no_days_back);
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);
                end

                %------------------------------------------------------------------
                % Below canopy R.M. Young 81000 sonic (Nick, Jan 7, 2009)
                %------------------------------------------------------------------

                sys = 'below_canopy_sonic';
                wc = ['*.RMYoung.mat'];
                lst_old = dir(fullfile(pth_new_mat_files,wc));
                try
                    %db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId,no_days_back);
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);
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
                    %db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId,no_days_back);
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);
                end
                
                %------------------------------------------------------------------
                % ACS System added for Eugenie
                %------------------------------------------------------------------
                sys = 'ACS-DC';
                wc = ['*.ACS_Flux_CR16.mat'];
                lst_old = dir(fullfile(pth_new_mat_files,wc));
                try
                    %db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId,no_days_back);
                    db_incremental_update(pth_new_mat_files,db_pth,pth_update_lst,wc,sys,SiteId);
                end
        end

    end
end