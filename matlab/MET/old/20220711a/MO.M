function [MO_39,MO_4] = MO(time);

%   Revisions:
%       Jun 12, 1997 (Zoran Nesic)
%               Introduced global variables for the data paths
%

% Set the global path for the data base
global DATA_PATH_1994_PA  DATA_PATH_PETER_2 DATA_PATH_PETER_3

% Physical constants
g = 9.81;
k = 0.41;

% aspen constants
aspen_ht = 21.5;
d_39 = 2/3 * aspen_ht;
z0_39 = 0.1 * aspen_ht;
z_39 = 39;

% hazelnut constants
hazel_ht = 2;
d_4 = 2/3 * hazel_ht;
z0_4= 0.1 * hazel_ht;
z_4 = 4;

ustar_39 = dbload(DATA_PATH_1994_PA,'ffaes',6,9); 
ustar_39 = cle_data(ustar_39,2,2);
ustar_39 = cle_data(ustar_39,3,0);

ustar_4 = dbload(DATA_PATH_1994_PA,'hfubc',87,88); 
ustar_4 = cle_data(ustar_4,2,0.5);
ustar_4 = cle_data(ustar_4,3,0);

% ustar at 39 m is incorrectly ahead 1 day (error) - shift back 1 day
ustar_39 = ustar_39';
ind = 49:length(ustar_39);
ustar_39 = [ustar_39(ind)  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
ustar_39 = ustar_39';
clear ind;

[e_39,T_39] = temp_39(time);

T_4 = dbload(DATA_PATH_1994_PA,'mfubc',7,15);
T_4 = cle_data(T_4,3,-50);
RH_4 = dbload(DATA_PATH_1994_PA,'mfubc',8,15);
RH_4 = cle_data(RH_4,3,0);
RH_4 = RH_4/100;
e_4 = sat_vp(T_4).*RH_4;

P = dbload(DATA_PATH_1994_PA,'meaes',12,53');
P = P/10;

Rn_39 = dbload(DATA_PATH_1994_PA,'meaes',16,53);
Rn_39 = cle_data(Rn_39,3,-200);
Rn_39 = Rn_39*0.970363;

eval ( ['load '  DATA_PATH_PETER_3]);
Rn_4 = undrad(:,2);
clear undrad.asc;

eval ( ['load '  DATA_PATH_PETER_2]);
A_39 = hh_ebc(:,2); 
le_39 = hh_ebc(:,3); 
H_39 = hh_ebc(:,4);
A_4 = hh_ebc(:,6); 
le_4 = hh_ebc(:,7); 
H_4 = hh_ebc(:,8);
clear hh_ebc.asc;

beta_39 = H_39./le_39;
exp_le_39 = A_39./(1 + beta_39); 
exp_H_39 = beta_39.*exp_le_39;

ind = find(Rn_39 < 0);
exp_H_39(ind) = H_39(ind);

ind = find(beta_39 > -1.5 & beta_39 < -0.5);
exp_H_39(ind) = H_39(ind);
clear ind;

beta_4 = H_4./le_4;
exp_le_4 = A_4./(1 + beta_4); 
exp_H_4 = beta_4.*exp_le_4;

ind = find(Rn_4 < 0);
exp_H_4(ind) = H_4(ind);

ind = find(beta_4 > -1.5 & beta_4 < -0.5);
exp_H_4(ind) = H_4(ind);
clear ind;

% M-O stability length
L_39 = -1*z_39* (rho_air(T_39).*spe_heat(e_39,P).*(T_39+273.15).*(ustar_39).^3)./(k*z_39*g.*exp_H_39);
L_4 = -1*z_4* (rho_air(T_4).*spe_heat(e_4,P).*(T_4+273.15).*(ustar_4).^3)./(k*z_4*g.*exp_H_4);

% M-O Stability Parameter
MO_39 = (z_39-d_39)./L_39;
MO_4 = (z_4-d_4)./L_4;