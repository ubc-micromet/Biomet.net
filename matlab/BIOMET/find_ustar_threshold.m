function ust_threshold = find_ustar_threshold(tv,radiation_hhour,ustar_hhour,fc_hhour,plot_flag)
% FIND_USTAR_THRESHOLD Find the u* threshold using a standar algorithm
%
%   FIND_USTAR_THRESHOLD(TV,RADIATION,USTAR,FC) plots the nighttime FC vs. USTAR relationship
%   given a time vector TV, a RADIATION with RADIATION==0 for nighttime, USTAR in m/s and Fc.
%   
%   UST_THRES = FIND_USTAR_THRESHOLD(TV,RADIATION,USTAR,FC) return the threshold value without
%   plotting the relationship
% 
%   UST_THRES = FIND_USTAR_THRESHOLD(TV,RADIATION,USTAR,FC,1) return the threshold value and
%   also produces the plot
%
%   Standard algorithm for finding the ustar threshold:
%   1) Find nighttime measurements (RADIATION == 0)
%   2) Remover outliers (0.5% percentile highest and lowest CO2 fluxes)
%   3) Bin average data according to USTAR in 10 bins with equal no. of points
%   4) Calculate threshold 
%          as 80% of the average CO2 flux of the last three bins 
%          for the June to August data
%   5) Round round up threshold value to nearest 0.05 m/s value

% (c) kai* Dec 12, 2002
% Revisions: 

if (~exist('plot_flag') | isempty(plot_flag)) 
   if nargout == 1
   	plot_flag = 0;
	else
      plot_flag = 1;
   end
end

%-----------------------------------------------------------------------------
%   1) Find nighttime measurements (RADIATION == 0)
%-----------------------------------------------------------------------------
yy = datevec(tv);
ind_nig = find(radiation_hhour==0 & (yy(:,2)>=6 & yy(:,2)<=8));

%-----------------------------------------------------------------------------
%   2) Remover outliers (0.5% percentile highest and lowest CO2 fluxes)
%-----------------------------------------------------------------------------
[fc_dum,ind_sort] = sort(fc_hhour(ind_nig));
ind_sort = ind_sort(1+ceil(length(ustar_hhour(ind_sort))*1e-3/2):end-floor(length(ind_sort)*1e-3/2));

%-----------------------------------------------------------------------------
%   3) Bin average data according to USTAR in 10 bins with equal no. of points
%-----------------------------------------------------------------------------
[ustar, fc] = bin_avg(ustar_hhour(ind_nig(ind_sort)), fc_hhour(ind_nig(ind_sort)), floor(length(ind_sort)/10),[1 2]);

%-----------------------------------------------------------------------------
%   4) Calculate threshold as 80% of the average CO2 flux of the last three bins
%-----------------------------------------------------------------------------
fc_max = mean(fc(end-2:end,1));
fc_threshold = 0.8 * fc_max;
ind_ust = max(find(fc(:,1)<fc_threshold));
ust_threshold = interp1(fc(ind_ust:ind_ust+1,1),ustar(ind_ust:ind_ust+1),fc_threshold);

%-----------------------------------------------------------------------------
%   5) Round round up threshold value to nearest 0.05 m/s value
%-----------------------------------------------------------------------------
ust_threshold = ceil(ust_threshold*20)./20;

%-----------------------------------------------------------------------------
%   Plot if requested
%-----------------------------------------------------------------------------
if plot_flag == 0;
   return
end

errorbar(ustar,fc(:,1),fc(:,2),'o-');
hold on

plot(ustar_hhour(ind_nig(ind_sort)),fc_hhour(ind_nig(ind_sort)),'ro','Markersize',2);
errorbar(ustar,fc(:,1),fc(:,2),'o-');
plot([ust_threshold ust_threshold],[-100 100],'k:');
plot([0 5],[fc_max fc_max],'k:');
plot([0 5],[fc_threshold fc_threshold],'k:');
hold off
axis([0 1.5 -5 15]);
text(1.1,-3,['Threshold u_* = ' num2str(ust_threshold)],'HorizontalA','right');
