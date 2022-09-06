function a = linregression(x,y)
% a = linregression(x,y)
%
% Linear regression of y against x. Function returns the following
% parameters in the vector a:
% a(1:2) - regression parameters (a(1): slope; a(2): the intercept)
% a(3:4) - x_bar and y_bar 
% a(5:6) - estimated standard errors of regression parameters
% a(7)   - error estimate for the parameter y_bar to be 
% 		   used in error progression analysis (y = m(x-x_bar) + y_bar)
% a(8)   - r
%
% The vector a is used by linprediction to calculate predicted y 
% values and their error estimate
%
% The calculations follow Squires (1968): Practical physics, ch. 4 & app. E
%
% Only data pairs with valid values in both x and y will be used in the
% regression.

% Revision:
% Feb 12, 2004 - kai* Zhong pointed out that the function returns r, not
%                     r^2, so it was corrected accordingly
% Nov 1, 2004  - crs a(5:6) are standard errors and NOT std dev, help fixed

[a,sig_a,r,y_cl95] = linreg(x,y);

ind_good = find(~isnan(x) & ~isnan(y));
a = [a mean(x(ind_good)) mean(y(ind_good)) sig_a r];
