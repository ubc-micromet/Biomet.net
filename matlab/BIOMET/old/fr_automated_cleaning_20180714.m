function fr_automated_cleaning(Years,Sites,stages,db_out,db_ini)
% fr_automated_cleaning(Years,Sites,stages,db_out)
%
% Run first to third stage cleaning and FCRN data export
%
%    fr_automated_cleaning with no arguments runs all stages for all sites 
%    for the current year and exits
% 
%    fr_automated_cleaning(Years,Sites,stages) allows to select Years (vector 
%    of years), Sites (cellstring array) and stages (vector of [1 2 3]). 
%    Defaults are the current year, all sites and all stages.
%    
%    If stages contains a 4 all cleaning stages are run and the data is
%    then exported in FCRN format to \\paoa003\BERMS
%
%    If stages contains a 5 all cleaning stages are run and the data is
%    then exported in FCRN format to \\paoa003\FCRN_local...added June 28,
%    2007 (Nick)
%
%   If stages contains a 6 all cleaning stages are run and web graphs are
%     exported...added July 10, 2007 (Nick--thanks Praveena!)
%
%    fr_automated_cleaning(Years,Sites,stages,db_out) writes the cleaned data 
%    into a different database with base path db_out. 
%    This option can be used to copy the cleaned database
%    using the standard biomet ini-files
%
%    fr_automated_cleaning(Years,Sites,stages,db_out,db_ini) uses db_ini as
%    a dabase base path to find the inifiles. This allows to update
%    a user specific database in db_out using the inifiles in db_ini and
%    data from the biomet database. 
% 
%    The default input and output database is y:\database on PAOA001 and
%    the biomet_path database on all other PCs. Use biomet_database_default
%    to use a local copy of the database.


% kai* Feb 12, 2003                     Last modified: Dec 19, 2011
%
% Revisions:
% 
% Jan 15, 2018 (Pat/Zoran)
%   - Added LGR1 site to the list of All_Sites and All_site_name
% Dec 19, 2011
%   - Fixed a bug that crashed the program when trying to write a diary file into a write-protected folder.
% July 10, 2007
%   -If stages contains a 6 all cleaning stages are run and web graphs are
%     exported...added July 10, 2007 to allow graphs to be created explicitly
%     by site and not just in dailymode (Nick)
% June 28, 2007
%       -If stages contains a 5 all cleaning stages are run and the data is
%    then exported in FCRN format to \\paoa003\FCRN_local...added June 28,
%    2007 (Nick)
% March 1, 2007
%       -put the diary writing into automated_cleaning.log inside a try
%       statement so function can be used on computers without write access
%       to Annex001 (e.g. to create local copies of cleaned traces)... Nick
% Nov 18, 2004
% Added FCRN export
% Oct 21, 2004
% Added HJP75 & FEN
% Sep 09, 2004
% Implemented db_out and db_ini option and use of db_dir_ini

if ~exist('Years') & ~exist('Sites')
    dailymode = 1;
else
    dailymode = 0;
end

Year_cur = datevec(now);
arg_default('Years',Year_cur(1));

All_Sites     = {'BS'   'CR' 'FEN' 'HJP02' 'HJP75' 'JP'   'OY' 'PA'   'YF' 'LGR1'};
All_Site_name = {'PAOB' 'CR' 'FEN' 'HJP02' 'HJP75' 'PAOJ' 'OY' 'PAOA' 'YF' 'LGR1'};

arg_default('Sites',All_Sites)

if ~iscellstr(Sites)
    % Assume it is a string with a single SiteId
    Sites = cellstr(Sites);
end

arg_default('stages',[1 2 3]);
% When FCRN export is requested make sure all cleaning is done
if ~isempty(find(stages == 4)) 
    stages = [1 2 3 4];
end

% June 28, 2007: Nick added for the case that we want to update a local copy of the
% FCRN export database for internal use only
if ~isempty(find(stages == 5)) 
    stages = [1 2 3 5];
end

% July 10, 2007: Nick added for the case that we want to produce
% web graphs for export
if ~isempty(find(stages == 6))
    stages = [1 2 3 6];
end


[SitesDum,ind_all] = intersect(All_Sites,upper(Sites));
if isempty(ind_all)
    Site_name = Sites;
else
    Site_name = All_Site_name(ind_all);
end

% ------------Nick's fix for using a local copy of the database---------------
if exist('biomet_database_default','file') == 2
    db_pth = biomet_database_default;
else
    db_pth = db_pth_root;
end
%--------------------------------------------------------------------------
arg_default('db_out',db_pth);
arg_default('db_ini',db_pth);

m = length(Years);
n = length(Sites);

for i = 1:n
    SiteId = upper(char(Sites(i)));
    
    for j = 1:m
        yy = Years(j);
        yy_str = num2str(yy(1));
        try
            fid = fopen(fullfile(db_pth,yy_str,SiteId,'automated_cleaning.log'),'a');
            if fid > -1
                fclose(fid);
                diary(fullfile(db_pth,yy_str,SiteId,'automated_cleaning.log'));
            else
                disp(['Write protected file: ' fullfile(db_pth,yy_str,SiteId,'automated_cleaning.log')]);
            end
        catch
            disp(lasterr);
        end
        disp(sprintf('==============  Start ========================================='));
        disp(sprintf('Date: %s',datestr(now)));
        disp(sprintf('SiteId = %s',SiteId));
        
        %------------------------------------------------------------------
        % Get output paths
        %------------------------------------------------------------------
        pth_out_first  = fullfile(db_out,yy_str,SiteId,'');
        pth_out_second = fullfile(db_out,yy_str,SiteId,'clean\SecondStage','');
        pth_out_third = fullfile(db_out,yy_str,SiteId,'clean\ThirdStage','');
        
        %------------------------------------------------------------------
        % Do first stage cleaning and exporting
        %------------------------------------------------------------------
        if ~isempty(find(stages == 1))
            stage_str = 'First ';
            disp(['============== ' stage_str ' stage cleaning ' SiteId ' ' yy_str ' ==============']);
            db_dir_ini(yy(1),SiteId,db_out,1);
            data_first = fr_cleaning_siteyear(yy(1),SiteId,1,db_ini);
            export(data_first,pth_out_first);
        end
        
        %------------------------------------------------------------------
        % Do second stage cleaning and exporting
        %------------------------------------------------------------------
        if ~isempty(find(stages == 2))
            stage_str = 'Second';
            disp(['============== ' stage_str ' stage cleaning ' SiteId ' ' yy_str ' ==============']);
            
            db_dir_ini(yy(1),SiteId,db_out,2);
            data_second = fr_cleaning_siteyear(yy(1),SiteId,2,db_ini);
            export(data_second,pth_out_second);
        end
        
        %------------------------------------------------------------------
        % Do third stage automated cleaning and exporting
        %------------------------------------------------------------------
        if ~isempty(find(stages == 3))
            stage_str = 'Third ';
            disp(['============== ' stage_str ' stage cleaning ' SiteId ' ' yy_str ' ==============']);
            db_dir_ini(yy(1),SiteId,db_out,3);
            data_third = fr_cleaning_siteyear(yy(1),SiteId,3,db_ini);
            export(data_third,pth_out_third);
        end
        
        %------------------------------------------------------------------
        % Do FCRN exporting
        %------------------------------------------------------------------
        if ~isempty(find(stages == 4))
            disp(['============== ' SiteId ' - FCRN Export =================================']);
            data_fcrn = fcrn_trace_str(data_first,data_second,data_third);
            fcrnexport(SiteId,data_fcrn);
        end
        
        % added June 28, 2007: Nick
        %------------------------------------------------------------------
        % Do a local FCRN export right up to current day
        %------------------------------------------------------------------
        if ~isempty(find(stages == 5))
            disp(['============== ' SiteId ' - Local FCRN Export =================================']);
            data_fcrn_local = fcrn_trace_str(data_first,data_second,data_third);
            flag_local = 1;
            fcrnexport(SiteId,data_fcrn_local,flag_local);
        end
        
        %------------------------------------------------------------------
        % When in daily mode also produce automatic graphs
        %------------------------------------------------------------------
        if dailymode | ~isempty(find(stages==6)) % July 10, 2007: added a stage 6 so we can produce web graphs explicitly by site
            try
                if ismember(SiteId,{'HP09' 'HP11' 'MPB1' 'MPB2' 'MPB3'})
                    opsite_web_analysis(yy(1),SiteId);
                    autoGraph(data_first)
                else
                    autoGraph(data_third)
                end
            catch
                disp(['Could not generate graphs for ' SiteId ' ' yy_str]);
            end
        end
        
        clear data_* ini_* pth_* mat_*
    end
    
    disp(['============== End ' stage_str ' stage cleaning' SiteId ' ' yy_str ' ===========']);
    disp(sprintf(''));
    
    diary off
end

