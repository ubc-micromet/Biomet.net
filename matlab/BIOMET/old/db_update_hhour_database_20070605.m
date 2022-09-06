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

All_Sites     = {'BS' 'CR' 'FEN' 'HJP02' 'HJP75' 'JP' 'PA' 'OY' 'YF'};

if ~exist('Sites') | isempty(Sites)
    Sites = All_Sites;
end

if ~exist('Years') | isempty(Years)
    dv_now = datevec(now);
    Years = dv_now(1);
end

All_Site_name = {'PAOB' 'CR' 'FEN' 'HJP02' 'HJP75' 'PAOJ' 'PAOA' 'OY' 'YF'};
All_Site_eddy = {'Eddy' 'Eddy' 'MainEddy' 'MainEddy' 'MainEddy' 'Eddy' 'Eddy' 'MainEddy' 'MainEddy'};

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
            case {'FEN' 'HJP02' 'HJP75' 'OY'}
                wc = ['*.h' SiteId '.mat'];
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
            case {'BS' 'PA'}
                sys = 'chambers';
                wc = ['*.h' SiteId(1) '.mat'];
                try
                    db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
                catch
                    lasterr   
                end
        end   
        
        %------------------------------------------------------------------
        % Stuff particular to the main sites
        %------------------------------------------------------------------
        switch upper(SiteId)
            case {'BS' 'CR' 'JP' 'PA'}
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
            case {'CR'}
                %------------------------------------------------------------------
                % Paul's chamber
                %------------------------------------------------------------------
                sys = 'chamber_paul';
                wc = ['*s.h' SiteId(1) '_ch.mat'];
                lst_old = dir(fullfile(pth_new_mat_files,wc));
                try
                    db_incremental_update(pth_new_mat_files,pth_db,pth_update_lst,wc,sys,SiteId,no_days_back);
                end
        end
        
    end 
end