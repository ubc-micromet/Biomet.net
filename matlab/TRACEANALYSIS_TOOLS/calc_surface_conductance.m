function [gc, rc] = calc_surface_conductance(T, RH, ra, A, LE, Pb, type);
%calc_surface_conductance.m Calculates surface conductance via inverted Penman-Monteith Eqn
% using either the Bowen ratio or direct fluxes

%---------------------------------------------------------------------------------
%
% LE = (sA+ pcpD/ra_h)/(s+gamma(1 +rc/ra_h)
%
%
% Inputs: T - air temperature, degC
%         RH - relative humidity (%)
%         ra - aerodynamic resistance for heat and water vapour (s/m)
%         A - available energy (W/m2)
%         LE - latent heat flux (W/m2)
%         Pb - barometric pressure (kPa)
%         type - 'bowen' for bowen ratio method
%              - 'direct' for direct method
%
%Elyn Humphreys                 Oct 16, 2001
%
%Revisions     
%  
%----------------------------------------------------------------------------------------
UBC_biomet_constants;

if exist('type') ~= 1 | isempty(type)
    type = 'direct';
end

%----------------------------------------------------------------------------------------
[e_H,ea_H] = vappress(T, RH);
vpd        = ea_H - e_H; %use HMP completely,kPa
vdd        = 10^6.*(vpd)./(Rv.*(T+ZeroK)); %g/m3

gamma      = psy_cons(T,e_H,Pb); % kPa/degC
s_cc       = ds_dt(T);           % kPa/degC

p          = rho_air(T);   %density of air kg/m3
sp_heat    = spe_heat(e_H,Pb); %specific heat of moist air J/kg/m3
 

%direct method
rc_direct   = (((s_cc.*A+p.*sp_heat.*vpd./ra)./LE-s_cc)./gamma-1).*ra; %s/m


%bowen ratio method
s_cc        = ds_dt(T,1);                 % g/m3/degC
gamma       = psy_cons(T, e_H, Pb, 1);    % g/m3/degC
rc_bowen    = ((s_cc./gamma).*((A./LE)-1)-1).*ra+(p.*sp_heat.*vdd)./(gamma.*LE); %s/m



switch type
case 'direct'
    rc          = rc_direct;
case 'bowen'
    rc          = rc_bowen;     
end

gc          = 1./rc;     %m/s



