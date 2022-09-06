function [gc] = calc_multiplicative_model_gc(T, RH, psi_soil,coeff);
%calc_multiplicative_model_gc.m 

%---------------------------------------------------------------------------------
%
% gc = gcmax[1/(1+aD)][1-exp(-b(psi_soil-psi_soil_max))]
%
%
% Inputs: T - air temperature (deg C)
%         RH - relative humidity (%)
%         psi_soil - matric potential in MPa
%
%Elyn Humphreys                 Nov 27, 2001
%
%Revisions     Dec 7, 2001 (new model and coefficients)
%              April 4, 2002 - user input coefficients  
%----------------------------------------------------------------------------------------
UBC_biomet_constants;


%coefficients:
gcmax = coeff(1);
a     = coeff(2);
b     = coeff(3);
psi_soil_max = coeff(4);

%----------------------------------------------------------------------------------------
[e_H,ea_H] = vappress(T, RH);
vpd        = ea_H - e_H;           %use HMP completely,kPa
ind        = find(vpd < 0);
vpd(ind)   = 0;


gc = gcmax.* (1./(1+a.*vpd)).* (1-exp(-b.*(psi_soil-psi_soil_max)));
gc = real(gc);
