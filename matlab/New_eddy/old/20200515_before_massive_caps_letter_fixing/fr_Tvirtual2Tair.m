function[Tair] = fr_Tvirtual2Tair(Tvirtual,Hmix);

% In:  Hmix - h2o mixing ratio (mmol/mol dry air)
%      Tvirtual - virtual temperature (K)

% E. Humphreys   Sept 18, 2001
%
% Ref.  Stull (1995) Meteorology Today for Scientists and Engineers p.8


Tair  = Tvirtual./(1+0.61.*Hmix./1000); 

