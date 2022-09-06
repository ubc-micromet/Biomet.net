function Lstar = calc_monin_obhukov_L(ustar,T_a,RH,p_bar,H,LE)
% monin_obukhov_length = calc_monin_obhukov_length(ustar_main,air_temperature_main,h2o_avg_main,barometric_pressure_main,h_main,le_main);
%*****************************************************
%function Lstar = calc_monin_obhukov_L(hc, z_m, u,T_a,RH,p_bar,H,LE)
%%Inputs:
%ustar, friction wind speed in m/s
%T_a: air temperature at z_m in oC
%p_bar: atmospheric pressure in kPa, minMax = [80,110]
%RH: relative humidity in %
%H:'Sensible Heat Flux' at z_m, units = 'W m^{-2}', minMax = [-200,1000]
%LE:'Latent Heat Flux' at z_m, units = 'W m^{-2}', minMax = [-200,1000]Outpu
%
%Uptputs:
%monin obhukov length in meter
%
%modified by Chenb, May 9, 2009
%********************************
UBC_biomet_constants_SI;
lambda_v = lambda(T_a); % J kg^-1 K^-1 ; Needs degC as input 

% Conversion to base units:
%s_v   = s_v./1e3;
p_bar = p_bar .* 1e3; %conver it to Pa from kPa
T_ak   = T_a + To;   %abslute temp, where To = 273.15
es_H = 0.61365.*exp((T_a.*17.502)./(240.97+T_a)); %SATURATION VAPOUR PRESSURE in kPa
                                                   %where T_a is air temperature in oC.
e_H = RH/100*es_H;  %vapour pressure in kPa
%[e_H,es_H] = vappress(T_a, RH); %es_H--saturation vapour pressure;e_H-- vapour pressure

chi_v = e_H.*1e3/p_bar;
s_v = Epsilon*(e_H/(p_bar/1e3-e_H));  %Mixing ratio can also be expressed with the partial pressure of water vapor. Epsilon = 0.62197
                                 % s_v is in kilograms of water vapour, mw, per kilogram of dry air, md, at a given pressure

%s_v = s_v*1e3;  % convert unit "kg water /kg dry air" to 'mmol / mol'                                
%chi_v = s_v./(1+s_v)

T_v = T_ak .* (1+(1-Epsilon) .* chi_v); % Monteith and Unsworth (1990), p. 12. Epsilon = 0.622
                                       %chi_v = e/p, where e = vapour pressure, p= air pressure

rho   = p_bar./(R.*T_ak); % mol m^-3
rho_v = rho .* chi_v;   % mol m^-3
rho_a = rho - rho_v;    % mol m^-3
rho_cp = Cp .* Ma .* rho_a + Cpv .* Mv .* rho_v;

cov_w_T_a = H ./ rho_cp;
cov_w_s_v = LE ./ (lambda_v .* Ma .* rho_a );

cov_w_T_v = cov_w_T_a .* (1 + (1-Epsilon).*s_v) + (1-Epsilon) .* cov_w_s_v .* T_ak;

Lstar = - T_v .* ustar.^3 ./ ( k .* g .* cov_w_T_v);

return