function [ga_m, ga_h] = calc_aerodynamic_conductance(u,ustar,zeta);
%---------------------------------------------------------------------------------
%Working Aerodynamic resistance... (s/m)
%
%
%Elyn Humphreys                 March 25, 1999
%
%Revisions    Feb 16, 2000 - y2k compatible 
%             Oct 16, 2001 - now a function with inputs
%---------------------------------------------------------------------------------
ver = version;
if ver(1) == '5'
    warning off;
else
    warning off MATLAB:divideByZero;
end

UBC_biomet_constants_SI;

%------------------------------------------------------------
% Integrated profile correction functions
% 
%------------------------------------------------------------.
[Psi_m, Psi_h] = Psi_cor(zeta,2);

%------------------------------------------------------------
% Aerodynmaic resistance for momentum
% 
%------------------------------------------------------------.
ra_m = u./ustar.^2; %this should be the best when the gill is working ok ... includes stability effects/corrections implied in ustar

%------------------------------------------------------------
% Aerodynmaic resistance for heat and water vapour
% with excess resistance, rah = ram+rb
%------------------------------------------------------------
%  Gash, JHC, Valente, F. & David, J.S. 1999. Estimates and measurement of evaporation from 
%  wet, sparse pine forest in Portugal.  Agric For Met. 94: 149-158.
ra_h = (u./ustar +2./k + (Psi_h-Psi_m)./k)./ustar;


ga_m = 1./ra_m;
ga_h = 1./ra_h;

if ver(1) == '5'
    warning on;
else
    warning off MATLAB:divideByZero;
end
