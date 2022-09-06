function [ustar,Lstar] = calc_ustar_L(h_c, z_m, u, T_a, RH, p_bar, H, LE)
%
%Lstar = calc_monin_obhukov_L(ustar,T_a,RH,p_bar,H,LE)
% monin_obukhov_length = calc_monin_obhukov_length(ustar_main,air_temperature_main,h2o_avg_main,barometric_pressure_main,h_main,le_main);
%*****************************************************
%function Lstar = calc_monin_obhukov_L(hc, z_m, u,T_a,RH,p_bar,H,LE)
%%Inputs:
%h_c: canopy height, in m;
%z_m: eddy-covarance and other sensors' height in m. normally z_m>h_c
%u: wind speed above canopy at z_m in m/s
%T_a: air temperature at z_m in oC
%p_bar: atmospheric pressure in kPa, minMax = [80,110]
%RH: relative humidity in %
%H:'Sensible Heat Flux' at z_m, units = 'W m^{-2}', minMax = [-200,1000]
%LE:'Latent Heat Flux' at z_m, units = 'W m^{-2}', minMax =
%[-200,1000]Outpu
%
%outputs: 
%ustar, friction wind speed in m/s
%monin obhukov length in meter
%
%By Chenb, May 8, 2009
%**************************************************************************

UBC_biomet_constants_SI;
z_0 = 0.1*h_c;
ustar_neo = u * k / (log(z_m/z_0)); % in neotrl condition, first order estimation
Lstar_first = calc_monin_obhukov_L(ustar_neo,T_a,RH,p_bar,H,LE);
ustar = u * k / (log(z_m/z_0)+ psi_m(z_m,Lstar_first)); %recal ustar with stability correction
%us = ustar
Lstar = calc_monin_obhukov_L(ustar,T_a,RH,p_bar,H,LE); %recalculate L as using corrected ustar
%ustar=ustar_neo
return


function z = psi_m(z,L);
zeta = (1 - 16 .* z./L).^(1/4);
if L>0
    z = 5*z./L;
else
    z = -2*log((1+zeta)/2) - log((1+zeta.^2)/2) + 2 * atan(zeta) - pi/2;
end


