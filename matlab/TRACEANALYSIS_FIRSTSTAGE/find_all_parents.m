function trace_out = find_all_parents(trace_in)
% add list of parent traces (traces that each trace depends on) to each trace
%
% Inputs:
%   trace_in        - list of all traces
% Outputs:
%   trace_out       - same as trace_in plus an additional field: ind_parents
%                     that contains the indeces of all traces' parents.
%                     ind_parents is a sorted array.
%
% Zoran Nesic           File created:           Apr 14, 2024
%                       Last modification:      Apr 14, 2024


% Revisions
%

% 
trace_out = trace_in;
% start from the last trace and find all parent traces
for cntTraces = length(trace_out):-1:1
    allTraceParents = [];
    cntParents = 0;
    for cntParentTraces = cntTraces-1:-1:1
        if isfield(trace_out(cntParentTraces),'ind_depend')
            ind_depend = trace_out(cntParentTraces).ind_depend;
            if any(ismember(ind_depend,cntTraces))
                cntParents = cntParents + 1;
                allTraceParents(cntParents) = cntParentTraces;
            end
        end
    end
    if cntParents > 0
        trace_out(cntTraces).ind_parents = sort(allTraceParents);
    end
end

