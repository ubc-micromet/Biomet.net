function [ra_m, ra_h] = calc_aerodynamic_resistance(SiteID,year,u,ustar, T, H2Omix, covwT, covwH2O);
%---------------------------------------------------------------------------------
%Working Aerodynamic resistance... (s/m)
%
%
%Elyn Humphreys                 March 25, 1999
%
%Revisions    Feb 16, 2000 - y2k compatible 
%             Oct 16, 2001 - now a function with inputs
%---------------------------------------------------------------------------------

%---------------------------------------------------------------------------------
%Campbell River site parameters
%---------------------------------------------------------------------------------
UBC_biomet_constants;
%[h,z,d,zo,zo_h,k] = canopy_characteristics(SiteID,year);
try,
   sc = read_site_characteristics(['\\PAOA001\MATLAB\MET\' upper(SiteID) '_characteristics']);
catch
   sc = read_site_characteristics(['C:\BIOMET.NET\MATLAB\MET\' upper(SiteID) '_characteristics']);
end
z  = sc.Measurement_Height;
d  = sc.Stand_Zero_plane_Displacement;
zo = sc.Stand_Momentum_Roughness_Length;
zo_h = sc.Stand_Scalar_Roughness_Length;
%---------------------------------------------------------------------------------
%Stability
%---------------------------------------------------------------------------------
[L] = MO_L(ustar, T, H2Omix, covwT, covwH2O);

z_d_L = (z-d)./L;

%----------------------------------------------------------
%fill in missing z_d_L
%----------------------------------------------------------
ind_g = find(~isnan(z_d_L)); size(ind_g);
ind_bad  = find(isnan(z_d_L));
tmp_z = z_d_L;
z_d_L(ind_bad) = interp1(ind_g, z_d_L(ind_g), ind_bad);
clear ind_g ind_bad tmp_z; 
%not a complete solution 
%... big chunks of missing data should be "modelled" eg ddoy 842-848

[Psi_m, Psi_h] = Psi_cor(z_d_L,2);

%find neutral, unstable and stable half hours taking out NaN for purposes of polyfit
neut_ind = find(z_d_L < 0.02 & z_d_L > -0.02 & ~isnan(u) & ~isnan(ustar)); %change to limit near-neutral conditions
unstable_ind = find(z_d_L <= -0.02 & z_d_L >= -2 & ~isnan(u) & ~isnan(ustar));
stable_ind = find(z_d_L >= 0.02 & z_d_L <= 2 & ~isnan(u) & ~isnan(ustar));
ext_stable = find(z_d_L > 2 & ~isnan(u) & ~isnan(ustar));
ext_unstable = find(z_d_L < -2 & ~isnan(u) & ~isnan(ustar));


%find neutral, unstable and stable half hours leaving in all NaN 
neut_ind = find(z_d_L < 0.02 & z_d_L > -0.02 ); %change to limit near-neutral conditions
unstable_ind = find(z_d_L <= -0.02 & z_d_L >= -2 );
stable_ind = find(z_d_L >= 0.02 & z_d_L <= 2 );
ext_stable = find(z_d_L > 2 );
ext_unstable = find(z_d_L < -2 );
%this will allow the filled in z_d_L points to carry through in the ra calculations

%correct ustar with above relationships or not
%1 = correct using ln(ustar) functions, 2 = as is, 3 = drop out ustar < 0.2,...
%4 = correct using ln(ustar) functions when ustar < 0.2, otherwise, as is
%5 and 6 as 1 and 4 except with un-ln functions
flag = 2;  %used to user flag = 4!!

switch flag
case 1,
   %corrections for data from Oct 15, 1997 to May 31, 1999
   ustar(neut_ind) = exp(1.0730.*log(u(neut_ind))-1.7015);
   ustar(stable_ind) = exp(1.1116.*log(u(stable_ind))-2.0320);
   ustar(unstable_ind) = exp(1.1463.*log(u(unstable_ind))-1.7849);
   ustar(ext_stable) = exp(0.7062.*log(u(ext_stable))-2.9749);
   ustar(ext_unstable) = exp(1.0325.*log(u(ext_unstable))-2.4416);
case 2,
   ustar = ustar;
case 3,
   cut = find(ustar < 0.2);
   ustar = clean(ustar, 2, cut);
case 4,
   cut = find(ustar >= 0.2);
   tmpustar = ustar;
   %corrections for data from Oct 15, 1997 to May 31, 1999
   ustar(neut_ind) = exp(1.0730.*log(u(neut_ind))-1.7015);
   ustar(stable_ind) = exp(1.1116.*log(u(stable_ind))-2.0320);
   ustar(unstable_ind) = exp(1.1463.*log(u(unstable_ind))-1.7849);
   ustar(ext_stable) = exp(0.7062.*log(u(ext_stable))-2.9749);
   ustar(ext_unstable) = exp(1.0325.*log(u(ext_unstable))-2.4416);
   ustar(cut) = tmpustar(cut);
case 5
   ustar(neut_ind) = 0.2075.*u(neut_ind)-0.0139;
   ustar(stable_ind) = 0.1874.*u(stable_ind)-0.0687;
   ustar(unstable_ind) = 0.2088.*u(unstable_ind)-0.0276;
   ustar(ext_stable) = 0.04377.*u(ext_stable)+0.0160;
   ustar(ext_unstable) = 0.1139.*u(ext_unstable)-0.0073;
   ind = find(ustar < 0);ustar(ind) = 0;
case 6
   cut = find(ustar >= 0.2);
   tmpustar = ustar;
   %corrections for data from Oct 15, 1997 to May 31, 1999
   ustar(neut_ind) = 0.2075.*u(neut_ind)-0.0139;
   ustar(stable_ind) = 0.1874.*u(stable_ind)-0.0687;
   ustar(unstable_ind) = 0.2088.*u(unstable_ind)-0.0276;
   ustar(ext_stable) = 0.04377.*u(ext_stable)+0.0160;
   ustar(ext_unstable) = 0.1139.*u(ext_unstable)-0.0073;
   ustar(cut) = tmpustar(cut);
   ind = find(ustar < 0);ustar(ind) = 0;
end


%------------------------------------------------------------
% Aerodynmaic resistance for momentum
% 
%------------------------------------------------------------.

ra_m = u./ustar.^2; %this should be the best when the gill is working ok ... includes stability effects/corrections implied in ustar

ind = find(isnan(ra_m));
ra_m(ind) = ((log((z-d)./zo)).^2)./(u(ind).*k.^2); %no stability corrections, log-wind profile method

%------------------------------------------------------------
% Aerodynmaic resistance for heat and water vapour
% with excess resistance, rah = ram+rb
%------------------------------------------------------------
%Gash, JHC, Valente, F. & David, J.S. 1999. Estimates and measurement of evaporation from 
%  wet, sparse pine forest in Portugal.  Agric For Met. 94: 149-158.
ra_h = (u./ustar +2./k + (Psi_h-Psi_m)./k)./ustar;

%when sonic, flux data unavailable
ind = find(isnan(ra_h));
ra_h(ind) = (log((z-d)./zo)).*(log((z-d)./zo_h))./(u(ind).*k.^2);

