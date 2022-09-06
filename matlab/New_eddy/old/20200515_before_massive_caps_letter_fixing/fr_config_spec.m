function [Flog,len_spec_bins,spec_bins] = fr_config_spec(no_spec_bins,no_in_bin,nfft,Fs)
% [Flog,len_spec_bins,spec_bins] = fr_config_spec(no_spec_bins,no_in_bin,nfft,Fs)
%
%	Calculates the bins for block averaging of turbulence spectra
%
%	Input: 	no_spec_bins	- number of bins
%				no_in_bin		- minimum number of frequency averaged
%				nfft				- length of the time series used in spectral calc
%				Fs					- sampling frequency
%
%	Output	Flog				- geometric mean of freq in each block
%				len_spec_bins	- vector of length no_spec_bins that contains the length of
%									  each bin
%				spec_bins		- matrix of size [no_spec_bins,max(len_spec_bin)] that for 
%									  spec_bins(i,j) contains the indicies of the j frequencies 
%									  that belong to the ith bin
%
%	Created:			kai* Feb,1 2001
%	Last modified:	kai* Feb,1 2001

% No of pts returned by psd, the first is just the average of the data
n_spec = nfft/2+1;  % for nfft even, and 2^N is even
% f = (Fs/2) / (nfft/2).* [0:n_spec-1]; -  freq returned by psd
% here we do not use the average - SO IT HAS TO BE DROPED AFTER USING PSD
f = (Fs/2) / (n_spec-1) .* [1:n_spec-1];


i=0;
no_spec_bins_current = no_spec_bins ;
d_min = 0.5*(Fs/2) / n_spec;
while d_min <= no_in_bin*(Fs/2) / n_spec
   i = i+1;
   
   flog = logspace(log10(f(i)),log10(f(end)),no_spec_bins_current+1);
   d_min = min(flog(2:end)-flog(1:end-1));
   no_spec_bins_current = no_spec_bins-(i-1) ;

end  

[len_spec_bins,spec_bins,Flog] = log_space_spec(f(i:end),no_spec_bins_current);


spec_bins     = [NaN .* zeros(i-1,length(spec_bins)) ; spec_bins+i-1];
spec_bins(1:i-1,1) = (1:i-1)';   
len_spec_bins = [ones(i-1,1); len_spec_bins];
Flog          = [f(1:i-1)'; Flog];

% Old version in a single function
% [len_spec_bins,spec_bins,Flog] = log_space_spec(f,no_spec_bins);