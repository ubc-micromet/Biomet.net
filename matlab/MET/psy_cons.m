function psychrometer_constant = psy_cons(T,e,P,flag);
%psy_cons.m THIS MATLAB FUNCTION CALCULATES THE PSYCHROMETRIC CONSTANT      
% (kPa C^-1)                                                      

% Input variables
%        T = air temperature (dry bulb) in deg C                  
%        e = water vapour pressure in kPa                         
%        P = barometric pressure in kPa               
%     flag = 0, output in kPa/degC
%          = 1, output in 
% Revisions: E.Humphreys Oct 16, 2001
%*****************************************************************%        

UBC_biomet_constants

if nargin < 4
    flag = 0;
end

specific_heat = spe_heat(e,P); %J/kg/degC
lamda         = Latent_heat_vaporization(T); %J/kg


switch flag
case 0
    psychrometer_constant = P.*specific_heat./(Epsilon.*lamda);      
case 1
    rho = rho_air(T); %kg/m3
    psychrometer_constant =  specific_heat./lamda; %(g water/ g air)/K
    psychrometer_constant =  psychrometer_constant.*rho.*1000; %g/m3/K
end
