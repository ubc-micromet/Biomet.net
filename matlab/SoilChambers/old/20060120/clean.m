function[trace_after] = clean(trace_before, flag, selection)
%*************************************************************
%
% INPUTS:
%	trace_before - trace to be cleaned from selected data
%   flag - to choose option: 1  removing NaNs from trace (reduces length of trace)
% 							   2  leaving NaNs in trace (keeps trace the same length)
%
%   selection - indices of data to eliminate from trace;
%				if non existing, then NaNs are eliminated from trace
%
%
% OUTPUTS:
%	trace_after - input trace, with selected data removed and exchanged with NaN
% 
%	(c)  by Eva Jork		    created on:  May 22, 1998
%							    modified on: May 26, 1998
%												* added flag
%
%
%*************************************************************

if nargin < 3
   selection = find(isnan(trace_before));
end

trace_before(selection) = NaN;

if flag == 1
   ind = find(~isnan(trace_before));
else
   ind = 1:length(trace_before);
end
   trace_after = trace_before(ind);
