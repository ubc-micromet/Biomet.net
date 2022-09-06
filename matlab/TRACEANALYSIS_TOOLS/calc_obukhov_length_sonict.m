function Lstar = calc_obukhov_length_sonict(sonic_temperature_main,ustar_main,covariance_w_sonict_after_rot)
% Lstar = calc_obukhov_length_sonict(sonic_temperature_main,ustar_main,covariance_w_sonict_after_rot)
% This function is different from calc_monin_obhukov_length in that it does
% not calculate the virtual potential temperature(Kaimal and Finnigan 1994,
% pg.15).The sonic-derived temperature can be treated as a close
% approximation of the true virtual temperature (Kaimal and Finnigan 1994,
% pg. 224). The virtual potential temperature correction only makes a small
% difference in the calculation,and it can be useful to compare the two. 
% Please note that the function MO_L is faulty and should not be used. 
% Function written by Eugenie Paul-Limoges, February 2012

UBC_biomet_constants_SI;

temperature_kelvins = sonic_temperature_main + To; %Conversion from Celsius to Kelvins

Lstar = - ( temperature_kelvins.* ustar_main.^3 )./ ( k .* g .* covariance_w_sonict_after_rot);

return