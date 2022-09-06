%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here are some examples of how fr_function_fit may be used.
% The utilisation of MAD for linear regression of data with
% outliers is explained at the very end.
%
% kai* June 21, 2001
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting a sin to test data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate test data - normally distributed noise 
% around a sin function
x = (1:1000)'./360;
param_true = [1.5 60];
eps = randn(1000,1); % This is the noise
y = param_true(1) .* sin(2*pi.*x + param_true(2)) + eps;

% Fit sin to test data
param0 = [1 0];
% Here the use of an Inline function is demonstrated
f = inline('param(1).*sin(2*pi.*x+param(2))','param','x');
% The fit uses the default option that are displayed when
% fr_optimset is called without any arguments

[param,y_fit] = fr_function_fit(f,param0,y,[],x);
param
plot(x,y,'.',x,y_fit,'r');

% For an *.m file named fit_sin.m and containing
% function y = fit_sin(param,x)
% param(1).*sin(2*pi.*x+param(2));
%
% the function call would look like this
[param,y_fit] = fr_function_fit('fit_sin',param0,y,[],x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting a straight line using OLS and MAD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate test data - normally distributed noise 
% around a straight line
x = (1:1000)'./100-5;
param_true = [1.5 3];
eps = randn(1000,1); % This is the noise
y = param_true(1) .*x + param_true(2) + eps;
y_r = randn(1000,1);

% Adding outliers
no = 100;
ind = round(rand(no,1)*1000);
ind_pos = find(x(ind) > 0);
ind_neg = find(x(ind) <= 0);

% By giving the outliers this bias they will pull
% the fit down
y(ind(ind_pos)) = -abs(y_r(ind(ind_pos))*10);
y(ind(ind_neg)) =  abs(y_r(ind(ind_neg))*10);


% Again, for simplicity we use an inline function
f = inline('param(1) .* x + param(2)','param','x');
% And here is a sensible choice for the options
options = optimset('maxiter', 10^7, 'maxfunevals', 10^7, 'tolx', 10^-6);
% More options can be added this way
options = fr_optimset(options,'method', 'ols');
[param_ols,y_ols,stats_ols] = fr_function_fit(f,param0,y,options,x);

options = fr_optimset(options,'method', 'mad');
[param_mad,y_mad,stats_mad] = fr_function_fit(f,param0,y,options,x);

plot(x,y,'.',x,y_ols,'r',x,y_mad,'g');

param_mad
stats_mad
param_ols
stats_ols

% These values show that (a) the MAD method does indeed come much closer to 
% to the true value, and (b) that the R2 for the MAD is slightly less, which 
% is expected since it does not maximize R2
