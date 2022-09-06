function [phi,f,D_y,xs,ys,param] = footprint_kormann_and_meixner_bob(z_0,z_m,u,ust,sig_v,L,x_max,y_max,pix);
% [phi,f,D_y,coord,param] = footprint_kormann_and_meixner(z_0,z_m,u,sig_v,L,x_max,y_max,d);
%
% Implementation of the analytical footprint model described in Kormann and
% Meixner, 2001. Boundary-Layer Meteorol. 99: 207-224. 
% 
% Here fzero is used to find the exponents of the power laws for the wind
% and eddy diffusivity profiles (Eq. 39 & 40 in Kormann & Meixner)
%
% See footprint_kormann_and_meixner_verification for usage examples and
% reproduction of results in Kormann and Meixner
%

% Bob Chen, May 9, 2009

k = 0.4; % von-Karman const.

% arg_default('x_max',500); %cai: arg_default('x_max',1000); model domain for x direction
% arg_default('y_max',250);  %cai: arg_default('y_max',400);  model domain for y direction
% arg_default('pix',5);

% Bounds of integration for Eq. 42 to 46, defined on p.218
z_1 = 3*z_0;
z_2 = (1+k)*z_m;

% Implementation of root finding for Eq. 39 & 40
m = fzero(@fequ_m, 1,[],z_0,z_m,L,z_1,z_2);
n = fzero(@fequ_n, 1,[],z_0,z_m,L,z_1,z_2);

% Inversion of Eq. 31
%u_star = u * k / (log(z_m/z_0) + psi_m(z_m,L));
u_star=ust;  %using measured u_star to replce the calculated one by kai

% Eq (41)
U = u_star/k * (I_2(m,z_0/z_m,z_1,z_2,z_m) + J_1(m,z_1,z_2,z_m,L,'f_psi_m'))...
    / (I_1(2*m,z_1,z_2,z_m) .* z_m^m);

% Eq (41)
kappa = k*u_star * J_1(n,z_1,z_2,z_m,L,'f_z_phi_c')...
    /(I_1(2*n,z_1,z_2,z_m) .* z_m^(n-1));


% Definition of the grid over which the footprint phi is going to be
% calculated
xs = [1:pix:(x_max+1)];
ys = [-y_max:pix:y_max];
x_x = xs' * ones(1,length(ys));
y_y = ones(length(xs),1) * ys;
x(:,1) = x_x(:);
x(:,2) = y_y(:);

% Cross wind integrated footprint
% r is defined at the top of p.213, mu after Eq. 18
r = 2 + m -n; mu  = (1+m)./r;
% Eq. 19
xsi = U .* z_m.^r./(r.^2 .* kappa);
% Eq. 21
f = gamma(mu).^-1 .* xsi.^mu./(x(:,1).^(1+mu)) .* exp(-xsi./x(:,1));

% Cross wind diffusion
% Eq. 18
u_bar = gamma(mu)/gamma(1/r) * (r^2*kappa/U)^(m/r)*U*x(:,1).^(m/r);
% Eq. 9, definition of sig right after it
sig = sig_v.*x(:,1)./u_bar;
D_y = (sqrt(2*pi).*sig).^-1 .* exp(-x(:,2).^2./(2.*sig.^2));

% Eq. 8
phi = D_y .* f;

% Output in gridded form
phi = reshape(phi.*pix^2,length(xs),length(ys));
D_y = reshape(D_y.*pix,length(xs),length(ys));
f   = reshape(f.*pix,length(xs),length(ys));

% Assemble model parameter
param.m      = m;
param.n      = n;
param.U      = U;
param.kappa  = kappa;
param.u_star = u_star;
param.xsi    = xsi;

return

function z = psi_m(z,L);
zeta = (1 - 16 .* z./L).^(1/4);
if L>0
    z = 5*z./L;
else
    z = -2*log((1+zeta)/2) - log((1+zeta.^2)/2) + 2 * atan(zeta) - pi/2;
end

function z = phi_c(z,L);
if L>0
    z = 1 + 5*z./L;
else
    z = (1 - 16 .* z./L).^(-1/2);
end

function d = I_1(p,z_1,z_2,z_m)
% Eq (42)
z = linspace(z_1/z_m,z_2/z_m,1000);
dz = diff(z);
z = z(1:end-1) + dz./2;
d = sum( z.^p .*dz );

function d = I_2(p,z0,z_1,z_2,z_m)
% Eq (43)
z = linspace(z_1/z_m,z_2/z_m,1000);
dz = diff(z);
z = z(1:end-1) + dz./2;
d = sum( z.^p .* log(z./z0).*dz );

function d = I_3(p,z0,z_1,z_2,z_m)
% Eq (44)
z = linspace(z_1/z_m,z_2/z_m,1000);
dz = diff(z);
z = z(1:end-1) + dz./2;
d = sum( z.^p .* log(z) .* log(z./z0).*dz );

function d = J_1(p,z_1,z_2,z_m,L,f)
% Eq (45)
z = linspace(z_1/z_m,z_2/z_m,1000);
dz = diff(z);
z = z(1:end-1) + dz./2;
d = sum( z.^p .* feval(f,z.*z_m,z_m,L) .*dz );

function d = J_2(p,z_1,z_2,z_m,L,f)
% Eq (46)
z = linspace(z_1/z_m,z_2/z_m,1000);
dz = diff(z);
z = z(1:end-1) + dz./2;
d = sum( z.^p .* feval(f,z.*z_m,z_m,L) .* log(z) .*dz );

% Functions that are the arguments of J_1 and J_2 
function d = f_psi_m(z,z_m,L)
d = psi_m(z,L);

function d = f_z_phi_c(z,z_m,L)
d = z./(phi_c(z,L).*z_m);

function d = fequ_m(m,z_0,z_m,L,z_1,z_2)
% Eq (39)

A = I_1(2*m,z_1,z_2,z_m)   .* ( I_3(m,z_0/z_m,z_1,z_2,z_m) + J_2(m,z_1,z_2,z_m,L,'f_psi_m') );
B = I_2(2*m,1,z_1,z_2,z_m) .* ( I_2(m,z_0/z_m,z_1,z_2,z_m) + J_1(m,z_1,z_2,z_m,L,'f_psi_m') );

d = B - A;

function d = fequ_n(n,z_0,z_m,L,z_1,z_2)
% Eq (40)

A = I_1(2*n,z_1,z_2,z_m)   .* J_2(n,z_1,z_2,z_m,L,'f_z_phi_c');
B = I_2(2*n,1,z_1,z_2,z_m) .* J_1(n,z_1,z_2,z_m,L,'f_z_phi_c');

d = B - A;