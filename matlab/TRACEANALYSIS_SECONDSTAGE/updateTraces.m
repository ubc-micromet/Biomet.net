function data_out = updateTraces(trace_str)
% This function provides optional cleaning procedures to a single trace structure,
% or an array of structures.
% An extra field called stats is created for each trace.
% This field contains various statistics about the cleaning procedures.
%
% Input:			trace_str:		Either one single trace, or an array of structures.
% Vars:		    	filt_len:		Length of the running filter.
%					num_std:		Number of standard deviations used in the running filter.
%					filt_opt:		Filter option (1==standard way) or (2==no-phase shift).
%					num_rep:		Number of repititions of the running filter.
%					clean_flags:    Represents the cleaning procedures used on each point.
%										(ex:   1 is selected, 2 is min, 4 is max, 8 is fr_despike,
%												 16 is runfilter, 32 is restored (used later).
% Output:		data_out:		Either one single cleaned trace, or an array of trace
%										structures.

disp('Updating Trace Information ...');

trace_str_out = [];

h = waitbar(0,'Updating Trace Information....');

numberTraces = length( trace_str );   %number of traces in the input trace structure that need cleaning

for countTraces = 1:numberTraces
   
   trace_str_in = trace_str(countTraces);
   
   cln_out = ta_update_statistics(trace_str_in);							%update the statistics on the trace
   
   if ishandle(h)
     waitbar(countTraces/numberTraces);         
   end   
   
   %if the cln_out is not empty then set cln to it
   if ~isempty(cln_out)
      trace_str_in = cln_out;
   end
   
   %if pts need to be restored or removed then do so
   if isfield(trace_str_in,'pts_restored') & ~isempty(trace_str_in.pts_restored)
      trace_str_in.data(trace_str_in.pts_restored) = trace_str_in.data_old(trace_str_in.pts_restored);
   end
   
   if isfield(trace_str_in,'pts_removed') & ~isempty(trace_str_in.pts_removed)
      %Reset all interpolated values:
      trace_str_in.data(trace_str_in.pts_removed) = NaN;
      if isfield(trace_str_in,'interpolated') & ~isempty(trace_str_in.interpolated)   
         trace_str_in.data(trace_str_in.pts_removed) = trace_str_in.interpolated(trace_str_in.pts_removed);   
      end
   end
end

trace_str_out = trace_str_in;

if ishandle(h)
   close(h);
end