function[Fluxes] = calc_WPL_fluxes(configIn, num, miscVariables, stats);
%[Fluxes, stats_out] = calc_WPL_fluxes(configIn, num, miscVariables, stats); call this function within extra
% calculation routine (ini file)

%Ref: Webb, E.K., Pearman, G.I., and Leuning, R. 1980. Correction of flux measurements for 
%density effects due to heat and water vapour transfer.  Quart. J. R. Met. Soc. 106: 85-100.

% E. Humphreys May 25, 2003
% added kinematic terms Praveena , nov 2004

Ubc_biomet_constants;

SysName = configIn.System(num).FieldName; 

BarometricP = miscVariables.BarometricP;
Tair        = miscVariables.Tair + ZeroK; %in Kelvins

st   = getfield(stats,{length(stats)},SysName,'Three_Rotations');
H_density   = getfield(st,'Avg',{6});
C_density   = getfield(st,'Avg',{5});

%setup air characteristics for flux calculations
WaterMoleFraction = H_density./Mw.*1000.*R.*Tair./(1000.*BarometricP); %mmol H2O/mol moist air
dryair_density    = Ma.*(BarometricP.*1000./(R.*Tair) - H_density./Mw); %g/m3
moistair_density  = rho_air_wet(Tair-ZeroK,[],BarometricP,WaterMoleFraction); % density of moist air kg/m3
Cp_moist          = spe_heat(WaterMoleFraction); %specific heat of moist air J/kg/degC
L_v               = Latent_heat_vaporization(Tair-ZeroK)./1000; %J/g

mu  = Ma./Mw;
sig = H_density./dryair_density;

%kinematic fluxes (covariances)
st_dt = getfield(st,'AvgDtr'); %gCO2/m2/s
kinematic_Fc = getfield(st_dt,'Cov',{3,5}); %gCO2/m2/s
kinematic_Le = getfield(st_dt,'Cov',{3,6}); %gH2O/m2/s
kinematic_H  = getfield(st_dt,'Cov',{3,4}); %C/m/s

%Calculate fluxes using WPL procedure on halfhour covariances
Fluxes.Fc   = kinematic_Fc +  ...
   			  	mu.*(C_density./dryair_density).*kinematic_Le + ...
                 (1+mu.*sig).*(C_density./Tair).*kinematic_H; %g/m3/s
              
Fluxes.Fc   = Fluxes.Fc./Mc.*10^6; %umol/m2/s
            
Fluxes.LE_L = L_v.*(1+mu.*sig).*(kinematic_Le + (H_density./Tair).*kinematic_H); %W/m2
            
Fluxes.Hs   = Cp_moist.*moistair_density.*kinematic_H; %W/m2

Fluxes.kinematic_Fc = kinematic_Fc;
Fluxes.kinematic_Le = kinematic_Le;
Fluxes.kinematic_H  = kinematic_H;
