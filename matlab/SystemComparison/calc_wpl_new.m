function[Fluxes] = calc_WPL_new(configIn, num, miscVariables, stats, chan_num);
%[Fluxes, stats_out] = calc_WPL_fluxes(configIn, num, miscVariables, stats); call this function within extra
% calculation routine (ini file)

%Ref: Webb, E.K., Pearman, G.I., and Leuning, R. 1980. Correction of flux measurements for 
%density effects due to heat and water vapour transfer.  Quart. J. R. Met. Soc. 106: 85-100.

arg_default('chan_num',[5 6])

Ubc_biomet_constants;

SysName = configIn.System(num).FieldName; 

p  = miscVariables.BarometricP.*1000;
Ta = miscVariables.Tair + ZeroK; %in Kelvins

st   = getfield(stats,{length(stats)},SysName,'Three_Rotations');
rho_v   = getfield(st,'Avg',{chan_num(2)})./1000; % mol / m^3
rho_C   = getfield(st,'Avg',{chan_num(1)})./1000; % mol / m^3

% air characteristics in molar units
rho   = p./(R.*Ta);  % mol / m3
chi_v = rho_v./rho;  % mol H2O / mol moist air
rho_a = rho - rho_v; % mol/m3

L_v      = Latent_heat_vaporization(Ta-ZeroK)./1000; %J/g

mu  = Ma./Mw;
sig = rho_v./rho_a;

%kinematic fluxes (covariances)
st_dt = getfield(st,'AvgDtr');
kinematic_Fc = getfield(st_dt,'Cov',{3,chan_num(1)}); % mmol CO2/m2/s
kinematic_Le = getfield(st_dt,'Cov',{3,chan_num(2)}); % mmol H2O/m2/s
kinematic_H  = getfield(st_dt,'Cov',{3,4}); %degC/m/s

% Calculate fluxes using WPL procedure on halfhour covariances
% all terms here are in units of mass
Fluxes.Fc   = kinematic_Fc .*1000 +  ...
   			  	(rho_C./rho_a).*kinematic_Le .* 1000 + ...
                 (1+sig).*(rho_C./Ta).*kinematic_H; %mumol/m3/s
                         
Fluxes.LE_L = L_v*Mw.*(1+sig).*(kinematic_Le./1000 + (rho_v./Ta).*kinematic_H); %W/m2
            
Fluxes.Hs   = (rho_a.* Ma .* Cp .* (1-chi_v)+ rho_v.* Mw .* Cpv .*chi_v) .* kinematic_H; %W/m2

Fluxes.kinematic_Fc = kinematic_Fc;
Fluxes.kinematic_Le = kinematic_Le;
Fluxes.kinematic_H  = kinematic_H;
