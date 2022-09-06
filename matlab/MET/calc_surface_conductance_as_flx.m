function [gc,ga,gc_vel,gc_vel_d,gc_vel_pm] = calc_surface_conductance_as_flx(T, RH, ra, A, LE, Pb);
%calc_surface_conductance_as_flux Calculates surface conductance from 
% E = gt * (chi_v(EC) - chi_v(internal)) and gc comes out in mol m^{-2} s^{-1}
% where 1./gt = (1./gc+1./ga) 
%
%---------------------------------------------------------------------------------
%
% E = gc .* (chi_v_EC - chi_v(internal)) 
% H = ga .* cp (T - T_leaf)
%
% Inputs: T - air temperature, degC
%         RH - relatve humidity (%)
%         ra - aerodynamic resistance for heat and water vapour (s/m)
%         A - available energy (W/m2)
%         LE - latent heat flux (W/m2)
%         Pb - barometric pressure (kPa)
%         type - 'bowen' for bowen ratio method
%              - 'direct' for direct method
%
% kai* Sep 20, 2001
%
%Revisions     
%  
%----------------------------------------------------------------------------------------
ver = version;
if ver(1) == '5'
    warning off;
else
    warning off MATLAB:divideByZero;
end

UBC_biomet_constants;

rho = (Pb.*1000)./(R.*(T+ZeroK));
es_a = sat_vp(T);
e_a = RH./100 .* es_a;
chi_va = e_a ./ Pb;

%----------------------------------------------------------------------------------------
% Convert aerodyn. resistance to flux conductance
%----------------------------------------------------------------------------------------
ga = rho./ra;

%----------------------------------------------------------------------------------------
% Leaf temperature 
%----------------------------------------------------------------------------------------
cp = spe_heat(e_a,Pb); % specific heat of moist air in J kg^-1 K^-1
M  = (Ma .* (1-chi_va) + Mw .* chi_va)./1000; % Molecular mass of moist air kg/mol_v 
cp_mol = cp .* M; % specific heat of moist air in J mol_v^-1 K^-1
% Assume ga = gH
T_leaf = T + (A-LE) ./ (ga .* cp_mol);

%----------------------------------------------------------------------------------------
% Vapour saturation mixing ratio
%----------------------------------------------------------------------------------------
es_leaf = sat_vp(T_leaf);
s_cc       = ds_dt(T);           % kPa/degC
es_leaf_d = es_a + s_cc.*(T_leaf-T);

chi_leaf = es_leaf ./ Pb;
chi_leaf_d = es_leaf_d ./ Pb;

%----------------------------------------------------------------------------------------
% Conductance
%----------------------------------------------------------------------------------------
L = lambda(T) .* Mw./1000; % J/mol
E = LE ./ L; % mol m^-2 s^-1

gt = -E ./ (chi_va - chi_leaf);
gt_d = -E ./ (chi_va - chi_leaf_d);

gc = (1./gt - 1./ga).^(-1);
gc_d = (1./gt_d - 1./ga).^(-1);

gc_vel = gc ./ rho;
gc_vel_d = gc_d ./ rho;

%----------------------------------------------------------------------------------------
% Penman-Monteith
%----------------------------------------------------------------------------------------
gamma      = psy_cons(T,e_a,Pb); % kPa/degC

rc_pm   = (((s_cc.*A+rho.*M.*cp.*(es_a-e_a)./ra)./LE-s_cc)./gamma-1).*ra; %s/m
gc_vel_pm = 1./rc_pm;

if ver(1) == '5'
    warning on;
else
    warning off MATLAB:divideByZero;
end
return