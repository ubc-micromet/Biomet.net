function [x_avg, ind_avg, x_std,x_n]= runmean(x,width,step)
% [x_avg, ind_avg, x_std,x_n]= runmean(x,width,step)
%
% Calculates the running mean for columns of x at points
% ind_avg = round(width/2)+[0:step:(length(x)-width)]';
% The mean values represent intervals of length width
% centred around the ind_avg. x_std are the standard
% deviations corresponding to the x_avg, x_n is the
% number of values used for averaging in the corresponding 
% interval.

% kai* June 13, 2002

[n,m] = size(x);

warning off;

x_nan = isnan(x);
x(find(x_nan(:) == 1)) = 0;

% The average of many overlapping interval is best done via
% the cumulative sum
x_sum   = cumsum(x);
x_sum_0 = [zeros(1,m); x_sum];

% The number of nan has to be tracked to have the correct denominator
% in the calculation of the average
x_sumnan = cumsum(x_nan);
x_sumnan_0 = [zeros(1,m); x_sumnan];

no_in_width = width * ones(size(x));
no_of_nan = x_sumnan(width:step:end,:)- x_sumnan_0(1:step:(end-width),:);
no_in_width = width * ones(size(no_of_nan)) - no_of_nan;

% Calculation of the average
x_avg   = (x_sum(width:step:end,:) - x_sum_0(1:step:(end-width),:))./no_in_width;
ind_avg = [0:step:(length(x)-width)]'+round(width/2);

% In case step is one the beginning and the end are initialized to
% NaN in order to get a vector that still has the original length.
if step == 1
   x_avg_temp = x_avg;
   x_avg = NaN .* zeros(size(x));
   x_avg(ind_avg,:) = x_avg_temp;
end

if nargout < 3
   warning backtrace;
   return
end

% Calculations needed to do the running std
% Calculation of the average for step of one
ind_avg_1 = [0:1:(length(x)-width)]'+round(width/2);
no_of_nan_1 = x_sumnan(width:1:end,:)- x_sumnan_0(1:1:(end-width),:);
no_in_width_1 = width * ones(size(no_of_nan_1)) - no_of_nan_1;
x_avg_1 = zeros(size(x));
x_avg_1(ind_avg_1,:) = (x_sum(width:1:end,:) - x_sum_0(1:1:(end-width),:))./no_in_width_1;

ind_nan = find(isnan(x_avg_1));
x_avg_1(ind_nan) = 0;

% Calculation of the std
x2_sum = cumsum((x-x_avg_1).^2);
x2_sum(ind_nan) = NaN;
x2_sum_0 = [zeros(1,m); x2_sum];
x2_sum_0(ind_nan) = NaN;

x_std = (x2_sum(width:step:end,:) - x2_sum_0(1:step:(end-width),:))./no_in_width;
x_std = sqrt(x_std);

x_n = no_in_width;

if step == 1
	x_std_temp = x_std;
   x_std = NaN .* zeros(size(x));
   x_std(ind_avg,:) = x_std_temp;
end

