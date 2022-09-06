function slope_satvp_temp = ds_dt(T,flag);
%ds_dt.m THIS MATLAB FUNCTION CALCULATES THE SLOPE OF THE SATURATION 
% VAPOUR PRESSURE VS. TEMPERATURE (BUCK, 1981)(kPa C^-1) - see LI610 manual  

% Note:  this is determined by differentiating the equation for saturation vapour 
% pressure/ density with respect to temperature

                          
% Input variables:                                                                 
%        T = air temperature in Celcius                           
%      flag = 0, output in kPa/degC
%      flag = 1, output in g/m3/degC
% 
% Revisions: E.Humphreys Oct 17, 2001
UBC_biomet_constants

if nargin < 2
    flag = 0;
end

switch flag
case 0
    slope_satvp_temp = 0.61365.*(17.502.*1./(240.97+T)-17.502.*T./((240.97+T).^2)).*...
        exp(17.502.*T./(240.97+T));
case 1
    slope_satvp_temp = 0.61365.*(17.502.*1./(240.97+T)-17.502.*T./((240.97+T).^2)).*...
        exp(17.502.*T./(240.97+T))./(Rv.*(T+ZeroK))-0.61365*exp(17.502.*T./(240.97+T))./...
        (Rv.*(T+ZeroK).^2);
    slope_satvp_temp = slope_satvp_temp.*10^6;
end


%slope_satvp_temp = 0.61121*((17.368*238.88)./(T+238.88).^2).*exp((T.*17.368)./(T+238.88));
