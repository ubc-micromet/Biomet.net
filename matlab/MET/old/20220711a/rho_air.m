function density_of_air = rho_air(T);
%rho_air.m THIS MATLAB FUNCTION CALCULATES THE DENSITY OF AIR AT 100 kPa   
% (kg m^-3)                                                       

% Input variables:                                                   
%        T = air temperature in Celcius                           
%                                                                 
% Revisions: E.Humphreys Oct 17, 2001  

 density_of_air = -4.03515e-3.* T + 1.28749;
