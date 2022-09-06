function fr_export_pr_data
% Export data measured at Powell River in 2004
%
% This is done here rather than in 
% fr_automated_cleaning because it is a one-time shot
%
% This program can only run from PAOA001


mat = load('Y:\Calculation_Procedures\TraceAnalysis_ini\PR\pr_2004_FirstStage.mat');

data_raw    = read_data(2004,'pr','Y:\Calculation_Procedures\TraceAnalysis_ini\PR\pr_FirstStage.ini');

% Clean and find dependents to clean
[data_auto,ct] = find_all_dependent(data_raw);
data_depend = clean_all_dependents(data_auto,[],ct);

% Clean dependents 
data_depend   = clean_traces( data_depend );
data_cleaned = addManualCleaning(data_depend,mat.trace_str);

export(data_cleaned,'Y:\2004\PR\');