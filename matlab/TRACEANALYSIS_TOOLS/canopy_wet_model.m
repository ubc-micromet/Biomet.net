function [bal_wet, bal_dry, bal_partwet] = canopy_wet_model(E, P, S, p, siteID);
%canopy_wet_model.m Determine when the canopy is saturated, partly wet and dry using
% a Rutter-type water balance model
%
% Inputs: E - evaporation in mm for a hhour
%         P - precipitation in mm for a hhour
%         S - canopy storage capacity (mm)
%         p - free throughfall coefficient 
%
% E. Humphreys Dec 4, 2001

%-----------------------------------------------
%Modelled water balance
if ~exist('siteID') | isempty(siteID);
    siteID = 'CR';
end

if ~exist('S') | isempty(S);
    switch upper(siteID)
    case 'CR';    S = 1.5; %canopy storage capacity (mm) - for CR determined by canopy_capacity.m
    end
end

if ~exist('p') | isempty(p);
    switch upper(siteID)
    case 'CR';  p = 0.28; %free throughfall coefficient - determined by canopy_capacity.m
    end
end

%depth of water on the canopy (C)
C = NaN.*ones(length(E),1);

%if E is negative, assume its a flux msmt problem for now so that canopy storage
%doesn't go up at night when small negative E's can arise
E_tmp = zeros(size(E));
ind = find(E >= 0);
E_tmp(ind) = E(ind); 


C(1) = 0;
for i = 2:length(E-1);
   %determine drainage...
   if C(i-1)>= S;
      D(i) = C(i-1)-S;
   else
      D(i) = 0;
   end
   tmp = P(i)-p.*P(i)-D(i)-E_tmp(i)+C(i-1); 
   
   if tmp <= 0;
      C(i) = 0;
   else if isnan(tmp)
      C(i) = C(i-1);   %just fill in with last hhour values
   else
      C(i) = tmp;
   end
end
end

%modelled dry periods
bal_dry = find(C == 0);
%modelled wet periods (saturated ie storage water > capacity)
bal_wet = find(C >= S);
%modelled partly wet periods (less than saturated, more than dry)
bal_partwet = find(C < S & C >0);
