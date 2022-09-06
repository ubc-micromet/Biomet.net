function delta_z = calc_delta_z(nbr_h, h_co2)
% Fonction that calculates DELTA_Z (for co2 storage calculations)
%
% input     = nbr_h, number of heigths of measurements for co2 profile system     
%           = h_co2, heights of measurements for co2 profile system (meters) 
%             **********(ASCENDING ORDER !!!)***********
% output    = delta_z, tickness of each layer (meters)
%
% example of h_co2 = [0.5 2 4 10 18 22 28 39];
%
% Created by   David Gaumont-Guay 2001.04.09
% ___________________________________________________________________________


h_mid_co2   = (h_co2(1:end-1) + h_co2(2:end)) ./ 2;

delta_z     = NaN .* ones(1,nbr_h);     % creates a matrix with NaN

delta_z         = [NaN diff(h_mid_co2)];    
delta_z(1)      = h_mid_co2(1);
delta_z(nbr_h)  = h_co2(end) - h_mid_co2(end);
