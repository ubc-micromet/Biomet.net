% UBC_biomet_constants.m

% References: Stull, R.B. (1995)  Meteorology Today for Scientists and Engineers, 
%                 West Publ. Co.
%             Stull, R.B. (1988)  Boundary Layer Meteorology, Kluwer Academic Publ.
%             Wallace and Hobbs(1977) Atmospheric Science - An Introductory Survey,
%                 Academic Press Inc.

ZeroK = 273.15;                         % zero deg. C in deg K.
R     = 8.31451;                        % J/mol/K universal gas constant
Rv    = 461.5;                          % J/kg/K gas constant for water vapour Stull(1995)
Rd    = 287.05;                         % J/kg/K gas constant for dry air Stull(1995)
Cp    = 1.00467;                        % J/g/K specific heat for dry air at constant pressure Stull(1995)
Cpv   = 1.875;                          % J/g/K specific heat for water vapour at constant pressure Stull(1995)
Mc    = 44.01;                          % g/mol molecular weight co2 Stull(1995)
Ma    = 28.96;                          % g/mol molecular weight for mean condition of air, Stull(1995)
Mw    = 18.02;                          % g/mol molecular weight for water, Stull(1995)
Epsilon = 0.622;                        % ratio, Rd/Rv, Stull(1988)
k     = 0.4;                            % von Karmaan's constant
g     = 9.8;                            % gravity m/s2
