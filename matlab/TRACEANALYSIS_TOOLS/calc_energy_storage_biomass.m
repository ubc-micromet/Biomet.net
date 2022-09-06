function energy_storage_biomass = calc_energy_storage_biomass(tv,...
   air_temperature_canopy,bole_temperature,fc,radiation_shortwave_downwelling,site,water_content_wood)

% Second level data processing function
%
% energy_storage_biomass = calc_energy_storage_biomass(tv,)
%
% This program calculates heat storage in the biomass at the PAOA site as
% energy_storage_biomass = energy_storage_leaves + energy_storage_boles + energy_storage_photosynthesis
%

% (C) Kai Morgenstern			    	File created:  14.08.00
%							    		Last modified: 14.08.00
%
% Reference: P.D. Blanken (1997) Evaporation within and above
%					a boreal aspen forest. PhD thesis(3.2.4), University of
%					British Columbia, Vancouver, Canada.

% Revision: Oct 16, 2003 - added in OY site (E. Humphreys).

% Revision: Aug 10 2009 - added in MPB sites (M.Brown).
% Revision April 30 2012 - added in MPB-09 site (A.Mathys)

switch upper(site)
case 'BS'
    lai = 6.3;      % Leaf area index (m^2_leaf m^-2_ground)
    WL  = 0.6;      % Water content of leafs (fraction on wet mass base)
    SWL = 0.2;      % Specific leaf weight (kg m^-2_leaf)
    WS  = 0.4;      % Water content of stems (fraction on wet mass base)
    SWS = 8.6;      % Specific stem weight (kg m^-2_ground)
case 'MPB1'
    lai = 1.4;      % Leaf area index (m^2_leaf m^-2_ground)
    WL  = 0.6;      % Water content of leafs (fraction on wet mass base)
    SWL = 0.2;      % Specific leaf weight (kg m^-2_leaf)
    WS  = 0.4;      % Water content of stems (fraction on wet mass base)
    SWS = 6.0;      % Specific stem weight (kg m^-2_ground)
case 'MPB2'
    lai = 0.9;      % Leaf area index (m^2_leaf m^-2_ground)
    WL  = 0.6;      % Water content of leafs (fraction on wet mass base)
    SWL = 0.2;      % Specific leaf weight (kg m^-2_leaf)
    WS  = 0.4;      % Water content of stems (fraction on wet mass base)
    SWS = 6.0;      % Specific stem weight (kg m^-2_ground)
case 'MPB3'
    lai = 1.3;      % Leaf area index (m^2_leaf m^-2_ground)
    WL  = 0.6;      % Water content of leafs (fraction on wet mass base)
    SWL = 0.2;      % Specific leaf weight (kg m^-2_leaf)
    WS  = 0.4;      % Water content of stems (fraction on wet mass base)
    SWS = 6.0;      % Specific stem weight (kg m^-2_ground)
case 'CR' % made this its own entry but calc_energy_storage_biomass_cr is used currently in cleaning
    lai = 8.4;
    WL  = 0.6;
    SWL = 0.2;
    WS  = 0.4;      
    SWS = 6.0;
case 'YF' % gave YF its own entry, lai is peak in 2004, everything else is from CR
    lai = 4.7;
    WL  = 0.6;
    SWL = 0.2;
    WS  = 0.4;      
    SWS = 6.0;
case 'JP'
    lai = 6.3;
    WL  = 0.6;
    SWL = 0.2;
    WS  = 0.4;      
    SWS = 6.0;
case 'PA'
    lai = 3.5;
    WL  = 0.7;      
    SWL = 0.04; 
    WS  = 0.4;      
    SWS = 18.4;
 case 'OY'
    lai = 0;  %assume energy storage in leaf biomass negligible
    WL  = 0;      
    SWL = 0; 
    WS  = 0;  %assume water content of wood negligible    
    SWS = 540.*0.0331; %density of Df (12perc h2o) kg/m3 * 0.0331 m3 wood/m2 ground (from CFS coarse woody debris survey) = 17.9 kg/m2 
end

if exist('water_content_wood') & ~isempty(water_content_wood)
    WS = water_content_wood;
end

c_w = 4.18e3; % Specific heat capacity of water (J kg^-1 K^-1)
c_g = 1.26e3; % Specific heat capacity of glucose (J kg^-1 K^-1), Thesis P. Blanken, p. 66
c_d = 1.26e3; % Specific heat capacity of dry wood (J kg^-1 K^-1), Thesis P. Blanken, p. 65
c_l = lai * SWL * (c_w * (WL/(1-WL)) + c_g ); % Heat capacity of the leaf per ground area(J m^-2 K^-1)
%   = lai * SWL * (c_w * W + c_g * (1-W)) / (1-W) = Thesis P. Blanken, p. 66
c_s =       SWS * (c_w * (WS/(1-WS)) + c_d );

%**************************************************************
% calculate the rate of photosynthesis energy storage
%**************************************************************

Jp 			= NaN*ones(length(tv),1);
ind 			= find(radiation_shortwave_downwelling>0 & fc<0);
Jp(ind)		= -0.469*fc(ind);
ind 			= find(radiation_shortwave_downwelling<=0);
Jp(ind)		= 0;

%**************************************************************
% calculate the rate of leaf heat storage
%**************************************************************

T_leaf 		= air_temperature_canopy;

ind 		= 2:length(tv)-1;
dT_leaf 	= T_leaf(ind+1,:)-T_leaf(ind-1,:);
dT_leaf		= [NaN;dT_leaf;NaN];

Jl			= c_l * dT_leaf ./ 3600;

%*****************************************************************
% calculate the rate of tree heat storage 
%*****************************************************************

T_stem 		= bole_temperature;

ind 		= 2:length(tv)-1;
dT_stem 	= T_stem(ind+1,:)-T_stem(ind-1,:);
dT_stem		= [NaN;dT_stem;NaN];

Js			= c_s * dT_stem ./ 3600;

%-----------------------------------------------------

% To avoid NaNs through one missing term, set NaNs to zero
flag_Jp = isfinite(Jp);
flag_Jl = isfinite(Jl);
flag_Js = isfinite(Js);
Jp(find(flag_Jp == 0)) = 0;
Jl(find(flag_Jl == 0)) = 0;
Js(find(flag_Js == 0)) = 0;

flag    = flag_Jp + flag_Jl + flag_Js;
ind_allnan = find(flag == 0);

energy_storage_biomass = Jp + Jl + Js;
energy_storage_biomass(ind_allnan) = NaN;
