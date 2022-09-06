function [x_time, x_avg, x_sum, x_max, x_min, x_std, x_n] = dailystats_number(time_array, ...
   x, upper_limit, lower_limit, no, NaNflag, perc)
%   Computes 24 h (or multiple) statistics on any variable
%
%                                                       
%  inputs: time_array = (associated with x)
%          x = variable in question
%          upper and lower limits for x
%          no = number of days to sum
%  NaNflag: 1 = include NaN or [] to remove all NaN outputs
%  perc   : value between 0 and 1 = only include daily values with > ##% of 48 hhours
%
%  outputs: time = daily time array 
%            avg = average
%            sum = summation
%            max = max value
%            min = min value
%            std = standard deviation
%             n  = number of observations
%
%  Example: gives 3-day stats on Fc
%     [time, avg, sum, max, min, std, n] = dailystats_number(time, Fc, 50, -50, 3)
%
%  First generated on:  19 Jan 1996 by Z. Nesic and P. Yang
%        Modified on:   27 May 1997 by P. Yang  
%  Revisions: (E. Humphreys)
%   27 May 1997: Put the std to the output file
%   06 May 1999: Sum a certain number of days together 
%   15 Oct 2001: Allow datenum to be input
%   28 Nov 2001: Output individual variables instead of a matric
%================================================================

if exist('lower_limit') ~= 1 | isempty(lower_limit)
   lower_limit = min(x);
end 
if exist('upper_limit') ~= 1 | isempty(upper_limit)
   upper_limit = max(x);
end 

%setup start and stop
ta = time_array;
st = 0;
ind = 1;
lenx = length(x);
min_ta = floor(min(ta));
max_ta = ceil(max(ta));

%remove NaNs from the incoming data, select only data which meet specified limits
doy        = -1;
ind_cut    = find(isnan(x)==1 | (x<lower_limit | x>upper_limit));
x(ind_cut) = NaN;


%initialize matrix
nn = max_ta-min_ta+1;
x_stats = zeros(nn,7);

%ind/select 24 h periods from time_array and do statistics
for i = min_ta:no:max_ta
   st = st + length(ind);
   stp = st + 50*no;
   if stp > lenx
      stp = lenx;
   end 
   ind = find( ta(st:stp) > i & ta(st:stp) <= i+no);
%    if rem(i,nn)==0            
%       disp(i);
%    end
   if length(ind)>0
      tmp = x(ind+st-1);
      keep = find(~isnan(tmp));
      if length(keep) > 0;
         xx = mean(tmp(keep));
         xx1 = sum(tmp(keep));
         xx2 = max(tmp(keep));
         xx3 = min(tmp(keep));
         xx4 = std(tmp(keep));
         n = length(keep);
      else
         xx = nan;
         xx1 = xx;
         xx2 = xx;
         xx3 = xx;
         xx4 = xx;
         n = xx;
      end
   else
      xx = nan;
      xx1 = xx;
      xx2 = xx;
      xx3 = xx;
      xx4 = xx;
      n = xx;
   end        
   x_stats(i-min_ta+1,1) = i;%i+no./2;
   x_stats(i-min_ta+1,2) = xx;
   x_stats(i-min_ta+1,3) = xx1;
   x_stats(i-min_ta+1,4) = xx2;
   x_stats(i-min_ta+1,5) = xx3;
   x_stats(i-min_ta+1,6) = xx4;
   x_stats(i-min_ta+1,7) = n;
end        

%choose to remove any rows containing NaNs
if exist('NaNflag') == 1 & ~isempty(NaNflag);
else
   cut = find(x_stats(:,1) == 0 | isnan(x_stats(:,1)) |isnan(x_stats(:,2)) |...
      isnan(x_stats(:,3)) |isnan(x_stats(:,4))|isnan(x_stats(:,5))|isnan(x_stats(:,6))|...
      isnan(x_stats(:,7)));
   if ~isempty(clean(x_stats(:,1),1,cut));
      for i = 1:7
         new_x_stats(:,i) = clean(x_stats(:,i),1,cut);
      end
   else
      new_x_stats = [NaN NaN NaN NaN NaN NaN NaN];
   end
   x_stats = new_x_stats;
end

%choose to select only rows with at least 'perc'(%) of the data input and which met limits
if exist('perc') == 1
   ind = find(x_stats(:,7) >= perc.*48.*no);
   x_stats_tmp = x_stats(ind,:); clear x_stats;
   x_stats = x_stats_tmp;
end

%output variables
x_time = x_stats(:,1);
x_avg  = x_stats(:,2);
x_sum  = x_stats(:,3);
x_max  = x_stats(:,4);
x_min  = x_stats(:,5);
x_std  = x_stats(:,6);
x_n    = x_stats(:,7);