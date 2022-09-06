function fr_clean_chamber_paul(Year,db_ini)

pth_proc = fullfile(db_ini,'Calculation_Procedures\TraceAnalysis_ini','cr','');

ini_file_ch = fullfile(pth_proc,['CR_chambers.ini']);
mat_file_ch = fullfile(pth_proc,['CR_' num2str(Year) '_chambers.mat']);
    if strcmp(fr_get_pc_name,'PAOA001')
        diary(['\\paoa001\Sites\' char(Site_name(i)) '\automated_cleaning.log']);
    else
        diary([pwd '\automated_cleaning_ ' char(Site_name(i)) '.log']);
    end
    disp(sprintf('==============  Start ========================================='));
    disp(sprintf('Date: %s',datestr(now)));
    disp(sprintf('SiteId = %s',SiteId));

mat = load(mat_file_ch);

data_raw    = read_data(Year(1),'cr',ini_file_ch);

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

export(data_cleaned,fullfile('y:','database',num2str(Year),'cr'));

    disp(['============== End ' stage_str ' stage cleaning' SiteId ' ' yy_str ' ===========']);
    disp(sprintf(''));
