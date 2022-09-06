function data_out = runMean_tool(data_in, filt_len, filt_opt)
% This function computes the running mean of filt_len data points for
% each element of the input data set. 
%
% Input: 	data_in: 		The input data vector.
%				filt_len: 		The length of the running mean.
%				filt_opt:		Filter type (standard==1) or (no phase shift==default)
%
% Output: 	data_out:		The array of running means for each element of data_in.
%									NaN's found in data_in remain in data_out.
%
% (c) by Ryan Newton           File created:       May 24, 2000

if(nargin<2)
   error('not enough arguments');
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

runFilt = ones(1,filt_len);								% running mean filter of length
ind = find(~isnan(data_in));								% find not-nan-s
if length(ind)<= 3*filt_len
    data_out = NaN .* ones(size(data_in));
    return
end

if filt_opt == 1
	run_m = filter(runFilt,1,data_in(ind))/filt_len; 					% calculate running means (standard way)
else
	run_m = filtfilt(runFilt,1,data_in(ind))/filt_len/filt_len; 	% calculate running means (no phase shift)
end

data_out = data_in;
data_out(ind)= run_m;
