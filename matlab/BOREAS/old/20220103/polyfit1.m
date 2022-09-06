function [p, R2, sigma, s, Y_hat, reg_stats] = polyfit1(x,y,n)
%	This is the program for polyfit with r2 output
%
%	Inputs:
%			x -- the independent variable
%			y -- the dependent variable
%			n -- the order of regression
%
%	Outputs:
%			p -- the coefficient matrix
%			R2 -- the coefficient of determination
%			sigma -- the standard deviation
%			s -- the same as in POLYFIT
%			Y_hat -- the calculated y
%
%	Syntax:
%
%			[p, R2, sigma, s, Y_hat] = polyfit1(x,y,n)
%
%	See also POLYFIT
%
%	Created on  06 June 1997 by Paul Yang
%	Modified on 28 Dec. 1998
%
%	Revisions:
%			10 Feb. 1998: more commentation
%			28 Dec. 1998: using polyval
%         23 Feb  2003: changed R2 calculation to SSreg/SStotal (used to be 1 - SSres/SStotal).  Usually same answer.
ind_good = find(~isnan(x) & ~isnan(y));
[p s] = polyfit(x(ind_good),y(ind_good),n);

% The regression problem is formulated in matrix format as:
%
%    y = V*p    or
%
%          3  2
%    y = [x  x  x  1] [p3
%                      p2
%                      p1
%                      p0]
%
% where the vector p contains the coefficients to be found.  For a
% 7th order polynomial, matrix V would be:
%
% V = [x.^7 x.^6 x.^5 x.^4 x.^3 x.^2 x ones(size(x))];

l = length(p);
V = [];
for i = 1:l-1
	V = [V x.^(l-i)];
end
V = [V ones(size(x))];

% Y_hat = V*p';
Y_hat = polyval(p,x);
Y = y;

%% R2 (R_squared)

reg = sum((Y_hat-mean(Y)).^2);
res = sum((Y_hat - Y).^2);
total = sum((Y - mean(Y)).^2);
if total == 0
    R2 = NaN;
else
    R2 = 1.0 - res/total;
end
%sigma = sqrt(res);
if n == 1;
   sigma = sqrt(res./(s.df)); %Zar p 270 - s_y.x, standard error of the estimate (or of the entire regression)
else
   sigma = NaN;
end

SSx = sum((x-mean(x)).^2);
reg_stats.SE_b = sqrt(sigma.^2./SSx);
reg_stats.SE_a = sqrt(sigma.^2.*((1./length(x)) + mean(x).^2./SSx));
reg_stats.Xbar = mean(x);
reg_stats.SSx  = SSx;
reg_stats.n    = length(x);
reg_stats.sigma = sigma;
%R2 = reg./total;
