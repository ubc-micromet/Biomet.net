function[Psi_m, Psi_h] = Psi_cor(z_d_L,flag);
%Calculates the diabatic correction factors for stable and unstable conditions ...

% Psi_m (momentum), Psi_h (heat/scalar)integrated from the basic 
% universal similarity functions (see Phi_cor.m)
% Generally used on scaling parameters, aerodynamic resistance by adding to adjust for stability
%
% flag 1 = Arya(1988) pg 167 note: switched sign to make psi_m, psi_h positive in unstable
%       range, negative in stable range
% flag 2 = Campbell & Norman (1998) pg 97
%
% E. Humphreys 1999
% Revisions: Feb 2, 2002 - separated Psi from Phi corrections
%-----------------------------------------------------

l = length(z_d_L);
Psi_h = NaN.*ones(l,1);
Psi_m = NaN.*ones(l,1);

switch flag
case 1;
    ind = find(z_d_L >= 0);
    Psi_m(ind) = -(-5.*z_d_L(ind));
    Psi_h(ind) = -(-5.*z_d_L(ind));
    
    ind = find(z_d_L < 0);
    x = (1-15.*z_d_L(ind)).^0.25;
    tmp = ((1+x.^2)./2).*(((1+x)./2).^2); tmp = log(tmp);
    Psi_m(ind) = -(tmp - 2.*atan(x) +pi./2);
    Psi_h(ind) = -(2.*log((1+x.^2)./2));
   
case 2;
    ind = find(z_d_L >= 0);
    Psi_h(ind) = 6.*log(1+z_d_L(ind));   
    Psi_m(ind) = Psi_h(ind);
    ind = find(z_d_L < 0);
    Psi_h(ind) = -2.*log((1+(1-16.*z_d_L(ind)).^0.5)./2);
    Psi_m(ind) = 0.6.*Psi_h(ind);
end

