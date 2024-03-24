function returnInd = ta_get_index_traceList(trc_names,list_of_traces)
%   This function returns the indices of the traces listed in 'trc_names' 
%   within the list of all traces present in the ini_file.
%
%   Input:	'trc_names'			-a character array of trace variableNames
%			'list_of_traces'	-contains list of all traces present in the ini_file.
%   Output:	'returnInd'			-contains indices of trc_names within list_of_traces.
%
% Last modification:    Mar 22, 2024 

% Revisions
%
% Mar 22, 2024 (Zoran)
%   - fixed syntax errors
%   - symplified the code
%   - added handling of tags
%   - implemented a meta tag: "tag_All". More to follow.


returnInd = [];
if ~exist('trc_names','var') || ~exist('list_of_traces','var') || ...
      isempty(trc_names) || isempty(list_of_traces)
   return
end
% First, remove all white space since it should not be present(variable names of traces
% should only contain character and underscores):
trc_names = trc_names(trc_names ~=32 & trc_names ~=9);

% Split comma separated string trc_names into a structure:
structNamesOfDependants = split(trc_names,',');

% Structure of all trace names
structAllVariableNames = {list_of_traces.variableName};

% Add custom tags from siteID_CustomTags.m file if such file exists
% under Derived_Variables
%--- to be implemented -------
siteID = list_of_traces(1).SiteID;
fileName = [siteID '_CustomTags'];
if exist(fileName,'file')
    customTags = eval(fileName);   
else
    customTags = [];
end

structNamesOfDependants = convert_tags_to_Traces(list_of_traces,structNamesOfDependants,customTags);

% Get the indices of all traces:
[~, ~, returnInd]=intersect(structNamesOfDependants,structAllVariableNames);

% make sure that returnInd is a row vector
returnInd = returnInd(:)';


function structNamesOfDependants = convert_tags_to_Traces(list_of_traces,structNamesOfDependants,customTags)
    % It converts 
    % Recursive search through all Tags to convert them to trace names 
    
    % Extract field names
    if ~isempty(customTags)
        customTagFieldNames = fieldnames(customTags);
    else
        customTagFieldNames = [];
    end

    % Structure of all trace names
    structAllVariableNames = {list_of_traces.variableName};

    % Find if there are any tags (tag_*) in the list of dependents
    indAllTagsInDependents = startsWith(structNamesOfDependants,'tag_');
    % move them to structAllTags
    structAllTags = structNamesOfDependants(indAllTagsInDependents);
    % and remove them from structNamesOfDependants
    structNamesOfDependants = structNamesOfDependants(~indAllTagsInDependents);

    % if tags exist, convert them to trace names and add them
    % to the list of dependants
    if ~isempty(structAllTags)
        indTaggedDependants = [];
        for cntTags = 1:length(structAllTags)
            cTag = char(structAllTags(cntTags));
            indField = find(ismember(customTagFieldNames,cTag));
            if ~isempty(indField)
                indField = indField(1);   % in case user made a mistake and there a same tag appears twice grab only the first one
            end
            % Deal with special tags (tag_ALL, tag_AllMet, tag_AllFlux)        
            if strcmpi(cTag,'tag_All')
                % tag_All affects all traces
                indTaggedDependants = 1:length(list_of_traces);
            elseif indField ~= 0
                % if cTag is memeber of customTags than add those trace names
                structCustomTagTraces = strtrim(split(customTags.(char(customTagFieldNames(indField))),','))';
                structNamesOfDependants = [structNamesOfDependants structCustomTagTraces]; %#ok<AGROW>
                % recursive call to check if there are more tag_ fields
                structNamesOfDependants = convert_tags_to_Traces(list_of_traces,structNamesOfDependants,customTags);
            else
                % loop through all the traces and find all the ones that have this tag
                for cntTraces = 1:length(list_of_traces)
                    if isfield(list_of_traces(cntTraces).ini,'tag') && contains(list_of_traces(cntTraces).ini.tag,cTag)
                        %fprintf('%d found tag\n',cntTraces);
                        indTaggedDependants = [indTaggedDependants cntTraces];   %#ok<AGROW>
                    end
                end
            end
        end
    
        % remove tags from structTraceName 
        structNamesOfDependants = structNamesOfDependants(~startsWith(structNamesOfDependants,'tag_'));
        % and replace them with unique trace names
        nDep = length(structNamesOfDependants);
        for cnt = 1:length(indTaggedDependants)
            structNamesOfDependants{cnt+nDep} = char(structAllVariableNames(indTaggedDependants(cnt)));
        end
        structNamesOfDependants = unique(structNamesOfDependants);
    end