function sat_vp = sat_vp(T);
%*****************************************************************%
% THIS MATLAB FUNCTION CALCULATES THE SATURATION VAPOUR PRESSURE  %
% (kPa) see Li-cor dew-point manual, p 3-7, eqn 3-4               %
%                                                                 %
%        function sat_vp = sat_vp(T)                              %
%                                                                 %
%        T = air temperature (dry bulb)                           %
%*****************************************************************%        

sat_vp = 0.61365.*exp((T.*17.502)./(240.97+T));
