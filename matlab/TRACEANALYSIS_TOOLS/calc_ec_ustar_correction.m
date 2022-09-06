function [correction_factor,correction_params] = calc_ec_ustar_correction(clean_tv,relative_energy_balance_closure,ustar)
% A correction factor is calculated for each hhourly observation based on the dependence of 
% energy balance closure on ustar. First all relative energy balance closure values between 
% -2 and 2 are binned into classes according to ustar. The width of the classes is 0.1 m/s and
% classes range from 0 to 1.5 m/s. Only classes with more than 100 obersations in them are 
% used in the subsequent analysis. The remaining classes are then normalized to the mean of 
% the values for the four highest ustars max_rebc and fit to the function
%       func(X) = 1./(1+exp(A(1).*(X-A(2))))
% This function gives the factor by which the relative energy balance closure is reduced for 
% a given ustar. The normalisation at high ustar allows for a lag even at high ustar values.
% The correction factor returned is calculated according to
%       correction_factor =  1 ./ (max_rebc .* func(ustar))
% For details see P. Blanken's thesis

% (c) kai*                                    File created:  Nov. 24, 2000
%                                             Last modified: Nov. 24, 2000
%
% Revisions: 

% The function uses only the following values:
upper_ustar = 1.5;
lower_rebc  = -2;
upper_rebc  = 2;

%E.Humphreys Nov 8, 2001 - divide up ustar into smaller groups according to ustar distribution
ind   = find(~isnan(ustar));
[N,X] = hist(ustar(ind));
N_sum = cumsum(N);
ind   = find(N_sum./sum(N) <= 0.98);
ustar_div = round(X(ind(end))./15.*1000)./1000

avg_rebc  = blockavg(ustar,relative_energy_balance_closure,ustar_div,upper_rebc,lower_rebc);
ind_ustar = find(avg_rebc(:,1) < upper_ustar & avg_rebc(:,4)>100); 
avg_rebc  = avg_rebc(ind_ustar,:);
max_rebc  = mean(avg_rebc([end-3:end],2));


% Fit logistic function to binned data
params_start = [1, 0];

f = inline('1./(1+exp(-param(1).*(x-param(2))))','param','x');

opts = fr_optimset('Display','off');
[params,Y_hat,output] = fr_function_fit(f,params_start,avg_rebc(:,2)./max_rebc,opts,avg_rebc(:,1));

correction_factor =  1 ./ (max_rebc .* ustar_correction(params,ustar));

% Assemble params for return
correction_params.avg_rebc  = avg_rebc;
correction_params.max_rebc  = max_rebc;
correction_params.params    = params;
correction_params.Y_hat  	= Y_hat;
correction_params.R2		= output.R2;

