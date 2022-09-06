function sigma = runStd(data_in, filt_len, filt_opt,run_m)
% This function computes the running std of filt_len data points for
% each element of the input data set.  
%
% Input: 	data_in: 		The input data set.
%				filt_len: 		The length of the running mean.
%				filt_opt:		Filter type (standard==1) or (no phase shift==default)
%
% Output: 	sigma:			The array of running std's for each element of data_in.
%									NaN's found in data_in remain in this array.
%
% (c) by Ryan Newton           File created:       May 24, 2000

if(nargin<2)
   error('not enough arguments');
end
if ~exist('run_m')
   run_m = '';
end
if~exist('filt_opt') | isempty(filt_opt)
   filt_opt = 1;     			
end
[m n] = size(data_in);								%input data set should be a column vector.
if(min(size(data_in))~=1)
   error('input data must be a vector')
end
if(m == 1)
   data_in = data_in';
end

ind = find(~isnan(data_in));								%get index of non-nans.
if length(ind)<= 3*filt_len
    sigma = NaN .* ones(size(data_in));
    return
end
temp = data_in(ind).^2;										%compute sum of squares.

edge_ind = ones(length(temp),1);							%adjust start edge.
edge_ind(1:filt_len) = [1:filt_len];
edge_ind(filt_len:end) = filt_len;

%calculate running std-s (standard way) or (no phase shift) 
runFilt = ones(1,filt_len);
if(filt_opt ~=1)
   y = filtfilt(runFilt,1,temp)./edge_ind./edge_ind;
else
   y = filter(runFilt,1,temp)./edge_ind;
end

if isempty(run_m)
   run_m = runMean_tool(data_in, filt_len, filt_opt);	%Compute running means.
end
sigma = data_in;
sigma(ind) = real(sqrt(y - run_m(ind).^2));				%Calculate sigma for each index pos.             
