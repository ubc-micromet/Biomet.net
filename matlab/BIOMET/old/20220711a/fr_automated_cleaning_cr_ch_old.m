function fr_automated_cleaning_cr_ch(Year)
% Clean Paul's single CR chamber
data_raw    = read_data(Year,'cr','Y:\DataBase\Calculation_Procedures\TraceAnalysis_ini\CR\CR_Chambers.ini');

% Clean and find dependents to clean
[data_auto,ct] = find_all_dependent(data_raw);
data_depend = clean_all_dependents(data_auto,[],ct);

% Clean dependents 
data_depend   = clean_traces( data_depend );
%   data_out = compare_trace_str(trace_str,old_structure,lc_path)
filename_mat = ['Y:\DataBase\Calculation_Procedures\TraceAnalysis_ini\CR\CR_' num2str(Year) '_Chambers.mat'];
if exist(filename_mat)
    mat = load(filename_mat);
    data_cleaned = addManualCleaning(data_depend,mat.trace_str);
else
    data_cleaned = data_depend;
end

export(data_cleaned,['Y:\DataBase\' num2str(Year) '\CR\']);