function[Phi_m, Phi_h] = Phi_cor(z_d_L,flag);
%Calculates basic universal similarity functions for momentum (Phi_m) and heat (Phi_h)

% for stable and unstable conditions basic universal similarity functions 
% relating constant fluxes to the mean gradients in the surface layer; 
% for use in 'correcting' or 'adjusting' dimensionless variables such as wind shear, u/u*, etc)
% (by multiplication or division) 
%
% flag 1 = Arya(1988) pg 162 and Campbell & Norman (1998) pg 97
% flag 2 = Arya(1988) pg 162 only
%
% E.Humphreys 1999
% Revisions: Feb 2, 2002 - separated Psi from Phi corrections
%-----------------------------------------------------

l = length(z_d_L);
Phi_h = NaN.*ones(l,1);
Phi_m = NaN.*ones(l,1);

switch flag
case 1;
   %Phi (to apply to flux-like stuff by multiplying or dividing)
   ind = find(z_d_L >= 0);
   Phi_h(ind) = (1+4.7.*z_d_L(ind));%Arya p162
   Phi_m(ind) = (1+4.7.*z_d_L(ind));
   ind = find(z_d_L < 0);
   Phi_h(ind) = (1+16.*abs(z_d_L(ind))).^-1/2; %Campbell & Norman p97
   Phi_m(ind) = (1+16.*abs(z_d_L(ind))).^-1/4;
case 2;
   ind = find(z_d_L >= 0);
   Phi_h(ind) = 0.74+4.7.*z_d_L(ind); %Businger et al (1971) in Arya p162
   Phi_m(ind) = 1+4.7.*z_d_L(ind);
   ind = find(z_d_L < 0);
   Phi_h(ind) = 0.74.*(1 - 9.*z_d_L(ind)).^-1/2; 
   Phi_m(ind) = (1-15.*z_d_L(ind)).^-1/4;
end

