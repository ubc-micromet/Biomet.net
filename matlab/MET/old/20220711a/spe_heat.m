function specific_heat = spe_heat(h2o,P);
%specific_heat = spe_heat(h2o,P); THIS MATLAB FUNCTION CALCULATES THE SPECIFIC HEAT OF MOIST AIR  
% (J KG^-1 DEG C^-1)                                              
               
%
% Inputs: h2o, mmol/mol wet air = water vapour mixing ratio when only entry                                                                %
%        h2o = water vapour pressure in kPa when accompanied by P
%        P = barometric pressure in kPa       
% Ref: Stull, R.B., 1988.  Boundary Layer Meteorology, Kluwer Academic Publ.
%
% Revisions: E.Humphreys  Oct 1, 2001   
% Aug  1, 2003 - h2o converted to mass mixing ratio within the function
% Feb 20, 2004 - Bug fix - before h2o was divided twice
% Apr  7, 2005 - Bug fix - Input is mixing ratio, but Stull requires mole
% fraction and
% the Stull formula has the wrong multiplier

UBC_biomet_constants;

if nargin == 1;
    h2o = h2o./1000;
    h2o = h2o./(1+h2o) .* Mw./Ma;
else
    h2o = h2o./P .* Mw./Ma;
end

specific_heat = Cp.*(1+(Cpv - Cp)./Cp.*h2o);  %specific heat of moist air, J/g/K
specific_heat = specific_heat.*1000;

      
