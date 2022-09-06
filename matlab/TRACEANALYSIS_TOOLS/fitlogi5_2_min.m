function[ESS] = logi5_2_min(coeff, obs_flux, Temp)

respiration = logi5(coeff,Temp); %3 coefficients + temperature

difference = obs_flux - respiration;

ESS = sum(difference .^2);

function y_hat = logi5(coeff,X)
%   THIS PROGRAM DO THE BEST FIT OF RECTANGULAR
%       HYPERBOLA 
%       
%       Y = a/(1 + exp(b*(c-x))) 
%
%   First created on: 20 June 1997 by Paul Yang
%        Modified on: 20 June 1997 by Paul Yang 
%

y_hat=(coeff(1))./(1 + exp(coeff(2).*(coeff(3)-X)));

