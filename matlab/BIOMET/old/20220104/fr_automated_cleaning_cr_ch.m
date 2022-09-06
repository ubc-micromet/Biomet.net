function fr_clean_chamber_paul(Year,db_ini,fcrn_export_flag)

% Revisions:
% Dec 10, 2009
%   -added an arg_default for fcrn_export_flag (Nick)
% Oct 15, 2008
%   -Nick added FCRN export

if nargin == 2
    fr_clean_chamber_paul_old(Year,db_ini)
end

arg_default('fcrn_export_flag',0); % Dec 10, 2009

diary(fullfile(db_pth_root,num2str(Year),'cr','automated_cleaning_chambers_chambers.log'));
arg_default('db_ini',db_pth_root);

disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('SiteId = %s','cr'));


pth_proc = fullfile(db_ini,'Calculation_Procedures\TraceAnalysis_ini','cr','');

ini_file_ch = fullfile(pth_proc,['CR_chambers.ini']);
mat_file_ch = fullfile(pth_proc,['CR_' num2str(Year) '_chambers.mat']);

data_raw    = read_data(Year(1),'cr',ini_file_ch);

% Clean and find dependents to clean
[data_auto,ct] = find_all_dependent(data_raw);
data_depend = clean_all_dependents(data_auto,[],ct);

% Clean dependents 
data_depend   = clean_traces( data_depend );

if exist(mat_file_ch)
    mat = load(mat_file_ch);
    data_cleaned = addManualCleaning(data_depend,mat.trace_str);
else
   data_cleaned = data_depend;
end

export(data_cleaned,fullfile(db_pth_root,num2str(Year),'cr'));

% added FCRN export functionality, Nick Oct 15, 2008
if fcrn_export_flag
   fcrn_local_flag = 0; % set to 1 to do a test export to \\PAOA003\FCRN_LOCAL, 0 to \\PAOA003\FTP_FLUXNET
   SiteId = 'CR'; 
   disp(['============== ' SiteId ' - FCRN Export =================================']);
   data_fcrn = fcrn_trace_str(data_cleaned);
   fcrnexport(SiteId,data_fcrn,fcrn_local_flag);
end
disp(['============== End CR chamber cleaning ' num2str(Year) ' ===========']);
disp(sprintf(''));


% legacy version
function fr_clean_chamber_paul_old(Year,db_ini)

diary(fullfile(db_pth_root,num2str(Year),'cr','automated_cleaning_chambers_chambers.log'));
arg_default('db_ini',db_pth_root);

disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('SiteId = %s','cr'));


pth_proc = fullfile(db_ini,'Calculation_Procedures\TraceAnalysis_ini','cr','');

ini_file_ch = fullfile(pth_proc,['CR_chambers.ini']);
mat_file_ch = fullfile(pth_proc,['CR_' num2str(Year) '_chambers.mat']);

data_raw    = read_data(Year(1),'cr',ini_file_ch);

% Clean and find dependents to clean
[data_auto,ct] = find_all_dependent(data_raw);
data_depend = clean_all_dependents(data_auto,[],ct);

% Clean dependents 
data_depend   = clean_traces( data_depend );

if exist(mat_file_ch)
    mat = load(mat_file_ch);
    data_cleaned = addManualCleaning(data_depend,mat.trace_str);
else
   data_cleaned = data_depend;
end

export(data_cleaned,fullfile(db_pth_root,num2str(Year),'cr'));

disp(['============== End CR chamber cleaning ' num2str(Year) ' ===========']);
disp(sprintf(''));
