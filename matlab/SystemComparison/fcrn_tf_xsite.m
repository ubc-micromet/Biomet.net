function [t_cp,t_op] = fcrn_tf_xsite(n,u_mean)
% [t_cp,t_op] = fcrn_tf_xsite(n,u_mean)
%
% Calculate the theoretical values of the transfer functions following
% Moncrieff et al., 1997; Aubinet et al., 2000

%-------------------------------------------------------------------               
% Measurement freq. and geometry of the XSITE system
%-------------------------------------------------------------------               
n_s       = 20;    % (Hz) sample frequency 

t_r_sonic = 1/n_s;    % (s) response time of sonic (freq. response 20.83Hz from analog filter?)
t_r_irga  = 1/n_s;      % (s) response time of irga (freq. response 2Hz?)
pl        = 0.15;     % (m) sonic path length 
s_cp      = 0.2;      % (m) maximum sensor separator distance, 0.4 for open path, 0.3 for closed path 
s_op      = 0.3;      % (m) maximum sensor separator distance, 0.4 for open path, 0.3 for closed path 
r         = 0.002;    % (m) tube radius (1/4" Dekabon tubing)
x         = 4;        % (m) tube length
d_c       = 1.48e-5;  % (m^2/s molec. diffusion coefficient of CO2 in air at 10C: 1.39e-5*(T[K]/273.15)^1.75
nu        = 1.461e-5; % (m^2/s) kinematic viscosity of air

n      = ones(length(u_mean),1) * n;
u_mean = u_mean * ones(1,length(n));

%-------------------------------------------------------------------               
% normalize frequency
%-------------------------------------------------------------------               
f_p       = n.*pl./u_mean;       % normalised frequency
f_s_cp    = n.*s_cp./u_mean;        % normalised frequency
f_s_op    = n.*s_op./u_mean;        % normalised frequency

%-------------------------------------------------------------------               
% calculate transfer function after Moncrieff et al., 1997
%-------------------------------------------------------------------               

u_t       = (0.009/60)/(pi*r^2); % (m/s) velocity in tube (9l/min / (2*pi*r^2) = 0.009/60 m^3/s / (2*pi*r^2))
t_t       = x/u_t;               % time for air parcel to travel through tube
re        = u_t*2*r/nu;          % reynolds number
d_t       = 1/n_s;               % (s) time interval between samples

t_r       = 1.*ones(size(n));;                                                        % because no recursive digital running mean use in UBC system
t_d_sonic = 1./sqrt(1+(2.*pi.*n.*t_r_sonic).^2);                                      % sensor dynamic frequency response irga
t_d_irga  = 1./sqrt(1+(2.*pi.*n.*t_r_irga).^2);                                       % sensor dynamic frequency response sonic
t_m       = (1+(2.*pi.*n).^2.*t_r_sonic.*t_r_irga)./...
            sqrt((1+(2.*pi.*n.*t_r_sonic).^2).*(1+(2.*pi.*n.*t_r_irga).^2));          % sensor response mismatch
t_w       = 2./pi./f_p.*(1+exp(-2.*pi.*f_p)./2-3.*(1-exp(-2.*pi.*f_p))./(4.*pi.*f_p));% sonic anemometer path averaging
t_s_cp    = real(exp(-9.9.*f_s_cp.^1.5));                                                % sensor separation loss (Moncrieff)
t_s_op    = real(exp(-9.9.*f_s_op.^1.5));                                                % sensor separation loss (Moncrieff)
t_t_turb  = exp(-80.*(re.^(-1/8)).*r.*n.^2.*x./u_t.^2);                               % frequency attenuation, assuming turbulent flow (Aubinet et al.,2000)
t_cp      = t_r.*t_d_irga.*t_d_sonic.*t_m.*t_w.*t_s_cp.*t_t_turb;                        % total transfer function
t_op      = t_r.*t_d_irga.*t_d_sonic.*t_m.*t_w.*t_s_op.*t_t_turb;                        % total transfer function

return

