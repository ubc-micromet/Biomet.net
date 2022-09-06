function fr_clean_chamber_paul(Year,db_ini)
% fr_clean_chamber_paul(Year,db_ini)

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
