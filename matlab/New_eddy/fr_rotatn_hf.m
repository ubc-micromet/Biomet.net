function [Eddy_HF_data_rot] = fr_rotatn_hf(Eddy_HF_data,angles)
%	[Eddy_HF_data] = fr_plot_raw(Eddy_HF_data,angles)
%
% Rotates the high frequency data assuming that the first the column in Eddy_HF_data 
% contain u v w

% Do the rotation
if isnan(angles(3))
   ce = cos(pi/180*angles(1));
   se = sin(pi/180*angles(1));
   ct = cos(pi/180*angles(2));
   st = sin(pi/180*angles(2));
   
   Eddy_HF_data_rot      = Eddy_HF_data;
   
   Eddy_HF_data_rot(:,1) = Eddy_HF_data(:,1)*ct*ce + Eddy_HF_data(:,2)*ct*se + Eddy_HF_data(:,3)*st;
   Eddy_HF_data_rot(:,2) = Eddy_HF_data(:,2)*ce - Eddy_HF_data(:,1)*se;
   Eddy_HF_data_rot(:,3) = Eddy_HF_data(:,3)*ct - Eddy_HF_data(:,1)*st*ce - Eddy_HF_data(:,2)*st*se;
     
else
   ce = cos(pi/180*angles(1));
   se = sin(pi/180*angles(1));
   ct = cos(pi/180*angles(2));
   st = sin(pi/180*angles(2));
   cb = cos(pi/180*angles(3));
   sb = sin(pi/180*angles(3));
   
   means2(:,1) = Eddy_HF_data(:,1)*ct*ce + Eddy_HF_data(:,2)*ct*se + Eddy_HF_data(:,3)*st;
   means2(:,2) = Eddy_HF_data(:,2)*ce - Eddy_HF_data(:,1)*se;
   means2(:,3) = Eddy_HF_data(:,3)*ct - Eddy_HF_data(:,1)*st*ce - Eddy_HF_data(:,2)*st*se;
   
   Eddy_HF_data_rot      = Eddy_HF_data;
   Eddy_HF_data_rot(:,1) = means2(:,1);
   Eddy_HF_data_rot(:,2) = means2(:,2)*cb + means2(:,3)*sb;
   Eddy_HF_data_rot(:,3) = means2(:,3)*cb - means2(:,2)*sb;   
end


