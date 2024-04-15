function returnInd = ta_get_index_traceList(dependent_names,trace_str_all)
%   This function returns the indices of the traces listed in 'trc_names' 
%   within the list of all traces present in the ini_file.
%
%   Input:	
%           dependent_names			- a character array of trace variableNames
%			trace_str_all	        - a structure array of all traces present in the ini_file.
%   Output:	
%           returnInd			    -contains indices of trc_names within list_of_traces.
%

returnInd = [];
if ~exist('dependent_names','var') || ~exist('trace_str_all','var') || ...
        isempty(dependent_names) || isempty(trace_str_all)
    return
end
% First, remove all white space since it should not be present(variable names of traces
% should only contain character and underscores):
dependent_names = dependent_names(dependent_names ~=32 & dependent_names ~=9);

% Split comma separated string trc_names into a cell array:
cellNamesOfDependents = split(dependent_names,',');

% Structure of all trace names
cellAllVariableNames = {trace_str_all.variableName};

% Add custom tags from siteID_CustomTags.m file if such file exists
% under Derived_Variables
%--- to be implemented -------
siteID = trace_str_all(1).SiteID;
allTags = getAllTagsYML(siteID);

cellNamesOfDependents = convert_tags_to_Traces(trace_str_all,cellNamesOfDependents,allTags);

% Get the indices of all traces:
[~, ~, returnInd]=intersect(cellNamesOfDependents,cellAllVariableNames);

% make sure that returnInd is a row vector
returnInd = returnInd(:)';

function cellNamesOfDependents = convert_tags_to_Traces(trace_str_all,cellNamesOfDependents,allTags)
    ixDepTags = startsWith(cellNamesOfDependents,'tag_');
    for i=1:numel(cellNamesOfDependents)
        if ixDepTags(i)==1
            if isfield(allTags,cellNamesOfDependents(i))
                tag_traces = allTags.(char(cellNamesOfDependents(i)));
                cellNamesOfDependents(i) = {convertStringsToChars(tag_traces)};
            else
                fprintf('%s is not valid tag',char(cellNamesOfDependents(i)))
                cellNamesOfDependents(i) = {['']};
            end
        end
    end
    % Concatenate the valid tags
    cellNamesOfDependents = cellNamesOfDependents(~cellfun(@isempty,cellNamesOfDependents));
    cellNamesOfDependents = strjoin(cellNamesOfDependents,",");
    cellNamesOfDependents = unique(split(cellNamesOfDependents,','));
end
end