function repeatTraces = findNonUniqueTraces(yearIn,siteID,stageIn,flagVerbose)
% This function find traces that repeat themselves within an First or SecondStage.ini file
%
%
%
% Zoran Nesic               File created:       Mar 26, 2024
%                           Last modification:  Mar 26, 2024

% Revisions:
%

arg_default('flagVerbose',0);
try
    trace_str = readIniFileDirect(yearIn,siteID,stageIn);
catch ME
    iniFileName = fullfile(db_pth_root,'Calculation_Procedures','TraceAnalysis_ini',siteID);
    error('Ini file for stage %d, siteID: %s, does not exist in folder: %s',stageIn,siteID,iniFileName);
end
allNames={trace_str(:).variableName};
[~,indUnique] = unique(allNames,'stable');
indReps = setdiff(1:numel(allNames),indUnique);
if ~isempty(indReps)
    if flagVerbose ~=0 
        fprintf('Repeats:\n');
        for cntReps = indReps
            fprintf('%4d - %30s\n',cntReps,allNames{cntReps});
        end
    end
    repeatTraces = {allNames{indReps}};
else
end
