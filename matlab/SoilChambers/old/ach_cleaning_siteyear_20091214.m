function data_cleaned = ach_cleaning_siteyear(Year,SiteId,stage,db_ini)
% data_cleaned = ach_cleaning_siteyear(Year,SiteId,stage,db_ini)
%
% Run one stage of cleaning
%
%    ach_automated_cleaning with no arguments runs all stages for all sites 
%    for the current year and exits
% 
%    ach_automated_cleaning(Years,Sites,stages) allows to select Years (vector 
%    of years), Sites (cellstring array) and stages (vector of [1 2 3]). 
%    Defaults are the current year, all sites and all stages.
%    
%    If stages contains a 4 all cleaning stages are run and the data is
%    then exported in FCRN format to \\paoa003\BERMS
%
%    ach_automated_cleaning(Years,Sites,stages,db_out) writes the cleaned data 
%    into a different database with base path db_out. 
%    This option can be used to copy the cleaned database
%    using the standard biomet ini-files
%
%    ach_automated_cleaning(Years,Sites,stages,db_out,db_ini) uses db_ini as
%    a dabase base path to find the inifiles. This allows to update
%    a user specific database in db_out using the inifiles in db_ini and
%    data from the biomet database. 
% 
%    The default input and output database is y:\database on PAOA001 and
%    the biomet_path database on all other PCs. Use biomet_database_default
%    to use a local copy of the database.


% kai* Feb 12, 2003
%
% Revisions:
% Dec 19, 2007 - use db_pth_root to get db path instead of hardwiring
% (Nick)
% Nov 18, 2004
% Added FCRN export
% Oct 21, 2004
% Added HJP75 & FEN
% Sep 09, 2004
% Implemented db_out and db_ini option and use of db_dir_ini

Year_cur = datevec(now);
if strcmp(fr_get_pc_name,'PAOA001')
%    db_pth = 'y:\database'; 
    db_pth = db_pth_root; % Dec 19, 2007 
else
    db_pth = biomet_path('1111','xx');
    ind = find(db_pth == filesep);
    db_pth = db_pth(1:ind(end-2));
end

arg_default('Year',Year_cur(1));
arg_default('SiteId',fr_current_siteid)
arg_default('stage',1);
arg_default('db_ini',db_pth);

yy_str = num2str(Year(1));

%------------------------------------------------------------------
% Get ini file names
%------------------------------------------------------------------
pth_proc = fullfile(db_ini,'Calculation_Procedures\TraceAnalysis_ini',SiteId,'');

if upper(SiteId) == 'PA' & Year < 2005
    ini_file_first  = fullfile(pth_proc,[SiteId '_Chambers_FirstStage_Sys1.ini']);
elseif upper(SiteId) == 'PA' & Year >= 2005
    ini_file_first  = fullfile(pth_proc,[SiteId '_Chambers_FirstStage_Sys2.ini']);
end

if upper(SiteId) == 'BS' & Year < 2004
    ini_file_first  = fullfile(pth_proc,[SiteId '_Chambers_FirstStage_Sys1.ini']);
elseif upper(SiteId) == 'BS' & Year >= 2004
    ini_file_first  = fullfile(pth_proc,[SiteId '_Chambers_FirstStage_Sys2.ini']);
end

if upper(SiteId) == 'JP'
    ini_file_first  = fullfile(pth_proc,[SiteId '_Chambers_FirstStage_Sys1.ini']);    
end

if upper(SiteId) == 'YF'
    ini_file_first  = fullfile(pth_proc,[SiteId '_Chambers_FirstStage_Sys2.ini']);    
end

ini_file_second = fullfile(pth_proc,[SiteId '_Chambers_SecondStage.ini']);
ini_file_third  = fullfile(pth_proc,[SiteId '_Chambers_ThirdStage.ini']);

%------------------------------------------------------------------
% Do first stage cleaning and exporting
%------------------------------------------------------------------
if stage == 1
    % Load first stage manual cleaning results
    if upper(SiteId) == 'PA' & Year < 2005
        mat_file = fullfile(pth_proc,[SiteId '_' num2str(yy_str) '_ChambersSys1.mat']);
    elseif upper(SiteId) == 'PA' & Year >= 2005
        mat_file = fullfile(pth_proc,[SiteId '_' num2str(yy_str) '_ChambersSys2.mat']);
    end

    if upper(SiteId) == 'BS' & Year < 2004
        mat_file = fullfile(pth_proc,[SiteId '_' num2str(yy_str) '_ChambersSys1.mat']);
    elseif upper(SiteId) == 'BS' & Year >= 2004
        mat_file = fullfile(pth_proc,[SiteId '_' num2str(yy_str) '_ChambersSys2.mat']);
    end

    if upper(SiteId) == 'JP'
        mat_file = fullfile(pth_proc,[SiteId '_' num2str(yy_str) '_ChambersSys1.mat']);
    end

    if upper(SiteId) == 'YF'
        mat_file = fullfile(pth_proc,[SiteId '_' num2str(yy_str) '_ChambersSys2.mat']);
    end

    if exist(mat_file)==2
        mat = load(mat_file);
    else
        mat = [];
    end
    
    data_raw    = read_data(Year(1),SiteId,ini_file_first);
    
    % Clean and find dependents to clean
    [data_auto,ct] = find_all_dependent(data_raw);
    data_depend = clean_all_dependents(data_auto,[],ct);
    
    % Clean dependents 
    data_depend   = clean_traces( data_depend );
    
    if ~isempty(mat)
        data_cleaned = addManualCleaning(data_depend,mat.trace_str);
    else
        data_cleaned = data_depend;
    end
end

%------------------------------------------------------------------
% Do second stage cleaning and exporting
%------------------------------------------------------------------
if stage == 2
    data_cleaned = read_data(Year(1),SiteId,ini_file_second);
end

%------------------------------------------------------------------
% Do third stage automated cleaning and exporting
%------------------------------------------------------------------
if stage == 3
    data_cleaned = read_data(Year(1),SiteId,ini_file_third);
end


