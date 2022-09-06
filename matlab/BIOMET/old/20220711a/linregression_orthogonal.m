function a = linregression_orthogonal(x,y)
% a = linregression_orthogonal(x,y)
%
% Orthogonal linear regression of y and x. Function returns the following
% parameters in the vector a:
% a(1:2) - regression parameters (a(1): slope; a(2): the intercept)
% a(3:4) - x_bar and y_bar 
% a(5:6) - estimated standard deviations of regression parameters
% a(7)   - RMSE (aka sigma_hat, s_yx, standard error of the regression etc.)
% a(8)   - r^2
% a(9)   - n
%
% error estimate for the parameter y_bar to be used in error progression
% analysis (y = m(x-x_bar) + y_bar) is NOT IMPLEMENTED AT THE MOMENT...
%
% The calculations follow Paul Wessely (2000): Geological Data Analysis, ch. 4.2
% and the accompanying matlab functions by Cecily Wolfe found at 
% www.higp.hawaii.edu/~cecily/courses/gg313.html
%
% Only data pairs with valid values in both x and y will be used in the
% regression.
%
% Nov 2, 2004 crs - Replaced not implemented error estimate with RMSE in a(7)

ind_good = find(~isnan(x) & ~isnan(y));
x = x(ind_good);
y = y(ind_good);

a = linreg(x,y);
n = length (x);
mean_x = mean (x);
mean_y = mean (y);
sig_x = std (x);
sig_y = std (y);
u = x - mean_x;
v = y - mean_y;
sum_v2 = sum (v .* v);
sum_u2 = sum (u .* u);
sum_uv = sum (u .* v);
part1 = sum_v2 - sum_u2;
part2 = sqrt ((sum_u2 - sum_v2) ^ 2.0 + 4.0 * sum_uv * sum_uv);
b(1) = (part1 + part2) / (2.0 * sum_uv);
b(2) = (part1 - part2) / (2.0 * sum_uv);
r = sum_uv / sqrt (sum_u2 * sum_v2);
if sign (b(1)) == sign (a(1))
	a(1) = b(1);
else
	a(1) = b(2);
end
a(2) = mean_y - a(1) * mean_x;

a(3) = mean_x;
a(4) = mean_y;

a(5) = a(1) * sqrt ((1.0 - r * r) / n) / r;
a(6) = sqrt (((sig_y - sig_x .* a(1)) .^ 2) / n + (1.0 - r) .* a(1) .* ...
   (2.0 .* sig_x .* sig_y + (mean_x .* a(1) .* (1.0 + r) / (r .* r))));
a(7) = sqrt(sum(((a(1).*x+a(2))-y).^2)/(length(y)-2));
a(8) = r*r;
a(9) = n;

return
