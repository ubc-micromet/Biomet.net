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
% Last modification:    Apr 11, 2024 

% Revisions
% Apr 11, 2024 (June)
%   - Updated to use tags from _config.yml file instead
% Apr 10, 2024 (June & Zoran)
%   - the function was not using getAllTags so the standard tags were not used.
%     Fixed it by calling getAllTags.
% Mar 22, 2024 (Zoran)
%   - fixed syntax errors
%   - symplified the code
%   - added handling of tags
%   - implemented a meta tag: "tag_All". More to follow.
    
returnInd = [];
if ~exist('dependent_names','var') || ~exist('trace_str_all','var') || ...
      isempty(dependent_names) || isempty(trace_str_all)
   return
end
% First, remove all white space since it should not be present(variable names of traces
% should only contain character and underscores):
dependent_names = dependent_names(dependent_names ~=32 & dependent_names ~=9);

% Split comma separated string trc_names into a cell array:

namesOfDependants = split(trc_names,',');

% Cell of all trace names
allVariableNames = {list_of_traces.variableName};

siteID = list_of_traces(1).SiteID;
% tags are a static value by site, so calling here is ineficient
% leaving for now as its in line with what was already done
% in the future it should be put towards the front of the pipeline, when
% all static configurations are imported
allTags = getAllTagsYML(siteID);

namesOfDependants = convert_tags_to_Traces(allVariableNames,namesOfDependants,allTags);

% Get the indices of all traces:
[~, ~, returnInd]=intersect(namesOfDependants,allVariableNames);


% make sure that returnInd is a row vector
returnInd = returnInd(:)';

function namesOfDependants = convert_tags_to_Traces(allVariableNames,namesOfDependants,allTags)
    % Find if there are any tags (tag_*) in the list of dependents
    ixDepTags = startsWith(namesOfDependants,'tag_');
    for i=1:numel(namesOfDependants)
        if ixDepTags(i)==1
            if isfield(allTags,namesOfDependants(i))
                tag_traces = allTags.(char(namesOfDependants(i)));
                namesOfDependants(i) = {convertStringsToChars(tag_traces)};
            else
                fprintf('%s is not valid tag',char(namesOfDependants(i)))
                namesOfDependants(i) = {['']};
            end
        end
    end
    % Concatenate the valid tags
    namesOfDependants = namesOfDependants(~cellfun(@isempty,namesOfDependants));
    namesOfDependants = strjoin(namesOfDependants,",");
    namesOfDependants = unique(split(namesOfDependants,','));
end



end
