function [Pxd] = csd_avg(Px, config_info)
%========================================================================= 
%   This program averages the Px -- cospectral/spectral density
%       for plotting
%
%   [Pxd, Flog] = csd_avg(Fx, Px, Nlog)
%
%   Outputs: (the inputs to CSD_PLOT or PSD_PLOT)
%       Pxd -- mean spectral/cospectral density
%       Flog -- mean frequency (Hz)
%       Nlog -- the average intervals (default = 50, return 50 values of Pxd)
%
%   Inputs:
%       Fx -- frequency (Hz) from CSD_MET or PSD_MET
%       Px -- spectral/cospectral density from CSD_MET or PSD_MET
%
%   Created on  16 Apr. 1997 by Paul Yang
%   Modified on 17 Apr. 1997

% do the averaging
[n,m] = size(Px);
Pxd = NaN * ones(config_info.no_spec_bins,m);
ind_min = min(find(config_info.len_spec_bins > 1));

for i = 1:ind_min-1;
   if config_info.len_spec_bins(i) ~= 0
      Pxd(i,:) = Px(config_info.spec_bins(i,1),:);
   end
end

for i = ind_min:config_info.no_spec_bins;
   if config_info.len_spec_bins(i) ~= 0
      Pxd(i,:) = mean(Px(config_info.spec_bins(i,1:config_info.len_spec_bins(i)),:));
   end
end
