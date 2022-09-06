function [a,sig_a,r,y_cl95] = linreg(x,y)
% [a,sig_a,r,y_cl95] = linreg(x,y)
%
% Linear regression of y against x. Function returns the regression 
% parameters a (a(1) being the slope and a(2) the intercept), their 
% estimated standard errors sig_a, with sig_a(3) containing the
% error estimate for the parameter y_bar to be used in error 
% progression analysis (y = m(x-x_bar) + y_bar), the correlation 
% coefficient  r, and the 95% confidence intervals y_cl95 for the 
% mean predicted values.
%
% The calculations follow Squires (1968): Practical physics, ch. 4 & app. E
%
% Only data pairs with valid values in both x and y will be used in the
% regression.

% Revision:
% Feb 12, 2004 - kai* Zhong pointed out that the function returns r, not
%                     r^2, so it was corrected accordingly
% Nov 1, 2004  - crs se_a are standard errors and NOT std dev, help fixed

% Reduce data to non-nan values
ind_good = find(~isnan(x) & ~isnan(y));

if isempty(ind_good)
   a 		 = [NaN NaN];
   sig_a  = [NaN NaN NaN];
   r     = NaN;
   y_cl95 = NaN .* ones(length(x),2);
   %disp('No valid data in call of linreg!')
   return
else
   x = x(ind_good);
   y = y(ind_good);
end

% Assign unit standard deviation if not given
if ~exist('sig') | isempty(sig)
    sig = ones(size(x));
end

% Calculate the parameters accoring to Squires (1968), p.43,
% for the unweighted case
N     = length(x); 
x_bar = mean(x);
y_bar = mean(y);
D     = sum((x-x_bar).^2);
a(1)  = sum((x-x_bar).*y)./D;
a(2)  = y_bar - a(1).*x_bar;
d     = y - a(1).*x - a(2);
sig_a(1) = sqrt(           1/D  .* sum(d.^2)/(N-2));
sig_a(2) = sqrt((1/N+x_bar^2/D) .* sum(d.^2)/(N-2));

% For an error estimate for predicted values the error of 
% the intercept cannot be used (see remark at the end of
% appendix E in Squires). 
sig_a(3) = sqrt((1/N) .* sum(d.^2)/(N-2));

% The correlation coefficient is calc. as usual
r = sum((x-x_bar).*(y-y_bar))./((N-1).*std(x).*std(y));

% The line should 'pivot around the center of gravity', therefore the form
% a(1).*(x-x_bar) + y_bar is used here and the error is derived using error
% propagation for a(1) (error sig_a(1)) and y_bar (error sig_a(3))
% The factor 1.96 is the 95% confidence interval.
[n,m] = size(y);
if n>m
	y_cl95(:,1) = a(1).*(x-x_bar) + y_bar - 1.960 .* sqrt(sig_a(3).^2+(sig_a(1).*(x-x_bar)).^2);
   y_cl95(:,2) = a(1).*(x-x_bar) + y_bar + 1.960 .* sqrt(sig_a(3).^2+(sig_a(1).*(x-x_bar)).^2);
else
	y_cl95(1,:) = a(1).*(x-x_bar) + y_bar - 1.960 .* sqrt(sig_a(3).^2+(sig_a(1).*(x-x_bar)).^2);
   y_cl95(2,:) = a(1).*(x-x_bar) + y_bar + 1.960 .* sqrt(sig_a(3).^2+(sig_a(1).*(x-x_bar)).^2);
end