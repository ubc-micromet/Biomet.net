function latent_heat_vaporization = lambda(T);
%*****************************************************************%
% THIS MATLAB FUNCTION CALCULATES THE LATENT HEAT OF VAPORIZATION %
% (J kg^-1)                                                       %
%                                                                 %
%        latent_heat_vaporization = lambda(T)                     %
%                                                                 %
%        T = air temperature in Celcius                           %
%                                                                 %
%*****************************************************************%        

latent_heat_vaporization = (2501-2.38.*T).*1000;
