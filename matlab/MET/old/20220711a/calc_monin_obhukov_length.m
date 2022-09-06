function Lstar = calc_monin_obhukov_length(ustar,T_a,s_v,p_bar,H,LE)
% Lstar = monin_obhukov_length(ustar,Ta,sv,pbar,H,LE)

UBC_biomet_constants_SI;
lambda_v = lambda(T_a); % J kg^-1 K^-1 ; Needs degC as input 

% Conversion to base units:
s_v   = s_v./1e3;
p_bar = p_bar .* 1e3;
T_a   = T_a + To;
chi_v = s_v./(1+s_v);

T_v = T_a .* (1+(1-Epsilon) .* chi_v); % Monteith and Unsworth (1990), p. 12

rho   = p_bar./(R.*T_a); % mol m^-3
rho_v = rho .* chi_v;   % mol m^-3
rho_a = rho - rho_v;    % mol m^-3
rho_cp = Cp .* Ma .* rho_a + Cpv .* Mv .* rho_v;

cov_w_T_a = H ./ rho_cp;
cov_w_s_v = LE ./ (lambda_v .* Ma .* rho_a );
% See kai*'s Notebook 5, Oct 5, 2004 for a derivation of this:
cov_w_T_v = cov_w_T_a .* (1 + (1-Epsilon).*s_v) + (1-Epsilon) .* cov_w_s_v .* T_a;

Lstar = - T_v .* ustar.^3 ./ ( k .* g .* cov_w_T_v);

return