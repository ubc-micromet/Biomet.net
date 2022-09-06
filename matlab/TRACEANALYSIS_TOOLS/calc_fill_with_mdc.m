function [x_filled,x_avg,mdc] = calc_fill_with_mdc(clean_tv,x,cyc_length)
% [x_filled,x_avg,mdc] = calc_fill_with_mdc(clean_tv,x,cyc_length)
% NaNs in variable x are filled with mean diurnal courses of over 
% cyc_length days. Any NaNs left after this are filled from a diurnal 
% course over 2*cyc_length

clean_tv = fr_round_hhour(clean_tv);
[yy,mm,dd,hh] = datevec(clean_tv);

tv_doy= convert_tv(clean_tv,'nod',6);

cyc = ceil(length(tv_doy)/48/cyc_length);
mdc = NaN .* zeros(cyc,24);
x_avg    = NaN .* zeros(size(tv_doy));
x_filled = x;

% Generate mean diurnal courses by doing running means for each hour
for i = 1:24
   ind_hh = find(hh == i-1);
   [x_avg_hh ind] = runmean(x(ind_hh),2*cyc_length,1);

   % This way the beginning and end of x_avg_hh have nans
   % All other nans are filled from an avg diurnal course of 2*cyc_length
   ind_nan = find(isnan(x_avg_hh)==1 & ...
      floor(tv_doy(ind_hh)) > 2*cyc_length/2 & floor(tv_doy(ind_hh)) < length(tv_doy(ind_hh))-2*cyc_length/2);
   if ~isempty(ind_nan)
      [x_avg_long ind] = runmean(x(ind_hh),4*cyc_length,1);
      x_avg_hh(ind_nan) = x_avg_long(ind_nan);
   end
      
   x_avg(ind_hh) = x_avg_hh;
   
   ind_nanorg = find(isnan(x)==1 & hh == i-1);
   x_filled(ind_nanorg) = x_avg(ind_nanorg);
   
   mdc_temp = runmean(x(ind_hh),2*cyc_length,2*cyc_length);
   mdc(1:length(mdc_temp),i) = mdc_temp;
end
