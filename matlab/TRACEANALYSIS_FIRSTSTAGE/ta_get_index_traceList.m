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
%   - implemented a meta tag: "Tag_All". More to follow.


returnInd = [];
if ~exist('trc_names','var') || ~exist('list_of_traces','var') || ...
      isempty(trc_names) || isempty(list_of_traces)
   return
end
% First, remove all white space since it should not be present(variable names of traces
% should only contain character and underscores):
trc_names = trc_names(trc_names ~=32 & trc_names ~=9);

% Split comma separated string trc_names into a structure:
structTraceName = split(trc_names,',');

% Structure of all trace names
structAllTraceNames = {list_of_traces.variableName};

% Find if there are any tags (tag_*) in the list of dependents
structAllTags = structTraceName(startsWith(structTraceName,'tag_'));

% if tags exist, convert them to trace names and add them
% to the list of dependants
if ~isempty(structAllTags)
    indTaggedDependants = [];
    for cntTags = 1:length(structAllTags)
        cTag = char(structAllTags(cntTags));
        % Deal with special tags (tag_ALL, tag_AllMet, tag_AllFlux)        
        if strcmpi(cTag,'tag_All')
            % tag_All affects all traces
            indTaggedDependants = 1:length(list_of_traces);
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
    structTraceName = structTraceName(~startsWith(structTraceName,'tag_'));
    % and replace them with unique trace names
    nDep = length(structTraceName);
    for cnt = 1:length(indTaggedDependants)
        structTraceName{cnt+nDep} = char(structAllTraceNames(indTaggedDependants(cnt)));
    end
    structTraceName = unique(structTraceName);

end



% Get the indices of all traces:
[~, ~, returnInd]=intersect(structTraceName,structAllTraceNames);

% make sure that returnInd is a row vector
returnInd = returnInd(:)';




