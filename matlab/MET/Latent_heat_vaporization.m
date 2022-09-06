function[L_v] = Latent_heat_vaporization(T);
%Latent_heat_vaporization.m Calculate the latent heat of vaporization at any temperature

% Input: temperature in deg C
% Output: J/kg
%
% Reference
% Stull, R.B. 1988.  An Introduction to Boundary Layer Meteorology.  Kluwer. p 641
%
% E. Humphreys          Oct 20, 1998
%
%------------------------------------------------------------------------

L_v = (2.501-0.00237*T).*10^6;