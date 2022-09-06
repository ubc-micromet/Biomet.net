function data_out= calc_runMeanStd(trace_str, filt_len, num_std, filt_opt, num_rep)
%This function calculates the running mean and std of the input trace.  A bound
%surrounding the dataset is created for each repitition and any point outside 
%is replaced by a NaN.  The resulting envelopes are stored into the trace variable.
% Input:
%				trace_str:		The single trace structure.
%				filt_len:		Running filter of length filt_len.
%				num_std:			Number of standard deviations.
%				filt_opt:		1==calculate running means (no phase shift)
%										or default is standard way.
%				num_rep:			Number of repitions of the running filter.
%
% Output:	
%				data_out:		A single trace structure with original data
%									and points outside bounds replaces by NaNs.

if(nargin<1)
   error('not enough arguments');
end
if isfield(trace_str,'data')
   temp = trace_str.data;     		%get data from trace variable.
else
   temp = trace_str;
end
if isfield(trace_str,'DOY')
   t = trace_str.DOY;
else
   t = length(temp);
end

env_mat = [];							%initialize variables.
ind_filtered = [];

lenf = length(filt_len);					
lens = length(num_std);						%check if each repition has filt_len and num_std
if(lenf ~= num_rep)							%if not, assign last values.
   filt_len(lenf+1:num_rep) = filt_len(lenf);
end
if(lens ~= num_rep)
   num_std(lens+1:num_rep) = num_std(lens);
end
count = [];
for i=1:num_rep
   run_m = runMean_tool(temp, filt_len(i), filt_opt);		%calulate running mean and std.   
   run_s = runStd(temp, filt_len(i), filt_opt,run_m);
   env_top = run_m + run_s*num_std(i);						%create envelope for current data.
   env_bot = run_m - run_s*num_std(i);
   
   %When calculating running means and stds the standard way, shift envelopes
   %to account for time delay (phase shift).
   if(filt_opt ==1)
      env_top(1:end-floor(filt_len(i)/2)) = env_top(1+floor(filt_len(i)/2):end);
      env_bot(1:end-floor(filt_len(i)/2)) = env_bot(1+floor(filt_len(i)/2):end);
   end
   outLimit = find(env_bot>temp | env_top<temp);		%get points outside envelope and
   temp(outLimit) = NaN;										%replace with nans.
   env_mat = [env_mat env_top env_bot];					%keep track of each envelope.
   count(i) =length(outLimit);
   ind_filtered= [ind_filtered; outLimit];				%track index of removed pts.
end

trace_str.data = temp;												%store new data 
trace_str.runFilter_stats.envelope_matrix = env_mat;     %store envelopes
trace_str.runFilter_stats.pts_per_envelope = count;		%store pts per envelope removed
trace_str.runFilter_stats.ind_filtered = ind_filtered;		%index of points removed

data_out = trace_str;