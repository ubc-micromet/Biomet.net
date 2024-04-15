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
% 
% Apr 11, 2024 (Zoran)
%   - changed the algorithm for expanding tags. Much simpler.
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
cellNamesOfDependants = split(dependent_names,',');

% Structure of all trace names
cellAllVariableNames = {trace_str_all.variableName};

% Add custom tags from siteID_CustomTags.m file if such file exists
% under Derived_Variables
%--- to be implemented -------
siteID = trace_str_all(1).SiteID;
allTags = getAllTags(siteID);

cellNamesOfDependants = convert_tags_to_Traces(trace_str_all,cellNamesOfDependants,allTags);

% Get the indices of all traces:
[~, ~, returnInd]=intersect(cellNamesOfDependants,cellAllVariableNames);

% make sure that returnInd is a row vector
returnInd = returnInd(:)';

function cellNamesOfDependants = convert_tags_to_Traces(trace_str_all,cellNamesOfDependantsIn,allTags)
    while contains(cellNamesOfDependantsIn,'tag_')
        cellList = split(cellNamesOfDependantsIn,',');
        newDependent = [];
        for cntList=1:length(cellList)
            depName = strtrim(char(cellList(cntList)));
            if ~isempty(depName)
                if startsWith(depName,'tag_')
                    if isfield(allTags,depName)
                        newDependent = [newDependent  strtrim(allTags.(depName)) ',']; %#ok<*AGROW>
                    elseif strcmpi(depName,'tag_All')
                        cellNamesOfDependants = {trace_str_all.variableName};
                        return
                    else
                        fprintf(2,'Tag: %s does not exist in standard or custom tags.',depName)
                    end
                else
                    newDependent = [newDependent  depName ','];
                end
            end
        end
        cellNamesOfDependantsIn = newDependent;
    end
    % there could still be some white spaces in the names. Trim them.
    cellList = split(cellNamesOfDependantsIn,',');
    for cntList=1:length(cellList)
        cellList(cntList) = strtrim(cellList(cntList));
    end
    % Keep only unique and non-empty traces
    cellList = unique(cellList);
    cellNamesOfDependants = cellList(~cellfun(@isempty,cellList) );


% 
% function structNamesOfDependants = convert_tags_to_Traces(list_of_traces,structNamesOfDependants,allTags)
%     % It converts 
%     % Recursive search through all Tags to convert them to trace names 
% 
%     % Extract field names
%     if ~isempty(allTags)
%         customTagFieldNames = fieldnames(allTags);
%     else
%         customTagFieldNames = [];
%     end
% 
%     % Structure of all trace names
%     structAllVariableNames = {list_of_traces.variableName};
% 
%     % Find if there are any tags (tag_*) in the list of dependents
%     indAllTagsInDependents = startsWith(structNamesOfDependants,'tag_');
%     % move them to structAllTags
%     structAllTags = structNamesOfDependants(indAllTagsInDependents);
%     % and remove them from structNamesOfDependants
%     structNamesOfDependants = structNamesOfDependants(~indAllTagsInDependents);
% 
%     % if tags exist, convert them to trace names and add them
%     % to the list of dependants
%     if ~isempty(structAllTags)
%         indTaggedDependants = [];
%         for cntTags = 1:length(structAllTags)
%             cTag = char(structAllTags(cntTags));
%             indField = find(ismember(customTagFieldNames,cTag));
%             if ~isempty(indField)
%                 indField = indField(1);   % in case user made a mistake and there a same tag appears twice grab only the first one
%             end
%             % Deal with special tags (tag_ALL, tag_AllMet, tag_AllFlux)        
%             if strcmpi(cTag,'tag_All')
%                 % tag_All affects all traces
%                 indTaggedDependants = 1:length(list_of_traces);
%             elseif indField ~= 0
%                 % if cTag is memeber of customTags than add those trace names
%                 structCustomTagTraces = strtrim(split(allTags.(char(customTagFieldNames(indField))),','))';
%                 structNamesOfDependants = [structNamesOfDependants structCustomTagTraces]; %#ok<AGROW>
%                 % recursive call to check if there are more tag_ fields
%                 structNamesOfDependants = convert_tags_to_Traces(list_of_traces,structNamesOfDependants,allTags);
%             else
%                 % loop through all the traces and find all the ones that have this tag
%                 for cntTraces = 1:length(list_of_traces)
%                     if isfield(list_of_traces(cntTraces).ini,'tag') && contains(list_of_traces(cntTraces).ini.tag,cTag)
%                         %fprintf('%d found tag\n',cntTraces);
%                         indTaggedDependants = [indTaggedDependants cntTraces];   %#ok<AGROW>
%                     end
%                 end
%             end
%         end
% 
%         % remove tags from structTraceName 
%         structNamesOfDependants = structNamesOfDependants(~startsWith(structNamesOfDependants,'tag_'));
%         % and replace them with unique trace names
%         nDep = length(structNamesOfDependants);
%         for cnt = 1:length(indTaggedDependants)
%             structNamesOfDependants{cnt+nDep} = char(structAllVariableNames(indTaggedDependants(cnt)));
%         end
%         structNamesOfDependants = unique(structNamesOfDependants);
%     end